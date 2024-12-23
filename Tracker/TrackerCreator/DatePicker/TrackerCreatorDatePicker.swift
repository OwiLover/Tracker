//
//  TrackerCreatorDatePicker.swift
//  Tracker
//
//  Created by Owi Lover on 11/25/24.
//

import UIKit


final class TrackerCreatorDatePicker: UIViewController {
    
    enum DayOfWeek: Int, CaseIterable {
        case Monday = 1
        case Tuesday = 2
        case Wednesday = 3
        case Thursday = 4
        case Friday = 5
        case Saturday = 6
        case Sunday = 7
        
        var fullName: String {
            switch self {
            case .Monday:
                return "Понедельник"
            case .Tuesday:
                return "Вторник"
            case .Wednesday:
                return "Среда"
            case .Thursday:
                return "Четверг"
            case .Friday:
                return "Пятница"
            case .Saturday:
                return "Суббота"
            case .Sunday:
                return "Воскресенье"
            }
        }
        var shortName: String {
            switch self {
            case .Monday:
                return "Пн"
            case .Tuesday:
                return "Вт"
            case .Wednesday:
                return "Ср"
            case .Thursday:
                return "Чт"
            case .Friday:
                return "Пт"
            case .Saturday:
                return "Сб"
            case .Sunday:
                return "Вс"
            }
        }
    }
    
    weak var delegate: TrackerCreatorDatePickerDelegate?
    
    private var activeSwitchers: [Int] = []
    
    private let header: UILabel = {
        let header = UILabel()
        header.text = "Расписание"
        header.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return header
    }()
    
    private let dateTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .none
        tableView.tintColor = .ypBlack
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .ypGray
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 16
        tableView.isScrollEnabled = false
        tableView.allowsSelection = false
        tableView.tableHeaderView = UIView()
        
        return tableView
    }()
    
    private let confirmButton: CustomButton = {
        let button = CustomButton()
        
        button.setTitle("Готово", for: .normal)
        button.addTarget(nil, action: #selector(confirmButtonDidPress), for: .touchUpInside)
        
        return button
    }()
    
    private var dateTableViewHelper: TrackerCreatorTableViewHelper?
    
    private let elementSpacing = CustomSpacing(leftInset: 16, rightInset: 16, topInset: 16, elementHeight: 75)
    
    
    init(delegate: TrackerCreatorDatePickerDelegate? = nil) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .ypWhite
        let elements = DayOfWeek.allCases.map({$0.fullName})
        
        setNavBar()
        
        dateTableViewHelper = TrackerCreatorTableViewHelper(tableView: dateTableView, elements: elements, spacing: elementSpacing, accessoryType: .switcher)
        
        dateTableViewHelper?.setSelectedSwitchers(turnedOnArray: activeSwitchers)
        
        setDateTableView(height: CGFloat(elements.count) * elementSpacing.elementHeight)

        setConfirmButton()
    }
    
    func setActiveSwitchers(activeArray: [Int]) {
        activeSwitchers = activeArray
    }
    
    private func setNavBar() {
        navigationItem.titleView = header
    }
    
    private func setDateTableView(height: CGFloat) {
        view.addSubview(dateTableView)
        
        dateTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dateTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            dateTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            dateTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            dateTableView.heightAnchor.constraint(equalToConstant: height)
        ])
    }
    
    private func setConfirmButton() {
        view.addSubview(confirmButton)
        
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            confirmButton.heightAnchor.constraint(equalToConstant: confirmButton.designedHeight),
        ])
    }
    
    @objc
    private func confirmButtonDidPress() {
        guard let selectedElements = dateTableViewHelper?.selectedElements else { return }
        let sortedElements = selectedElements.sorted()
        var days: [(Int, String)] = []
        for element in sortedElements {
            guard let day = DayOfWeek(rawValue: element) else { continue }
            days.append((day.rawValue, day.shortName))
        }
        delegate?.receivePickedDays(days: days)
        self.dismiss(animated: true)
    }
}