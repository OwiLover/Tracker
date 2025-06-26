//
//  ViewController.swift
//  Tracker
//
//  Created by Owi Lover on 11/5/24.
//

import UIKit

final class TrackerViewController: UIViewController {
    
    private let analyticsTag: String = "TrackersReports"
    private let analyticsScreenName: String = "TrackerViewController"
    
    private enum LocalizableText: String {
        case emptyCategoriesLabel
        case navigationBarTitle
        case filterButtonTitle
        case nothingFoundLabel
        case streakDaysCount
        
        func getLocalizedText() -> String {
            NSLocalizedString(self.rawValue, value: self.getDefaultText(), comment: "")
        }
        
        func getDefaultText() -> String {
            switch self {
            case .emptyCategoriesLabel:
                return "Что будем отслеживать?"
            case .navigationBarTitle:
                return "Трекеры"
            case .filterButtonTitle:
                return "Фильтры"
            case .nothingFoundLabel:
                return "Ничего не найдено"
            case .streakDaysCount:
                return ""
            }
        }
    }
    
    var categories: [TrackerCategory]?

    var completedTrackers: [TrackerRecord]?
    
    var trackerCollectionViewHelper: TrackerViewCollectionHelper?
    
    var trackerStorage: TrackerStorageProtocol?
    
    private var filteredCategories: [TrackerCategory]?
    
    private var selectedFilter: FilterType?
    
    private var trackerStorageObserver: NSObjectProtocol?
    
    private var selectedDate: Date
    
    private let analyticsService = AnalyticsService()
    
    private var isCurrentDay: Bool {
        let selectedDateString = dateFormatter.string(from: self.selectedDate)
        let currentDateString = dateFormatter.string(from: Date())
        
        return selectedDateString == currentDateString
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.locale = .current
        return formatter
    }()
    
    private lazy var trackerCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collection.backgroundColor = nil
        collection.isScrollEnabled = true
        
        collection.allowsMultipleSelection = false
        collection.allowsSelection = false
        
