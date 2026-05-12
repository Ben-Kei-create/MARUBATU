import Foundation

enum GameMode {
    case vsAI
    case twoPlayer
}

enum NavigationDestination: Hashable {
    case modeSelection
    case howToPlay
    case gameplay(mode: GameMode)
    case skillSelection
    case skillTargetSelection(skill: String)
    case result(won: Bool, score: Int, bonus: Int)
    case stats
    case settings

    func hash(into hasher: inout Hasher) {
        switch self {
        case .modeSelection:
            hasher.combine("modeSelection")
        case .howToPlay:
            hasher.combine("howToPlay")
        case .gameplay(let mode):
            hasher.combine("gameplay")
            hasher.combine(mode == .vsAI ? "vsAI" : "twoPlayer")
        case .skillSelection:
            hasher.combine("skillSelection")
        case .skillTargetSelection(let skill):
            hasher.combine("skillTargetSelection")
            hasher.combine(skill)
        case .result(let won, let score, let bonus):
            hasher.combine("result")
            hasher.combine(won)
            hasher.combine(score)
            hasher.combine(bonus)
        case .stats:
            hasher.combine("stats")
        case .settings:
            hasher.combine("settings")
        }
    }

    static func == (lhs: NavigationDestination, rhs: NavigationDestination) -> Bool {
        switch (lhs, rhs) {
        case (.modeSelection, .modeSelection): return true
        case (.howToPlay, .howToPlay): return true
        case (.gameplay(let lhsMode), .gameplay(let rhsMode)): return lhsMode == rhsMode
        case (.skillSelection, .skillSelection): return true
        case (.skillTargetSelection(let l), .skillTargetSelection(let r)): return l == r
        case (.result(let lw, let ls, let lb), .result(let rw, let rs, let rb)):
            return lw == rw && ls == rs && lb == rb
        case (.stats, .stats): return true
        case (.settings, .settings): return true
        default: return false
        }
    }
}
