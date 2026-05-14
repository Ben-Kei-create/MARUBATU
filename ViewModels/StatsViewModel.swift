import Combine
import SwiftUI

@MainActor
final class StatsViewModel: ObservableObject {
    @Published var totalPlays: Int = 0
    @Published var totalWins: Int = 0
    @Published var bestScore: Int = 0
    @Published var winStreak: Int = 0
    @Published var maxWinStreak: Int = 0
    @Published var winRate: Double = 0

    private let defaults: UserDefaults
    private var selectedMode: GameMode?

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
    }

    func load(mode: GameMode? = nil) {
        selectedMode = mode

        switch mode {
        case .some(let mode):
            loadSingleMode(mode)
        case .none:
            loadTotals()
        }

        winRate = totalPlays == 0 ? 0 : Double(totalWins) / Double(totalPlays)
    }

    func recordResult(won: Bool, score: Int, mode: GameMode) {
        let plays = defaults.integer(forKey: key(.totalPlays, mode: mode)) + 1
        let wins = defaults.integer(forKey: key(.totalWins, mode: mode)) + (won ? 1 : 0)
        let best = max(defaults.integer(forKey: key(.bestScore, mode: mode)), score)
        let currentStreak = won
            ? defaults.integer(forKey: key(.currentWinStreak, mode: mode)) + 1
            : 0
        let maxStreak = max(
            defaults.integer(forKey: key(.maxWinStreak, mode: mode)),
            currentStreak
        )

        defaults.set(plays, forKey: key(.totalPlays, mode: mode))
        defaults.set(wins, forKey: key(.totalWins, mode: mode))
        defaults.set(best, forKey: key(.bestScore, mode: mode))
        defaults.set(currentStreak, forKey: key(.currentWinStreak, mode: mode))
        defaults.set(maxStreak, forKey: key(.maxWinStreak, mode: mode))

        load(mode: selectedMode)
    }

    func reset() {
        GameMode.statsModes.forEach { mode in
            StatKey.allCases.forEach { statKey in
                defaults.removeObject(forKey: key(statKey, mode: mode))
            }
        }

        load(mode: selectedMode)
    }

    private func loadSingleMode(_ mode: GameMode) {
        totalPlays = defaults.integer(forKey: key(.totalPlays, mode: mode))
        totalWins = defaults.integer(forKey: key(.totalWins, mode: mode))
        bestScore = defaults.integer(forKey: key(.bestScore, mode: mode))
        winStreak = defaults.integer(forKey: key(.currentWinStreak, mode: mode))
        maxWinStreak = defaults.integer(forKey: key(.maxWinStreak, mode: mode))
    }

    private func loadTotals() {
        let snapshots = GameMode.statsModes.map { snapshot(for: $0) }
        totalPlays = snapshots.reduce(0) { $0 + $1.totalPlays }
        totalWins = snapshots.reduce(0) { $0 + $1.totalWins }
        bestScore = snapshots.map(\.bestScore).max() ?? 0
        winStreak = snapshots.map(\.winStreak).max() ?? 0
        maxWinStreak = snapshots.map(\.maxWinStreak).max() ?? 0
    }

    private func snapshot(for mode: GameMode) -> StatsSnapshot {
        StatsSnapshot(
            totalPlays: defaults.integer(forKey: key(.totalPlays, mode: mode)),
            totalWins: defaults.integer(forKey: key(.totalWins, mode: mode)),
            bestScore: defaults.integer(forKey: key(.bestScore, mode: mode)),
            winStreak: defaults.integer(forKey: key(.currentWinStreak, mode: mode)),
            maxWinStreak: defaults.integer(forKey: key(.maxWinStreak, mode: mode))
        )
    }

    private func key(_ statKey: StatKey, mode: GameMode) -> String {
        "nexus.\(mode.statsKey).\(statKey.rawValue)"
    }

    private enum StatKey: String, CaseIterable {
        case totalPlays
        case totalWins
        case bestScore
        case currentWinStreak
        case maxWinStreak
    }

    private struct StatsSnapshot {
        let totalPlays: Int
        let totalWins: Int
        let bestScore: Int
        let winStreak: Int
        let maxWinStreak: Int
    }
}

private extension GameMode {
    static let statsModes: [GameMode] = [.vsAI, .twoPlayer]

    var statsKey: String {
        switch self {
        case .vsAI:
            "vsAI"
        case .twoPlayer:
            "twoPlayer"
        }
    }
}
