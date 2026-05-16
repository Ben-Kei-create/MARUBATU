import Combine
import SwiftUI

@MainActor
final class TutorialViewModel: ObservableObject {
    @Published var board: [[CellMark]]
    @Published var packIndex = 0
    @Published var lessonIndex = 0
    @Published var feedbackText = "青く光る枠をタップ"
    @Published var isSolved = false
    @Published var mistakePulse = false
    @Published var frozenCells: Set<Int> = []

    let packs: [TutorialPack] = [
        TutorialPack(
            title: "基礎",
            subtitle: "◯×からNEXUSへ",
            lessons: [
                TutorialLesson(
                    title: "1. ◯×の一手",
                    subtitle: "まずは枠を押してXを置く。ここがNEXUSの入口です。",
                    board: TutorialViewModel.emptyBoard(),
                    action: .place(index: 9, mark: .x),
                    successText: "いい感じ。枠を押すと、マークが盤面に定着します。"
                ),
                TutorialLesson(
                    title: "2. 3つ並べる",
                    subtitle: "◯×と同じく、3つ並ぶ形を見つけます。",
                    board: TutorialViewModel.board(with: [
                        8: .x,
                        9: .x,
                        13: .o,
                        17: .o
                    ]),
                    action: .place(index: 10, mark: .x),
                    successText: "ライン完成。NEXUSではこれが得点になります。"
                ),
                TutorialLesson(
                    title: "3. 相手の筋を止める",
                    subtitle: "勝つだけでなく、相手の3つ目を先にふさぐ判断も大事です。",
                    board: TutorialViewModel.board(with: [
                        4: .o,
                        5: .o,
                        8: .x,
                        13: .x
                    ]),
                    action: .place(index: 6, mark: .x),
                    successText: "ブロック成功。防御も詰め筋のひとつです。"
                ),
                TutorialLesson(
                    title: "4. ダブルライン",
                    subtitle: "1手で横ラインと縦ラインを同時に完成させます。",
                    board: TutorialViewModel.board(with: [
                        6: .x,
                        8: .x,
                        9: .x,
                        14: .x,
                        1: .o,
                        17: .o
                    ]),
                    action: .place(index: 10, mark: .x),
                    successText: "ダブルライン。これが詰めNEXUSの気持ちいい瞬間です。"
                )
            ]
        ),
        TutorialPack(
            title: "スキル",
            subtitle: "盤面を動かす詰め筋",
            lessons: [
                TutorialLesson(
                    title: "1. ラインブレイク",
                    subtitle: "相手の完成ラインを、行ごと消して流れを切ります。",
                    board: TutorialViewModel.board(with: [
                        4: .o,
                        5: .o,
                        6: .o,
                        9: .x,
                        14: .x
                    ]),
                    action: .lineBreak(cells: [4, 5, 6, 7], cost: 3),
                    successText: "ラインを破壊。相手の得点源を丸ごと消せました。"
                ),
                TutorialLesson(
                    title: "2. カラー変更",
                    subtitle: "敵のマークを自分の色に変えて、ラインを一気に作ります。",
                    board: TutorialViewModel.board(with: [
                        8: .o,
                        9: .o,
                        10: .x,
                        2: .o,
                        14: .x
                    ]),
                    action: .colorChange(cells: [8, 9], mark: .x, cost: 4),
                    successText: "色を奪ってライン完成。スキルは攻めにも使えます。"
                ),
                TutorialLesson(
                    title: "3. リセット",
                    subtitle: "混み合った2x2を空に戻して、次の詰め筋を作ります。",
                    board: TutorialViewModel.board(with: [
                        5: .x,
                        6: .o,
                        9: .o,
                        10: .x,
                        14: .o
                    ]),
                    action: .reset(cells: [5, 6, 9, 10], cost: 6),
                    successText: "盤面をリセット。詰まりをほどく判断もNEXUSらしさです。"
                ),
                TutorialLesson(
                    title: "4. エリア凍結",
                    subtitle: "相手が次に置きたい場所を、2x2ごと止めます。",
                    board: TutorialViewModel.board(with: [
                        2: .o,
                        6: .o,
                        8: .x,
                        13: .x
                    ]),
                    action: .freeze(cells: [6, 7, 10, 11], cost: 5),
                    successText: "凍結成功。置かせないことも強い一手です。"
                )
            ]
        )
    ]

    var currentPack: TutorialPack {
        packs[packIndex]
    }

    var currentLesson: TutorialLesson {
        currentPack.lessons[lessonIndex]
    }

    var progressText: String {
        "\(lessonIndex + 1) / \(currentPack.lessons.count)"
    }

    var highlightedCells: Set<Int> {
        isSolved ? [] : currentLesson.action.highlightedCells
    }

    var canGoNext: Bool {
        isSolved && lessonIndex < currentPack.lessons.count - 1
    }

    var canGoNextPack: Bool {
        isSolved && lessonIndex == currentPack.lessons.count - 1 && packIndex < packs.count - 1
    }

