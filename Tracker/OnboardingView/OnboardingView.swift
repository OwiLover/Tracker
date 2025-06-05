//
//  OnboardingView.swift
//  Tracker
//
//  Created by Owi Lover on 3/28/25.
//

import UIKit

final class OnboardingView: UIPageViewController {
    
    private enum BackgroundImages: String {
        case first = "OnboardingBackground1"
        case second = "OnboardingBackground2"
    }
    
    lazy var confirmButton: CustomButton = {
        let button = CustomButton()
        
        button.setTitle("Вот это технологии!", for: .normal)
        button.addTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)
        
        return button
    }()
    
    lazy var pageController: UIPageControl = {
        let pageControl = UIPageControl()
        
        pageControl.currentPageIndicatorTintColor = .ypBlackConstant
        pageControl.pageIndicatorTintColor = .ypBlackConstant.withAlphaComponent(0.3)
        pageControl.numberOfPages = backgroundViews.count
        pageControl.currentPage = 0
        
        return pageControl
    }()
    
    lazy var backgroundViews: [UIViewController] = {
        guard let firstImage = UIImage(named: BackgroundImages.first.rawValue), let secondImage = UIImage(named: BackgroundImages.second.rawValue) else {
            return []
        }
        
        let firstBackgroundController = UIViewController()
        let secondBackgroundController = UIViewController()
        
        let firstBackgroundImageView = UIImageView(image: firstImage)
        let secondBackgroundImageView = UIImageView(image: secondImage)
        
        let firstBackgroundText: UILabel = {
            let text = UILabel()
            text.text = "Отслеживайте только то, что хотите"
            
            let font = UIFont.systemFont(ofSize: 32, weight: .bold)
            
            text.font = font
            text.textColor = .black
            text.textAlignment = .center
            text.numberOfLines = 0
            
            return text
        }()
        
        let secondBackgroundText: UILabel = {
            let text = UILabel()
            text.text = "Даже если это не литры воды и йога"
            
            let font = UIFont.systemFont(ofSize: 32, weight: .bold)
            
            text.font = font
            text.textColor = .black
            text.textAlignment = .center
            text.numberOfLines = 0
            
            return text
        }()
        
        setBackgroundImage(firstBackgroundImageView, view: firstBackgroundController.view)
        setBackgroundText(text: firstBackgroundText, view: firstBackgroundController.view)
        
        setBackgroundImage(secondBackgroundImageView, view: secondBackgroundController.view)
        setBackgroundText(text: secondBackgroundText, view: secondBackgroundController.view)
        
        return [firstBackgroundController, secondBackgroundController]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        
        setUI()
        
        guard let firstController = backgroundViews.first else { return }
        setViewControllers([firstController], direction: .forward, animated: true)

    }

    private func setBackgroundImage(_ imageView: UIImageView, view: UIView) {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor)])
    }
    
    private func setBackgroundText(text: UILabel, view: UIView) {
        text.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(text)
        
        NSLayoutConstraint.activate([
            text.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            text.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            text.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            text.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -270)
        ])
    }
    
    private func setUI() {
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(confirmButton)
        
        NSLayoutConstraint.activate([
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            confirmButton.heightAnchor.constraint(equalToConstant: confirmButton.designedHeight),
        ])
        
        pageController.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(pageController)
        
        NSLayoutConstraint.activate([
            pageController.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -24),
            pageController.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    @objc
    private func didTapConfirmButton() {
        let storage = DefaultsStorage.shared
        storage.setCheckedOnboardView(true)
        
        let tabBarController = TabBarController()
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: { [weak self] in
            guard self != nil else { return }
            window.rootViewController = tabBarController
        }, completion: nil)
        self.presentingViewController?.dismiss(animated: true)
    }
}

extension OnboardingView: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = backgroundViews.firstIndex(of: viewController) else {
            return nil
        }
        
        let newIndex = currentIndex - 1
        
        if newIndex < 0 {
            let endIndex = backgroundViews.endIndex - 1
            return backgroundViews[endIndex]
        }
        
        return backgroundViews[newIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = backgroundViews.firstIndex(of: viewController) else {
            return nil
        }
        
        let newIndex = currentIndex + 1
        
        if newIndex >= backgroundViews.count {
            let startIndex = backgroundViews.startIndex
            return backgroundViews[startIndex]
        }

        return backgroundViews[newIndex]
    }
}

extension OnboardingView: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = backgroundViews.firstIndex(of: currentViewController) {
            pageController.currentPage = currentIndex
        }
    }
}
