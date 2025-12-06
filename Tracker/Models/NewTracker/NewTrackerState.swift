import UIKit

struct NewTrackerState {
    var title: String
    var category: TrackerCategory?
    var schedule: Set<Weekday>
    var emoji: String
    var color: UIColor?
    
    var isReady: Bool {
        !title.isEmpty &&
        !schedule.isEmpty &&
        category != nil &&
        !emoji.isEmpty &&
        color != nil
    }
}
