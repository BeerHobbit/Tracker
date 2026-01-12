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
            navigationTitle: "Редактирование привычки",
            createButtonTitle: "Сохранить"
        )
        let quantityString = getDayString(quantity)
        setQuantityForEditTracker(quantityString)
    }
    
    override func didTapCreateButton() {
        delegate?.changeTracker(id: tracker.id, with: state)
        dismiss(animated: true)
    }
    
    // MARK: - Private Methods
    
    private func getDayString(_ value: Int) -> String {
        let mod10 = value % 10
        let mod100 = value % 100
        
        let word: String = {
            switch (mod100, mod10) {
            case (11...14, _):
                return "дней"
            case (_, 1):
                return "день"
            case (_, 2...4):
                return "дня"
            default:
                return "дней"
            }
        }()
        
        return "\(value) \(word)"
    }
    
}
