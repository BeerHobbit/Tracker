import UIKit

final class OnboardingPageViewController: UIPageViewController {
    
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
    
    private lazy var readyButton: UIButton = {
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
    
    private lazy var pages: [OnboardingScreenViewController] = {
        let firstPage = OnboardingScreenViewController(pageType: .first)
        firstPage.view.backgroundColor = .red
        let secondPage = OnboardingScreenViewController(pageType: .second)
        secondPage.view.backgroundColor = .green
        return [firstPage, secondPage]
    }()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configDependencies()
        setVCs()
        setupUI()
    }
    
    // MARK: - Configure Dependencies
    
    private func configDependencies() {
        dataSource = self
        delegate = self
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.addSubviews([pageControl, readyButton])
        setupConstraints()
        setupActions()
    }
    
    // MARK: - Setup Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            readyButton.heightAnchor.constraint(equalToConstant: 60),
            readyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            readyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            readyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            
            pageControl.bottomAnchor.constraint(equalTo: readyButton.topAnchor, constant: -24),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    // MARK: - Setup Actions
    
    private func setupActions() {
        readyButton.addTarget(self, action: #selector(didTapReadyButton), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func didTapReadyButton() {
        changeRootAndSave()
    }
    
    // MARK: - Private Methods
    
    private func setVCs() {
        guard let first = pages.first else { return }
        setViewControllers([first], direction: .forward, animated: true)
    }
    
    private func changeRootAndSave() {
        guard let window = UIApplication.shared.keyWindow else {
            assertionFailure("❌ [changeRootAndSave] invalid window configuration")
            return
        }
        
        UserDefaults.standard.set(true, forKey: "didFinishOnboarding")
        
        let newRoot = MainTabBarController()
        UIView.transition(
            with: window,
            duration: 0.35,
            options: .transitionCrossDissolve,
            animations: {
                window.rootViewController = newRoot
            }
        )
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

#Preview {
    OnboardingPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal
    )
}
