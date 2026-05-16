import Combine
import SwiftUI

struct ScoringEvent: Identifiable {
    let id = UUID()
    let player: CellMark
    let title: String
    let subtitle: String
    let totalPoints: Int
    let lineCount: Int
    let cells: Set<Int>
    let lineSegments: [[Int]]
}

@MainActor
final class GameSessionStore: ObservableObject {
    private var currentViewModel: GameViewModel?

    var activeViewModel: GameViewModel {
        currentViewModel ?? viewModel(for: .vsAI)
    }

    func viewModel(for mode: GameMode) -> GameViewModel {
        if let currentViewModel, currentViewModel.mode == mode {
            return currentViewModel
        }

        let viewModel = GameViewModel(mode: mode)
        currentViewModel = viewModel
        return viewModel
    }
}

@MainActor
final class GameViewModel: ObservableObject {
    @Published var board: [[CellMark]]
    @Published var currentPlayer: CellMark
    @Published var energy: Int
    @Published var playerScore: Int
    @Published var opponentScore: Int
    @Published var totalBonus: Int
    @Published var frozenCells: Set<Int>
    @Published var frozenTurnsRemaining: Int
    @Published var isGameOver: Bool
    @Published var turnLabel: String
    @Published var isAITurn: Bool
    @Published var resultWon: Bool
    @Published var resultScore: Int
    @Published var scoringEvent: ScoringEvent?
    @Published var scoringHighlightCells: Set<Int>
    @Published var scoringLineSegments: [[Int]]
    @Published var scoringLinePlayer: CellMark?
    @Published var scoringPulseID: Int
    @Published var energyPulseID: Int

    let mode: GameMode

    static func rowTarget(_ row: Int) -> Int {
        Target.rowOffset + row
    }

    static func columnTarget(_ column: Int) -> Int {
        Target.columnOffset + column
    }

    static func diagonalTarget(_ index: Int) -> Int {
        Target.diagonalOffset + index
    }

    private enum Constants {
        static let rows = 5
        static let columns = 4
        static let maxEnergy = 10
        static let winningScore = 30
        static let freezeDuration = 2
        static let comboBonus = 5
        static let aiDelay: UInt64 = 600_000_000
        static let positionScores = [
            1, 2, 2, 1,
            2, 4, 4, 2,
            3, 5, 5, 3,
            2, 4, 4, 2,
            1, 2, 2, 1
        ]
    }

    private enum Target {
        static let rowOffset = 1_000
        static let columnOffset = 2_000
        static let diagonalOffset = 3_000
    }

    private enum Direction: Hashable {
        case horizontal
        case vertical
        case diagonalDown
        case diagonalUp
    }

    private enum Skill: String {
        case lineBreak = "Line Break"
        case colorChange = "Color Change"
        case areaFreeze = "Area Freeze"
        case reset = "Reset"

        var cost: Int {
            switch self {
            case .lineBreak:
                3
            case .colorChange:
                4
            case .areaFreeze:
                5
            case .reset:
                6
            }
        }
    }

    private struct LineIdentity: Hashable {
        let owner: String
        let direction: Direction
        let cells: [Int]
    }

    private struct BoardLine {
        let owner: CellMark
        let direction: Direction
        let cells: [Int]

        var identity: LineIdentity {
            LineIdentity(owner: owner.scoreKey, direction: direction, cells: cells)
        }

        var points: Int {
            switch cells.count {
            case 3:
                3
            case 4:
                7
            default:
                12
            }
        }
    }

    private var scoredLines: Set<LineIdentity> = []
    private var freezeCounters: [Int: Int] = [:]
    private var lastPlayer: CellMark?
    private var hasRecordedResult = false
    private var aiTask: Task<Void, Never>?
    private var feedbackTask: Task<Void, Never>?

