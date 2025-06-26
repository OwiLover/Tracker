//
//  FilterViewController.swift
//  Tracker
//
//  Created by Owi Lover on 6/23/25.
//

import UIKit

protocol FilterDelegate: AnyObject {
    func receiveFilter(filter: FilterType)
}

final class FilterViewController: UIViewController {
    
    private let viewModel: FilterViewModelProtocol?
    
    private weak var delegate: FilterDelegate?
    
    private var tableViewHelper: CustomTableViewHelper?
    
    private var pickedFilter: FilterType?
    
    private lazy var filterTableView: UITableView = {
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
    
    private lazy var header: UILabel = {
        let header = UILabel()
        header.text = "Фильтры"
        header.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return header
    }()
    
    init(viewModel: FilterViewModelProtocol? = FilterViewModel(), pickedFilter: FilterType? = .all, delegate: FilterDelegate? = nil) {
        self.delegate = delegate
        self.viewModel = viewModel
        self.viewModel?.pickedFilter = pickedFilter?.rawValue
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .ypWhite
        setNavBar()
        setFilterTableView()
        setBindsForViewModel()

        guard let viewModel else {
            return
        }
        
        let array = viewModel.filtersArray.map( { $0.rawValue })
        
        
        
        tableViewHelper = CustomTableViewHelper(tableView: filterTableView, elements: array, delegate: self, accessoryType: .checkmark)
        tableViewHelper?.setMarkedElement(withName: viewModel.pickedFilter)
    }
    
    func setPickedCategory(withName name: String?) {
        guard let viewModel else { return }
        viewModel.pickedFilter = name
    }
    
    private func setBindsForViewModel() {
        guard let viewModel else { return }
        
        viewModel.onFilterSelected = { [weak self] name in
            guard let self else { return }
            tableViewHelper?.setMarkedElement(withName: name)
        }
    }
    
    private func setNavBar() {
        navigationItem.titleView = header
    }
    
    private func setFilterTableView() {
        view.addSubview(filterTableView)
        
        filterTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            filterTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            filterTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            filterTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            filterTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
}

extension FilterViewController: CustomTableViewHelperDelegate {
    func cellWasPressed(withHeader header: String) {
        let filter = FilterType(rawValue: header) ?? FilterType.all
        delegate?.receiveFilter(filter: filter)
        self.dismiss(animated: true)
    }
}
