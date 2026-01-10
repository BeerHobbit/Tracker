import UIKit

final class TrackerListViewController: UIViewController {
    
    // MARK: - Views
    
    private lazy var addTrackerButton: UIButton = {
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
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        return searchController
    }()
    
    private lazy var emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .emptyState
        return imageView
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.textAlignment = .center
        return label
    }()
    
    private lazy var emptyStateStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [emptyStateImageView, emptyStateLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()
    
    private lazy var trackersCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseID)
        collectionView.register(TrackerCategoryHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackerCategoryHeader.reuseID)
        collectionView.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 50, right: 0)
        return collectionView
    }()
    
    private lazy var filterButton: UIButton = {
        let button = UIButton()
        button.setTitle("Фильтры", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.backgroundColor = .ypBlue
        
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        
        return button
    }()
    
    private lazy var emptySearchImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .emptySearch
        return imageView
    }()
    
    private lazy var emptySearchLabel: UILabel = {
        let label = UILabel()
        label.text = "Ничего не найдено"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.textAlignment = .center
        return label
    }()
    
    private lazy var emptySearchStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [emptySearchImageView, emptySearchLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.isHidden = true
        return stackView
    }()
    
    // MARK: - Private Properties
    
    private let trackerStore: TrackerStoreProtocol = TrackerStore()
    private let trackerRecordStore: TrackerRecordStoreProtocol = TrackerRecordStore()
    private var completedTrackers: Set<TrackerRecord> = []
    private var currentFilter: FilterType? {
        didSet {
            setWeekdayAndFilter()
        }
    }
    
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
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configDependencies()
        setupUI()
        loadTrackerRecords()
        setWeekdayAndFilter()
        updateEmptyState()
    }
    
    // MARK: - Configure Dependencies
    
    private func configDependencies() {
        trackersCollectionView.dataSource = self
        trackersCollectionView.delegate = self
        trackerStore.delegate = self
        searchController.searchResultsUpdater = self
        searchController.delegate = self
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.backgroundColor = .ypWhite
        view.addSubviews([
            emptyStateStackView,
            trackersCollectionView,
            filterButton,
            emptySearchStackView
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
        [
            dateContainerView,
            emptyStateLabel,
            emptyStateImageView,
            emptyStateStackView,
            trackersCollectionView,
            filterButton,
            emptySearchStackView
        ].disableAutoresizingMasks()
        
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
            emptyStateStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            emptySearchImageView.heightAnchor.constraint(equalToConstant: 80),
            emptySearchImageView.widthAnchor.constraint(equalTo: emptySearchImageView.heightAnchor),
            
            emptySearchStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            emptySearchStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ])
        datePicker.edgesToSuperview()
        dateLabel.edgesToSuperview()
    }
    
    // MARK: - Setup Actions
    
    private func setupActions() {
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        addTrackerButton.addTarget(self, action: #selector(addTrackerButtonDidTap), for: .touchUpInside)
        filterButton.addTarget(self, action: #selector(filterButtonDidTap), for: .touchUpInside)
        view.addGestureRecognizer(singleTapRecognizer())
    }
    
    // MARK: - Actions
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        updateCurrentWeekday(datePicker: sender)
    }
    
    @objc private func addTrackerButtonDidTap() {
        presentNewTrackerVC()
    }
    
    @objc private func filterButtonDidTap() {
        presentFilterScreenVC()
    }
    
    @objc private func didSingleTap() {
        navigationController?.view.endEditing(false)
    }
    
    // MARK: - Private Methods
    
    private func configureCell(_ cell: TrackerCell, at indexPath: IndexPath) {
        let tracker = trackerStore.tracker(at: indexPath)
        let isCompleted = isCompleted(id: tracker.id, for: datePicker.date)
        let quanity = getCurrentQuanity(id: tracker.id)
        cell.configure(from: tracker, isCompleted: isCompleted, quanity: quanity)
        cell.delegate = self
    }
    
    private func updateCurrentWeekday(datePicker: UIDatePicker) {
        let selectedDate = datePicker.date.excludeTime()
        let today = Date().excludeTime()
        if !selectedDate.isSameDay(as: today) && currentFilter == .todayTrackers {
            currentFilter = .allTrackers
        }
        dateLabel.text = dateFormatter.string(from: selectedDate)
        setWeekdayAndFilter()
    }
    
    private func presentNewTrackerVC() {
        let newTrackerVC = NewTrackerViewController()
        newTrackerVC.delegate = self
        let navigationVC = UINavigationController(rootViewController: newTrackerVC)
        navigationVC.modalPresentationStyle = .popover
        present(navigationVC, animated: true)
    }
    
    private func presentFilterScreenVC() {
        let filterScreenVC = FilterScreenViewController(
            selectedFilter: currentFilter,
            onFilterSelection: { [weak self] filter in
                self?.selectFilter(filter)
            })
        let navigationVC = UINavigationController(rootViewController: filterScreenVC)
        navigationVC.modalPresentationStyle = .popover
        present(navigationVC, animated: true)
    }
    
    private func selectFilter(_ filter: FilterType) {
        if filter == .todayTrackers {
            let today = Date().excludeTime()
            datePicker.date = today
            dateLabel.text = dateFormatter.string(from: today)
        }
        currentFilter = filter
    }
    
    private func setWeekdayAndFilter() {
        let date = datePicker.date.excludeTime()
        let weekday = getWeekday(from: date)
        let filter = currentFilter ?? .allTrackers
        trackerStore.setCurrentWeekdayAndFilter(
            weekday: weekday,
            filter: filter,
            date: date
        )
    }
    
    private func updateEmptyState() {
        emptyStateStackView.isHidden = !trackersCollectionView.isEmpty
        updateFilterButtonVisibility()
    }
    
    private func updateFilterButtonVisibility() {
        let date = datePicker.date.excludeTime()
        let weekday = getWeekday(from: date)
        let hasTrackers = trackerStore.hasTrackers(for: weekday)
        filterButton.isHidden = !hasTrackers
    }
    
    private func getWeekday(from date: Date) -> Weekday {
        let value = Calendar.current.component(.weekday, from: date)
        guard let weekday = Weekday(rawValue: value) else {
            assertionFailure("❌[getWeekday]: No such rawValue for Weekday")
            return Weekday.monday
        }
        return weekday
    }
    
    private func isCompleted(id: UUID, for date: Date) -> Bool {
        let record = TrackerRecord(trackerID: id, completionDate: date.excludeTime())
        return completedTrackers.contains(record)
    }
    
    private func toggleTracker(id: UUID, for date: Date) {
        let record = TrackerRecord(trackerID: id, completionDate: date.excludeTime())
        if completedTrackers.contains(record) {
            do {
                try trackerRecordStore.deleteTrackerRecord(record)
                loadTrackerRecords()
            } catch {
                print("❌[toggleTracker]: TrackerRecord was not removed")
                return
            }
        } else {
            do {
                try trackerRecordStore.addNewTrackerRecord(record)
                loadTrackerRecords()
            } catch {
                print("❌[toggleTracker]: New TrackerRecord was not added")
            }
        }
    }
    
    private func getCurrentQuanity(id: UUID) -> Int {
        completedTrackers.filter { $0.trackerID == id }.count
    }
    
    private func loadTrackerRecords() {
        completedTrackers = trackerRecordStore.trackerRecords
    }
    
    private func singleTapRecognizer() -> UITapGestureRecognizer {
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(didSingleTap))
        singleTap.numberOfTapsRequired = 1
        singleTap.cancelsTouchesInView = false
        return singleTap
    }
    
    private func updateSearchState() {
        let isEmpty = trackersCollectionView.isEmpty
        filterButton.isHidden = isEmpty
        emptySearchStackView.isHidden = !isEmpty
        emptyStateStackView.isHidden = true
    }
    
    private func resetSearchState() {
        emptySearchStackView.isHidden = true
        updateEmptyState()
    }
    
}

