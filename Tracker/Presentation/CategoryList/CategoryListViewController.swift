import UIKit

final class CategoryListViewController: UIViewController {
    
    // MARK: - Delegate
    
    weak var delegate: CategoryListViewControllerDelegate?
    
    // MARK: - Views and Layout guides
    
    private lazy var emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .emptyState
        return imageView
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Привычки и события можно объединить по смыслу"
        label.numberOfLines = 2
        label.textAlignment = .center
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
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton()
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypBlack
        
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        
        return button
    }()
    
    private lazy var categoriesTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .clear
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.reuseID)
        tableView.separatorStyle = .none
        tableView.rowHeight = 75
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = false
        return tableView
    }()
    
    private let emptyStateGuide = UILayoutGuide()
    
    // MARK: - Private Properties
    
    private let trackerCategoryStore = TrackerCategoryStore()
    
    private var categories: [TrackerCategory] = [] {
        didSet {
            updateEmptyState()
        }
    }
    
    private var selectedIndexPath: IndexPath?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configDependencies()
        setupUI()
        loadCategories()
        updateEmptyState()
    }
    
    // MARK: - Configure Dependencies
    
    private func configDependencies() {
        categoriesTableView.dataSource = self
        categoriesTableView.delegate = self
        
        trackerCategoryStore.delegate = self
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.backgroundColor = .ypWhite
        
        view.addSubviews([
            emptyStateStackView,
            addCategoryButton,
            categoriesTableView
        ])
        view.addLayoutGuide(emptyStateGuide)
        
        setupNavigationBar()
        setupConstraints()
        setupActions()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Категория"
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.ypBlack,
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
        navigationItem.hidesBackButton = true
    }
    
    // MARK: - Setup Constraints
    
    private func setupConstraints() {
        [
            emptyStateLabel,
            emptyStateImageView,
            emptyStateStackView,
            addCategoryButton,
            categoriesTableView
        ].disableAutoresizingMasks()
        
        NSLayoutConstraint.activate([
            emptyStateGuide.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyStateGuide.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor),
            
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.widthAnchor.constraint(equalTo: emptyStateImageView.heightAnchor),
            
            emptyStateLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 200),
            
            emptyStateStackView.centerYAnchor.constraint(equalTo: emptyStateGuide.centerYAnchor),
            emptyStateStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            categoriesTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            categoriesTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            categoriesTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            categoriesTableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -16)
        ])
    }
    
    // MARK: - Setup Actions
    
    private func setupActions() {
        addCategoryButton.addTarget(self, action: #selector(didTapAddCategoryButton), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func didTapAddCategoryButton() {
        let newCategoryVC = NewCategoryViewController()
        newCategoryVC.delegate = self
        navigationController?.pushViewController(newCategoryVC, animated: true)
    }
    
    // MARK: - Private Methods
    
    private func loadCategories() {
        categories = trackerCategoryStore.trackerCategories
    }
    
    private func updateEmptyState() {
        emptyStateStackView.isHidden = !categories.isEmpty
    }
    
}

extension CategoryListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.reuseID) as? CategoryCell else {
            assertionFailure("❌[dequeueReusableCell]: can't dequeue reusable cell with id: \(CategoryCell.reuseID) as \(String(describing: CategoryCell.self))")
            return UITableViewCell()
        }
        let title = categories[indexPath.row].title
        let isSelected = indexPath == selectedIndexPath
        let isFirst = indexPath.row == 0
        let isLast = indexPath.row == categories.count - 1
        
        cell.configure(title: title, isSelected: isSelected, isFirst: isFirst, isLast: isLast)
        return cell
    }
    
}

extension CategoryListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let oldIndexPath = selectedIndexPath
        selectedIndexPath = indexPath
        
        var indexPathsToReload: [IndexPath] = [indexPath]
        if let oldIndexPath = oldIndexPath, oldIndexPath != indexPath {
            indexPathsToReload.append(oldIndexPath)
        }
        tableView.reloadRows(at: indexPathsToReload, with: .none)
        
        let category = categories[indexPath.row]
        delegate?.categoryListVC(didSelectCategory: category)
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 24
    }
    
}

extension CategoryListViewController: NewCategoryViewControllerDelegate {
    
    func didCreateNewCategory(title: String) {
        let newCategory = TrackerCategory(id: UUID(), title: title, createdAt: Date())
        do {
            try trackerCategoryStore.addNewTrackerCategory(newCategory)
        } catch {
            assertionFailure("❌[addNewTrackerCategory]: can't add new object to TrackerCategoryCoreData, error: \(error)")
        }
    }
    
}

extension CategoryListViewController: TrackerCategoryStoreDelegate {
    
    func store(_ store: TrackerCategoryStore, didUpdate update: TrackerCategoryStoreUpdate) {
        categories = store.trackerCategories
        
        categoriesTableView.performBatchUpdates {
            let deletedIndexPaths = update.deletedIndexes.map { IndexPath(row: $0, section: 0) }
            let insertedIndexPaths = update.insertedIndexes.map { IndexPath(row: $0, section: 0) }
            let updatedIndexPaths = update.updatedIndexes.map { IndexPath(row: $0, section: 0) }
            
            categoriesTableView.deleteRows(at: deletedIndexPaths, with: .automatic)
            categoriesTableView.insertRows(at: insertedIndexPaths, with: .automatic)
            categoriesTableView.reloadRows(at: updatedIndexPaths, with: .automatic)
            for move in update.movedIndexes {
                categoriesTableView.moveRow(
                    at: IndexPath(row: move.oldIndex, section: 0),
                    to: IndexPath(row: move.newIndex, section: 0)
                )
            }
        }
    }
    
}

#Preview {
    UINavigationController(rootViewController: CategoryListViewController())
}
