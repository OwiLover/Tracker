//
//  TrackerCreatorRegularView.swift
//  Tracker
//
//  Created by Owi Lover on 11/19/24.
//

import UIKit

// MARK: Вопрос, как стоит реализовывать enum для выбора поведения класса?
//    Внутри класса как статическая переменная, просто переменная или отдельно от класса?

enum TrackerType {
    case regular
    case unRegular
}

final class TrackerCreatorController: UIViewController {
    
    enum CreatorMode {
        case create
        case edit
    }
    
    enum CollectionHeaderNames: String {
        case emojiCollection = "Emoji"
        case colorCollection = "Цвет"
    }
    
    enum TableViewHeaderNames: String, CaseIterable {
        case tableViewCategoryCell = "Категория"
        case tableViewScheduleCell = "Расписание"
    }
    
    private enum LocalizableText: String {
        case trackerCreatorHeaderTitle
        case tableViewCategoryCellTitle
        case tableViewScheduleCellTitle
        
        func getLocalizedText() -> String {
            NSLocalizedString(self.rawValue, value: self.getDefaultText(), comment: "")
        }
        
        func getDefaultText() -> String {
            switch self {
            case .trackerCreatorHeaderTitle:
                return "Новая привычка"
            case .tableViewCategoryCellTitle:
                return "Категория"
            case .tableViewScheduleCellTitle:
                return "Расписание"
            }
        }
    }
    
    let trackerCreatorType: TrackerType
    
    let creatorMode: CreatorMode
    
    var trackerStorage: TrackerStorageProtocol?
    
    var categoryPicked: String?
    var daysOfWeekPicked = [Int]()
    var emojiPicked: String?
    var colorPicked: UIColor?
    var nameCreated: String = ""
    
    private var trackerOldId: UUID?
    private var trackerOldCategory: String?
    private let streakCount: Int?
    
    private weak var delegate: TrackerCreatorControllerDelegate?
    
    private let emojiArray = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"]
    
    private let colorArray = [UIColor.colorSelection1, UIColor.colorSelection2,UIColor.colorSelection3, UIColor.colorSelection4,UIColor.colorSelection5, UIColor.colorSelection6,UIColor.colorSelection7, UIColor.colorSelection8,UIColor.colorSelection9, UIColor.colorSelection10,UIColor.colorSelection11, UIColor.colorSelection12,UIColor.colorSelection13, UIColor.colorSelection14,UIColor.colorSelection15, UIColor.colorSelection16,UIColor.colorSelection17, UIColor.colorSelection18]

    
    private let collectionSpacing = CollectionSpacing(elementsInRow: 6, leftInset: 18, rightInset: 18, topInset: 24, bottomInset: 24, spaceBetweenElementsInRow: 5, spaceBetweenElementsInColumn: 0)
    
    private let elementSpacing = CustomSpacing(leftInset: 16, rightInset: 16, topInset: 24, elementHeight: 75)
    
    private var maxLengthWarningLabelConstraints: [NSLayoutConstraint] = []
    
    private lazy var header: UILabel = {
        let header = UILabel()
        
        let name = {
            switch creatorMode {
            case .create:
                return "Новая привычка"
            case .edit:
                return "Редактирование привычки"
            }
        }()
        
        header.text = name
        header.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return header
    }()
    
