import UIKit
import CoreData

enum TrackerCategoryStoreError: Error {
    case decodingErorInvalidId
    case decodingErrorInvalidTitle
    case decodingErrorInvalidCreatedAt
}

final class TrackerCategoryStore: NSObject {
    
    // MARK: - Delegate
    
    weak var delegate: TrackerCategoryStoreDelegate?
    
    // MARK: - Public Properties
    
    var trackerCategories: [TrackerCategory] {
        guard let objects = fetchedResultsController.fetchedObjects else { return [] }
        return objects.compactMap {
            do {
                return try makeTrackerCategory(from: $0)
            } catch {
                print(error)
                return nil
            }
        }
    }
    
    // MARK: - Private Properties
    
    private let context: NSManagedObjectContext
    
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<TrackerCategoryStoreUpdate.Move>?
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCategoryCoreData.createdAt, ascending: true)]
        
        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        controller.delegate = self
        do {
            try controller.performFetch()
        } catch {
            print("❌[fetchedResultsController.performFetch()] Failed to perform fetch: \(error)")
        }
        return controller
    }()
    
    // MARK: - Initializer
    
    convenience override init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate is unavailable")
        }
        let context = appDelegate.coreDataStack.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Public Methods
    
    func addNewTrackerCategory(_ category: TrackerCategory) throws {
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.id = category.id
        categoryCoreData.title = category.title
        categoryCoreData.createdAt = category.createdAt
        try context.save()
    }
    
    func trackerCategoryCoreData(by id: UUID) -> TrackerCategoryCoreData? {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.id), id.uuidString)
    }
    
    // MARK: - Private Methods
    
    private func makeTrackerCategory(from categoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let id = categoryCoreData.id else { throw TrackerCategoryStoreError.decodingErorInvalidId }
        guard let title = categoryCoreData.title else { throw TrackerCategoryStoreError.decodingErrorInvalidTitle }
        guard let createdAt = categoryCoreData.createdAt else { throw TrackerCategoryStoreError.decodingErrorInvalidCreatedAt }
        return TrackerCategory(
            id: id,
            title: title,
            createdAt: createdAt
        )
    }
    
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        movedIndexes = Set<TrackerCategoryStoreUpdate.Move>()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        guard
            let insertedIndexes = insertedIndexes,
            let deletedIndexes = deletedIndexes,
            let updatedIndexes = updatedIndexes,
            let movedIndexes = movedIndexes
        else {
            print(
                  """
                  ❌[controllerDidChangeContent]: some indexes are nil.
                  Indexes: inserted \(String(describing: insertedIndexes)), deleted \(String(describing: deletedIndexes)),
                  updated \(String(describing: updatedIndexes)), moved \(String(describing: movedIndexes))
                  """
            )
            return
        }
        
        delegate?.store(
            self,
            didUpdate: TrackerCategoryStoreUpdate(
                insertedIndexes: insertedIndexes,
                deletedIndexes: deletedIndexes,
                updatedIndexes: updatedIndexes,
                movedIndexes: movedIndexes
            )
        )
    }
    
    func controller(
        _ controller: NSFetchedResultsController<any NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { fatalError() }
            insertedIndexes?.insert(indexPath.item)
        case .delete:
            guard let indexPath = indexPath else { fatalError() }
            deletedIndexes?.insert(indexPath.item)
        case .update:
            guard let indexPath = indexPath else { fatalError() }
            updatedIndexes?.insert(indexPath.item)
        case .move:
            guard let oldIndexPath = indexPath, let newIndexPath = newIndexPath else { fatalError() }
            movedIndexes?.insert(.init(oldIndex: oldIndexPath.item, newIndex: newIndexPath.item))
        @unknown default:
            fatalError()
        }
    }
    
}
