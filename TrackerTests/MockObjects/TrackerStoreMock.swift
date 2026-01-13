import UIKit
@testable import Tracker

final class TrackerStoreMock: TrackerStoreProtocol {
    var delegate: TrackerStoreDelegate?
    
    func setCurrentWeekdayAndFilter(weekday: Weekday?, filter: FilterType, date: Date) {
        
    }
    
    func setSearchText(_ text: String?) {
        
    }
    
    func addNewTracker(_ tracker: Tracker, to category: TrackerCategory) throws {
        
    }
    
    func deleteTracker(id: UUID) throws {
        
    }
    
    func numberOfSections() -> Int {
        1
    }
    
    func titleForSection(_ section: Int) -> String {
        "TestCategory"
    }
    
    func numberOfItems(in section: Int) -> Int {
        4
    }
    
    func tracker(at indexPath: IndexPath) -> Tracker {
        Tracker(
            id: UUID(),
            title: "TestTracker",
            color: .gray,
            emoji: "😻",
            schedule: [.monday, .tuesday, .wednesday,
                       .thursday, .friday, .saturday,
                       .sunday],
            createdAt: Date().excludeTime()
        )
    }
    
    func category(of trackerID: UUID) -> TrackerCategory? {
        TrackerCategory(
            id: UUID(),
            title: "TestCategory",
            createdAt: Date().excludeTime()
        )
    }
    
    func hasTrackers(for weekday: Weekday) -> Bool {
        true
    }
    
    func changeTracker(with id: UUID, config: NewTrackerState) throws {
        
    }
    
}
