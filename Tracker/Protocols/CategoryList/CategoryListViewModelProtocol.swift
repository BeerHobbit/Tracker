import Foundation

protocol CategoryListViewModelProtocol: AnyObject {
    
    var onUpdate: ((StoreUpdate) -> Void)? { get set }
    var onIsEmptyChanged: ((Bool) -> Void)? { get set }
    var onInitialSelection: (() -> Void)? { get set }
    var selectedIndexPath: IndexPath? { get set }
    var categories: [TrackerCategory] { get }
    
    func selectCategory(at indexPath: IndexPath)
    func createCategory(title: String)
    func setInitialSelection(for category: TrackerCategory?)
    
}
