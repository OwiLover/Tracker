//
//  StatsViewController.swift
//  Tracker
//
//  Created by Owi Lover on 11/7/24.
//

import UIKit

final class StatsViewController: UIViewController {
    
    private enum LocalizableText: String {
        case emptyStatsLabel
        case statsViewTitle
        case statsCompletedTrackers
        
        func getLocalizedText() -> String {
            NSLocalizedString(self.rawValue, value: self.getDefaultText(), comment: "")
        }
        
        func getDefaultText() -> String {
            switch self {
            case .emptyStatsLabel:
                return "Анализировать пока нечего"
            case .statsViewTitle:
                return "Статистика"
            case .statsCompletedTrackers:
                return "Трекеров завершено"
            }
        }
    }
    
    private var statsChangeObserver: NSObjectProtocol?
    private var statsHelper: StatsTableViewHelper?
    private var trackerStorage: TrackerStorageProtocol? = TrackerStorage.shared
    
    private lazy var emptyStatsImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "EmptyStatsIcon"))

        return imageView
    }()
    
    private lazy var emptyStatsLabel: UILabel = {
        let label = UILabel()
        label.text = LocalizableText.emptyStatsLabel.getLocalizedText()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        
        return label
    }()

    private lazy var emptyStatsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.axis = .vertical
        
        stackView.isHidden = true
        
        return stackView
    }()
    
    private lazy var statsTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(StatsTableViewCell.self,
                           forCellReuseIdentifier: StatsTableViewCell.reuseIdentifier)
        tableView.bounces = false
        tableView.layer.masksToBounds = true
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypWhite
        
        navigationBarSetup()
        setEmptyStatsStackView()
        setStatsTableView()
        
        let completedTrackers = trackerStorage?.completedTrackers.count ?? 0
        
        completedTrackers > 0 ? showStats() : showStatsAreEmpty()
        
        
        
        statsHelper = StatsTableViewHelper(tableView: statsTableView, elements: [(LocalizableText.statsCompletedTrackers.getLocalizedText(), completedTrackers)])
        
        statsChangeObserver = NotificationCenter.default.addObserver(forName: TrackerStorage.didAddRecord, object: nil, queue: .main, using: { [weak self] notification in
            guard let self else { return }
            
            let completedTrackers = self.trackerStorage?.completedTrackers.count ?? 0
            print("RecordsCount: ",completedTrackers)
            completedTrackers > 0 ? showStats() : showStatsAreEmpty()
            
            statsHelper?.reloadData(elements: [(LocalizableText.statsCompletedTrackers.getLocalizedText(), completedTrackers)])
        })
    }

    private func navigationBarSetup() {
        self.navigationItem.title = LocalizableText.statsViewTitle.getLocalizedText()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        let searchController = UISearchController()
        
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.isActive = false
        searchController.searchBar.isHidden = true

        self.navigationItem.searchController = searchController
    }

    private func setEmptyStatsStackView() {
        
        emptyStatsImageView.translatesAutoresizingMaskIntoConstraints = false
        
        emptyStatsStackView.addArrangedSubview(emptyStatsImageView)
        
        emptyStatsStackView.addArrangedSubview(emptyStatsLabel)
        
        emptyStatsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(emptyStatsStackView)
        
        let searchBarHeight = navigationItem.searchController?.searchBar.bounds.height ?? 0
        
        print(searchBarHeight)
        
        NSLayoutConstraint.activate([
            emptyStatsStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emptyStatsStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -(searchBarHeight/2)),
            emptyStatsStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            emptyStatsStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            emptyStatsImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyStatsImageView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func setStatsTableView() {
        statsTableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(statsTableView)
        
        NSLayoutConstraint.activate([
            statsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            statsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            statsTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            statsTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
        ])
    }

    private func showStatsAreEmpty() {
        emptyStatsStackView.isHidden = false
        statsTableView.isHidden = true
    }

    private func showStats() {
        emptyStatsStackView.isHidden = true
        statsTableView.isHidden = false
    }
}