    private lazy var emojiCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = nil
        collection.isScrollEnabled = false
        return collection
    }()
    
    private lazy var colorCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = nil
        collection.isScrollEnabled = false
        return collection
    }()
    
    private lazy var trackerNameTextField: CustomTextField = {
        let textField = CustomTextField()
    
        textField.placeholder = "Введите название трекера"
        
        textField.text = nameCreated
        
        textField.addTarget(nil, action: #selector(trackerNameTextFieldDidChange), for: .editingChanged)
        
        return textField
    }()
    
    private lazy var maxLengthWarningLabel: CustomWarningLabel = {
        let label = CustomWarningLabel()
        
        label.isHidden = true
        
        label.text = "Ограничение 38 символов"
        
        return label
    }()
    
    private lazy var tableView: UITableView = {
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
    
    private lazy var cancelButton: UIButton = {
        let font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        let cancelButton = UIButton()
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.setTitleColor(.ypRed, for: .normal)
        cancelButton.titleLabel?.font = font
        
        cancelButton.backgroundColor = .none
        
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.masksToBounds = true
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.ypRed.cgColor
        
        cancelButton.addTarget(nil, action: #selector(cancelButtonPressed), for: .touchUpInside)
        
        return cancelButton
    }()
    
    private lazy var createButton: CustomButton  = {
        
        let createButton = CustomButton()

        let name = {
            switch creatorMode {
            case .create:
                return "Создать"
            case .edit:
                return "Сохранить"
            }
        }()
        createButton.setTitle(name, for: .normal)
        createButton.isEnabled = false
        
        createButton.addTarget(nil, action: #selector(createButtonPressed), for: .touchUpInside)
        
        return createButton
    }()
    
    private lazy var trackerNameView: UIView = {
        let view = UIView()
        
        return view
    }()
    
    private lazy var buttonsView: UIView = {
        let buttonsView = UIView()

        return buttonsView
    }()
    
    private lazy var scrollView: CustomScrollView = {
        let scrollView = CustomScrollView()
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .none
        scrollView.contentInset.top = 24

        return scrollView
    }()
    
    private lazy var streakLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.numberOfLines = 0
        
        let count = streakCount ?? 0
        
        let text = getDayCountString(number: count)
        label.text = "\(count) \(text)"
        
        return label
    }()
    
    private var emojiHelper: TrackerCreatorCollectionHelper<String>?
    
    private var colorHelper: TrackerCreatorCollectionHelper<UIColor>?
    
    private var tableViewHelper: CustomTableViewHelper?
    
    init(trackerCreatorType: TrackerType, creatorMode: CreatorMode = .create, trackerId: UUID? = nil, streakCount: Int? = nil, trackerStorage: TrackerStorageProtocol? = TrackerStorage.shared, delegate: TrackerCreatorControllerDelegate? = nil) {
        self.trackerStorage = trackerStorage
        self.trackerCreatorType = trackerCreatorType
        self.delegate = delegate
        self.creatorMode = creatorMode
        self.streakCount = streakCount
        
        super.init(nibName: nil, bundle: nil)
        
        if let trackerId, creatorMode == .edit {
            let trackerAndCategory = trackerStorage?.getTracker(id: trackerId)
            self.categoryPicked = trackerAndCategory?.category
            self.nameCreated = trackerAndCategory?.tracker.name ?? ""
            self.daysOfWeekPicked = trackerAndCategory?.tracker.schedule ?? []
            self.emojiPicked = trackerAndCategory?.tracker.emoji
            self.colorPicked = trackerAndCategory?.tracker.color
            self.trackerOldId = trackerAndCategory?.tracker.id
            self.trackerOldCategory = trackerAndCategory?.category
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        super.present(viewControllerToPresent, animated: true)
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypWhite
        
        trackerNameTextField.delegate = self
        
        let tableViewElements = (trackerCreatorType == .unRegular) ?
        TableViewHeaderNames.allCases.filter({ header in
            if header == .tableViewScheduleCell {
                return false
            }
            return true
        }).map({$0.rawValue}) : TableViewHeaderNames.allCases.map({$0.rawValue})
        
        setNavBar()
        
        setFullView(for: scrollView, baseView: view)
        
        switch creatorMode {
        case .create:
            setScrollViewTopElement(scrollView: scrollView, element: trackerNameTextField, spacing: elementSpacing, overrideTopInset: 0)
        case .edit:
            setScrollViewTopElement(scrollView: scrollView, element: streakLabel, spacing: elementSpacing, overrideTopInset: 0, overrideHeight: 38)
            
            _ = setScrollViewElement(scrollView: scrollView, under: streakLabel, element: trackerNameTextField, spacing: elementSpacing, overrideTopInset: 40)
        }
        
        maxLengthWarningLabelConstraints = setScrollViewElement(scrollView: scrollView, under: trackerNameTextField, element: maxLengthWarningLabel, spacing: nil)
        
        let underElements = {
            let category = categoryPicked ?? ""
            let days = convertDaysIntToString(days: daysOfWeekPicked)
            
            switch trackerCreatorType {
            case .regular:
                return [category, days]
            case .unRegular:
                return [category]
            }
        }()
        
        tableViewHelper = CustomTableViewHelper(tableView: tableView, elements: tableViewElements, underElements: underElements, spacing: elementSpacing, delegate: self, accessoryType: .disclosure)
        
        _ = setScrollViewElement(scrollView: scrollView, under: maxLengthWarningLabel, element: tableView, spacing: elementSpacing, overrideHeight: elementSpacing.elementHeight * CGFloat(tableViewElements.count))
        
        emojiHelper = TrackerCreatorCollectionHelper(headerTitle: CollectionHeaderNames.emojiCollection.rawValue, elements: emojiArray, selectedElement: emojiPicked, spacing: collectionSpacing, collection: emojiCollectionView, delegate: self)
        
        let totalEmojiCollectionHeight = getCollectionHeight(for: view, collectionSpacing: collectionSpacing, elementsCount: emojiArray.count)
        
        _ = setScrollViewElement(scrollView: scrollView, under: tableView, element: emojiCollectionView, spacing: nil, overrideTopInset: 32 ,overrideHeight: totalEmojiCollectionHeight)
        
        colorHelper = TrackerCreatorCollectionHelper(headerTitle: CollectionHeaderNames.colorCollection.rawValue, elements: colorArray, selectedElement: colorPicked, spacing: collectionSpacing, collection: colorCollectionView, delegate: self)
        
        let totalColorCollectionHeight = getCollectionHeight(for: view, collectionSpacing: collectionSpacing, elementsCount: colorArray.count)
        
        _ = setScrollViewElement(scrollView: scrollView, under: emojiCollectionView, element: colorCollectionView, spacing: nil, overrideTopInset: 16, overrideHeight: totalColorCollectionHeight)
        
        setScrollViewBottomElement(scrollView: scrollView, under: colorCollectionView, element: buttonsView, spacing: elementSpacing, overrideTopInset: 16, overrideLeftInset: 20, overrideRightInset: 20, overrideHeight: 60)
        
        setButtonsView(spaceBetweenButtons: 8)
        
    }
    
    private func getDayCountString(number: Int) -> String {
        switch number {
        case 1:
            return "день"
        case 2, 3, 4:
            return "дня"
        default:
            return "дней"
        }
    }
    
    private func setNavBar() {
        navigationItem.titleView = header
    }
        
    private func setButtonsView(spaceBetweenButtons: CGFloat) {
        
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.translatesAutoresizingMaskIntoConstraints = false
        
        buttonsView.addSubview(cancelButton)
        buttonsView.addSubview(createButton)
        
        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: buttonsView.topAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor),
            cancelButton.leadingAnchor.constraint(equalTo: buttonsView.leadingAnchor),
            cancelButton.widthAnchor.constraint(equalTo: buttonsView.widthAnchor, multiplier: 0.5, constant: -spaceBetweenButtons/2),
            cancelButton.heightAnchor.constraint(equalTo: buttonsView.heightAnchor)
        ])
        
        NSLayoutConstraint.activate([
            createButton.topAnchor.constraint(equalTo: buttonsView.topAnchor),
            createButton.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor),
            createButton.trailingAnchor.constraint(equalTo: buttonsView.trailingAnchor),
            createButton.widthAnchor.constraint(equalTo: buttonsView.widthAnchor, multiplier: 0.5, constant: -spaceBetweenButtons/2),
            createButton.heightAnchor.constraint(equalTo: buttonsView.heightAnchor)
        ])
    }
    
    private func getCollectionHeight(for customView: UIView, collectionSpacing: CollectionSpacing, elementsCount: Int) -> CGFloat {

        let elementSize = (customView.frame.width - collectionSpacing.totalMarginInRow) / CGFloat(collectionSpacing.elementsInRow)
        let totalRows = CGFloat(Double(elementsCount)/Double(collectionSpacing.elementsInRow)).rounded(.up)
        let totalHeight = elementSize * totalRows + collectionSpacing.topInset + collectionSpacing.bottomInset + collectionSpacing.spaceBetweenElementsInColumn * totalRows
        
        return totalHeight
    }
    
    private func setFullView(for customView: UIView, baseView: UIView) {
        baseView.addSubview(customView)
        customView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            customView.topAnchor.constraint(equalTo: baseView.safeAreaLayoutGuide.topAnchor),
            customView.bottomAnchor.constraint(equalTo: baseView.safeAreaLayoutGuide.bottomAnchor),
            customView.leadingAnchor.constraint(equalTo: baseView.safeAreaLayoutGuide.leadingAnchor),
            customView.trailingAnchor.constraint(equalTo: baseView.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
    private func setScrollViewTopElement(scrollView: UIScrollView, element: UIView, spacing: CustomSpacing?, overrideTopInset: CGFloat? = nil, overrideLeftInset: CGFloat? = nil, overrideRightInset: CGFloat? = nil, overrideHeight: CGFloat? = nil) {
        
        scrollView.addSubview(element)
        
        element.translatesAutoresizingMaskIntoConstraints = false
        
        let spacing = spacing ?? CustomSpacing(leftInset: 0, rightInset: 0, topInset: 0, elementHeight: 0)
        
        NSLayoutConstraint.activate([
            element.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: overrideTopInset ?? spacing.topInset),
            element.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: overrideLeftInset ?? spacing.leftInset),
            element.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -(overrideRightInset ?? spacing.rightInset)),
            element.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -(overrideLeftInset ?? spacing.leftInset) - (overrideRightInset ?? spacing.rightInset)),
            element.heightAnchor.constraint(equalToConstant: overrideHeight ?? spacing.elementHeight)
        ])
    }
    
    private func setScrollViewElement(scrollView: UIScrollView, under customView: UIView, element: UIView, spacing: CustomSpacing?, overrideTopInset: CGFloat? = nil, overrideLeftInset: CGFloat? = nil, overrideRightInset: CGFloat? = nil, overrideHeight: CGFloat? = nil) -> [NSLayoutConstraint] {
        
        scrollView.addSubview(element)
        
        let spacing = spacing ?? CustomSpacing(leftInset: 0, rightInset: 0, topInset: 0, elementHeight: 0)
        
        element.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            element.topAnchor.constraint(equalTo: customView.bottomAnchor, constant: overrideTopInset ?? spacing.topInset),
            element.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: overrideLeftInset ?? spacing.leftInset),
            element.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -(overrideRightInset ?? spacing.rightInset)),
            element.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -(overrideLeftInset ?? spacing.leftInset) - (overrideRightInset ?? spacing.rightInset)),
            element.heightAnchor.constraint(equalToConstant: overrideHeight ?? spacing.elementHeight)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        return constraints
    }
        
    private func setScrollViewBottomElement(scrollView: UIScrollView, under customView: UIView, element: UIView, spacing: CustomSpacing?, overrideTopInset: CGFloat? = nil, overrideLeftInset: CGFloat? = nil, overrideBottomInset: CGFloat? = nil, overrideRightInset: CGFloat? = nil, overrideHeight: CGFloat? = nil) {
        
        scrollView.addSubview(element)
        
        let spacing = spacing ?? CustomSpacing(leftInset: 0, rightInset: 0, topInset: 0, elementHeight: 0)
        
        element.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            element.topAnchor.constraint(equalTo: customView.bottomAnchor, constant: overrideTopInset ?? spacing.topInset),
            element.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: overrideLeftInset ?? spacing.leftInset),
            element.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -(overrideRightInset ?? spacing.rightInset)),
            element.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -(overrideLeftInset ?? spacing.leftInset) - (overrideRightInset ?? spacing.rightInset)),
            element.heightAnchor.constraint(equalToConstant: overrideHeight ?? spacing.elementHeight),
            element.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
    }
    
    private func changeElementConstraints(stickTo: UIView, under customView: UIView, element: UIView, oldConstraints: [NSLayoutConstraint], spacing: CustomSpacing?, overrideTopInset: CGFloat? = nil, overrideLeftInset: CGFloat? = nil, overrideRightInset: CGFloat? = nil, overrideHeight: CGFloat? = nil) -> [NSLayoutConstraint] {
        
        let spacing = spacing ?? CustomSpacing(leftInset: 0, rightInset: 0, topInset: 0, elementHeight: 0)
        
        NSLayoutConstraint.deactivate(oldConstraints)
        
        let newConstants = [
            element.topAnchor.constraint(equalTo: customView.bottomAnchor, constant: overrideTopInset ?? spacing.topInset),
            element.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: overrideLeftInset ?? spacing.leftInset),
            element.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -(overrideRightInset ?? spacing.rightInset)),
            element.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -(overrideLeftInset ?? spacing.leftInset) - (overrideRightInset ?? spacing.rightInset)),
            element.heightAnchor.constraint(equalToConstant: overrideHeight ?? spacing.elementHeight),
        ]
        
        NSLayoutConstraint.activate(newConstants)
        
        return newConstants
    }
    
    
    private func checkToAllowCreateButton() {
        switch trackerCreatorType {
        case .regular:
            if (colorPicked != nil) && (emojiPicked != nil) && (categoryPicked != nil) && (!daysOfWeekPicked.isEmpty) && (!nameCreated.isEmpty) {
                createButton.isEnabled = true
            } else {
                createButton.isEnabled = false
            }
        case .unRegular:
            if (colorPicked != nil) && (emojiPicked != nil) && (categoryPicked != nil) && (!nameCreated.isEmpty) {
                createButton.isEnabled = true
            } else {
                createButton.isEnabled = false
            }
        }
    }
    
    private func convertDaysIntToString(days: [Int]) -> String {
        if days.count == 7 {
            return "Каждый день"
        } else {
            var daysString: String = ""
            for day in days.dropLast() {
                let dayString = DayOfWeek(rawValue: day)?.shortName ?? ""
                daysString += "\(dayString), "
            }
            guard let last = days.last else {
                return ""
            }
            let lastDayString = DayOfWeek(rawValue: last)?.shortName ?? ""
            daysString += "\(lastDayString)"
            
            return daysString
        }
    }
    
    @objc
    private func cancelButtonPressed() {
        self.dismiss(animated: true)
    }
    
    @objc
    private func trackerNameTextFieldDidChange() {
        guard let name = trackerNameTextField.text else { return }
        
        if name.count < 38 {
            nameCreated = name
            if !maxLengthWarningLabel.isHidden {
                maxLengthWarningLabelConstraints = changeElementConstraints(stickTo: scrollView, under: trackerNameTextField, element: maxLengthWarningLabel, oldConstraints: maxLengthWarningLabelConstraints, spacing: nil)
                
                maxLengthWarningLabel.isHidden = true
                
                UIView.animate(withDuration: 0.25) { [weak self] in
                    guard let self else { return }
                    self.view.layoutIfNeeded()
                }
            }
        }
        else if name.count >= 38 {
            let trimmedName = String(name[name.startIndex..<name.index(name.startIndex, offsetBy: 38)])
            trackerNameTextField.text = trimmedName
            nameCreated = trimmedName
            
            if maxLengthWarningLabel.isHidden {
                maxLengthWarningLabelConstraints = changeElementConstraints(stickTo: scrollView, under: trackerNameTextField, element: maxLengthWarningLabel, oldConstraints: maxLengthWarningLabelConstraints, spacing: nil, overrideLeftInset: elementSpacing.leftInset + 28, overrideRightInset: elementSpacing.rightInset + 28, overrideHeight: 22 + 8 + 8)
                
                maxLengthWarningLabel.isHidden = false
                
                UIView.animate(withDuration: 0.25) { [weak self] in
                    guard let self else { return }
                    self.view.layoutIfNeeded()
                }
            }
        }
        checkToAllowCreateButton()
    }
    
    @objc
    private func createButtonPressed() {
        guard !nameCreated.isEmpty, let colorPicked, let emojiPicked, let categoryPicked else { return }
        
        if trackerCreatorType == .regular {
            guard !daysOfWeekPicked.isEmpty else { return }
        }
        
        switch creatorMode {
        case .create:
            trackerStorage?.addTrackerToCategory(name: nameCreated, color: colorPicked, emoji: emojiPicked, schedule: daysOfWeekPicked, category: categoryPicked)
        case .edit:
            guard let trackerOldId else { return }
            
            let tracker = Tracker(id: trackerOldId, name: nameCreated, color: colorPicked, emoji: emojiPicked, schedule: daysOfWeekPicked)
            trackerStorage?.updateTracker(tracker: tracker, newCategory: categoryPicked == trackerOldCategory ? nil : categoryPicked )
        }
        delegate?.trackerWasCreated()
    }
}

