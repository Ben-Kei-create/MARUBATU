import SwiftUI

struct GameBoard: View {
    let marks: [[CellMark]]
    let selectedIndex: Int?
    var highlightedIndices: Set<Int> = []
    var frozenIndices: Set<Int> = []
    let onCellTap: (Int) -> Void

    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<5, id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(0..<4, id: \.self) { col in
                        let index = row * 4 + col
                        let mark = marks[row][col]
                        let isSelected = selectedIndex == index

                        GameCell(
                            index: index,
                            mark: mark,
                            isSelected: isSelected,
                            isHighlighted: highlightedIndices.contains(index),
                            isFrozen: frozenIndices.contains(index),
                            action: { onCellTap(index) }
                        )
                    }
                }
            }
        }
        .padding(DesignSystem.spacing.lg)
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
