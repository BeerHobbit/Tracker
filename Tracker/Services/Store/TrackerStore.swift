import UIKit
import CoreData

enum TrackerStoreError: Error {
    case decodingErrorInvalidID
    case decodingErrorInvalidTitle
    case decodingErrorInvalidEmoji
    case decodingErrorInvalidCreatedAt
    case decodingErrorInvalidColor
}

final class TrackerStore: NSObject, TrackerStoreProtocol {
    
    // MARK: - Delegate
    
    weak var delegate: TrackerStoreDelegate?
    
    // MARK: - Private Properties
    
    private let context: NSManagedObjectContext
    
    private var currentWeekday: Weekday?
    private var currentFilter: FilterType? = .allTrackers
    private var currentSearchText: String? = nil
    private var _currentDate: Date?
    private var currentDate: Date? {
        get {
            _currentDate
        }
        set {
            guard let newValue else {
                _currentDate = nil
                return
            }
            _currentDate = newValue.excludeTime()
        }
    }
    
    private var insertedSections: IndexSet?
    private var deletedSections: IndexSet?
    private var inserted: Set<IndexPath>?
    private var deleted: Set<IndexPath>?
    private var updated: Set<IndexPath>?
    private var moved: Set<StoreUpdate.Move>?
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        updateFetchResultsController()
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
    
    func setCurrentWeekdayAndFilter(weekday: Weekday?, filter: FilterType, date: Date) {
        currentWeekday = weekday
        currentFilter = filter
        currentDate = date
        fetchedResultsController = updateFetchResultsController()
        delegate?.storeDidReloadFRC(self)
    }
    
    func setSearchText(_ text: String?) {
        currentSearchText = text
        fetchedResultsController = updateFetchResultsController()
        delegate?.storeDidReloadFRC(self)
    }
    
    func addNewTracker(_ tracker: Tracker, to category: TrackerCategory) throws {
        guard let categoryCoreData = findCategory(by: category.id) else { throw TrackerCategoryStoreError.decodingErrorInvalidID }
        
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.trackerID = tracker.id
        trackerCoreData.title = tracker.title
        trackerCoreData.color = tracker.color
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.createdAt = tracker.createdAt

        trackerCoreData.category = categoryCoreData
        categoryCoreData.addToTrackers(trackerCoreData)
        
        addSchedule(tracker.schedule, to: trackerCoreData)
        
        try context.save()
    }
    
    func numberOfSections() -> Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func titleForSection(_ section: Int) -> String {
        fetchedResultsController.sections?[section].name ?? ""
    }
    
    func numberOfItems(in section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tracker(at indexPath: IndexPath) -> Tracker {
        let object = fetchedResultsController.object(at: indexPath)
        do {
            return try makeTracker(from: object)
        } catch {
            assertionFailure("❌[makeTracker]: Failed to decode Tracker: \(error)")
            return Tracker(id: UUID(), title: "", color: .colorSelection1, emoji: "", schedule: [], createdAt: Date())
        }
    }
    
    func hasTrackers(for weekday: Weekday) -> Bool {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = makeWeekdayPredicate(weekday: weekday)
        request.fetchLimit = 1
        let count = (try? context.count(for: request)) ?? 0
        return count > 0
    }
    
    // MARK: - Private Methods
    
    private func makeTracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
        guard let id = trackerCoreData.trackerID else { throw TrackerStoreError.decodingErrorInvalidID }
        guard let title = trackerCoreData.title else { throw TrackerStoreError.decodingErrorInvalidTitle }
        guard let color = trackerCoreData.color as? UIColor else { throw TrackerStoreError.decodingErrorInvalidColor }
        guard let emoji = trackerCoreData.emoji else { throw TrackerStoreError.decodingErrorInvalidEmoji }
        guard let createdAt = trackerCoreData.createdAt else { throw TrackerStoreError.decodingErrorInvalidCreatedAt }
        let schedule = getSchedule(from: trackerCoreData)
        return Tracker(
            id: id,
            title: title,
            color: color,
            emoji: emoji,
            schedule: schedule,
            createdAt: createdAt
        )
    }
    
