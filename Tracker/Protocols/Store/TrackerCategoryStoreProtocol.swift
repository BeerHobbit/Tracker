protocol TrackerCategoryStoreProtocol: AnyObject {
    
    var delegate: TrackerCategoryStoreDelegate? { get set }
    var trackerCategories: [TrackerCategory] { get }
    
    func addNewTrackerCategory(_ category: TrackerCategory) throws
    
}
