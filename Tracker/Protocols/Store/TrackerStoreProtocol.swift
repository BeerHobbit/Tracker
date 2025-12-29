import Foundation

protocol TrackerStoreProtocol: AnyObject {
    
    var delegate: TrackerStoreDelegate? { get set }
    
    func setCurrentWeekday(_ weekday: Weekday?)
    func addNewTracker(_ tracker: Tracker, to category: TrackerCategory) throws
    func numberOfSections() -> Int
    func titleForSection(_ section: Int) -> String
    func numberOfItems(in section: Int) -> Int
    func tracker(at indexPath: IndexPath) -> Tracker
    
}
