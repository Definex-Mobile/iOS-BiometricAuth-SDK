//
//  TabbarController.swift
//  CoinX
//
//  Created by Mücahit Katırcı on 13.09.2023.
//

import UIKit

class TabbarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

private extension TabbarController {
    
    private func setupUI() {
        viewControllers = [
            createNavController(
                for: Home.createModule(),
                title: "Home",
                activeImage: UIImage(named: "homeTabActiveIcon")!,
                inactiveImage: UIImage(named: "homeTabInactiveIcon")!
            ),
            createNavController(
                for: Portfolio.createModule(),
                title: "Portfolio",
                activeImage: UIImage(named: "portfolioTabActiveIcon")!,
                inactiveImage: UIImage(named: "portfolioTabInactiveIcon")!
            ),
            createNavController(
                for: SecuritySettings.createModule(),
                title: "Security",
                activeImage: UIImage(named: "profileTabActiveIcon")!,
                inactiveImage: UIImage(named: "profileTabInactiveIcon")!
            )
        ]
        
        tabBar.layer.shadowOffset = CGSize(width: 0, height: 0)
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOpacity = 0.1
        
        tabBar.isTranslucent = false
        tabBar.backgroundColor = .white
    }
    
    private func createNavController(
        for rootViewController: UIViewController,
        title: String,
        activeImage: UIImage,
        inactiveImage: UIImage
    ) -> UIViewController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = inactiveImage.withRenderingMode(.alwaysOriginal)
        navController.tabBarItem.selectedImage = activeImage.withRenderingMode(.alwaysOriginal)
        
        // Hide navigation bar by default, but SecuritySettings will show it
        if rootViewController is SecuritySettingsViewController {
            navController.navigationBar.prefersLargeTitles = true
            navController.setNavigationBarHidden(false, animated: false)
        } else {
            navController.setNavigationBarHidden(true, animated: false)
        }
        
        return navController
    }
}