extension TrackerCreatorController: TrackerCreatorDatePickerDelegate {
    func receivePickedDays(days: [Int]) {
        daysOfWeekPicked = days
        
        tableView.beginUpdates()
        let cells = tableView.visibleCells
        
        guard let cell = cells.first(where: {$0.textLabel?.text == TableViewHeaderNames.tableViewScheduleCell.rawValue}) else { return }

        if days.count == 7 {
            cell.detailTextLabel?.text = "Каждый день"
        } else {
            var daysString: String = ""
            for day in days.dropLast() {
                let dayString = DayOfWeek(rawValue: day)?.shortName ?? ""
                daysString += "\(dayString), "
            }
            guard let last = days.last else {
                cell.detailTextLabel?.text = nil
                tableView.endUpdates()
                checkToAllowCreateButton()
                return
            }
            let lastDayString = DayOfWeek(rawValue: last)?.shortName ?? ""
            daysString += "\(lastDayString)"

            cell.detailTextLabel?.text = daysString
        }
        
        tableView.endUpdates()
        checkToAllowCreateButton()
    }
}

extension TrackerCreatorController: TrackerCreatorCategoryPickerDelegate {
    func receiveCategoryName(name: String) {
        categoryPicked = name
        tableView.beginUpdates()
        let cells = tableView.visibleCells
    
        guard let cell = cells.first(where: {$0.textLabel?.text == TableViewHeaderNames.tableViewCategoryCell.rawValue }) else { return }
        cell.detailTextLabel?.text = name
        tableView.endUpdates()

        checkToAllowCreateButton()
    }
}

