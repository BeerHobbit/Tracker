import UIKit

final class NewCategoryViewController: UIViewController {
    
    // MARK: - Delegate
    
    weak var delegate: NewCategoryViewControllerDelegate?
    
    // MARK: - Views
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .ypWhite
        tableView.keyboardDismissMode = .onDrag
        
        tableView.register(EnterNewCategoryCell.self, forCellReuseIdentifier: EnterNewCategoryCell.reuseID)
        
        return tableView
    }()
    
    private lazy var readyButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypGray
        
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        
        button.isEnabled = false
        return button
    }()
    
    // MARK: - Private Properties
    
    private var newCategoryTitle: String = "" {
        didSet {
            readyButton.isEnabled = !newCategoryTitle.isEmpty
            readyButton.backgroundColor = readyButton.isEnabled ? .ypBlack : .ypGray
        }
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configDependencies()
        setupUI()
    }
    
    // MARK: - Configure Dependencies
    
    private func configDependencies() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.backgroundColor = .ypWhite
        
        view.addSubviews([
            tableView,
            readyButton
        ])
        
        setupNavigationBar()
        setupConstraints()
        setupActions()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Новая категория"
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.ypBlack,
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
        navigationItem.hidesBackButton = true
    }

    // MARK: - Setup Constraints
    
    private func setupConstraints() {
        [tableView, readyButton].disableAutoresizingMasks()
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: readyButton.topAnchor, constant: -16),
            
            readyButton.heightAnchor.constraint(equalToConstant: 60),
            readyButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            readyButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            readyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Setup Actions
    
    private func setupActions() {
        view.addGestureRecognizer(singleTapRecognizer())
        readyButton.addTarget(self, action: #selector(didTapReadyButton), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func didSingleTap() {
        view.endEditing(true)
    }
    
    @objc private func didTapReadyButton() {
        delegate?.didCreateNewCategory(title: newCategoryTitle)
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Private Methods
    
    private func singleTapRecognizer() -> UITapGestureRecognizer {
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(didSingleTap))
        singleTap.numberOfTapsRequired = 1
        singleTap.cancelsTouchesInView = false
        return singleTap
    }
    
}

// MARK: - UITableViewDataSource

extension NewCategoryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EnterNewCategoryCell.reuseID, for: indexPath) as? EnterNewCategoryCell else {
            assertionFailure("❌[dequeueReusableCell]: can't dequeue reusable cell with id: \(EnterNewCategoryCell.reuseID) as \(String(describing: EnterNewCategoryCell.self))")
            return UITableViewCell()
        }
        cell.delegate = self
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension NewCategoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 24
    }
    
}

// MARK: - EnterNewCategoryCellDelegate

extension NewCategoryViewController: EnterNewCategoryCellDelegate {
    
    func enterNewCategoryCell(didChangeText text: String) {
        newCategoryTitle = text
    }
    
    func updateCellLayout() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
}
