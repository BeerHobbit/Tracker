import UIKit

final class MainTabBarController: UITabBarController {
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildTabBarControllers()
    }
    
    // MARK: - Private Methods
    
    private func buildTabBarControllers() {
        let trackersListVC = TrackersListViewController()
        trackersListVC.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(resource: .tabBarTrackers),
            selectedImage: nil
        )
        
        let statisticsVC = StatisticsViewController()
        statisticsVC.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(resource: .tabBarStats),
            selectedImage: nil
        )
        
        viewControllers = [trackersListVC, statisticsVC]
    }
    
}
