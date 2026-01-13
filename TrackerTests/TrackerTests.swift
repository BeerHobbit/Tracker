import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {

    func testTrackerListViewControllerLightTheme() {
        let vc = TrackerListViewController(
            trackerStore: TrackerStoreMock(),
            trackerRecordStore: TrackerRecordStoreMock()
        )
        
        assertSnapshot(of: vc, as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .light)), record: false)
    }
    
    func testTrackerListViewControllerDarkTheme() {
        let vc = TrackerListViewController(
            trackerStore: TrackerStoreMock(),
            trackerRecordStore: TrackerRecordStoreMock()
        )
        
        assertSnapshot(of: vc, as: .image(on: .iPhone13, traits: .init(userInterfaceStyle: .dark)), record: false)
    }

}
