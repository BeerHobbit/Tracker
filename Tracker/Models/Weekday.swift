enum Weekday: Int, CaseIterable, Codable {
    
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    
    var shortString: String {
        switch self {
        case .sunday: return "weekday.short_sunday".localized
        case .monday: return "weekday.short_monday".localized
        case .tuesday: return "weekday.short_tuesday".localized
        case .wednesday: return "weekday.short_wednesday".localized
        case .thursday: return "weekday.short_thursday".localized
        case .friday: return "weekday.short_friday".localized
        case .saturday: return "weekday.short_saturday".localized
        }
    }
    
    var longString: String {
        switch self {
        case .sunday: return "weekday.long_sunday".localized
        case .monday: return "weekday.long_monday".localized
        case .tuesday: return "weekday.long_tuesday".localized
        case .wednesday: return "weekday.long_wednesday".localized
        case .thursday: return "weekday.long_thursday".localized
        case .friday: return "weekday.long_friday".localized
        case .saturday: return "weekday.long_saturday".localized
        }
    }
    
    static let ordered: [Weekday] = [
        .monday,
        .tuesday,
        .wednesday,
        .thursday,
        .friday,
        .saturday,
        .sunday
    ]
    
    static func formattedWeekdays(_ days: [Weekday]) -> String {
        guard !days.isEmpty else { return "" }
        guard !(days.count == allCases.count) else { return "weekday.every_day".localized }
        
        let orderedDays = ordered.filter { days.contains($0) }
        let orderedDaysString = orderedDays.map { $0.shortString }.joined(separator: ", ")
        return orderedDaysString
    }
    
}
