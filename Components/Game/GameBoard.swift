import SwiftUI

struct GameBoard: View {
    let marks: [[CellMark]]
    let selectedIndex: Int?
    var highlightedIndices: Set<Int> = []
    var frozenIndices: Set<Int> = []
    var scoringLines: [[Int]] = []
    var scoringPlayer: CellMark?
    var scoringAnimationID: Int = 0
    var cellSize: CGFloat = 68
    var spacing: CGFloat = 10
    var boardPadding: CGFloat = 0
    let onCellTap: (Int) -> Void

    var body: some View {
        ZStack {
            BoardAmbientGlow(width: boardWidth, height: boardHeight)

            VStack(spacing: spacing) {
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: spacing) {
                        ForEach(0..<columns, id: \.self) { col in
                            let index = row * columns + col
                            let mark = marks[row][col]
                            let isSelected = selectedIndex == index

                            GameCell(
                                index: index,
                                mark: mark,
                                isSelected: isSelected,
                                isHighlighted: highlightedIndices.contains(index),
                                isFrozen: frozenIndices.contains(index),
                                size: cellSize,
                                action: { onCellTap(index) }
                            )
                        }
                    }
                }
            }

            ScoringLineOverlay(
                lines: visibleScoringLines,
                player: visibleScoringPlayer,
                cellSize: cellSize,
                spacing: spacing,
                columns: columns
            )
            .frame(width: boardWidth, height: boardHeight)
            .id(scoringAnimationID)
            .allowsHitTesting(false)
        }
        .frame(width: boardWidth, height: boardHeight)
        .padding(boardPadding)
    }

    private let rows = 5
    private let columns = 4

    private var boardWidth: CGFloat {
        cellSize * CGFloat(columns) + spacing * CGFloat(columns - 1)
    }

    private var boardHeight: CGFloat {
        cellSize * CGFloat(rows) + spacing * CGFloat(rows - 1)
    }

    private var visibleScoringLines: [[Int]] {
        scoringLines.isEmpty ? completedLines.map(\.cells) : scoringLines
    }

    private var visibleScoringPlayer: CellMark? {
        scoringPlayer ?? completedLines.first?.player
    }

    private var completedLines: [(cells: [Int], player: CellMark)] {
        var lines: [(cells: [Int], player: CellMark)] = []

        for row in 0..<rows {
            appendRuns(in: (0..<columns).map { row * columns + $0 }, to: &lines)
        }

        for column in 0..<columns {
            appendRuns(in: (0..<rows).map { $0 * columns + column }, to: &lines)
        }

        diagonalStartsDown.forEach { start in
            appendRuns(in: orderedCells(from: start, delta: (1, 1)), to: &lines)
        }

        diagonalStartsUp.forEach { start in
            appendRuns(in: orderedCells(from: start, delta: (1, -1)), to: &lines)
        }

        return lines
    }

    private var diagonalStartsDown: [(row: Int, column: Int)] {
        (0..<columns).map { (row: 0, column: $0) }
            + (1..<rows).map { (row: $0, column: 0) }
    }

    private var diagonalStartsUp: [(row: Int, column: Int)] {
        (0..<columns).map { (row: 0, column: $0) }
            + (1..<rows).map { (row: $0, column: columns - 1) }
    }

    private func appendRuns(
        in indices: [Int],
        to lines: inout [(cells: [Int], player: CellMark)]
    ) {
        var run: [Int] = []
        var owner: CellMark = .empty

        for index in indices {
            let mark = mark(at: index)

            if mark != .empty, mark == owner {
                run.append(index)
            } else {
                appendRunIfNeeded(run, owner: owner, to: &lines)
                run = mark == .empty ? [] : [index]
                owner = mark
            }
        }

        appendRunIfNeeded(run, owner: owner, to: &lines)
    }

    private func appendRunIfNeeded(
        _ run: [Int],
        owner: CellMark,
        to lines: inout [(cells: [Int], player: CellMark)]
    ) {
        guard owner != .empty, run.count >= 3 else { return }
        lines.append((cells: run, player: owner))
    }

    private func orderedCells(
        from start: (row: Int, column: Int),
        delta: (row: Int, column: Int)
    ) -> [Int] {
        var indices: [Int] = []
        var row = start.row
        var column = start.column

        while (0..<rows).contains(row), (0..<columns).contains(column) {
            indices.append(row * columns + column)
            row += delta.row
            column += delta.column
        }

        return indices
    }

    private func mark(at index: Int) -> CellMark {
        marks[index / columns][index % columns]
    }
}

