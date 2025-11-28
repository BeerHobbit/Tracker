import UIKit

final class EnterNewCategoryCell: UITableViewCell {
    
    // MARK: - Identifier
    
    static let reuseID = "EnterNewCategoryCellReuseIdentifier"
    
    // MARK: - Delegate
    
    weak var delegate: EnterNewCategoryCellDelegate?
    
    // MARK: - Views
    
    private lazy var categoryNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название категории"
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.textColor = .ypBlack
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .go
        textField.enablesReturnKeyAutomatically = true
        return textField
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypBackground
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        return view
    }()
    
    // MARK: - Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super .init(style: style, reuseIdentifier: reuseIdentifier)
        configDependencies()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure Dependencies
    
    private func configDependencies() {
        categoryNameTextField.delegate = self
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        selectionStyle = .none
        contentView.addSubview(containerView)
        containerView.addSubview(categoryNameTextField)
        setupConstraints()
        setupActions()
    }
    
    // MARK: - Setup Constraints
    
    private func setupConstraints() {
        [
            categoryNameTextField,
            containerView,
        ].disableAutoresizingMasks()
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            categoryNameTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            categoryNameTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            categoryNameTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }
    
    // MARK: - Setup Actions
    
    private func setupActions() {
        categoryNameTextField.addTarget(self, action: #selector(categoryNameTextFieldEditingChanged), for: .editingChanged)
    }
    
    @objc private func categoryNameTextFieldEditingChanged() {
        let text = categoryNameTextField.text ?? ""
        delegate?.enterNewCategoryCell(didChangeText: text)
    }
    
}

extension EnterNewCategoryCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
