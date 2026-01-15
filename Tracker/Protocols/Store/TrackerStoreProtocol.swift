import Foundation

protocol TrackerStoreProtocol: AnyObject {
    
    var delegate: TrackerStoreDelegate? { get set }
    
    func setCurrentWeekdayAndFilter(weekday: Weekday?, filter: FilterType, date: Date)
    func setSearchText(_ text: String?)
    func addNewTracker(_ tracker: Tracker, to category: TrackerCategory) throws
    func deleteTracker(id: UUID) throws
    func numberOfSections() -> Int
    func titleForSection(_ section: Int) -> String
    func numberOfItems(in section: Int) -> Int
    func tracker(at indexPath: IndexPath) -> Tracker
    func category(of trackerID: UUID) -> TrackerCategory?
    func hasTrackers(for weekday: Weekday) -> Bool
    func changeTracker(with id: UUID, config: NewTrackerState) throws
    
}
