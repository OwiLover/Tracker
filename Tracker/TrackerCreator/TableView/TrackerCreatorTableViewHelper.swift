//
//  TrackerCreatorTableViewHelper.swift
//  Tracker
//
//  Created by Owi Lover on 11/21/24.
//

import UIKit

final class TrackerCreatorTableViewHelper: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    enum AccessoryType {
        case disclosure
        case switcher
        case checkmark
    }
    
    weak var delegate: TrackerCreatorTableViewHelperDelegate?
    
    private(set) var selectedElements: Set<Int> = Set<Int>()
    
    private(set) var checkMarkedElement: TrackerCreatorTableViewCell? = nil
    
    private(set) var checkMarkedElementName: String? = nil
    
    private var elements: [String]
    
    private var tableView: UITableView
    
    private var spacing: CustomSpacing
    
    private let accessoryType: AccessoryType
    
    init(tableView: UITableView, elements: [String], spacing: CustomSpacing = CustomSpacing(leftInset: 16, rightInset: 16, topInset: 0, elementHeight: 75), delegate: TrackerCreatorTableViewHelperDelegate? = nil, accessoryType: AccessoryType) {
                
        self.elements = elements
        self.tableView = tableView
        self.spacing = spacing
        self.delegate = delegate
        self.accessoryType = accessoryType
        super.init()
        
        tableView.register(TrackerCreatorTableViewCell.self, forCellReuseIdentifier: TrackerCreatorTableViewCell.identifier)
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TrackerCreatorTableViewCell.identifier, for: indexPath) as? TrackerCreatorTableViewCell else { return UITableViewCell() }
        cell.prepareForReuse()
        
        cell.textLabel?.text = elements[indexPath.row]

        switch accessoryType {
        case .disclosure:
            cell.accessoryType = .disclosureIndicator
        case .switcher:
            let switcher = UISwitch()
            switcher.tag = indexPath.row+1
            switcher.onTintColor = .ypBlue
            switcher.tintColor = .ypLightGray
            switcher.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
            
            if selectedElements.contains(switcher.tag) {
                switcher.isOn = true
            }
            cell.accessoryView = switcher
        
        case .checkmark:
            if elements[indexPath.row] == checkMarkedElementName {
                markCell(cell: cell)
            } else {
                cell.accessoryType = .none
            }
        }
        
        if indexPath.row + 1 == elements.count {

            cell.setInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width)
            
            elements.count == 1 ? cell.setAsTheOnlyCell() : cell.setAsLastCell()

        } else {
            cell.setInsets(top: 0, left: spacing.leftInset, bottom: 0, right: spacing.rightInset)
            if indexPath.row == 0 {
                cell.setAsFirstCell()
            }
        }

        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return spacing.elementHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? TrackerCreatorTableViewCell, let header = cell.textLabel?.text else { return }
        switch self .accessoryType {
        case .disclosure:
            self.delegate?.cellWasPressed(withHeader: header)
        case .checkmark:
            markCell(cell: cell)
            
            self.delegate?.cellWasPressed(withHeader: header)
        case .switcher:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func updateTable(elements: [String]) {
        
        guard elements.count != self.elements.count else { return }
        let newCount = elements.count
        let oldCount = self.elements.count
        
        self.elements = elements
        
        self.tableView.performBatchUpdates({ [weak self] in
            guard let self else { return }
            if oldCount != newCount {
                let indexPathArray = (oldCount..<newCount).map {
                    index in
                    return IndexPath(row: index, section: 0)
                }
                self.tableView.insertRows(at: indexPathArray, with: .automatic)
                }
        })
        self.tableView.reloadData()
        print("Updated!")
    }
    
    func setSelectedSwitchers(turnedOnArray: [Int]) {
        guard !turnedOnArray.isEmpty else { return }
        switch accessoryType {
        case .switcher:
            selectedElements.formUnion(turnedOnArray)
        default:
            break
        }
    }
    
    func setMarkedElement(withName name: String?) {
        checkMarkedElementName = name
    }
    
    private func markCell(cell: TrackerCreatorTableViewCell) {
        if let lastCheckedCell = checkMarkedElement {
            lastCheckedCell.accessoryView = .none
        }
        checkMarkedElement = cell
        let image = UIImage(named: "CheckmarkSymbol")
        let checkMarkImageView = UIImageView(image: image)
        cell.accessoryView = checkMarkImageView
    }
    
    @objc
    private func switchValueChanged(_ sender: UISwitch) {
        let weekDay = sender.tag
        if sender.isOn {
            selectedElements.insert(weekDay)
        }
        else {
            selectedElements.remove(weekDay)
        }
    }
}