// MARK: - UICollectionViewDataSource

extension TrackerListViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        trackerStore.numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        trackerStore.numberOfItems(in: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = trackersCollectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.reuseID, for: indexPath) as? TrackerCell else {
            assertionFailure("❌[dequeueReusableCell]: Can't dequeue reusable cell with id: \(TrackerCell.reuseID) as \(String(describing: TrackerCell.self))")
            return UICollectionViewCell()
        }
        configureCell(cell, at: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TrackerCategoryHeader.reuseID,
            for: indexPath
        ) as? TrackerCategoryHeader else { return UICollectionReusableView() }
        
        let title = trackerStore.titleForSection(indexPath.section)
        header.configure(title: title)
        
        return header
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackerListViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - layoutParams.paddingWidth
        let cellWidth = availableWidth / CGFloat(layoutParams.cellCount)
        return CGSize(width: cellWidth, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 12, left: layoutParams.leftInset, bottom: 16, right: layoutParams.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        layoutParams.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let headerView = TrackerCategoryHeader(frame: CGRect(x: 0, y: 0, width: collectionView.frame.width, height: 0))
        let title = trackerStore.titleForSection(section)
        headerView.configure(title: title)
        
        let targetSize = headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width, height: UIView.layoutFittingExpandedSize.height))
        let size = CGSize(width: targetSize.width, height: targetSize.height)
        
        return size
    }
    
}

