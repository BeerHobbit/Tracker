import UIKit

struct NewTrackerState {
    let title: String
    let category: TrackerCategory?
    let schedule: Set<Weekday>
    let emoji: String
    let color: UIColor?
    
    var isReady: Bool {
        !title.isEmpty &&
        !schedule.isEmpty &&
        category != nil &&
        !emoji.isEmpty &&
        color != nil
    }
}
