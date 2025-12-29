protocol TrackerCategoryStoreDelegate: AnyObject {
    func store(_ store: TrackerCategoryStoreProtocol, didUpdate update: StoreUpdate)
}
