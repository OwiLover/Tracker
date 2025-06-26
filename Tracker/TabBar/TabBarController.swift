//
//  TabBarController.swift
//  Tracker
//
//  Created by Owi Lover on 11/6/24.
//


import UIKit
 
final class TabBarController: UITabBarController {
    
    private enum LocalizableText: String {
        case trackerTitle
        case statsTitle
        
        func getLocalizedText() -> String {
            NSLocalizedString(self.rawValue, value: self.getDefaultText(), comment: "")
        }
        
        func getDefaultText() -> String {
            switch self {
            case .trackerTitle:
                return "Трекеры"
            case .statsTitle:
                return "Статистика"
            }
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()

        tabBarAppearanceSetup()
        
        let trackerViewController = TrackerViewController()
        
        let trackerTitle = LocalizableText.trackerTitle.getLocalizedText()
        
        trackerViewController.tabBarItem = UITabBarItem(
            title: trackerTitle,
            image: UIImage(named: "TabBarTrackerIcon"),
            selectedImage: nil)
        
        let statsViewController = StatsViewController()
        
        let statsTitle = LocalizableText.statsTitle.getLocalizedText()
        
        statsViewController.tabBarItem = UITabBarItem(
            title: statsTitle,
            image: UIImage(named: "TabBarStatsIcon"),
            selectedImage: nil)
        
        let navTracker = UINavigationController(rootViewController: trackerViewController)
    
        navTracker.setupNavigationAppearance()
        
        let navStats = UINavigationController(rootViewController: statsViewController)
        
        navStats.setupNavigationAppearance()
        
        self.viewControllers = [navTracker, navStats]
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
