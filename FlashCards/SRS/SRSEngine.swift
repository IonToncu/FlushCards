import Foundation

struct SRSEngine {
    static let minEaseFactor = 1.3
    static let defaultEaseFactor = 2.5
    static let defaultInterval: Double = 1

    func nextReview(record: ReviewRecord, rating: ReviewRecord.Rating) -> ReviewRecord {
        var interval = record.interval
        var easeFactor = record.easeFactor
        var repetitions = record.repetitions

        switch rating {
        case .good:
            interval = max(1, interval * easeFactor)
            easeFactor = min(easeFactor + 0.1, 4.0)
            repetitions += 1
        case .okay:
            interval = max(1, interval * easeFactor * 0.8)
            repetitions += 1
        case .bad:
            interval = 1
            easeFactor = max(Self.minEaseFactor, easeFactor - 0.2)
            repetitions = 0
        }

        record.interval = interval
        record.easeFactor = easeFactor
        record.repetitions = repetitions
        record.dueDate = Calendar.current.date(byAdding: .second, value: Int(interval * 86400), to: Date.now) ?? Date.now
        record.lastResult = rating
        record.lastReviewedAt = Date.now
        return record
    }
}
