import UIKit

final class EditTrackerViewController: BaseEditTrackerViewController {
    
    // MARK: - Delegate
    
    weak var delegate: EditTrackerViewControllerDelegate?
    
    // MARK: - Private Properties
    
    private let tracker: Tracker
    private let quantity: Int
    
    // MARK: - Initializer
    
    init(tracker: Tracker, trackerCategory: TrackerCategory?, quantity: Int) {
        self.tracker = tracker
        self.quantity = quantity
        super.init(nibName: nil, bundle: nil)
        state = NewTrackerState(
            title: tracker.title,
            category: trackerCategory,
            schedule: tracker.schedule,
            emoji: tracker.emoji,
            color: tracker.color
        )
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("❌init(coder:) has not been implemented")
        return nil
    }
    
    // MARK: - Overrides
    
    override func setupUI() {
        super.setupUI()
        setTitles(
            navigationTitle: "edit_tracker.navigation_title".localized,
            createButtonTitle: "edit_tracker.create_button".localized
        )
        let quantityString = String.localizedStringWithFormat(
            NSLocalizedString("days_quantity", comment: ""),
            quantity
        )
        setQuantityForEditTracker(quantityString)
    }
    
    override func didTapCreateButton() {
        delegate?.changeTracker(id: tracker.id, with: state)
        dismiss(animated: true)
    }
    
}
