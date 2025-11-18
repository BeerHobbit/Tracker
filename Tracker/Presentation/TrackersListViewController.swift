import UIKit

final class TrackersListViewController: UIViewController {
    
    // MARK: - Views
    
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
    
    private let trackersCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseID)
        collectionView.register(TrackerCategoryHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackerCategoryHeader.reuseID)
        collectionView.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
        return collectionView
    }()
    
    // MARK: - Private Properties
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter
    }()
    
    private let layoutParams = LayoutParams(
        cellCount: 2,
        leftInset: 16,
        rightInset: 16,
        cellSpacing: 10
    )
    
    private var categories: [TrackerCategory] = [
        TrackerCategory(
            title: "Важное",
            trackers: [
                Tracker(id: UUID(), title: "Помыть посуду", color: .colorSelection3, emoji: "🤔", schedule: [.monday, .tuesday]),
                Tracker(id: UUID(), title: "Приготовить фобо", color: .colorSelection1, emoji: "🍲", schedule: [.tuesday, .wednesday]),
                Tracker(id: UUID(), title: "Поспать", color: .colorSelection5, emoji: "😴", schedule: [.wednesday, .thursday]),
            ]
        ),
        TrackerCategory(
            title: "Бумажное",
            trackers: [
                Tracker(id: UUID(), title: "Погладить кошку", color: .colorSelection14, emoji: "😸", schedule: [.thursday, .friday]),
                Tracker(id: UUID(), title: "Посмотреть брейнрот", color: .colorSelection15, emoji: "🧠", schedule: [.friday, .saturday]),
                Tracker(id: UUID(), title: "Заказать пиццу", color: .colorSelection5, emoji: "🍕", schedule: [.saturday, .sunday]),
            ]
        )
    ]
    
    private var visibleCategories: [TrackerCategory] = [] {
        didSet {
            updateEmptyState()
        }
    }
    
    private var completedTrackers: [TrackerRecord] = []
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configDependencies()
        setupUI()
        filterTrackers(for: datePicker.date)
        updateEmptyState()
    }
    
    // MARK: - Configure Dependencies
    
    private func configDependencies() {
        trackersCollectionView.dataSource = self
        trackersCollectionView.delegate = self
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .ypWhite
        view.addSubviews([
            emptyStateStackView,
            trackersCollectionView,
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
        disableAutoresizingMaskForViews([
            dateContainerView,
            emptyStateLabel,
            emptyStateImageView,
            emptyStateStackView,
            trackersCollectionView
        ])
        
        NSLayoutConstraint.activate([
            addTrackerButton.heightAnchor.constraint(equalToConstant: 42),
            addTrackerButton.widthAnchor.constraint(equalTo: addTrackerButton.heightAnchor),
            
            dateContainerView.heightAnchor.constraint(equalToConstant: 34),
            dateContainerView.widthAnchor.constraint(equalToConstant: 77),
            
            trackersCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            trackersCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            trackersCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            trackersCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.widthAnchor.constraint(equalTo: emptyStateImageView.heightAnchor),
            emptyStateStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            emptyStateStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ])
        datePicker.edgesToSuperview()
        dateLabel.edgesToSuperview()
    }
    
    // MARK: - Setup Actions
    
    private func setupActions() {
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
    }
    
    // MARK: - Actions
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        dateLabel.text = dateFormatter.string(from: selectedDate)
        filterTrackers(for: selectedDate)
    }
    
    // MARK: - Private Methods
    
    private func updateEmptyState() {
        emptyStateStackView.isHidden = !visibleCategories.isEmpty
    }
    
    private func filterTrackers(for date: Date) {
        let weekday = getWeekday(from: date)
        filterTrackers(for: weekday)
    }
    
    private func getWeekday(from date: Date) -> Weekday {
        let value = Calendar.current.component(.weekday, from: date)
        guard let weekday = Weekday(rawValue: value) else {
            assertionFailure("❌[getWeekday]: no such rawValue for Weekday")
            return Weekday.monday
        }
        return weekday
    }
    
    private func filterTrackers(for weekday: Weekday) {
        var filteredCategories = categories
        for index in filteredCategories.indices {
            filteredCategories[index].trackers = filteredCategories[index].trackers.filter { $0.schedule.contains(weekday) }
        }
        filteredCategories = filteredCategories.filter { !$0.trackers.isEmpty }
        visibleCategories = filteredCategories
        trackersCollectionView.reloadData()
    }
    
}

// MARK: - UICollectionViewDataSource

extension TrackersListViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let category = visibleCategories[section]
        return category.trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = trackersCollectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.reuseID, for: indexPath) as? TrackerCell else { return UICollectionViewCell() }
        
        let category = visibleCategories[indexPath.section]
        let tracker = category.trackers[indexPath.item]
        cell.configure(from: tracker)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TrackerCategoryHeader.reuseID,
            for: indexPath
        ) as? TrackerCategoryHeader else { return UICollectionReusableView() }
        
        let category = visibleCategories[indexPath.section]
        header.configure(category: category)
        
        return header
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackersListViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - layoutParams.paddingWidth
        let cellWidth = availableWidth / CGFloat(layoutParams.cellCount)
        return CGSize(width: cellWidth, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: layoutParams.leftInset, bottom: 16, right: layoutParams.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let headerView = TrackerCategoryHeader(frame: CGRect(x: 0, y: 0, width: collectionView.frame.width, height: 0))
        headerView.configure(category: visibleCategories[section])
        
        let targetSize = headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width, height: UIView.layoutFittingExpandedSize.height))
        let size = CGSize(width: targetSize.width, height: targetSize.height)
        
        return size
    }
    
    
}
/*
#Preview {
    MainTabBarController()
}
*/
