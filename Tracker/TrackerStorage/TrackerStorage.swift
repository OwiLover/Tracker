//
//  TrackerStorage.swift
//  Tracker
//
//  Created by Owi Lover on 11/29/24.
//

import UIKit

// MARK: Данный класс является временным решением для проверки работы создания трекеров

final class TrackerStorage: TrackerStorageProtocol {

    static let shared = TrackerStorage()
    static let didAddCategory = Notification.Name(rawValue: "TrackerStorageDidAddCategory")
    static let didAddTracker = Notification.Name(rawValue: "TrackerStorageDidAddTracker")
    
    private init() {
        print("Tracker Storage was created!")
    }
    
    deinit {
        print("Tracker Storage was deleted!")
    }
    
    private(set) var categoriesArray: [TrackerCategory] = [TrackerCategory(category: "Random stuff", array: [Tracker(id: 0, name: "Wow", color: .colorSelection1, emoji: "❤️", schedule: [1,2,3]), Tracker(id: 1, name: "Look at the window", color: .colorSelection3, emoji: "😻", schedule: [1,2,3,4,5,6,7]), Tracker(id: 2, name: "Amazing Track", color: .colorSelection1, emoji: "🥶", schedule: [1,2,3]), Tracker(id: 3, name: "Get some food", color: .colorSelection3, emoji: "🥦", schedule: [2,3])]), TrackerCategory(category: "Another category", array: [Tracker(id: 4, name: "Give those plants some water!", color: .colorSelection2, emoji: "🌺", schedule: [2,3])])]
    
    
    private(set) var completedTrackers: [TrackerRecord] = {
        let calendar = Calendar.current
        let date = Date()
        return [TrackerRecord(id: 1, date: calendar.date(byAdding: .day, value: -4, to: date) ?? date), TrackerRecord(id: 1, date: calendar.date(byAdding: .day, value: -3, to: date) ?? date), TrackerRecord(id: 1, date: date)]
    }()
    private var completedTrackerIds: Set<UInt32> = [1]
    
//    MARK: id начинается не с 0 в связи с тем, что для тестов заранее уже были придуманы трекеры выше

    private var id: UInt32 = 4
    
    func addCategory(category: String) {
        let newTrackerCategory = TrackerCategory(category: category, array: [])
        if !categoriesArray.contains(where: {
            element in
            element.category == newTrackerCategory.category
        }) {
            categoriesArray.append(newTrackerCategory)
        }
        
        print("Added new category!")
        
        NotificationCenter.default.post(name: TrackerStorage.didAddCategory, object: self, userInfo: ["Categories": self.categoriesArray])
    }
    
    func createTracker(name: String, color: UIColor, emoji: String, schedule: [Int]) -> Tracker {
        let id = generateId()
        let tracker = Tracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule)
        return tracker
    }
    
    func addTrackerToCategory(name: String, color: UIColor, emoji: String, schedule: [Int], category: String) {
        guard let categoryIndex = categoriesArray.firstIndex(where: { element in
            element.category == category
        }) else { return }
        
        let tracker = createTracker(name: name, color: color, emoji: emoji, schedule: schedule)
        
        var trackerArray = categoriesArray[categoryIndex].array
        trackerArray.append(tracker)
        
        let newCategoryArray = TrackerCategory(category: categoriesArray[categoryIndex].category, array: trackerArray)
        categoriesArray[categoryIndex] = newCategoryArray
        
        NotificationCenter.default.post(name: TrackerStorage.didAddTracker, object: self, userInfo: ["Tracker": tracker])
    }
    

    
    func markTrackerAsCompleted(id: UInt32) {
        if !completedTrackerIds.contains(id) {
            completedTrackerIds.insert(id)
            setTrackerRecord(id: id)
        }
        print(completedTrackers, completedTrackerIds)
    }
    
    func unmarkTrackerAsCompleted(id: UInt32) {
        if completedTrackerIds.contains(id) {
            completedTrackerIds.remove(id)
            removeTrackerRecord(id: id)
        }
        print(completedTrackers, completedTrackerIds)
    }
    
    private func setTrackerRecord(id: UInt32) {
        let record = TrackerRecord(id: id, date: Date())
        completedTrackers.append(record)
    }
    
    private func removeTrackerRecord(id: UInt32) {
        let calendar = NSCalendar.current
        let date = Date()
        guard let index = completedTrackers.firstIndex(where: {
            tracker in
            (tracker.id == id) && (calendar.isDate(tracker.date, equalTo: date, toGranularity: .day))
        }) else {
            return
        }
        completedTrackers.remove(at: index)
    }
    
    private func generateId() -> UInt32 {
        id += 1
        return id
    }
}
