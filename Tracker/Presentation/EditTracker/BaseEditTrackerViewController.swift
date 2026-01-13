import UIKit

class BaseEditTrackerViewController: UIViewController {
    
    // MARK: - Types
    
    enum Section {
        case enterName
        case parameters([Parameter])
        case customization
    }
    
    enum Parameter {
        case category(ParameterItem)
        case schedule(ParameterItem)
    }
    
    // MARK: - Views
    
    private let topSpacerView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
    private lazy var quantityLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private lazy var vStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                topSpacerView,
                quantityLabel,
                tableView
            ]
        )
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.setCustomSpacing(24, after: topSpacerView)
        stackView.distribution = .fill
        return stackView
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        
        tableView.register(EnterNameCell.self, forCellReuseIdentifier: EnterNameCell.reuseID)
        tableView.register(ParameterCell.self, forCellReuseIdentifier: ParameterCell.reuseID)
        tableView.register(CustomizationCell.self, forCellReuseIdentifier: CustomizationCell.reuseID)
        
        tableView.backgroundColor = .ypWhite
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        
        return tableView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.ypRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .clear
        
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(resource: .ypRed).cgColor
        
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
        
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypGray
        
        button.setTitleColor(.ypWhite, for: .normal)
        button.setTitleColor(
            UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .light ? .ypWhite : .ypBlack
            },
            for: .disabled
        )
        
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        
        button.isEnabled = false
        return button
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cancelButton, createButton])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    // MARK: - State
    
    var state = NewTrackerState(
        title: "",
        category: nil,
        schedule: [],
        emoji: "",
        color: nil
    ) {
        didSet {
            createButton.isEnabled = state.isReady
            createButton.backgroundColor = state.isReady ? .ypBlack : .ypGray
        }
    }
    
    // MARK: - Private Properties
    
    private lazy var scheduleVC: ScheduleViewController? = ScheduleViewController()
    private lazy var categoryListVC: CategoryListViewController? = CategoryListViewController()
    
    private let sections: [Section] = [
        .enterName,
        .parameters([
            .category(ParameterItem(title: "Категория")),
            .schedule(ParameterItem(title: "Расписание"))
        ]),
        .customization
    ]
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configDependencies()
        setupUI()
    }
    
    // MARK: - Public Methods
    
    func setTitles(navigationTitle: String, createButtonTitle: String) {
        navigationItem.title = navigationTitle
        createButton.setTitle(createButtonTitle, for: .normal)
    }
    
    func setQuantityForEditTracker(_ quantityString: String) {
        topSpacerView.isHidden = false
        quantityLabel.isHidden = false
        quantityLabel.text = quantityString
    }
    
    // MARK: - Configure Dependencies
    
    private func configDependencies() {
        tableView.dataSource = self
        tableView.delegate = self
        
        scheduleVC?.delegate = self
        categoryListVC?.delegate = self
    }
    
    // MARK: - Setup UI
    
    func setupUI() {
        view.backgroundColor = .ypWhite
        view.addSubviews([
            vStackView,
            buttonStackView
        ])
        
        setupNavigationBar()
        setupConstraints()
        setupActions()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.ypBlack,
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
    }
    
    // MARK: - Setup Constraints
    
    private func setupConstraints() {
        [
            vStackView,
            buttonStackView
        ].disableAutoresizingMasks()
        
        NSLayoutConstraint.activate([
            vStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            vStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            vStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            vStackView.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -16),
            
            buttonStackView.heightAnchor.constraint(equalToConstant: 60),
            buttonStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Setup Actions
    
    private func setupActions() {
        view.addGestureRecognizer(singleTapRecognizer())
        cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func didSingleTap() {
        view.endEditing(true)
    }
    
    @objc private func didTapCancelButton() {
        dismiss(animated: true)
    }
    
    @objc func didTapCreateButton() {
        dismiss(animated: true)
    }
    
    // MARK: - Private Methods
    
    private func singleTapRecognizer() -> UITapGestureRecognizer {
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(didSingleTap))
        singleTap.numberOfTapsRequired = 1
        singleTap.cancelsTouchesInView = false
        return singleTap
    }
    
    private func pushToScheduleVC() {
        guard let scheduleVC = scheduleVC else { return }
        scheduleVC.configure(with: state.schedule)
        navigationController?.pushViewController(scheduleVC, animated: true)
    }
    
    private func pushToCategoryListVC() {
        guard let categoryListVC = categoryListVC else { return }
        categoryListVC.configure(selectedCategory: state.category)
        navigationController?.pushViewController(categoryListVC, animated: true)
    }
    
    private func makeEnterNameCell(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EnterNameCell.reuseID, for: indexPath) as? EnterNameCell else {
            assertionFailure("❌[dequeueReusableCell]: can't dequeue reusable cell with id: \(EnterNameCell.reuseID) as \(String(describing: EnterNameCell.self))")
            return UITableViewCell()
        }
        cell.delegate = self
        cell.configure(with: state.title)
        
        return cell
    }
    
    private func makeParameterCell(_ tableView: UITableView, _ indexPath: IndexPath, _ items: [Parameter]) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ParameterCell.reuseID, for: indexPath) as? ParameterCell else {
            assertionFailure("❌[dequeueReusableCell]: can't dequeue reusable cell with id: \(ParameterCell.reuseID) as \(String(describing: ParameterCell.self))")
            return UITableViewCell()
        }
        configureParameterCell(cell, indexPath, items)
        
        return cell
    }
    
    private func makeCustomizationCell(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CustomizationCell.reuseID, for: indexPath) as? CustomizationCell else {
            assertionFailure("❌[dequeueReusableCell]: can't dequeue reusable cell with id: \(CustomizationCell.reuseID) as \(String(describing: CustomizationCell.self))")
            return UITableViewCell()
        }
        cell.delegate = self
        cell.configure(emoji: state.emoji, color: state.color)
        
        return cell
    }
    
    private func configureParameterCell(_ cell: ParameterCell, _ indexPath: IndexPath, _ items: [Parameter]) {
        let item = items[indexPath.row]
        
        let isFirst = indexPath.row == 0
        let isLast = indexPath.row == items.count - 1
        
        switch item {
        case .category(let param):
            cell.configure(
                parameter: NewTrackerParameter(
                    title: param.title,
                    subtitle: state.category?.title ?? "",
                    isFirst: isFirst,
                    isLast: isLast
                )
            )
            
        case .schedule(let param):
            let scheduleString = Weekday.formattedWeekdays(Array(state.schedule))
            cell.configure(
                parameter: NewTrackerParameter(
                    title: param.title,
                    subtitle: scheduleString,
                    isFirst: isFirst,
                    isLast: isLast
                )
            )
        }
    }
    
    private func updateStateTitle(_ title: String) {
        state = NewTrackerState(
            title: title,
            category: state.category,
            schedule: state.schedule,
            emoji: state.emoji,
            color: state.color
        )
    }
    
    private func updateStateSchedule(_ schedule: Set<Weekday>) {
        state = NewTrackerState(
            title: state.title,
            category: state.category,
            schedule: schedule,
            emoji: state.emoji,
            color: state.color
        )
    }
    
    private func updateStateEmoji(_ emoji: String) {
        state = NewTrackerState(
            title: state.title,
            category: state.category,
            schedule: state.schedule,
            emoji: emoji,
            color: state.color
        )
    }
    
    private func updateStateColor(_ color: UIColor?) {
        state = NewTrackerState(
            title: state.title,
            category: state.category,
            schedule: state.schedule,
            emoji: state.emoji,
            color: color
        )
    }
    
    private func updateStateCategory(_ category: TrackerCategory?) {
        state = NewTrackerState(
            title: state.title,
            category: category,
            schedule: state.schedule,
            emoji: state.emoji,
            color: state.color
        )
    }
    
}

