import Foundation
@testable import Tracker

final class TrackerRecordStoreMock: TrackerRecordStoreProtocol {
    
    var trackerRecords: Set<TrackerRecord> = []
    
    func addNewTrackerRecord(_ record: TrackerRecord) throws {
        
    }
    
    func deleteTrackerRecord(_ record: TrackerRecord) throws {
        
    }
    
}
