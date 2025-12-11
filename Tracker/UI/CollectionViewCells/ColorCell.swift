import UIKit

final class ColorCell: UICollectionViewCell {
    
    // MARK: - Identifier
    
    static let reuseID = "ColorCellReuseIdentifier"
    
    // MARK: - Views
    
    private lazy var colorView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 8
        return view
    }()
    
    private lazy var selectedView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 3
        return view
    }()
    
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
        selectedBackgroundView = selectedView
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 16
        
        contentView.addSubview(colorView)
        
        setupConstraints()
    }
    
    // MARK: - Stup Constraints
    
    private func setupConstraints() {
        colorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            colorView.heightAnchor.constraint(equalToConstant: 40),
            colorView.widthAnchor.constraint(equalTo: colorView.heightAnchor),
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    // MARK: Public Methods
    
    func configure(color: UIColor) {
        colorView.backgroundColor = color
        selectedView.layer.borderColor = color.withAlphaComponent(0.3).cgColor
    }
    
}
