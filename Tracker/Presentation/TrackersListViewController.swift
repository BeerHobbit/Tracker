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
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        return datePicker
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.textColor = .datePickerBlack
        label.backgroundColor = .datePickerGray
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 8
        label.text = dateFormatter.string(from: datePicker.date)
        return label
    }()
    
    private lazy var dateContainerView: UIView = {
        let view = UIView()
        view.addSubview(datePicker)
        view.insertSubview(dateLabel, aboveSubview: datePicker)
        return view
    }()
    
    private let searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Поиск"
        return searchController
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
    
    // MARK: - Private Properties
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter
    }()
    
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = [] {
        didSet {
            emptyStateStackView.isHidden = visibleCategories.isEmpty ? true : false
        }
    }
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
            emptyStateStackView
        ])
        
        setupNavigationBar()
        setupConstraints()
        setupActions()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .foregroundColor: UIColor.ypBlack,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        navigationItem.title = "Трекеры"
        
        navigationItem.searchController = searchController
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: addTrackerButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: dateContainerView)
    }
    
    // MARK: - Setup Constraints
    
    private func setupConstraints() {
        disableAutoresizingMaskForSubviews()
        
        NSLayoutConstraint.activate([
            addTrackerButton.heightAnchor.constraint(equalToConstant: 42),
            addTrackerButton.widthAnchor.constraint(equalTo: addTrackerButton.heightAnchor),
            
            dateContainerView.heightAnchor.constraint(equalToConstant: 34),
            dateContainerView.widthAnchor.constraint(equalToConstant: 77),
            
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.widthAnchor.constraint(equalTo: emptyStateImageView.heightAnchor),
            emptyStateStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            emptyStateStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ])
        datePicker.edgesToSuperview()
        dateLabel.edgesToSuperview()
    }
    
    private func disableAutoresizingMaskForSubviews() {
        let views = [
            dateContainerView,
            emptyStateLabel,
            emptyStateImageView,
            emptyStateStackView
        ]
        views.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
    }
    
    // MARK: - Setup Actions
    
    private func setupActions() {
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
    }
    
    // MARK: - Actions
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        dateLabel.text = dateFormatter.string(from: selectedDate)
    }
    
}

