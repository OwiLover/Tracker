//
//  TrackerViewCategoryCreator.swift
//  Tracker
//
//  Created by Owi Lover on 11/28/24.
//

import UIKit

final class TrackerCreatorCategoryCreatorController: UIViewController {
    
    private weak var delegate: TrackerCreatorCategoryCreatorDelegate?
    
    private var trackerStorage: TrackerStorageProtocol? = TrackerStorage.shared
    
    private lazy var header: UILabel = {
        let header = UILabel()
        header.text = "Новая привычка"
        header.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return header
    }()
    
    private lazy var  categoryNameTextField: CustomTextField = {
        let textField = CustomTextField()
    
        textField.placeholder = "Введите название категории"
        
        textField.addTarget(nil, action: #selector(categoryNameTextFieldDidChange), for: .editingChanged)
        
        return textField
    }()
    
    private lazy var  maxLengthWarningLabel: CustomWarningLabel = {
        let label = CustomWarningLabel()
        
        label.isHidden = true
        
        label.text = "Ограничение 38 символов"
        
        return label
    }()
    
    private lazy var  confirmButton: CustomButton = {
       let button = CustomButton()
        
        button.setTitle("Готово", for: .normal)
        
        button.isEnabled = false
        
        button.addTarget(nil, action: #selector(confirmButtonDidPress), for: .touchUpInside)
        
        return button
    }()
    
    init(delegate: TrackerCreatorCategoryCreatorDelegate? = nil, trackerStorage: TrackerStorageProtocol? = TrackerStorage.shared) {
        self.delegate = delegate
        self.trackerStorage = trackerStorage
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .ypWhite
        
        setNavBar()
        setCategoryNameTextField()
        setMaxLengthWarningLabel()
        setConfirmButton()
    }
    
    private func setNavBar() {
        navigationItem.titleView = header
    }
    
    private func setCategoryNameTextField() {
        view.addSubview(categoryNameTextField)
        
        categoryNameTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            categoryNameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            categoryNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryNameTextField.heightAnchor.constraint(equalToConstant: categoryNameTextField.designedHeight)
        ])
    }
    
    private func setMaxLengthWarningLabel() {
        view.addSubview(maxLengthWarningLabel)
        
        maxLengthWarningLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            maxLengthWarningLabel.topAnchor.constraint(equalTo: categoryNameTextField.bottomAnchor, constant: 8),
            maxLengthWarningLabel.leadingAnchor.constraint(equalTo: categoryNameTextField.leadingAnchor, constant: 28),
            maxLengthWarningLabel.trailingAnchor.constraint(equalTo: categoryNameTextField.trailingAnchor, constant: -28),
        ])
    }
    
    private func setConfirmButton() {
        view.addSubview(confirmButton)
        
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            confirmButton.heightAnchor.constraint(equalToConstant: confirmButton.designedHeight),
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    @objc
    private func categoryNameTextFieldDidChange() {
        guard let name = categoryNameTextField.text else { return }
        
        confirmButton.isEnabled = !name.isEmpty

        if name.count < 38 && !maxLengthWarningLabel.isHidden {
                self.maxLengthWarningLabel.isHidden = true
        }
        
        else if name.count >= 38 {
            categoryNameTextField.text = String(name[name.startIndex..<name.index(name.startIndex, offsetBy: 38)])
            
            if maxLengthWarningLabel.isHidden {
                self.maxLengthWarningLabel.isHidden = false
            }
        }
    }
    
    @objc
    private func confirmButtonDidPress() {
        guard let name = categoryNameTextField.text else { return }

        trackerStorage?.addCategory(category: name)

        self.dismiss(animated: true)
    }
}