// MARK: - TrackerCellDelegate

extension TrackerListViewController: TrackerCellDelegate {
    
    func completeButtonDidTap(in cell: TrackerCell) {
        let currentDate = datePicker.date
        guard !currentDate.isFutureDate() else {
            presentSimpleAlert(
                title: "Не получится",
                message: "Нельзя отметить привычку для будущей даты",
                actionTitle: "Хорошо"
            )
            return
        }
        
        guard let indexPath = trackersCollectionView.indexPath(for: cell) else { return }
        let tracker = trackerStore.tracker(at: indexPath)
        toggleTracker(id: tracker.id, for: currentDate)
        UIView.performWithoutAnimation {
            trackersCollectionView.reloadItems(at: [indexPath])
        }
    }
    
}

// MARK: - NewTrackerViewControllerDelegate

extension TrackerListViewController: NewTrackerViewControllerDelegate {
    
    func createTracker(from config: NewTrackerState) {
        guard
            let color = config.color,
            let category = config.category
        else {
            print("❌[createTracker]: Color from config is nil")
            return
        }
        
        let tracker = Tracker(
            id: UUID(),
            title: config.title,
            color: color,
            emoji: config.emoji,
            schedule: config.schedule,
            createdAt: Date()
        )
        do {
            try trackerStore.addNewTracker(tracker, to: category)
        } catch {
            assertionFailure("❌[addNewTracker]: New tracker was not saved: \(error)")
        }
    }
    
}

// MARK: - TrackerStoreDelegate

extension TrackerListViewController: TrackerStoreDelegate {
    
    func store(_ store: TrackerStoreProtocol, didUpdate update: StoreUpdate) {
        trackersCollectionView.performBatchUpdates({
            let insertedSections = update.insertedSections
            let deletedSections = update.deletedSections
            let deletedIndexPaths = Array(update.deletedIndexPaths)
            let insertedIndexPaths = Array(update.insertedIndexPaths)
            let updatedIndexPaths = Array(update.updatedIndexPaths)
            
            trackersCollectionView.deleteSections(deletedSections)
            trackersCollectionView.insertSections(insertedSections)
            
            trackersCollectionView.deleteItems(at: deletedIndexPaths)
            trackersCollectionView.insertItems(at: insertedIndexPaths)
            trackersCollectionView.reloadItems(at: updatedIndexPaths)
            for move in update.movedIndexPaths {
                trackersCollectionView.moveItem(
                    at: move.oldIndexPath,
                    to: move.newIndexPath
                )
            }
        }, completion: { [weak self] _ in
            self?.updateEmptyState()
        })
    }
    
    func storeDidReloadFRC(_ store: TrackerStoreProtocol) {
        trackersCollectionView.reloadData()
        updateEmptyState()
    }
    
}

// MARK: - UISearchResultsUpdating

extension TrackerListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        trackerStore.setSearchText(searchText)
        updateSearchState()
    }
    
}

// MARK: - UISearchControllerDelegate

extension TrackerListViewController: UISearchControllerDelegate {
    
    func didDismissSearchController(_ searchController: UISearchController) {
        resetSearchState()
    }
    
}

#Preview {
    MainTabBarController()
}