    init(mode: GameMode) {
        self.mode = mode
        board = Self.emptyBoard()
        currentPlayer = .x
        energy = 0
        playerScore = 0
        opponentScore = 0
        totalBonus = 0
        frozenCells = []
        frozenTurnsRemaining = 0
        isGameOver = false
        turnLabel = "あなたのターン"
        isAITurn = false
        resultWon = false
        resultScore = 0
        scoringEvent = nil
        scoringHighlightCells = []
        scoringLineSegments = []
        scoringLinePlayer = nil
        scoringPulseID = 0
        energyPulseID = 0
    }

    func placeMark(at index: Int) {
        guard !isGameOver else { return }
        guard !(mode == .vsAI && isAITurn) else { return }
        guard isLegalMove(index) else { return }

        performMove(at: index)
    }

    func activateSkill(_ skillName: String, targetIndex: Int) {
        guard !isGameOver else { return }
        guard !(mode == .vsAI && isAITurn) else { return }
        guard let skill = Skill(rawValue: skillName) else { return }
        guard energy >= skill.cost else { return }

        let didApply = apply(skill, targetIndex: targetIndex)
        guard didApply else { return }

        energy -= skill.cost
        refreshScoredLines()
        updateFrozenState()
        checkWinCondition()
    }

    func activateSkill(_ skillName: String, boardIndex: Int) {
        guard let skill = Skill(rawValue: skillName) else { return }
        let targetIndex = defaultTargetIndex(for: skill, boardIndex: boardIndex)
        activateSkill(skillName, targetIndex: targetIndex)
    }

    func canActivateSkill(_ skillName: String) -> Bool {
        guard !isGameOver else { return false }
        guard !(mode == .vsAI && isAITurn) else { return false }
        guard let skill = Skill(rawValue: skillName) else { return false }
        return energy >= skill.cost
    }

    func resetGame() {
        aiTask?.cancel()
        aiTask = nil
        feedbackTask?.cancel()
        feedbackTask = nil
        board = Self.emptyBoard()
        currentPlayer = .x
        energy = 0
        playerScore = 0
        opponentScore = 0
        totalBonus = 0
        frozenCells = []
        frozenTurnsRemaining = 0
        isGameOver = false
        turnLabel = "あなたのターン"
        isAITurn = false
        resultWon = false
        resultScore = 0
        scoredLines = []
        freezeCounters = [:]
        lastPlayer = nil
        hasRecordedResult = false
        scoringEvent = nil
        scoringHighlightCells = []
        scoringLineSegments = []
        scoringLinePlayer = nil
        scoringPulseID = 0
        energyPulseID = 0
    }

    private static func emptyBoard() -> [[CellMark]] {
        Array(
            repeating: Array(repeating: CellMark.empty, count: Constants.columns),
            count: Constants.rows
        )
    }

    private func performMove(at index: Int) {
        setMark(currentPlayer, at: index)
        lastPlayer = currentPlayer

        let scoring = checkLines()
        addScore(scoring.points + scoring.bonus, to: currentPlayer)
        totalBonus += scoring.bonus
        energy = min(Constants.maxEnergy, energy + 1)
        energyPulseID += 1

        if scoring.points + scoring.bonus > 0 {
            publishScoringEvent(
                player: currentPlayer,
                points: scoring.points,
                bonus: scoring.bonus,
                lines: scoring.lines
            )
        }

        advanceFrozenTurns()
        refreshScoredLines()
        checkWinCondition()

        guard !isGameOver else { return }
        switchTurn()
    }

    private func addScore(_ points: Int, to player: CellMark) {
        guard points > 0 else { return }

        if player == .x {
            playerScore += points
        } else {
            opponentScore += points
        }
    }

    private func switchTurn() {
        currentPlayer = currentPlayer.opponent

        if mode == .vsAI && currentPlayer == .o {
            isAITurn = true
            turnLabel = "AI思考中..."
            aiMove()
        } else {
            isAITurn = false
            updateTurnLabel()
        }
    }

    private func updateTurnLabel() {
        switch mode {
        case .vsAI:
            turnLabel = currentPlayer == .x ? "あなたのターン" : "AI思考中..."
        case .twoPlayer:
            turnLabel = currentPlayer == .x ? "P1のターン" : "P2のターン"
        }
    }

