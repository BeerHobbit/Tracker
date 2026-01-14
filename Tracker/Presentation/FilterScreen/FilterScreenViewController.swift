import UIKit

final class FilterScreenViewController: UIViewController {
    
    // MARK: - Views
    
    private lazy var filterListTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(FilterCell.self, forCellReuseIdentifier: FilterCell.reuseID)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = 75
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = false
        return tableView
    }()
    
    // MARK: - Bindings
    
    var onFilterSelection: ((FilterType) -> Void)?
    
    // MARK: - Private Properties
    
    private let filters: [FilterType] = [
        .allTrackers,
        .todayTrackers,
        .completedTrackers,
        .unfinishedTrackers
    ]
    
    private var selectedFilter: FilterType? {
        didSet {
            if let filter = selectedFilter,
               let onFilterSelection {
                onFilterSelection(filter)
            }
        }
    }
    
    // MARK: - Initializer
    
    init(selectedFilter: FilterType?, onFilterSelection: ((FilterType) -> Void)?) {
        self.selectedFilter = selectedFilter
        self.onFilterSelection = onFilterSelection
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("❌init(coder:) has not been implemented")
        return nil
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configDependencies()
        setupUI()
    }
    
    // MARK: - Configure Dependencies
    
    private func configDependencies() {
        filterListTableView.dataSource = self
        filterListTableView.delegate = self
    }
    
    // MARK: - SetupUI
    
    private func setupUI() {
        view.backgroundColor = .ypWhite
        view.addSubview(filterListTableView)
        
        setupNavigationBar()
        setupConstraints()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "filter_screen.navigation_title".localized
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.ypBlack,
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
        navigationItem.hidesBackButton = true
    }
    
    // MARK: - Setup Constraints
    
    private func setupConstraints() {
        [filterListTableView].disableAutoresizingMasks()
        
        NSLayoutConstraint.activate([
            filterListTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            filterListTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filterListTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            filterListTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
}

extension FilterScreenViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FilterCell.reuseID) as? FilterCell else {
            assertionFailure("❌[dequeueReusableCell]: can't dequeue reusable cell with id: \(FilterCell.reuseID) as \(String(describing: FilterCell.self))")
            return UITableViewCell()
        }
        let filter = filters[indexPath.row]
        let isSelected = filter == selectedFilter
        let isFirst = indexPath.row == 0
        let isLast = indexPath.row == filters.count - 1
        
        cell.configure(
            filter: filter,
            isSelected: isSelected,
            isFirst: isFirst,
            isLast: isLast
        )
        return cell
    }

}

extension FilterScreenViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedFilter = filters[indexPath.row]
        tableView.reloadData()
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        24
    }
    
}
