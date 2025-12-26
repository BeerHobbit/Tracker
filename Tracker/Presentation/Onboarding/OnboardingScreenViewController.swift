import UIKit

final class OnboardingScreenViewController: UIViewController {
    
    // MARK: - Types
    
    enum OnboardingPageType {
        case first
        case second
    }
    
    // MARK: - Views
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Private Properties
    
    let pageType: OnboardingPageType
    
    // MARK: - Initializer
    
    init(pageType: OnboardingPageType) {
        self.pageType = pageType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("❌init(coder:) has not been implemented")
        return nil
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI(for: pageType)
    }
    
    // MARK: - Setup UI
    
    private func setupUI(for page: OnboardingPageType) {
        view.addSubviews([imageView, label])
        
        switch page {
        case .first:
            imageView.image = .onboarding1
            label.text = "Отслеживайте только то, что хотите"
        case .second:
            imageView.image = .onboarding2
            label.text = "Даже если это\nне литры воды и йога"
        }
        
        setupConstraints()
    }
    
    // MARK: - Setup Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -270)
        ])
    }
    
}

