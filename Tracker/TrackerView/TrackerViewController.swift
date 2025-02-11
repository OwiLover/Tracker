//
//  ViewController.swift
//  Tracker
//
//  Created by Owi Lover on 11/5/24.
//

import UIKit

final class TrackerViewController: UIViewController {
    
    var categories: [TrackerCategory]?

    var completedTrackers: [TrackerRecord]?
    
    var trackerCollectionViewHelper: TrackerViewCollectionHelper?
    
    var trackerStorage: TrackerStorageProtocol? = TrackerStorage.shared
    
    
    private var trackerStorageObserver: NSObjectProtocol?
    
    private var selectedDate: Date = Date()
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    private lazy var trackerCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collection.backgroundColor = nil
        collection.isScrollEnabled = true
        
        return collection
    }()
    
    private lazy var emptyCategoriesImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "TrackerEmptyIcon"))

        return imageView
    }()
    
    private lazy var emptyCategoriesLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypWhite
        
        navigationBarSetup()
        setEmptyTrackersStackView()
        setTrackerCollectionView()
        
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
    }
    
    private func navigationBarSetup() {
        self.navigationItem.title = "Трекеры"
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
    
    private func showTrackersArrayIsEmpty() {
        emptyCategoriesStackView.isHidden = false
        trackerCollectionView.isHidden = true
    }
    
    private func hideTrackersArrayIsEmpty() {
        emptyCategoriesStackView.isHidden = true
        trackerCollectionView.isHidden = false
    }
    
    private func setNavigationBarAddTrackerButton() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "NavBarPlusIcon"), style: .done, target: self, action: #selector(addTrackerButtonTapped))
    }
    
    
    @objc
    private func addTrackerButtonTapped() {
        let trackerCreator = TrackerCreatorPickerController()
        let navigationBar = UINavigationController(rootViewController: trackerCreator)

        modalPresentationStyle = .popover
        
        present(navigationBar, animated: true)
    }
    
    /*
     Изначально была идея создать кнопку с датой, однако во время беседы с наставником выяснилось, что с таким подходом реализовать функционал всплывающего календаря крайне сложно и следует использовать DatePicker в стиле .compact, хоть он и не совсем соответствует макету
     Однако мне всё ещё интересно, как можно было реализовать появление календаря через обычный UIButton?
     */
    
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
        reloadCollection(date: date)
    }
    
    private func setNavigationBarSearchBar() {
        let searchController = UISearchController()
        
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.tintColor = .ypBlue

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
    
    private func reloadCollection(date: Date) {
        selectedDate = date
        let selectedDateString = dateFormatter.string(from: selectedDate)
        let currentDateString = dateFormatter.string(from: Date())
        
        let isCurrentDay: Bool = selectedDateString == currentDateString
        
        guard let dayOfWeek = selectedDate.dayNumberOfWeek(), let filteredCategories = getFilteredTrackerCategory(dayOfWeek: dayOfWeek, isToday: isCurrentDay), !filteredCategories.isEmpty else {
            showTrackersArrayIsEmpty()
            return
        }
        
        hideTrackersArrayIsEmpty()
        trackerCollectionViewHelper?.reloadCollection(newElements: filteredCategories, isCurrentDay: isCurrentDay)
    }
}

extension TrackerViewController: TrackerViewCollectionHelperDelegate {
    func updateStreak(shouldIncrease: Bool, trackerId: UInt32) {
        guard let trackerStorage else { return }
        shouldIncrease ? trackerStorage.markTrackerAsCompleted(id: trackerId) : trackerStorage.unmarkTrackerAsCompleted(id: trackerId)
        
        let records = trackerStorage.completedTrackers
        
        let dictionary = TrackerRecordDictionary(trackerRecords: records)
        
        trackerCollectionViewHelper?.updateElementRecords(elementRecordDictionary: dictionary)
    }
}

