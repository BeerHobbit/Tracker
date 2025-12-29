import UIKit
import CoreData

enum TrackerRecordStoreError: Error {
    case decodingErrorInvalidCompletionDate
    case decodingErrorInvalidTrackerID
}

final class TrackerRecordStore: TrackerRecordStoreProtocol {
    
    // MARK: - Public Properties
    
    var trackerRecords: Set<TrackerRecord> {
        let request = TrackerRecordCoreData.fetchRequest()
        guard let objects = try? context.fetch(request) else { return [] }
        let records = objects.compactMap {
            do {
                return try makeTrackerRecord(from: $0)
            } catch {
                print(error)
                return nil
            }
        }
        return Set(records)
    }
    
    // MARK: - Private Properties
    
    private let context: NSManagedObjectContext
    
    // MARK: - Initializer
    
    convenience init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("❌AppDelegate is unavailable")
        }
        let context = appDelegate.coreDataStack.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Public Methods
    
    func addNewTrackerRecord(_ record: TrackerRecord) throws {
        guard let trackerCoreData = findTracker(by: record.trackerID) else { throw TrackerRecordStoreError.decodingErrorInvalidTrackerID }
        
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        trackerRecordCoreData.completionDate = record.completionDate
        trackerRecordCoreData.tracker = trackerCoreData
        
        try context.save()
    }
    
    func deleteTrackerRecord(_ record: TrackerRecord) throws {
        guard let recordToDelete = findRecord(from: record) else {
            print("❌[findRecord]: failed to find record in database")
            return
        }
        context.delete(recordToDelete)
        try context.save()
    }
    
    // MARK: - Private Methods
    
    private func makeTrackerRecord(from trackerRecordCoreData: TrackerRecordCoreData) throws -> TrackerRecord {
        guard let trackerID = trackerRecordCoreData.tracker?.trackerID else { throw TrackerRecordStoreError.decodingErrorInvalidTrackerID}
        guard let completionDate = trackerRecordCoreData.completionDate else { throw TrackerRecordStoreError.decodingErrorInvalidCompletionDate }
        return TrackerRecord(trackerID: trackerID, completionDate: completionDate)
    }
    
    private func findTracker(by id: UUID) -> TrackerCoreData? {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCoreData.trackerID), id as CVarArg)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }
    
    private func findRecord(from record: TrackerRecord) -> TrackerRecordCoreData? {
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "%K == %@", #keyPath(TrackerRecordCoreData.tracker.trackerID), record.trackerID as CVarArg),
            NSPredicate(format: "%K == %@", #keyPath(TrackerRecordCoreData.completionDate), record.completionDate as CVarArg)
        ])
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }
    
}
