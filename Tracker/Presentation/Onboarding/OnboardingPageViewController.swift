import UIKit

final class OnboardingPageViewController: UIPageViewController {
    
    // MARK: - Binding
    
    var onFinish: (() -> Void)?
    
    // MARK: - Views
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        
        let color: UIColor = .ypBlack.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
        pageControl.currentPageIndicatorTintColor = color
        pageControl.pageIndicatorTintColor = color.withAlphaComponent(0.3)
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.isUserInteractionEnabled = false
        return pageControl
    }()
    
    private lazy var finishButton: UIButton = {
        let button = UIButton()
        button.setTitle("Вот это технологии!", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        
        let white: UIColor = .ypWhite.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
        let black: UIColor = .ypBlack.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
        button.setTitleColor(white, for: .normal)
        button.backgroundColor = black
        
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Private Properties
    
    private let settingsStorage: SettingsStorageProtocol
    
    private lazy var pages: [OnboardingScreenViewController] = {
        let firstPage = OnboardingScreenViewController(pageModel: .aboutTracking)
        let secondPage = OnboardingScreenViewController(pageModel: .aboutWaterAndYoga)
        return [firstPage, secondPage]
    }()
    
    // MARK: - Initializer
    
    convenience override init(
        transitionStyle style: UIPageViewController.TransitionStyle,
        navigationOrientation: UIPageViewController.NavigationOrientation,
        options: [UIPageViewController.OptionsKey : Any]? = nil
    ) {
        self.init(
            transitionStyle: style,
            navigationOrientation: navigationOrientation,
            options: options,
            settingsStorage: SettingsStorage()
        )
    }
    
    init(
        transitionStyle: UIPageViewController.TransitionStyle,
        navigationOrientation: UIPageViewController.NavigationOrientation,
        options: [UIPageViewController.OptionsKey : Any]? = nil,
        settingsStorage: SettingsStorageProtocol
    ) {
        self.settingsStorage = settingsStorage
        super.init(
            transitionStyle: transitionStyle,
            navigationOrientation: navigationOrientation,
            options: options
        )
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("❌init(coder:) has not been implemented")
        return nil
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configDependencies()
        setVCs()
        setupUI()
    }
    
    // MARK: - Overrides
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setPagesSafeArea()
    }
    
    // MARK: - Configure Dependencies
    
    private func configDependencies() {
        dataSource = self
        delegate = self
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.addSubviews([pageControl, finishButton])
        setupConstraints()
        setupActions()
    }
    
    // MARK: - Setup Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            finishButton.heightAnchor.constraint(equalToConstant: 60),
            finishButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            finishButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            finishButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            
            pageControl.bottomAnchor.constraint(equalTo: finishButton.topAnchor, constant: -24),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    // MARK: - Setup Actions
    
    private func setupActions() {
        finishButton.addTarget(self, action: #selector(didTapFinishButton), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func didTapFinishButton() {
        onFinish?()
    }
    
    // MARK: - Private Methods
    
    private func setVCs() {
        guard let first = pages.first else { return }
        setViewControllers([first], direction: .forward, animated: true)
    }
    
    private func setPagesSafeArea() {
        let pageControlTop = pageControl.frame.minY
        let desiredBottomSafe = view.bounds.height - pageControlTop
        let currentBottomSafe = view.safeAreaInsets.bottom
        let additionalSafe = max(0, desiredBottomSafe - currentBottomSafe)
        
        pages.forEach {
            $0.additionalSafeAreaInsets.bottom = additionalSafe
        }
    }
    
}

// MARK: - UIPageViewControllerDataSource

extension OnboardingPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard
            let currentVC = viewController as? OnboardingScreenViewController,
            let currentIndex = pages.firstIndex(of: currentVC),
            currentIndex > 0
        else {
            return nil
        }
        return pages[currentIndex - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard
            let currentVC = viewController as? OnboardingScreenViewController,
            let currentIndex = pages.firstIndex(of: currentVC),
            currentIndex < pages.count - 1
        else {
            return nil
        }
        return pages[currentIndex + 1]
    }
    
}

// MARK: - UIPageViewControllerDelegate

extension OnboardingPageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard
            let currentVC = pageViewController.viewControllers?.first as? OnboardingScreenViewController,
            let currentIndex = pages.firstIndex(of: currentVC)
        else { return }
        pageControl.currentPage = currentIndex
    }
    
}
