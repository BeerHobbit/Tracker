import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    
    // MARK: - LifeCycle
    
    override func setUp() {
        super.setUp()
        isRecording = false
    }
    
    // MARK: - Tests

    func testTrackerListViewControllerLightTheme() {
        let vc = makeViewController()
        let traits = UITraitCollection(userInterfaceStyle: .light
        )
        assertSnapshot(
            of: vc,
            as: .image(on: .iPhone13, traits: traits),
        )
    }
    
    func testTrackerListViewControllerDarkTheme() {
        let vc = makeViewController()
        let traits = UITraitCollection(userInterfaceStyle: .dark
        )
        assertSnapshot(
            of: vc,
            as: .image(on: .iPhone13, traits: traits),
        )
    }
    
    // MARK: - Helpers
    
    private func makeViewController() -> UIViewController {
        TrackerListViewController(
            trackerStore: TrackerStoreMock(),
            trackerRecordStore: TrackerRecordStoreMock()
        )
    }

}
