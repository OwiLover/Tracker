//
//  TabBarController.swift
//  Tracker
//
//  Created by Owi Lover on 11/6/24.
//


import UIKit
 
final class TabBarController: UITabBarController {
        
    override func viewDidLoad() {
        super.viewDidLoad()

        tabBarAppearanceSetup()
        
        let trackerViewController = TrackerViewController()
        
        trackerViewController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "TabBarTrackerIcon"),
            selectedImage: nil)
        
        let statsViewController = StatsViewController()
        
        statsViewController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "TabBarStatsIcon"),
            selectedImage: nil)
        
        let nav = UINavigationController(rootViewController: trackerViewController)
    
        nav.setupNavigationAppearance()
        
        self.viewControllers = [nav, statsViewController]
    }
    
    private func tabBarAppearanceSetup() {
        
        let tabBarAppearance = {
            let appearance = UITabBarAppearance()
            appearance.backgroundColor = .ypWhite
            appearance.configureWithTransparentBackground()
            
            appearance.shadowColor = .black.withAlphaComponent(0.3)
            
            return appearance
        }()
        
//        MARK: Без применения if #Available не смог найти решения для появления разделяющей полосочки
        
        self.tabBar.standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            self.tabBar.scrollEdgeAppearance = tabBarAppearance
        }
    }
}
