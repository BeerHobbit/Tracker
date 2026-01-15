enum FilterType {
    case allTrackers
    case todayTrackers
    case completedTrackers
    case unfinishedTrackers
    
    var title: String {
        switch self {
        case .allTrackers: return "filter_screen.all".localized
        case .todayTrackers: return "filter_screen.today".localized
        case .completedTrackers: return "filter_screen.completed".localized
        case .unfinishedTrackers: return "filter_screen.unfinished".localized
        }
    }
}