        return collection
    }()
    
    private lazy var emptyCategoriesImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "TrackerEmptyIcon"))

        return imageView
    }()
    
    private lazy var emptyCategoriesLabel: UILabel = {
        let label = UILabel()
        label.text = LocalizableText.emptyCategoriesLabel.getLocalizedText()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        
        return label
    }()
    
    private lazy var emptyCategoriesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.axis = .vertical
        
        stackView.isHidden = true
        
        return stackView
    }()
    
    private lazy var nothingFoundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "TrackerNothingFoundIcon"))
        
        return imageView
    }()
    
    private lazy var nothingFoundLabel: UILabel = {
        let label = UILabel()
        label.text = LocalizableText.nothingFoundLabel.getLocalizedText()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        
        return label
    }()
    
    private lazy var nothingFoundStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.axis = .vertical
        
        stackView.isHidden = true
        
        return stackView
    }()
    
    private lazy var filterButton: CustomFilterButton = {
        let button = CustomFilterButton()
        
        let title = LocalizableText.filterButtonTitle.getLocalizedText()
        
        button.setTitle(title, for: .normal)
        button.addTarget(nil, action: #selector(filterButtonWasPressed), for: .touchUpInside)
        
        return button
    }()
    
    init(trackerStorage: TrackerStorageProtocol? = TrackerStorage.shared, selectedDate: Date? = nil) {
        self.trackerStorage = trackerStorage
        self.selectedDate = selectedDate ?? Date()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypWhite
        
        navigationBarSetup()
        setEmptyTrackersStackView()
        setNothingFoundStackView()
        setTrackerCollectionView()
        setFilterButton()
        
        trackerStorageObserver = NotificationCenter.default.addObserver(forName: TrackerStorage.didAddTracker, object: nil, queue: .main, using: { [weak self] notification in
            guard let self else { return }
            self.reloadCollection(date: self.selectedDate)
        })
        
        let dayOfWeek = selectedDate.dayNumberOfWeek()
        
        let filteredCategories = getFilteredTrackerCategory(dayOfWeek: dayOfWeek, isToday: true)
        
        let records = trackerStorage?.completedTrackers
        
        let dictionary = TrackerRecordDictionary(trackerRecords: records)
        
        trackerCollectionViewHelper = TrackerViewCollectionHelper(collectionView: trackerCollectionView, elements: filteredCategories, elementsRecordDictionary: dictionary, delegate: self)
        
        guard let filteredCategories, !filteredCategories.isEmpty else {
            showTrackersArrayIsEmpty()
            return
        }
        hideTrackersArrayIsEmpty()
        
        reloadCollection(date: selectedDate)
        
        analyticsService.report(name: analyticsTag, event: .open, screen: analyticsScreenName, item: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        stopTypingFromSearchBar()
    }
    
    deinit {
        analyticsService.report(name: analyticsTag, event: .close, screen: analyticsScreenName, item: nil)
    }

    
    private func navigationBarSetup() {
        self.navigationItem.title = LocalizableText.navigationBarTitle.getLocalizedText()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        
        setNavigationBarAddTrackerButton()
        setNavigationBarDatePicker()
        setNavigationBarSearchBar()
    }
    
    private func setEmptyTrackersStackView() {
        
        emptyCategoriesImageView.translatesAutoresizingMaskIntoConstraints = false
        
        emptyCategoriesStackView.addArrangedSubview(emptyCategoriesImageView)
        
        emptyCategoriesStackView.addArrangedSubview(emptyCategoriesLabel)
        
        emptyCategoriesStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(emptyCategoriesStackView)
        
        NSLayoutConstraint.activate([
            emptyCategoriesStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emptyCategoriesStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            emptyCategoriesStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            emptyCategoriesStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            emptyCategoriesImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyCategoriesImageView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func setNothingFoundStackView() {
        
        nothingFoundImageView.translatesAutoresizingMaskIntoConstraints = false
        
        nothingFoundStackView.addArrangedSubview(nothingFoundImageView)
        
        nothingFoundStackView.addArrangedSubview(nothingFoundLabel)
        
        nothingFoundStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(nothingFoundStackView)
        
        NSLayoutConstraint.activate([
            nothingFoundStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            nothingFoundStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            nothingFoundStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            nothingFoundStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nothingFoundImageView.widthAnchor.constraint(equalToConstant: 80),
            nothingFoundImageView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func setTrackerCollectionView() {
        trackerCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(trackerCollectionView)
        
        NSLayoutConstraint.activate([
            trackerCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            trackerCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            trackerCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            trackerCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
    private func setFilterButton() {
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(filterButton)
        
        NSLayoutConstraint.activate([
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            filterButton.heightAnchor.constraint(equalToConstant: CustomFilterButton.designedHeight)
        ])
    }
    
    @objc
    private func filterButtonWasPressed() {
        
        analyticsService.report(name: analyticsTag, event: .click, screen: analyticsScreenName, item: .filter)
        
        let filter = selectedFilter ?? FilterType.all
        
        let filterViewController = FilterViewController(pickedFilter: filter, delegate: self)
        filterViewController.modalPresentationStyle = .popover
        
        let navBar = UINavigationController(rootViewController: filterViewController)
        
        stopTypingFromSearchBar()
        self.present(navBar, animated: true)
    }
    
    private func stopTypingFromSearchBar() {
        guard let searchController = navigationItem.searchController else { return }
        searchController.searchBar.endEditing(true)
        searchController.searchBar.resignFirstResponder()
    }
    
    private func showTrackersArrayIsEmpty() {
        emptyCategoriesStackView.isHidden = false
        trackerCollectionView.isHidden = true
        nothingFoundStackView.isHidden = true
        hideFilterButton()
    }
    
    private func hideTrackersArrayIsEmpty() {
        emptyCategoriesStackView.isHidden = true
        trackerCollectionView.isHidden = false
        showFilterButton()
    }
    
    private func showNothingFound() {
        nothingFoundStackView.isHidden = false
        trackerCollectionView.isHidden = true
        emptyCategoriesStackView.isHidden = true
    }
    
    private func hideNothingFound() {
        nothingFoundStackView.isHidden = true
        trackerCollectionView.isHidden = false
    }
    
    private func showFilterButton() {
        filterButton.isHidden = false
    }
    
    private func hideFilterButton() {
        filterButton.isHidden = true
    }
    
    private func setNavigationBarAddTrackerButton() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "NavBarPlusIcon"), style: .done, target: self, action: #selector(addTrackerButtonTapped))
    }
    
    @objc
    private func addTrackerButtonTapped() {
        let trackerCreator = TrackerCreatorPickerController()
        let navigationBar = UINavigationController(rootViewController: trackerCreator)
        
        analyticsService.report(name: analyticsTag, event: .click, screen: analyticsScreenName, item: .add_track)
        
        self.stopTypingFromSearchBar()
        modalPresentationStyle = .popover
        
        present(navigationBar, animated: true)
    }
    
    private func setNavigationBarDatePicker() {
        let datePickerButton = UIDatePicker()
        
        datePickerButton.datePickerMode = .date
        datePickerButton.preferredDatePickerStyle = .compact
        datePickerButton.tintColor = .ypBlue
        datePickerButton.addTarget(self, action: #selector(datePicked), for: .valueChanged)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePickerButton)
    }
    
    @objc
    private func datePicked(_ datePicker: UIDatePicker) {
        let date = datePicker.date
        (selectedFilter == .today && isCurrentDay) ? selectedFilter = .all : ()
        print("Current filter: \(selectedFilter?.rawValue ?? "none")")
        reloadCollection(date: date)
    }
    
    private func setNavigationBarSearchBar() {
        let searchController = UISearchController()
        
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.tintColor = .ypBlue
        searchController.searchResultsUpdater = self

        self.navigationItem.searchController = searchController
    }
    
    private func setNavigationBarRightButton() {
        
        let datePickerButton = UIButton()
        
        let currentDate = dateFormatter.string(from: Date())
        
        datePickerButton.setTitle(currentDate, for: .normal)
        datePickerButton.setTitleColor(.black, for: .normal)
        datePickerButton.setTitleColor(.black.withAlphaComponent(0.3), for: .highlighted)
        
        datePickerButton.backgroundColor = .ypLightGray
        datePickerButton.layer.cornerRadius = 8
        
        guard let title = datePickerButton.titleLabel else { return }
        datePickerButton.translatesAutoresizingMaskIntoConstraints = false
        
        datePickerButton.heightAnchor.constraint(equalTo: title.heightAnchor, constant: 12).isActive = true
        datePickerButton.widthAnchor.constraint(equalTo: title.widthAnchor, constant: 11).isActive = true
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePickerButton)
    }
    
    private func getFilteredTrackerCategory(dayOfWeek: Int?, isToday: Bool) -> [TrackerCategory]? {
        
        guard let trackers = trackerStorage?.categoriesArray, let dayOfWeek else { return nil }
        
        categories = trackers.map({
            category in

            let acceptedElements = category.array.filter({
                element in
                
                
                let filter = element.schedule.contains(where: {day in
                    day == dayOfWeek 
                })
                
                return isToday ? filter || element.schedule.isEmpty : filter
            })
            
            let newCategory = TrackerCategory(category: category.category, array: acceptedElements)
            return newCategory
        })
        
        categories = categories?.filter({ category in
            !category.array.isEmpty
        })
        
        return categories
    }
    
    private func getSearchFieldFilteredTrackerCategory(categories: [TrackerCategory], searchedWords: String) -> [TrackerCategory]? {
        filteredCategories = categories.map({
            category in
            
            let acceptedElements = category.array.filter({
                element in
                
                let filter = element.name.lowercased().contains(searchedWords.lowercased())
                return filter
            })
            let filteredCategory = TrackerCategory(category: category.category, array: acceptedElements)
            return filteredCategory
        })
        filteredCategories = filteredCategories?.filter( { !$0.array.isEmpty })
        
        return filteredCategories
    }
    
    private func getFilteredTrackerCategory(categories: [TrackerCategory]) -> [TrackerCategory] {
        switch selectedFilter {
        case .all:
            return categories
            
        case .today:
            return categories
            
        case .completed:
            guard let completedTrackers = trackerStorage?.completedTrackers else {
                return []
            }
            var filteredCategories = categories.map({ category in
                let acceptedTrackers = category.array.filter({
                    tracker in
                    
                    let currentDateString = dateFormatter.string(from: Date())
                    
                    return completedTrackers.contains(where: { records in
                        let recordDateString = dateFormatter.string(from: records.date)
                        return records.id == tracker.id && recordDateString == currentDateString
                    })
                })
                return TrackerCategory(category: category.category, array: acceptedTrackers)
            })
            
            filteredCategories = filteredCategories.filter( { !$0.array.isEmpty })
            
            return filteredCategories
            
        case .notCompleted:
            guard let completedTrackers = trackerStorage?.completedTrackers else {
                return categories
            }
            
            var filteredCategories = categories.map({ category in
                let acceptedTrackers = category.array.filter({
                    tracker in
                    
                    let currentDateString = dateFormatter.string(from: Date())
                    
                    return !completedTrackers.contains(where: { records in
                        let recordDateString = dateFormatter.string(from: records.date)
                        return records.id == tracker.id && recordDateString == currentDateString
                    })
                })
                return TrackerCategory(category: category.category, array: acceptedTrackers)
            })
            
            filteredCategories = filteredCategories.filter( { !$0.array.isEmpty })
            
            return filteredCategories
            
        case .none:
            return categories
        }
    }
    
//    private func getPinnedTrackerCategory(categories: [TrackerCategory]) -> [TrackerCategory] {
//        
//    }

    
    private func reloadCollection(date: Date) {
        selectedDate = date
        
        guard let dayOfWeek = selectedDate.dayNumberOfWeek(), var filteredCategories = getFilteredTrackerCategory(dayOfWeek: dayOfWeek, isToday: isCurrentDay), !filteredCategories.isEmpty else {
            showTrackersArrayIsEmpty()
            return
        }
        
        if let searchController = navigationItem.searchController, let words = searchController.searchBar.text, !words.isEmpty {
            
            filteredCategories = getSearchFieldFilteredTrackerCategory(categories: filteredCategories, searchedWords: words) ?? filteredCategories
        }
        
        filteredCategories = getFilteredTrackerCategory(categories: filteredCategories)
        
        filteredCategories.isEmpty ? showNothingFound() : hideNothingFound()
        
        hideTrackersArrayIsEmpty()
        
        trackerCollectionViewHelper?.reloadCollection(newElements: filteredCategories, isCurrentDay: isCurrentDay)
    }
}

extension TrackerViewController: TrackerViewCollectionHelperDelegate {
    
    func deleteTracker(trackerId: UUID) {
        analyticsService.report(name: analyticsTag, event: .click, screen: analyticsScreenName, item: .delete)
        trackerStorage?.deleteTracker(id: trackerId)
    }
    
    func pinTracker(trackerId: UUID) {
        trackerStorage?.pinTracker(id: trackerId)
        reloadCollection(date: selectedDate)
    }
    
    func unpinTracker(trackerId: UUID) {
        trackerStorage?.unpinTracker(id: trackerId)
        reloadCollection(date: selectedDate)
    }
    
    func editTracker(trackerId: UUID) {
        
        analyticsService.report(name: analyticsTag, event: .click, screen: analyticsScreenName, item: .edit)
        
        let tracker = trackerStorage?.getTracker(id: trackerId)
        var isRegular = true
        if let tracker {
            if tracker.tracker.schedule.isEmpty {
                isRegular = false
            }
        }

        let streakCount = trackerStorage?.getTrackersStreakCount(id: trackerId) ?? 0
        
        let trackerController = TrackerCreatorController(trackerCreatorType: isRegular ? .regular : .unRegular, creatorMode: .edit, trackerId: trackerId, streakCount: streakCount, delegate: self)
        
        stopTypingFromSearchBar()
        
        let navBar = UINavigationController(rootViewController: trackerController)
        present(navBar, animated: true)
    }
    
    func updateStreak(shouldIncrease: Bool, trackerId: UUID) {
        analyticsService.report(name: analyticsTag, event: .click, screen: analyticsScreenName, item: .track)
        
        guard let trackerStorage else { return }
        shouldIncrease ? trackerStorage.markTrackerAsCompleted(id: trackerId) : trackerStorage.unmarkTrackerAsCompleted(id: trackerId)
        
        let records = trackerStorage.completedTrackers
        
        let dictionary = TrackerRecordDictionary(trackerRecords: records)
        
        trackerCollectionViewHelper?.updateElementRecords(elementRecordDictionary: dictionary)
    }
}

extension TrackerViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        reloadCollection(date: selectedDate)
    }
}

extension TrackerViewController: FilterDelegate {
    func receiveFilter(filter: FilterType) {
        self.selectedFilter = filter
        guard let datePicker = self.navigationItem.rightBarButtonItem?.customView as? UIDatePicker else {
            return
        }
        if selectedFilter == .today {
            selectedDate = Date()
            datePicker.setDate(selectedDate, animated: true)
        }
        
        reloadCollection(date: selectedDate)
    }
}

extension TrackerViewController: TrackerCreatorControllerDelegate {
    func trackerWasCreated() {
        reloadCollection(date: selectedDate)
    }
}
