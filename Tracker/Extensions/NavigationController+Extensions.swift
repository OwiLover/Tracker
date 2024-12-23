//
//  NavigationController.swift
//  Tracker
//
//  Created by Owi Lover on 11/6/24.
//
import UIKit

extension UINavigationController {
    func setupNavigationAppearance() {
        
        let appearance = UINavigationBarAppearance()
        
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .ypWhite
        appearance.titleTextAttributes = [.foregroundColor: UIColor.ypBlack]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.ypBlack]
        
        self.navigationBar.standardAppearance = appearance
        self.navigationBar.scrollEdgeAppearance = appearance
        self.navigationBar.compactAppearance = appearance

        self.navigationBar.tintColor = .ypBlack
    }
}
