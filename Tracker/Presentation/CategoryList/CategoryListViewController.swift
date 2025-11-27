import UIKit

final class CategoryListViewController: UIViewController {
    
    // MARK: - Views
    
    private lazy var emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .emptyState
        return imageView
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Привычки и события можно объединить по смыслу"
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
        tableView.backgroundColor = .ypWhite
        tableView.register(ScheduleCell.self, forCellReuseIdentifier: ScheduleCell.reuseID)
        tableView.separatorStyle = .none
        tableView.rowHeight = 75
        return tableView
    }()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configDependencies()
        setupUI()
    }
    
    // MARK: - Configure Dependencies
    
    private func configDependencies() {
        
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
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
    }
    
    // MARK: - Setup Constraints
    
    private func setupConstraints() {
        
    }
    
    // MARK: - Setup Actions
    
    private func setupActions() {
        
    }
    
    // MARK: - Actions
    
}

#Preview {
    UINavigationController(rootViewController: CategoryListViewController())
}
