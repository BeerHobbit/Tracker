protocol TrackerStoreDelegate: AnyObject {
    func store(_ store: TrackerStore, didUpdate update: StoreUpdate)
    func storeDidReloadFRC(_ store: TrackerStore)
}
