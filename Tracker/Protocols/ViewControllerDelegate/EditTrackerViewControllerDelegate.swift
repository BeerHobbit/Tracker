import Foundation

protocol EditTrackerViewControllerDelegate: AnyObject {
    func changeTracker(id: UUID, with config: NewTrackerState)
}