    var isComplete: Bool {
        isSolved && packIndex == packs.count - 1 && lessonIndex == currentPack.lessons.count - 1
    }

    var isSkillLesson: Bool {
        currentLesson.action.isSkill
    }

    var skillTitle: String {
        currentLesson.action.skillTitle
    }

    var skillCostText: String {
        guard let cost = currentLesson.action.cost else { return "" }
        return "コスト \(cost)"
    }

    init() {
        board = packs[0].lessons[0].board
    }

    func selectPack(at index: Int) {
        guard packs.indices.contains(index), index != packIndex else { return }
        packIndex = index
        lessonIndex = 0
        loadCurrentLesson()
    }

    func placeMark(at index: Int) {
        guard !isSolved else { return }
        guard currentLesson.action.acceptsTap(at: index) else {
            showMistake()
            return
        }

        resolveCurrentAction()
    }

    func performSkill() {
        guard !isSolved, currentLesson.action.isSkill else { return }
        resolveCurrentAction()
    }

    func goNext() {
        guard canGoNext else { return }
        lessonIndex += 1
        loadCurrentLesson()
    }

    func goNextPack() {
        guard canGoNextPack else { return }
        packIndex += 1
        lessonIndex = 0
        loadCurrentLesson()
    }

    func reset() {
        packIndex = 0
        lessonIndex = 0
        loadCurrentLesson()
    }

    private func resolveCurrentAction() {
        switch currentLesson.action {
        case .place(let index, let mark):
            guard isValidIndex(index), self.mark(at: index) == .empty else {
                showMistake()
                return
            }
            setMark(mark, at: index)

        case .lineBreak(let cells, _):
            cells.forEach { setMark(.empty, at: $0) }

        case .colorChange(let cells, let mark, _):
            cells.forEach { setMark(mark, at: $0) }

        case .reset(let cells, _):
            cells.forEach { setMark(.empty, at: $0) }

        case .freeze(let cells, _):
            frozenCells = Set(cells)
        }

        feedbackText = currentLesson.successText
        isSolved = true
    }

    private func loadCurrentLesson() {
        board = currentLesson.board
        frozenCells = []
        feedbackText = currentLesson.action.initialHint
        isSolved = false
        mistakePulse = false
    }

    private func showMistake() {
        feedbackText = currentLesson.action.mistakeHint
        mistakePulse.toggle()
    }

    private func mark(at index: Int) -> CellMark {
        let row = index / 4
        let column = index % 4
        return board[row][column]
    }

    private func setMark(_ mark: CellMark, at index: Int) {
        guard isValidIndex(index) else { return }
        let row = index / 4
        let column = index % 4
        board[row][column] = mark
    }

    private func isValidIndex(_ index: Int) -> Bool {
        (0..<20).contains(index)
    }

    private static func emptyBoard() -> [[CellMark]] {
        Array(repeating: Array(repeating: CellMark.empty, count: 4), count: 5)
    }

    private static func board(with marks: [Int: CellMark]) -> [[CellMark]] {
        var board = emptyBoard()
        for (index, mark) in marks {
            guard (0..<20).contains(index) else { continue }
            board[index / 4][index % 4] = mark
        }
        return board
    }
}

struct TutorialPack: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let lessons: [TutorialLesson]
}

struct TutorialLesson {
    let title: String
    let subtitle: String
    let board: [[CellMark]]
    let action: TutorialAction
    let successText: String
}

enum TutorialAction {
    case place(index: Int, mark: CellMark)
    case lineBreak(cells: [Int], cost: Int)
    case colorChange(cells: [Int], mark: CellMark, cost: Int)
    case reset(cells: [Int], cost: Int)
    case freeze(cells: [Int], cost: Int)

    var highlightedCells: Set<Int> {
        switch self {
        case .place(let index, _):
            [index]
        case .lineBreak(let cells, _),
             .colorChange(let cells, _, _),
             .reset(let cells, _),
             .freeze(let cells, _):
            Set(cells)
        }
    }

    var isSkill: Bool {
        switch self {
        case .place:
            false
        case .lineBreak, .colorChange, .reset, .freeze:
            true
        }
    }

    var skillTitle: String {
        switch self {
        case .place:
            ""
        case .lineBreak:
            "ラインブレイク"
        case .colorChange:
            "カラー変更"
        case .reset:
            "リセット"
        case .freeze:
            "エリア凍結"
        }
    }

    var cost: Int? {
        switch self {
        case .place:
            nil
        case .lineBreak(_, let cost),
             .colorChange(_, _, let cost),
             .reset(_, let cost),
             .freeze(_, let cost):
            cost
        }
    }

    var initialHint: String {
        isSkill ? "光る対象をタップ、またはスキルを発動" : "青く光る枠をタップ"
    }

    var mistakeHint: String {
        isSkill ? "惜しい。光っている対象が今回のスキル範囲です。" : "惜しい。青く光る枠が今回の詰め筋です。"
    }

    func acceptsTap(at index: Int) -> Bool {
        highlightedCells.contains(index)
    }
}
