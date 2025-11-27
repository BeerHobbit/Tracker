import UIKit

final class EmojiCell: UICollectionViewCell {
    
    // MARK: - Identifier
    
    static let reuseID = "EmojiCellReuseIdentifier"
    
    // MARK: - Views
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var selectedView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypLightGray
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        return view
    }()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        selectedBackgroundView = selectedView
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 16
        
        contentView.addSubview(emojiLabel)
        
        setupConstraints()
    }
    
    // MARK: - Stup Constraints
    
    private func setupConstraints() {
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    // MARK: Public Methods
    
    func configure(emoji: String) {
        emojiLabel.text = emoji
    }
    
}
