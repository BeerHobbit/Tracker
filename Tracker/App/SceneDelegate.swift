import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    // MARK: - Public Properties

    var window: UIWindow?
    
    // MARK: - Private Properties
    
    private let settingsStorage: SettingsStorageProtocol = SettingsStorage()
    
    // MARK: - Public Methods

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        if settingsStorage.didFinishOnboarding {
            window?.rootViewController = MainTabBarController()
        } else {
            let onboarding = OnboardingPageViewController(
                transitionStyle: .scroll,
                navigationOrientation: .horizontal,
            )
            onboarding.onFinish = { [weak self] in
                self?.changeRootAndSave(window: self?.window)
            }
            window?.rootViewController = onboarding
        }
        
        window?.makeKeyAndVisible()
    }
    
    // MARK: - Private Methods
    
    private func changeRootAndSave(window: UIWindow?) {
        guard let window = window else { return }
        
        settingsStorage.didFinishOnboarding = true
        
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