// MARK: - UITableViewDataSource

extension BaseEditTrackerViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .enterName: return 1
        case .parameters(let items): return items.count
        case .customization: return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section] {
        case .enterName:
            return makeEnterNameCell(tableView, indexPath)
        case .parameters(let items):
            return makeParameterCell(tableView, indexPath, items)
        case .customization:
            return makeCustomizationCell(tableView, indexPath)
        }
    }
    
}

// MARK: - UITableViewDelegate

extension BaseEditTrackerViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch sections[indexPath.section] {
        case .parameters(let items):
            switch items[indexPath.row] {
            case .category: pushToCategoryListVC()
            case .schedule: pushToScheduleVC()
            }
        default: return
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        UIView()
    }
  
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch sections[section] {
        case .customization: return 32
        default: return 24
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch sections[indexPath.section] {
        case .enterName: return 75
        case .parameters(_): return 75
        case .customization: return 460
        }
    }
    
}

// MARK: - EnterNameCellDelegate

extension BaseEditTrackerViewController: EnterNameCellDelegate {
    
    func enterNameCell(didChangeText text: String) {
        updateStateTitle(text)
    }
    
    func updateCellLayout() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
}

// MARK: - ScheduleViewControllerDelegate

extension BaseEditTrackerViewController: ScheduleViewControllerDelegate {
    
    func getConfiguredSchedule(_ schedule: Set<Weekday>) {
        updateStateSchedule(schedule)
        tableView.reloadData()
    }
    
}

// MARK: - CustomizationCellDelegate

extension BaseEditTrackerViewController: CustomizationCellDelegate {
    
    func customizationCell(didChangeEmoji emoji: String) {
        updateStateEmoji(emoji)
    }
    
    func customizationCell(didChangeColor color: UIColor?) {
        updateStateColor(color)
    }
    
}

// MARK: - CategoryListViewControllerDelegate

extension BaseEditTrackerViewController: CategoryListViewControllerDelegate {
    
    func categoryListVC(didSelectCategory category: TrackerCategory) {
        updateStateCategory(category)
        tableView.reloadData()
    }
    
}


#Preview {
    let navController = UINavigationController(rootViewController: BaseEditTrackerViewController())
    return navController
}