    private func checkLines() -> (points: Int, bonus: Int, lines: [BoardLine]) {
        let newLines = findLines(for: currentPlayer, on: board)
            .filter { !scoredLines.contains($0.identity) }

        guard !newLines.isEmpty else { return (0, 0, []) }

        newLines.forEach { scoredLines.insert($0.identity) }
        let points = newLines.reduce(0) { $0 + $1.points }
        let bonus = max(0, newLines.count - 1) * Constants.comboBonus
        return (points, bonus, newLines)
    }

    private func publishScoringEvent(
        player: CellMark,
        points: Int,
        bonus: Int,
        lines: [BoardLine]
    ) {
        let lineCells = Set(lines.flatMap(\.cells))
        let longestLine = lines.map(\.cells.count).max() ?? 0
        let total = points + bonus
        let title: String

        if lines.count >= 2 {
            title = "ネクサス連鎖 x\(lines.count)"
        } else if longestLine >= 5 {
            title = "フルNEXUS"
        } else if longestLine == 4 {
            title = "4ライン完成"
        } else {
            title = "ライン完成"
        }

        let subtitle = bonus > 0
            ? "+\(points) / ボーナス +\(bonus)"
            : "+\(points)"

        scoringHighlightCells = lineCells
        scoringLineSegments = lines.map(\.cells)
        scoringLinePlayer = player
        scoringPulseID += 1
        scoringEvent = ScoringEvent(
            player: player,
            title: title,
            subtitle: subtitle,
            totalPoints: total,
            lineCount: lines.count,
            cells: lineCells,
            lineSegments: scoringLineSegments
        )

        feedbackTask?.cancel()
        feedbackTask = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 3_200_000_000)
            self?.scoringEvent = nil
            self?.scoringHighlightCells = []
            self?.scoringLineSegments = []
            self?.scoringLinePlayer = nil
        }
    }

    private func aiMove() {
        aiTask?.cancel()
        aiTask = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: Constants.aiDelay)
            self?.finishAIMove()
        }
    }

    private func finishAIMove() {
        guard mode == .vsAI else { return }
        guard currentPlayer == .o, isAITurn, !isGameOver else { return }

        if let winningMove = bestScoringMove(for: .o) {
            performMove(at: winningMove)
            return
        }

        if let blockingMove = bestScoringMove(for: .x) {
            performMove(at: blockingMove)
            return
        }

        if let buildingMove = bestBuildingMove(for: .o) {
            performMove(at: buildingMove)
            return
        }

        _ = performAISkillIfHelpful()

        guard let fallbackMove = fallbackMove() else {
            advanceFrozenTurns()
            refreshScoredLines()
            switchTurn()
            return
        }

        performMove(at: fallbackMove)
    }

    private func checkWinCondition() {
        if playerScore >= Constants.winningScore {
            finishGame(winner: .x)
            return
        }

        if opponentScore >= Constants.winningScore {
            finishGame(winner: .o)
            return
        }

        guard isBoardFull else { return }

        if playerScore > opponentScore {
            finishGame(winner: .x)
        } else if opponentScore > playerScore {
            finishGame(winner: .o)
        } else {
            finishGame(winner: lastPlayer == .x ? .o : .x)
        }
    }

    private func finishGame(winner: CellMark) {
        guard !hasRecordedResult else { return }

        let won = winner == .x
        let winningScore = winner == .x ? playerScore : opponentScore
        resultWon = won
        resultScore = winningScore
        isAITurn = false
        isGameOver = true
        turnLabel = won ? "勝利" : "敗北"
        hasRecordedResult = true

        StatsViewModel().recordResult(won: won, score: winningScore, mode: mode)
    }

    private func apply(_ skill: Skill, targetIndex: Int) -> Bool {
        switch skill {
        case .lineBreak:
            return applyLineBreak(targetIndex: targetIndex)
        case .colorChange:
            return applyColorChange(targetIndex: targetIndex)
        case .areaFreeze:
            return applyAreaFreeze(targetIndex: targetIndex)
        case .reset:
            return applyReset(targetIndex: targetIndex)
        }
    }

    private func defaultTargetIndex(for skill: Skill, boardIndex: Int) -> Int {
        let position = rowAndColumn(for: boardIndex)

        switch skill {
        case .lineBreak:
            return Self.rowTarget(position.row)
        case .colorChange:
            return boardIndex
        case .areaFreeze, .reset:
            let row = min(position.row, Constants.rows - 2)
            let column = min(position.column, Constants.columns - 2)
            return index(row: row, column: column)
        }
    }

    private func applyLineBreak(targetIndex: Int) -> Bool {
        guard let cells = rowOrColumnCells(for: targetIndex) else { return false }
        cells.forEach { setMark(.empty, at: $0) }
        return true
    }

    private func applyColorChange(targetIndex: Int) -> Bool {
        let enemy = currentPlayer.opponent
        let targetCells = lineCells(for: targetIndex) ?? [targetIndex].filter(isValidIndex)
        let enemyCells = targetCells.filter { mark(at: $0) == enemy }.prefix(3)
        guard !enemyCells.isEmpty else { return false }

        enemyCells.forEach { setMark(currentPlayer, at: $0) }
        return true
    }

    private func applyAreaFreeze(targetIndex: Int) -> Bool {
        guard let cells = areaCells(topLeftIndex: targetIndex) else { return false }
        cells.forEach { freezeCounters[$0] = max(freezeCounters[$0] ?? 0, Constants.freezeDuration) }
        return true
    }

    private func applyReset(targetIndex: Int) -> Bool {
        guard let cells = areaCells(topLeftIndex: targetIndex) else { return false }
        cells.forEach { setMark(.empty, at: $0) }
        return true
    }

    private func performAISkillIfHelpful() -> Bool {
        guard energy >= Skill.areaFreeze.cost else { return false }

        let playerLines = findLines(for: .x, on: board)
            .sorted { $0.cells.count > $1.cells.count }
        guard let line = playerLines.first else { return false }

        if let lineBreakTarget = lineBreakTarget(for: line), energy >= Skill.lineBreak.cost {
            guard applyLineBreak(targetIndex: lineBreakTarget) else { return false }
            energy -= Skill.lineBreak.cost
            refreshScoredLines()
            return true
        }

        guard let freezeTarget = bestAreaTarget(covering: line.cells) else { return false }
        guard applyAreaFreeze(targetIndex: freezeTarget) else { return false }
        energy -= Skill.areaFreeze.cost
        updateFrozenState()
        return true
    }

    private func lineBreakTarget(for line: BoardLine) -> Int? {
        switch line.direction {
        case .horizontal:
            guard let row = line.cells.first.map({ rowAndColumn(for: $0).row }) else { return nil }
            return Self.rowTarget(row)
        case .vertical:
            guard let column = line.cells.first.map({ rowAndColumn(for: $0).column }) else { return nil }
            return Self.columnTarget(column)
        case .diagonalDown, .diagonalUp:
            return nil
        }
    }

    private func bestAreaTarget(covering cells: [Int]) -> Int? {
        var bestTarget: Int?
        var bestScore = Int.min

        for row in 0..<(Constants.rows - 1) {
            for column in 0..<(Constants.columns - 1) {
                let topLeft = index(row: row, column: column)
                guard let area = areaCells(topLeftIndex: topLeft) else { continue }
                let overlap = area.filter { cells.contains($0) }.count
                let emptyCount = area.filter { mark(at: $0) == .empty }.count
                let score = overlap * 10 + emptyCount

                if score > bestScore {
                    bestScore = score
                    bestTarget = topLeft
                }
            }
        }

        return bestTarget
    }

    private func bestScoringMove(for player: CellMark) -> Int? {
        legalMoves()
            .map { index in
                (
                    index: index,
                    score: scorePotentialAfterMove(at: index, for: player),
                    position: Constants.positionScores[index]
                )
            }
            .filter { $0.score > 0 }
            .sorted {
                if $0.score == $1.score {
                    return $0.position > $1.position
                }
                return $0.score > $1.score
            }
            .first?
            .index
    }

    private func bestBuildingMove(for player: CellMark) -> Int? {
        let rankedMoves = legalMoves()
            .map { index in
                (
                    index: index,
                    length: longestPartialLengthAfterMove(at: index, for: player),
                    windows: openWindowScoreAfterMove(at: index, for: player),
                    position: Constants.positionScores[index]
                )
            }
            .sorted {
                if $0.length != $1.length {
                    return $0.length > $1.length
                }

                if $0.windows != $1.windows {
                    return $0.windows > $1.windows
                }

                return $0.position > $1.position
            }

        guard let best = rankedMoves.first, best.length >= 2 else { return nil }
        return best.index
    }

    private func fallbackMove() -> Int? {
        legalMoves().max {
            Constants.positionScores[$0] < Constants.positionScores[$1]
        }
    }

    private func scorePotentialAfterMove(at index: Int, for player: CellMark) -> Int {
        var testBoard = board
        setMark(player, at: index, on: &testBoard)

        let lines = findLines(for: player, on: testBoard)
            .filter { $0.cells.contains(index) && !scoredLines.contains($0.identity) }
        let points = lines.reduce(0) { $0 + $1.points }
        let bonus = max(0, lines.count - 1) * Constants.comboBonus
        return points + bonus
    }

    private func longestPartialLengthAfterMove(at index: Int, for player: CellMark) -> Int {
        var testBoard = board
        setMark(player, at: index, on: &testBoard)

        let directions = [(1, 0), (0, 1), (1, 1), (1, -1)]
        return directions
            .map { contiguousLength(from: index, player: player, delta: $0, on: testBoard) }
            .max() ?? 1
    }

    private func openWindowScoreAfterMove(at index: Int, for player: CellMark) -> Int {
        var testBoard = board
        setMark(player, at: index, on: &testBoard)

        let enemy = player.opponent
        return allWindows()
            .filter { $0.contains(index) }
            .reduce(0) { score, window in
                let marks = window.map { mark(at: $0, on: testBoard) }
                guard !marks.contains(enemy) else { return score }
                return score + marks.filter { $0 == player }.count
            }
    }

    private func contiguousLength(
        from index: Int,
        player: CellMark,
        delta: (row: Int, column: Int),
        on testBoard: [[CellMark]]
    ) -> Int {
        let origin = rowAndColumn(for: index)
        let forward = countMarks(
            fromRow: origin.row + delta.row,
            column: origin.column + delta.column,
            delta: delta,
            player: player,
            on: testBoard
        )
        let backward = countMarks(
            fromRow: origin.row - delta.row,
            column: origin.column - delta.column,
            delta: (row: -delta.row, column: -delta.column),
            player: player,
            on: testBoard
        )
        return 1 + forward + backward
    }

    private func countMarks(
        fromRow row: Int,
        column: Int,
        delta: (row: Int, column: Int),
        player: CellMark,
        on testBoard: [[CellMark]]
    ) -> Int {
        var row = row
        var column = column
        var count = 0

        while isValid(row: row, column: column), testBoard[row][column] == player {
            count += 1
            row += delta.row
            column += delta.column
        }

        return count
    }

    private func allWindows() -> [[Int]] {
        var windows: [[Int]] = []
        let directions = [(0, 1), (1, 0), (1, 1), (1, -1)]

        for row in 0..<Constants.rows {
            for column in 0..<Constants.columns {
                for direction in directions {
                    let cells = (0..<3).map {
                        self.index(row: row + direction.0 * $0, column: column + direction.1 * $0)
                    }

                    if cells.allSatisfy(isValidIndex) {
                        windows.append(cells)
                    }
                }
            }
        }

        return windows
    }

    private func findLines(for player: CellMark, on sourceBoard: [[CellMark]]) -> [BoardLine] {
        var lines: [BoardLine] = []

        for row in 0..<Constants.rows {
            appendRuns(
                in: (0..<Constants.columns).map { index(row: row, column: $0) },
                direction: .horizontal,
                player: player,
                sourceBoard: sourceBoard,
                lines: &lines
            )
        }

        for column in 0..<Constants.columns {
            appendRuns(
                in: (0..<Constants.rows).map { index(row: $0, column: column) },
                direction: .vertical,
                player: player,
                sourceBoard: sourceBoard,
                lines: &lines
            )
        }

        diagonalStartsDown().forEach { start in
            appendRuns(
                in: orderedCells(start: start, delta: (1, 1)),
                direction: .diagonalDown,
                player: player,
                sourceBoard: sourceBoard,
                lines: &lines
            )
        }

        diagonalStartsUp().forEach { start in
            appendRuns(
                in: orderedCells(start: start, delta: (1, -1)),
                direction: .diagonalUp,
                player: player,
                sourceBoard: sourceBoard,
                lines: &lines
            )
        }

        return lines
    }

    private func appendRuns(
        in orderedCells: [Int],
        direction: Direction,
        player: CellMark,
        sourceBoard: [[CellMark]],
        lines: inout [BoardLine]
    ) {
        var run: [Int] = []

        for cell in orderedCells {
            if mark(at: cell, on: sourceBoard) == player {
                run.append(cell)
            } else {
                appendRunIfNeeded(run, direction: direction, player: player, lines: &lines)
                run.removeAll()
            }
        }

        appendRunIfNeeded(run, direction: direction, player: player, lines: &lines)
    }

    private func appendRunIfNeeded(
        _ run: [Int],
        direction: Direction,
        player: CellMark,
        lines: inout [BoardLine]
    ) {
        guard run.count >= 3 else { return }
        lines.append(BoardLine(owner: player, direction: direction, cells: run))
    }

    private func refreshScoredLines() {
        let activeLines = findLines(for: .x, on: board) + findLines(for: .o, on: board)
        let activeIdentities = Set(activeLines.map(\.identity))
        scoredLines = scoredLines.intersection(activeIdentities)
    }

    private func diagonalStartsDown() -> [(row: Int, column: Int)] {
        let topRowStarts = (0..<Constants.columns).map { (row: 0, column: $0) }
        let leftColumnStarts = (1..<Constants.rows).map { (row: $0, column: 0) }
        return topRowStarts + leftColumnStarts
    }

    private func diagonalStartsUp() -> [(row: Int, column: Int)] {
        let topRowStarts = (0..<Constants.columns).map { (row: 0, column: $0) }
        let rightColumnStarts = (1..<Constants.rows).map {
            (row: $0, column: Constants.columns - 1)
        }
        return topRowStarts + rightColumnStarts
    }

    private func orderedCells(start: (row: Int, column: Int), delta: (row: Int, column: Int)) -> [Int] {
        var cells: [Int] = []
        var row = start.row
        var column = start.column

        while isValid(row: row, column: column) {
            cells.append(index(row: row, column: column))
            row += delta.row
            column += delta.column
        }

        return cells
    }

    private func rowOrColumnCells(for targetIndex: Int) -> [Int]? {
        if let row = decodedRow(from: targetIndex) {
            return (0..<Constants.columns).map { index(row: row, column: $0) }
        }

        if let column = decodedColumn(from: targetIndex) {
            return (0..<Constants.rows).map { index(row: $0, column: column) }
        }

        return nil
    }

    private func lineCells(for targetIndex: Int) -> [Int]? {
        if let rowOrColumn = rowOrColumnCells(for: targetIndex) {
            return rowOrColumn
        }

        if let diagonal = decodedDiagonal(from: targetIndex) {
            return Self.diagonalTargets[safe: diagonal]
        }

        return nil
    }

    private func areaCells(topLeftIndex: Int) -> [Int]? {
        guard isValidIndex(topLeftIndex) else { return nil }
        let position = rowAndColumn(for: topLeftIndex)
        guard position.row < Constants.rows - 1 else { return nil }
        guard position.column < Constants.columns - 1 else { return nil }

        return [
            topLeftIndex,
            index(row: position.row, column: position.column + 1),
            index(row: position.row + 1, column: position.column),
            index(row: position.row + 1, column: position.column + 1)
        ]
    }

    private func decodedRow(from targetIndex: Int) -> Int? {
        let row = targetIndex - Target.rowOffset
        return (0..<Constants.rows).contains(row) ? row : nil
    }

    private func decodedColumn(from targetIndex: Int) -> Int? {
        let column = targetIndex - Target.columnOffset
        return (0..<Constants.columns).contains(column) ? column : nil
    }

    private func decodedDiagonal(from targetIndex: Int) -> Int? {
        let diagonal = targetIndex - Target.diagonalOffset
        return Self.diagonalTargets.indices.contains(diagonal) ? diagonal : nil
    }

    private func advanceFrozenTurns() {
        guard !freezeCounters.isEmpty else { return }

        for cell in Array(freezeCounters.keys) {
            let remaining = (freezeCounters[cell] ?? 0) - 1
            if remaining <= 0 {
                freezeCounters.removeValue(forKey: cell)
            } else {
                freezeCounters[cell] = remaining
            }
        }

        updateFrozenState()
    }

    private func updateFrozenState() {
        frozenCells = Set(freezeCounters.keys)
        frozenTurnsRemaining = freezeCounters.values.max() ?? 0
    }

    private func legalMoves() -> [Int] {
        (0..<(Constants.rows * Constants.columns))
            .filter(isLegalMove)
    }

    private func isLegalMove(_ index: Int) -> Bool {
        isValidIndex(index) && mark(at: index) == .empty && !frozenCells.contains(index)
    }

    private var isBoardFull: Bool {
        board.flatMap { $0 }.allSatisfy { $0 != .empty }
    }

    private func mark(at index: Int) -> CellMark {
        mark(at: index, on: board)
    }

    private func mark(at index: Int, on sourceBoard: [[CellMark]]) -> CellMark {
        let position = rowAndColumn(for: index)
        return sourceBoard[position.row][position.column]
    }

    private func setMark(_ mark: CellMark, at index: Int) {
        let position = rowAndColumn(for: index)
        board[position.row][position.column] = mark
    }

    private func setMark(_ mark: CellMark, at index: Int, on sourceBoard: inout [[CellMark]]) {
        let position = rowAndColumn(for: index)
        sourceBoard[position.row][position.column] = mark
    }

    private func rowAndColumn(for index: Int) -> (row: Int, column: Int) {
        (row: index / Constants.columns, column: index % Constants.columns)
    }

    private func index(row: Int, column: Int) -> Int {
        row * Constants.columns + column
    }

    private func isValidIndex(_ index: Int) -> Bool {
        (0..<(Constants.rows * Constants.columns)).contains(index)
    }

    private func isValid(row: Int, column: Int) -> Bool {
        (0..<Constants.rows).contains(row) && (0..<Constants.columns).contains(column)
    }

    private static let diagonalTargets: [[Int]] = [
        [0, 5, 10, 15],
        [1, 6, 11],
        [4, 9, 14, 19],
        [8, 13, 18],
        [3, 6, 9, 12],
        [2, 5, 8],
        [7, 10, 13, 16],
        [11, 14, 17]
    ]
}

private extension CellMark {
    var opponent: CellMark {
        switch self {
        case .x:
            .o
        case .o:
            .x
        case .empty:
            .empty
        }
    }

    var scoreKey: String {
        switch self {
        case .x:
            "x"
        case .o:
            "o"
        case .empty:
            "empty"
        }
    }
}

private extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
