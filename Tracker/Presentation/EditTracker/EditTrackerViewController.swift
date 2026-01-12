import UIKit

final class EditTrackerViewController: BaseEditTrackerViewController {
    
    // MARK: - Delegate
    
    weak var delegate: EditTrackerViewControllerDelegate?
    
    // MARK: - Private Properties
    
    private let tracker: Tracker
    private let quanity: Int
    
    // MARK: - Initializer
    
    init(tracker: Tracker, trackerCategory: TrackerCategory?, quanity: Int) {
        self.tracker = tracker
        self.quanity = quanity
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
    }
    
    override func didTapCreateButton() {
        delegate?.changeTracker(id: tracker.id, with: state)
        super.didTapCreateButton()
    }
    
}

#Preview {
    UINavigationController(
        rootViewController: EditTrackerViewController(
            tracker: Tracker(
                id: UUID(),
                title: "Погладить кошку",
                color: .colorSelection2,
                emoji: "😻",
                schedule: [.monday, .tuesday],
                createdAt: Date()
            ),
            trackerCategory: TrackerCategory(
                id: UUID(),
                title: "Категория 1",
                createdAt: Date()
            ), quanity: 5
        )
    )
}
