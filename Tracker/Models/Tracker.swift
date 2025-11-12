import UIKit

struct Tracker {
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: Set<Weekday>
}

enum Weekday {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
}
