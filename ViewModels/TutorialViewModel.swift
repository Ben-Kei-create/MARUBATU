import Combine
import SwiftUI

@MainActor
final class TutorialViewModel: ObservableObject {
    @Published var board: [[CellMark]]
    @Published var lessonIndex = 0
    @Published var feedbackText = "青く光る枠をタップ"
    @Published var isSolved = false
    @Published var mistakePulse = false

    private let lessons: [TutorialLesson] = [
        TutorialLesson(
            title: "1. ◯×の一手",
            subtitle: "まずは枠を押してXを置く。ここがNEXUSの入口です。",
            board: TutorialViewModel.emptyBoard(),
            targetIndex: 9,
            placedMark: .x,
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
            targetIndex: 10,
            placedMark: .x,
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
            targetIndex: 6,
            placedMark: .x,
            successText: "ブロック成功。防御も詰め筋のひとつです。"
        ),
        TutorialLesson(
            title: "4. 詰めNEXUS",
            subtitle: "1手で横ラインと縦ラインを同時に完成させます。",
            board: TutorialViewModel.board(with: [
                6: .x,
                8: .x,
                9: .x,
                14: .x,
                1: .o,
                17: .o
            ]),
            targetIndex: 10,
            placedMark: .x,
            successText: "ダブルライン。これが詰めNEXUSの気持ちいい瞬間です。"
        )
    ]

    var currentLesson: TutorialLesson {
        lessons[lessonIndex]
    }

    var progressText: String {
        "\(lessonIndex + 1) / \(lessons.count)"
    }

    var highlightedCells: Set<Int> {
        isSolved ? [] : [currentLesson.targetIndex]
    }

    var canGoNext: Bool {
        isSolved && lessonIndex < lessons.count - 1
    }

    var isComplete: Bool {
        isSolved && lessonIndex == lessons.count - 1
    }

    init() {
        board = lessons[0].board
    }

    func placeMark(at index: Int) {
        guard !isSolved else { return }
        guard isValidIndex(index), mark(at: index) == .empty else { return }

        guard index == currentLesson.targetIndex else {
            showMistake()
            return
        }

        setMark(currentLesson.placedMark, at: index)
        feedbackText = currentLesson.successText
        isSolved = true
    }

    func goNext() {
        guard canGoNext else { return }
        lessonIndex += 1
        loadCurrentLesson()
    }

    func reset() {
        lessonIndex = 0
        loadCurrentLesson()
    }

    private func loadCurrentLesson() {
        board = currentLesson.board
        feedbackText = "青く光る枠をタップ"
        isSolved = false
        mistakePulse = false
    }

    private func showMistake() {
        feedbackText = "惜しい。青く光る枠が今回の詰め筋です。"
        mistakePulse.toggle()
    }

    private func mark(at index: Int) -> CellMark {
        let row = index / 4
        let column = index % 4
        return board[row][column]
    }

    private func setMark(_ mark: CellMark, at index: Int) {
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

struct TutorialLesson {
    let title: String
    let subtitle: String
    let board: [[CellMark]]
    let targetIndex: Int
    let placedMark: CellMark
    let successText: String
}
