//
//  TrackerCreatorCategoryPicker.swift
//  Tracker
//
//  Created by Owi Lover on 11/27/24.
//

import UIKit

final class TrackerCreatorCategoryPickerController: UIViewController {
    
    private(set) var pickedCategory: String? = nil
    
    private var trackerStorage: TrackerStorageProtocol
    
    private var trackerStorageObserver: NSObjectProtocol?
    
//    MARK: Возможно стоит хранить название выбранной ячейки в контроллере, а не в хелпере?
    
    private weak var delegate: TrackerCreatorCategoryPickerDelegate?
    
    private var tableViewHelper: TrackerCreatorTableViewHelper? = nil
    
    private lazy var categoryTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .none
        tableView.tintColor = .ypBlack
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .ypGray
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 16
        tableView.tableHeaderView = UIView()

        return tableView
    }()
    
    private lazy var createButton: CustomButton = {
       let button = CustomButton()
        
        button.setTitle("Добавить категорию", for: .normal)
        
        button.addTarget(nil, action: #selector(didPressConfirmButton), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var emptyCategoryLabel: UILabel = {
        let label = UILabel()
        label.text = "Привычки и события можно\nобъединить по смыслу"
        label.textAlignment = .center
        label.numberOfLines = 2
        let font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.font = font

        return label
    }()
    
    private lazy var emptyIconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "TrackerEmptyIcon"))
        return imageView
    }()
    
    private lazy var iconAndLabelStackView: UIStackView = {
       let stackView = UIStackView()
        
        stackView.isHidden = true
        
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.axis = .vertical
        
        return stackView
    }()
    
    private lazy var freeSpaceView: UIView = {

        let view = UIView()
        
        return view
    }()
    
    private lazy var header: UILabel = {
        let header = UILabel()
        header.text = "Категория"
        header.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return header
    }()
    
    init(trackerStorage: TrackerStorageProtocol = TrackerStorage.shared, delegate: TrackerCreatorCategoryPickerDelegate? = nil) {
        self.trackerStorage = trackerStorage
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .ypWhite
        setNavBar()
        setConfirmButton()
        setIconAndLabelStackView()
        setEmptyIconImageView()
        setCategoryTableView()
        
        trackerStorage.categoriesArray.isEmpty ? showCategoriesAreEmpty() : showCategoryTableView()
        
        let categories = trackerStorage.categoriesArray.map { $0.category }
        
        tableViewHelper = TrackerCreatorTableViewHelper(tableView: categoryTableView, elements: categories, delegate: self, accessoryType: .checkmark)
        
        tableViewHelper?.setMarkedElement(withName: pickedCategory)
        
        trackerStorageObserver = NotificationCenter.default.addObserver(forName: TrackerStorage.didAddCategory, object: .none, queue: .main, using: { [weak self] changesDictionary in
            guard let self else { return }
            print("CHANGES: ", changesDictionary)
            let categoriesArray = self.trackerStorage.categoriesArray.map({ $0.category })
            categoriesArray.isEmpty ? self.showCategoriesAreEmpty() : self.showCategoryTableView()
            self.tableViewHelper?.updateTable(elements: categoriesArray)
        })
    }
    
    func setPickedCategory(withName name: String?) {
        pickedCategory = name
    }
    
    private func showCategoriesAreEmpty() {
        categoryTableView.isHidden = true
        iconAndLabelStackView.isHidden = false
    }
    
    private func showCategoryTableView() {
        categoryTableView.isHidden = false
        iconAndLabelStackView.isHidden = true
    }
    
    private func setNavBar() {
        navigationItem.titleView = header
    }
    
    private func setCategoryTableView() {
        view.addSubview(categoryTableView)
        
        categoryTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            categoryTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            categoryTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            categoryTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            categoryTableView.bottomAnchor.constraint(equalTo: createButton.topAnchor, constant: -16)
        ])
    }
    
    private func setEmptyIconImageView() {
    
        freeSpaceView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(freeSpaceView)
        
        freeSpaceView.addSubview(iconAndLabelStackView)
        
        iconAndLabelStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            freeSpaceView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            freeSpaceView.bottomAnchor.constraint(equalTo: createButton.topAnchor),
            freeSpaceView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            freeSpaceView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            iconAndLabelStackView.centerXAnchor.constraint(equalTo: freeSpaceView.centerXAnchor),
            iconAndLabelStackView.centerYAnchor.constraint(equalTo: freeSpaceView.centerYAnchor)
        ])
    }
    
    private func setIconAndLabelStackView() {
        iconAndLabelStackView.addArrangedSubview(emptyIconImageView)
        iconAndLabelStackView.addArrangedSubview(emptyCategoryLabel)
        
        
        emptyIconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emptyIconImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyIconImageView.heightAnchor.constraint(equalToConstant: 80),
        ])
    }
    
    private func setConfirmButton() {
        view.addSubview(createButton)
        createButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: createButton.designedHeight)
        ])
    }
    
    @objc
    private func didPressConfirmButton() {
        let categoryCreator = TrackerCreatorCategoryCreatorController()
        let navBar = UINavigationController(rootViewController: categoryCreator)
        self.present(navBar, animated: true)
    }
}

extension TrackerCreatorCategoryPickerController: TrackerCreatorTableViewHelperDelegate {
    func cellWasPressed(withHeader header: String) {
        delegate?.receiveCategoryName(name: header)
        self.dismiss(animated: true)
    }
}
