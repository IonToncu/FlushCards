import Foundation

struct TopicStats {
    let totalCards: Int
    let dueCount: Int
    let averageEaseFactor: Double
    let retentionRate: Double   // last 7 days: (good+okay) / total
}

struct StatisticsService {
    func compute(cards: [Card], records: [ReviewRecord]) -> TopicStats {
        let now = Date.now
        let totalCards = cards.count
        let cardIdSet = Set(cards.map(\.id))

        let topicRecords = records.filter { cardIdSet.contains($0.cardId) }

        let dueCount = cards.filter { card in
            guard let r = topicRecords.first(where: { $0.cardId == card.id }) else { return true }
            return r.dueDate <= now
        }.count

        let avgEase = topicRecords.isEmpty ? SRSEngine.defaultEaseFactor
            : topicRecords.map(\.easeFactor).reduce(0, +) / Double(topicRecords.count)

        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: now) ?? now
        let recentRecords = topicRecords.filter { $0.lastReviewedAt >= sevenDaysAgo }
        let retention: Double
        if recentRecords.isEmpty {
            retention = 0
        } else {
            let positiveCount = recentRecords.filter { $0.lastResult == .good || $0.lastResult == .okay }.count
            retention = Double(positiveCount) / Double(recentRecords.count)
        }

        return TopicStats(
            totalCards: totalCards,
            dueCount: dueCount,
            averageEaseFactor: avgEase,
            retentionRate: retention
        )
    }
}
