import UIKit

final class NewTrackerViewController: BaseEditTrackerViewController {
    
    // MARK: - Delegate
    
    weak var delegate: NewTrackerViewControllerDelegate?
    
    // MARK: Overrides
    
    override func setupUI() {
        super.setupUI()
        setTitles(
            navigationTitle: "Создание привычки",
            createButtonTitle: "Создать"
        )
    }
    
    override func didTapCreateButton() {
        delegate?.createTracker(from: state)
        dismiss(animated: true)
    }
    
}
