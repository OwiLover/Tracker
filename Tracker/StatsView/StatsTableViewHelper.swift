//
//  StatsTableView.swift
//  Tracker
//
//  Created by Owi Lover on 6/26/25.
//

import UIKit

final class StatsTableViewHelper: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    private var tableView: UITableView
    
    private var elements: [(name: String, value: Int)]
    
    init(tableView: UITableView, elements: [(name: String, value: Int)]) {
        self.tableView = tableView
        self.elements = elements
        
        super.init()
        tableView.register(StatsTableViewCell.self, forCellReuseIdentifier: StatsTableViewCell.reuseIdentifier)
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StatsTableViewCell.reuseIdentifier, for: indexPath)
        cell.prepareForReuse()
        cell.textLabel?.text = String(elements[indexPath.row].value)
        cell.detailTextLabel?.text = elements[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func reloadData(elements: [(name: String, value: Int)]) {
        self.elements = elements
        
        tableView.reloadData()
    }
}
