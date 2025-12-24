protocol TrackerStoreDelegate: AnyObject {
    func store(_ store: TrackerStoreProtocol, didUpdate update: StoreUpdate)
    func storeDidReloadFRC(_ store: TrackerStoreProtocol)
}