extension TrackerCreatorController: CustomTableViewHelperDelegate {
    func cellWasPressed(withHeader header: String) {
        
        guard let header = TableViewHeaderNames(rawValue: header) else { return }
        
        switch header {
        case .tableViewCategoryCell:
            let viewController = CategoryPickerViewController(delegate: self)
            viewController.setPickedCategory(withName: categoryPicked)
            viewController.modalPresentationStyle = .popover
        
            let navBar = UINavigationController(rootViewController: viewController)
            
            self.present(navBar, animated: true)
            
        case .tableViewScheduleCell:
            let viewController = TrackerCreatorDatePicker(delegate: self)
            viewController.setActiveSwitchers(activeArray: daysOfWeekPicked)
            viewController.modalPresentationStyle = .popover
            
            let navBar = UINavigationController(rootViewController: viewController)
            
            self.present(navBar, animated: true)
        }
    }
}

extension TrackerCreatorController: TrackerCreatorCollectionHelperDelegate {
    func cellWasPressed(content: String) {
        emojiPicked = content

        checkToAllowCreateButton()
    }
    
    func cellWasPressed(content: UIColor) {
        colorPicked = content
        
        checkToAllowCreateButton()
    }
}

extension TrackerCreatorController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        trackerNameTextField.resignFirstResponder()
    }
}


