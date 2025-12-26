import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        let didFinishOnboarding = UserDefaults.standard.bool(forKey: "didFinishOnboarding")
        if didFinishOnboarding {
            window?.rootViewController = MainTabBarController()
        } else {
            window?.rootViewController = OnboardingPageViewController(
                transitionStyle: .scroll,
                navigationOrientation: .horizontal
            )
        }
        window?.makeKeyAndVisible()
    }
    
}

