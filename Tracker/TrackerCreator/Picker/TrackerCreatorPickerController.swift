//
//  TrackerCreatorController.swift
//  Tracker
//
//  Created by Owi Lover on 11/19/24.
//

import UIKit

final class TrackerCreatorPickerController: UIViewController {
    
    private lazy var header: UILabel = {
        let header = UILabel()
        
        header.text = "Создание трекера"
        header.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return header
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setNavBar()
        setButtonsView()
    }
    
    private func setUI() {
        view.addSubview(header)
        header.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setNavBar() {
        navigationItem.titleView = header
    }
    
    private func setButton(title: String, action: Selector) -> UIButton {
        let button =  UIButton()
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)

        button.setTitleColor(.ypWhite, for: .normal)
        
        button.setTitle(title, for: .normal)
        
        button.addTarget(self, action: action, for: .touchUpInside)
    
        return button
    }
    
    private func setButtonsView() {
        let regularButton = setButton(title: "Привычка", action: #selector(regularButtonTapped))
        let unRegularButton = setButton(title: "Нерегулярное событие", action: #selector(unRegularButtonTapped))
        
        let stackView = UIStackView(arrangedSubviews: [regularButton, unRegularButton])
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.axis = .vertical
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20)
        ])
        
        setButtonConstraints(button: regularButton, to: stackView)
        setButtonConstraints(button: unRegularButton, to: stackView)
        
    }
    
    private func setButtonConstraints(button: UIButton, to view: UIView) {
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        guard let titleHeightAnchor = button.titleLabel?.heightAnchor else { return }

        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalTo: titleHeightAnchor, constant: 38),
            button.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
    }

    
    @objc
    private func regularButtonTapped() {
        let trackerController = TrackerCreatorController(trackerCreatorType: .regular, delegate: self)
        
        let navBar = UINavigationController(rootViewController: trackerController)
        present(navBar, animated: true)
    }
    
    @objc
    private func unRegularButtonTapped() {
        let trackerController = TrackerCreatorController(trackerCreatorType: .unRegular, delegate: self)
        
        let navBar = UINavigationController(rootViewController: trackerController)
        present(navBar, animated: true)
    }
}

extension TrackerCreatorPickerController: TrackerCreatorControllerDelegate {
    func trackerWasCreated() {
        self.presentingViewController?.dismiss(animated: true)
    }
}
