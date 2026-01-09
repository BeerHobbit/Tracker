enum FilterType {
    
    case allTrackers
    case todayTrackers
    case completedTrackers
    case unfinishedTrackers
    
    var title: String {
        switch self {
        case .allTrackers: return "Все трекеры"
        case .todayTrackers: return "Трекеры на сегодня"
        case .completedTrackers: return "Завершенные"
        case .unfinishedTrackers: return "Не завершенные"
        }
    }
    
}
