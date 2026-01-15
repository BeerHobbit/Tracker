import UIKit

final class CategoryCell: BaseTableViewCell {
    
    // MARK: - Identifier
    
    static let reuseID = "CategoryCellReuseIdentifier"
    
    // MARK: - Views
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypBlack
        return label
    }()
    
    private lazy var checkImageView: UIImageView = {
        let imageView = UIImageView(image: .checkmarkIcon)
        imageView.isHidden = true
        return imageView
    }()
    
    // MARK: - Overrides
    
    override func setupSubviews() {
        super.setupSubviews()
        hStackView.addArrangedSubviews([
            titleLabel,
            UIView(),
            checkImageView
        ])
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        [titleLabel, checkImageView].disableAutoresizingMasks()
        
        NSLayoutConstraint.activate([
            checkImageView.heightAnchor.constraint(equalToConstant: 24),
            checkImageView.widthAnchor.constraint(equalTo: checkImageView.heightAnchor)
        ])
    }
    
    // MARK: - Public Methods
    
    func configure(title: String, isSelected: Bool, isFirst: Bool, isLast: Bool) {
        titleLabel.text = title
        checkImageView.isHidden = !isSelected
        configAppearance(isFirst: isFirst, isLast: isLast)
    }
    
}
