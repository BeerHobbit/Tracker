import UIKit

final class TrackersListViewController: UIViewController {
    
    // MARK: - Views and Guides
    
    private let addTrackerButton: UIButton = {
        let button = UIButton()
        let image = UIImage.addTracker.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .ypBlack
        return button
    }()
    
    private let datePickerButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.setTitleColor(.ypBlack.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light)), for: .normal)
        button.backgroundColor = .datePickerGray
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 8
        return button
    }()
    
    private lazy var topElementsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [addTrackerButton, UIView(), datePickerButton])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()
    
    private let trackersLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .ypBlack
        return label
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Поиск"
        return searchBar
    }()
    
    private let emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .emptyState
        return imageView
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        return label
    }()
    
    private lazy var emptyStateStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [emptyStateImageView, emptyStateLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()
    
    private let emptyStateGuide = UILayoutGuide()
    
    // MARK: - Private Properties
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter
    }()
    
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .ypWhite
        view.addSubviews([
            topElementsStackView,
            trackersLabel,
            searchBar,
            emptyStateStackView
        ])
        view.addLayoutGuide(emptyStateGuide)
        setDatePickerText()
        setupConstraints()
    }
    
    private func setDatePickerText() {
        let dateString = dateFormatter.string(from: Date())
        datePickerButton.setTitle(dateString, for: .normal)
    }
    
    // MARK: - Setup Constraints
    
    private func setupConstraints() {
        disableAutoresizingMaskForSubviews()
        
        NSLayoutConstraint.activate([
            addTrackerButton.heightAnchor.constraint(equalToConstant: 42),
            addTrackerButton.widthAnchor.constraint(equalToConstant: 42),
            
            datePickerButton.heightAnchor.constraint(equalToConstant: 34),
            datePickerButton.widthAnchor.constraint(equalToConstant: 77),
            
            topElementsStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),
            topElementsStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 6),
            topElementsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            trackersLabel.topAnchor.constraint(equalTo: topElementsStackView.bottomAnchor, constant: 1),
            trackersLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            trackersLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            searchBar.topAnchor.constraint(equalTo: trackersLabel.bottomAnchor, constant: 7),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            emptyStateGuide.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            emptyStateGuide.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            emptyStateStackView.centerYAnchor.constraint(equalTo: emptyStateGuide.centerYAnchor),
            emptyStateStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    // MARK: - Setup Actions
    
    // MARK: - Actions
    
    // MARK: - Private Methods
    
    private func disableAutoresizingMaskForSubviews() {
        let views = [
            addTrackerButton,
            datePickerButton,
            topElementsStackView,
            trackersLabel,
            searchBar,
            emptyStateStackView,
            emptyStateImageView,
            emptyStateLabel
        ]
        views.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
    }
    
}