private struct BoardAmbientGlow: View {
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        ZStack {
            RadialGradient(
                colors: [
                    DesignSystem.colors.accentBlue.opacity(0.15),
                    DesignSystem.colors.accentPurple.opacity(0.07),
                    .clear
                ],
                center: .center,
                startRadius: 20,
                endRadius: max(width, height) * 0.72
            )
            .frame(width: width * 1.35, height: height * 1.1)
            .blur(radius: 18)

            Circle()
                .trim(from: 0.04, to: 0.46)
                .stroke(
                    LinearGradient(
                        colors: [
                            DesignSystem.colors.accentBlue.opacity(0.05),
                            DesignSystem.colors.textPrimary.opacity(0.45),
                            DesignSystem.colors.accentBlue.opacity(0.08)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 1.2, lineCap: .round)
                )
                .frame(width: width * 1.6, height: width * 1.6)
                .offset(y: -height * 0.55)
                .shadow(color: DesignSystem.colors.accentBlue.opacity(0.35), radius: 16)
        }
    }
}

private struct ScoringLineOverlay: View {
    let lines: [[Int]]
    let player: CellMark?
    let cellSize: CGFloat
    let spacing: CGFloat
    let columns: Int
    @State private var progress: CGFloat = 0
    @State private var flare = false

    var body: some View {
        ZStack {
            ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                if let first = line.first, let last = line.last {
                    let start = centerPoint(for: first)
                    let end = centerPoint(for: last)

                    NeonScoringSegment(
                        start: start,
                        end: end,
                        progress: progress,
                        accent: accent
                    )

                    ForEach(line, id: \.self) { index in
                        Circle()
                            .fill(accent.opacity(flare ? 0.45 : 0.2))
                            .frame(width: cellSize * 0.95, height: cellSize * 0.95)
                            .blur(radius: 12)
                            .position(centerPoint(for: index))

                        Circle()
                            .stroke(.white.opacity(flare ? 0.74 : 0.24), lineWidth: 1.2)
                            .frame(width: cellSize * 0.72, height: cellSize * 0.72)
                            .position(centerPoint(for: index))
                    }
                }
            }
        }
        .opacity(lines.isEmpty ? 0 : 1)
        .onAppear {
            playAnimation()
        }
        .onChange(of: lineSignature) { _, _ in
            playAnimation()
        }
    }

    private var lineSignature: String {
        lines
            .map { $0.map(String.init).joined(separator: "-") }
            .joined(separator: "|")
    }

    private func playAnimation() {
        guard !lines.isEmpty else {
            progress = 0
            flare = false
            return
        }

        progress = 0
        flare = false

        withAnimation(.easeOut(duration: 0.42)) {
            progress = 1
        }
        withAnimation(.easeInOut(duration: 0.5).repeatCount(4, autoreverses: true)) {
            flare = true
        }
    }

    private var accent: Color {
        player == .o ? DesignSystem.colors.accentPurple : DesignSystem.colors.accentBlue
    }

    private func centerPoint(for index: Int) -> CGPoint {
        let row = index / columns
        let column = index % columns
        return CGPoint(
            x: CGFloat(column) * (cellSize + spacing) + cellSize / 2,
            y: CGFloat(row) * (cellSize + spacing) + cellSize / 2
        )
    }
}

private struct NeonScoringSegment: View {
    let start: CGPoint
    let end: CGPoint
    let progress: CGFloat
    let accent: Color

    var body: some View {
        ZStack {
            Capsule()
                .fill(accent.opacity(0.32))
                .frame(width: visibleLength, height: 26)
                .blur(radius: 11)

            Capsule()
                .fill(accent.opacity(0.88))
                .frame(width: visibleLength, height: 8)
                .shadow(color: accent.opacity(0.95), radius: 18)
                .shadow(color: .white.opacity(0.55), radius: 5)

            Capsule()
                .fill(.white.opacity(0.92))
                .frame(width: visibleLength, height: 2)
        }
        .rotationEffect(.radians(angle))
        .position(visibleCenter)
    }

    private var dx: CGFloat {
        end.x - start.x
    }

    private var dy: CGFloat {
        end.y - start.y
    }

    private var length: CGFloat {
        sqrt(dx * dx + dy * dy)
    }

    private var visibleLength: CGFloat {
        max(1, length * progress)
    }

    private var visibleCenter: CGPoint {
        CGPoint(
            x: start.x + dx * progress / 2,
            y: start.y + dy * progress / 2
        )
    }

    private var angle: CGFloat {
        atan2(dy, dx)
    }
}

#Preview {
    let sampleMarks: [[CellMark]] = [
        [.x, .empty, .o, .empty],
        [.empty, .x, .empty, .o],
        [.o, .empty, .x, .empty],
        [.empty, .o, .empty, .x],
        [.x, .empty, .o, .empty]
    ]

    VStack {
        GameBoard(marks: sampleMarks, selectedIndex: nil) { _ in }
    }
    .background(DesignSystem.colors.darkBg)
    .ignoresSafeArea()
}
