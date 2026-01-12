import Foundation

final class CategoryListViewModel: CategoryListViewModelProtocol {
    
    // MARK: - Bindings
    
    var onUpdate: ((StoreUpdate) -> Void)?
    var onIsEmptyChanged: ((Bool) -> Void)?
    var onInitialSelection: (() -> Void)?
    
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
    
    func setInitialSelection(for category: TrackerCategory?) {
        guard let category,let index = findCategoryIndex(for: category) else {
            selectedIndexPath = nil
            return
        }
        selectedIndexPath = IndexPath(row: index, section: 0)
        DispatchQueue.main.async { [weak self] in
            self?.onInitialSelection?()
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
    
    private func findCategoryIndex(for category: TrackerCategory) -> Int? {
        return categories.firstIndex(where: { $0.id == category.id })
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
