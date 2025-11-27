import UIKit

final class ParameterCell: BaseTableViewCell {
    
    // MARK: - Identifier
    
    static let reuseID = "ParametersReuseIdentifier"
    
    // MARK: - Views
    
    private lazy var vStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.alignment = .leading
        stackView.distribution = .fill
        return stackView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypBlack
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypGray
        return label
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .chevron
        return imageView
    }()
    
    // MARK: - Private Properties
    
    private var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    
    private var subtitle: String = "" {
        didSet {
            subtitleLabel.text = subtitle
            subtitleLabel.isHidden = subtitle.isEmpty
        }
    }
    
    // MARK: - Overrides
    
    override func setupSubviews() {
        super.setupSubviews()
        hStackView.addArrangedSubview(vStackView)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        [
            vStackView,
            titleLabel,
            subtitleLabel,
            iconImageView
        ].disableAutoresizingMasks()
        
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalTo: iconImageView.widthAnchor)
        ])
    }
    
    // MARK: - Public Methods
    
    func configure(parameter: NewTrackerParameter) {
        title = parameter.title
        subtitle = parameter.subtitle
        configAppearance(isFirst: parameter.isFirst, isLast: parameter.isLast)
    }
    
}
