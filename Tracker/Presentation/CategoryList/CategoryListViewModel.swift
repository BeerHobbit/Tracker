import Foundation

final class CategoryListViewModel: CategoryListViewModelProtocol {
    
    // MARK: - Bindings
    
    var onUpdate: ((StoreUpdate) -> Void)?
    var onIsEmptyChanged: ((Bool) -> Void)?
    
    // MARK: - Public Properties
    
    private(set) var categories: [TrackerCategory] = [] {
        didSet {
            let isEmpty = categories.isEmpty
            if oldValue.isEmpty != isEmpty {
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.onIsEmptyChanged?(isEmpty)
                }
            }
        }
    }
    
    var selectedIndexPath: IndexPath?
    
    // MARK: - Private Properties
    
    private let store: TrackerCategoryStoreProtocol
    
    // MARK: - Initializer
    
    init(store: TrackerCategoryStoreProtocol) {
        self.store = store
        configDependencies()
        loadCategories()
    }
    
    // MARK: - Public Methods
    
    func selectCategory(at indexPath: IndexPath) {
        selectedIndexPath = indexPath
    }
    
    func createCategory(title: String) {
        let newCategory = TrackerCategory(id: UUID(), title: title, createdAt: Date())
        do {
            try store.addNewTrackerCategory(newCategory)
        } catch {
            assertionFailure("❌[addNewTrackerCategory]: can't add new object to TrackerCategoryCoreData, error: \(error)")
        }
    }
    
    // MARK: - Configure Dependencies
    
    private func configDependencies() {
        store.delegate = self
    }
    
    // MARK: - Private Methods
    
    private func loadCategories() {
        categories = store.trackerCategories
    }
    
}

// MARK: - TrackerCategoryStoreDelegate

extension CategoryListViewModel: TrackerCategoryStoreDelegate {
    
    func store(_ store: TrackerCategoryStoreProtocol, didUpdate update: StoreUpdate) {
        categories = store.trackerCategories
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.onUpdate?(update)
        }
    }
    
}
