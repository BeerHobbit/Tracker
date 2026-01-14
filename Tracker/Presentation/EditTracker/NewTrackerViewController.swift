import UIKit

final class NewTrackerViewController: BaseEditTrackerViewController {
    
    // MARK: - Delegate
    
    weak var delegate: NewTrackerViewControllerDelegate?
    
    // MARK: Overrides
    
    override func setupUI() {
        super.setupUI()
        setTitles(
            navigationTitle: "new_tracker.navigation_title".localized,
            createButtonTitle: "new_tracker.create_button".localized
        )
    }
    
    override func didTapCreateButton() {
        delegate?.createTracker(from: state)
        dismiss(animated: true)
    }
    
}