    private func findCategory(by id: UUID) -> TrackerCategoryCoreData? {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.categoryID), id as CVarArg)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }
    
    private func addSchedule(_ schedule: Set<Weekday>, to tracker: TrackerCoreData) {
        for weekday in schedule {
            let request = WeekdayCoreData.fetchRequest()
            request.predicate = NSPredicate(format: "%K == %d", #keyPath(WeekdayCoreData.rawValue), weekday.rawValue)
            request.fetchLimit = 1
            let weekdayCoreData = (try? context.fetch(request).first) ?? WeekdayCoreData(context: context)
            weekdayCoreData.rawValue = Int16(weekday.rawValue)
            
            weekdayCoreData.addToTrackers(tracker)
            tracker.addToSchedule(weekdayCoreData)
        }
    }
    
    private func getSchedule(from tracker: TrackerCoreData) -> Set<Weekday> {
        guard let schedule = tracker.schedule as? Set<WeekdayCoreData> else { return [] }
        return Set(schedule.compactMap { Weekday(rawValue: Int($0.rawValue)) })
    }
    
    private func resetTracking() {
        self.insertedSections = nil
        self.deletedSections = nil
        self.inserted = nil
        self.deleted = nil
        self.updated = nil
        self.moved = nil
    }
    
    private func makeFetchRequest() -> NSFetchRequest<TrackerCoreData> {
        let request = TrackerCoreData.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.category?.title, ascending: true),
            NSSortDescriptor(keyPath: \TrackerCoreData.createdAt, ascending: true)
        ]
        
        var predicates: [NSPredicate] = []
        
        if let currentWeekday {
            predicates.append(makeWeekdayPredicate(weekday: currentWeekday))
        }
        if let currentFilter, let currentDate {
            predicates.append(makeFilterPredicate(filter: currentFilter, date: currentDate))
        }
        if let currentSearchText, !currentSearchText.isEmpty {
            predicates.append(makeSearchPredicate(searchText: currentSearchText))
        }
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        return request
    }
    
    private func makeWeekdayPredicate(weekday: Weekday) -> NSPredicate {
        return NSPredicate(
            format: "ANY %K == %d",
            #keyPath(TrackerCoreData.schedule.rawValue), weekday.rawValue
        )
    }
    
    private func makeFilterPredicate(filter: FilterType, date: Date) -> NSPredicate {
        switch filter {
        case .allTrackers:
            return NSPredicate(value: true)
            
        case .todayTrackers:
            return NSPredicate(value: true)
            
        case .completedTrackers:
            return NSPredicate(
                format: "ANY %K == %@",
                #keyPath(TrackerCoreData.record.completionDate), date as NSDate
            )
            
        case .unfinishedTrackers:
            return NSPredicate(
                format: "SUBQUERY(%K, $r, $r.completionDate == %@).@count == 0",
                #keyPath(TrackerCoreData.record), date as NSDate
            )
        }
    }
    
    private func makeSearchPredicate(searchText: String) -> NSPredicate {
        return NSPredicate(
            format: "%K CONTAINS[cd] %@",
            #keyPath(TrackerCoreData.title), searchText
        )
    }
    
    private func updateFetchResultsController() -> NSFetchedResultsController<TrackerCoreData> {
        let request = makeFetchRequest()
        let newController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: #keyPath(TrackerCoreData.category.title),
            cacheName: nil
        )
        newController.delegate = self
        do {
            try newController.performFetch()
        } catch {
            assertionFailure("❌[fetchedResultsController.performFetch()] Failed to perform fetch: \(error)")
        }
        return newController
    }
    
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerStore: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        insertedSections = IndexSet()
        deletedSections = IndexSet()
        inserted = []
        deleted = []
        updated = []
        moved = Set<StoreUpdate.Move>()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        guard
            let insertedSections = insertedSections,
            let deletedSections = deletedSections,
            let insertedIndexPaths = inserted,
            let deletedIndexPaths = deleted,
            let updatedIndexPaths = updated,
            let movedIndexPaths = moved
        else {
            print(
                  """
                  ❌[controllerDidChangeContent]: some indexes are nil.
                  Indexes: insertedSections \(String(describing: insertedSections)), deletedSections \(String(describing: deletedSections)),
                  inserted \(String(describing: inserted)), deleted \(String(describing: deleted)),
                  updated \(String(describing: updated)), moved \(String(describing: moved))
                  """
            )
            return
        }
        
        delegate?.store(
            self,
            didUpdate: StoreUpdate(
                insertedSections: insertedSections,
                deletedSections: deletedSections,
                insertedIndexPaths: insertedIndexPaths,
                deletedIndexPaths: deletedIndexPaths,
                updatedIndexPaths: updatedIndexPaths,
                movedIndexPaths: movedIndexPaths
            )
        )
        resetTracking()
    }
    
    func controller(
        _ controller: NSFetchedResultsController<any NSFetchRequestResult>,
        didChange sectionInfo: any NSFetchedResultsSectionInfo,
        atSectionIndex sectionIndex: Int,
        for type: NSFetchedResultsChangeType
    ) {
        switch type {
        case .insert:
            insertedSections?.insert(sectionIndex)
        case .delete:
            deletedSections?.insert(sectionIndex)
        default:
            break
        }
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
            break
        }
    }
    
}
