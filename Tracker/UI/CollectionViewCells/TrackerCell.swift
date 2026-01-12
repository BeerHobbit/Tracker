import UIKit

final class TrackerCell: UICollectionViewCell {
    
    // MARK: - Identifier
    
    static let reuseID = "TrackerCellReuseIdentifier"
    
    // MARK: - Delegate
    
    weak var delegate: TrackerCellDelegate?
    
    // MARK: - Views
    
    private lazy var cardView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        view.backgroundColor = fillColor
        
        return view
    }()
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 1
        
        label.backgroundColor = .cellEmojiBackground
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 12
        
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypWhite
        label.textAlignment = .left
        label.numberOfLines = 0
        
        return label
    }()
    
    private lazy var quantityLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.textAlignment = .left
        label.numberOfLines = 1
        label.text = getDayString(quantity)
        
        return label
    }()
    
    private lazy var completeButton: UIButton = {
        let button = UIButton()
        let image = UIImage.plusButton.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = fillColor
        
        return button
    }()
    
    private lazy var quantityStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [quantityLabel, UIView(), completeButton])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 0
        stackView.alignment = .center
        stackView.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 16, right: 12)
        stackView.isLayoutMarginsRelativeArrangement = true
        
        return stackView
    }()
    
    // MARK: - Private Properties
    
    private var quantity: Int = 0 {
        didSet {
            quantityLabel.text = getDayString(quantity)
        }
    }
    private var fillColor: UIColor = .ypGray {
        didSet {
            cardView.backgroundColor = fillColor
            completeButton.tintColor = fillColor
        }
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("❌init(coder:) has not been implemented")
        return nil
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        contentView.addSubviews([
            cardView,
            quantityStackView
        ])
        cardView.addSubviews([
            emojiLabel,
            titleLabel
        ])
        
        setupConstraints()
        setupActions()
    }
    
    // MARK: - Setup Constraints
    
    private func setupConstraints() {
        [
            cardView,
            emojiLabel,
            titleLabel,
            quantityLabel,
            completeButton,
            quantityStackView
        ].disableAutoresizingMasks()
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),
            
            quantityStackView.topAnchor.constraint(equalTo: cardView.bottomAnchor),
            quantityStackView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor),
            quantityStackView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor),
            quantityStackView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor),
            
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalTo: emojiLabel.widthAnchor),
            emojiLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: cardView.trailingAnchor, constant: -12),
        ])
    }
    
    // MARK: - Setup Actions
    
    private func setupActions() {
        completeButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func plusButtonTapped() {
        delegate?.completeButtonDidTap(in: self)
    }
    
    // MARK: - Public Methods
    
    func configure(from tracker: Tracker, isCompleted: Bool, quantity: Int) {
        emojiLabel.text = tracker.emoji
        titleLabel.text = tracker.title
        fillColor = tracker.color
        self.quantity = quantity
        
        let plusImage = UIImage.plusButton.withRenderingMode(.alwaysTemplate)
        let doneImage = UIImage.doneButton.withRenderingMode(.alwaysTemplate)
        if isCompleted {
            completeButton.setImage(doneImage, for: .normal)
        } else {
            completeButton.setImage(plusImage, for: .normal)
        }
    }
    
    func getCardView() -> UIView {
        cardView
    }
    
    // MARK: - Private Methods
    
    private func getDayString(_ value: Int) -> String {
        let mod10 = value % 10
        let mod100 = value % 100
        
        let word: String = {
            switch (mod100, mod10) {
            case (11...14, _):
                return "дней"
            case (_, 1):
                return "день"
            case (_, 2...4):
                return "дня"
            default:
                return "дней"
            }
        }()
        
        return "\(value) \(word)"
    }
    
}
