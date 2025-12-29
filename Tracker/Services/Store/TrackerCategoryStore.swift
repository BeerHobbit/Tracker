import UIKit
import CoreData

enum TrackerCategoryStoreError: Error {
    case decodingErrorInvalidID
    case decodingErrorInvalidTitle
    case decodingErrorInvalidCreatedAt
}

final class TrackerCategoryStore: NSObject, TrackerCategoryStoreProtocol {
    
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
    
    private var inserted: Set<IndexPath>?
    private var deleted: Set<IndexPath>?
    private var updated: Set<IndexPath>?
    private var moved: Set<StoreUpdate.Move>?
    
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
            assertionFailure("❌[fetchedResultsController.performFetch()] Failed to perform fetch: \(error)")
        }
        return controller
    }()
    
    // MARK: - Initializer
    
    convenience override init() {
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
    
    func addNewTrackerCategory(_ category: TrackerCategory) throws {
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.categoryID = category.id
        categoryCoreData.title = category.title
        categoryCoreData.createdAt = category.createdAt
        try context.save()
    }
    
    // MARK: - Private Methods
    
    private func makeTrackerCategory(from categoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let id = categoryCoreData.categoryID else { throw TrackerCategoryStoreError.decodingErrorInvalidID }
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
        inserted = []
        deleted = []
        updated = []
        moved = Set<StoreUpdate.Move>()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        guard
            let insertedIndexPaths = inserted,
            let deletedIndexPaths = deleted,
            let updatedIndexPaths = updated,
            let movedIndexPaths = moved
        else {
            print(
                  """
                  ❌[controllerDidChangeContent]: some indexPaths are nil.
                  Indexes: inserted \(String(describing: inserted)), deleted \(String(describing: deleted)),
                  updated \(String(describing: updated)), moved \(String(describing: moved))
                  """
            )
            return
        }
        
        delegate?.store(
            self,
            didUpdate: StoreUpdate(
                insertedSections: [],
                deletedSections: [],
                insertedIndexPaths: insertedIndexPaths,
                deletedIndexPaths: deletedIndexPaths,
                updatedIndexPaths: updatedIndexPaths,
                movedIndexPaths: movedIndexPaths
            )
        )
        self.inserted = nil
        self.deleted = nil
        self.updated = nil
        self.moved = nil
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
            if let newIndexPath {
                inserted?.insert(newIndexPath)
            }
        case .delete:
            if let indexPath {
                deleted?.insert(indexPath)
            }
        case .update:
            if let indexPath {
                updated?.insert(indexPath)
            }
        case .move:
            if let oldIndexPath = indexPath, let newIndexPath = newIndexPath {
                moved?.insert(.init(oldIndexPath: oldIndexPath, newIndexPath: newIndexPath))
            }
        @unknown default:
            assertionFailure()
        }
    }
    
}
