import UIKit

final class ScheduleCell: BaseTableViewCell {
    
    // MARK: - Identifier
    
    static let reuseID = "ScheduleCellReuseIdentifier"
    
    // MARK: - Delegate
    
    weak var delegate: ScheduleCellDelegate?
    
    // MARK: - Views
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypBlack
        return label
    }()
    
    private lazy var daySwitch: UISwitch = {
        let toggler = UISwitch()
        toggler.isOn = false
        toggler.onTintColor = .ypBlue
        return toggler
    }()
    
    // MARK: - Private Properties
    
    private var cellWeekday: Weekday?
    
    // MARK: - Overrides
    
    override func setupUI() {
        super.setupUI()
        setupActions()
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        hStackView.addArrangedSubviews([
            titleLabel,
            UIView(),
            daySwitch
        ])
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        [titleLabel, daySwitch].disableAutoresizingMasks()
        
        NSLayoutConstraint.activate([
            daySwitch.widthAnchor.constraint(equalToConstant: 51),
            daySwitch.heightAnchor.constraint(equalToConstant: 31)
        ])
    }
    
    // MARK: - Setup Actions
    
    private func setupActions() {
        daySwitch.addTarget(self, action: #selector(daySwitchChanged), for: .valueChanged)
    }
    
    // MARK: - Actions
    
    @objc private func daySwitchChanged() {
        guard let day = cellWeekday else { return }
        delegate?.weekdayInCell(day: day, isIncluded: daySwitch.isOn)
    }
    
    // MARK: - Public Methods
    
    func configure(weekday: Weekday, isIncluded: Bool, isFirst: Bool, isLast: Bool) {
        cellWeekday = weekday
        titleLabel.text = weekday.longString
        daySwitch.isOn = isIncluded
        configAppearance(isFirst: isFirst, isLast: isLast)
    }
    
}
