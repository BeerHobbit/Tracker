protocol TrackerRecordStoreProtocol: AnyObject {
    
    var trackerRecords: Set<TrackerRecord> { get }
    
    func addNewTrackerRecord(_ record: TrackerRecord) throws
    func deleteTrackerRecord(_ record: TrackerRecord) throws
    
}
