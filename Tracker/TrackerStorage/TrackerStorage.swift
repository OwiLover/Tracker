//
//  TrackerStorage.swift
//  Tracker
//
//  Created by Owi Lover on 11/29/24.
//

import UIKit

final class TrackerStorage: TrackerStorageProtocol {

    static let shared = TrackerStorage()
    static let didAddCategory = Notification.Name(rawValue: "TrackerStorageDidAddCategory")
    static let didAddTracker = Notification.Name(rawValue: "TrackerStorageDidAddTracker")
    static let didAddRecord = Notification.Name(rawValue: "TrackerStorageDidAddRecord")
    
    private var trackerStore: TrackerStore?
    private var trackerCategoryStore: TrackerCategoryStore?
    private var trackerRecordStore: TrackerRecordStore?
    
    private var completedTrackerIds: Set<UUID> = []
    
    private init() {
        print("Store initialized!")
        self.trackerStore = TrackerStore(delegate: self)
        self.trackerCategoryStore = TrackerCategoryStore(delegate: self)
        self.trackerRecordStore = TrackerRecordStore(delegate: self)
        self.completedTrackerIds = trackerRecordStore?.getDateRecordsIds(date: Date()) ?? []
    }

    var categoriesArray: [TrackerCategory] {
        let array = trackerCategoryStore?.fetchedElements ?? []
        return array
    }
    
    var completedTrackers: [TrackerRecord] {
        let array = trackerRecordStore?.fetchedElements ?? []
        return array
    }
    
    func addCategory(category: String) {
        let newTrackerCategory = TrackerCategory(category: category, array: [])
        if !categoriesArray.contains(where: {
            element in
            element.category == newTrackerCategory.category
        }) {
            do {
                try trackerCategoryStore?.addNewCategory(category: newTrackerCategory)
            } catch {
                print("Can't add new category!")
            }
        }
    }
    
    func createTracker(name: String, color: UIColor, emoji: String, schedule: [Int]) -> Tracker {
        let id = generateId()
        let tracker = Tracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule)
        do {
            try trackerStore?.addNewTracker(element: tracker)
        }
        catch {
            print("Can't create tracker!")
        }
        return tracker
    }
    
    func addTrackerToCategory(name: String, color: UIColor, emoji: String, schedule: [Int], category: String) {

        let tracker = createTracker(name: name, color: color, emoji: emoji, schedule: schedule)

        do {
            try trackerCategoryStore?.addNewTracker(for: category, tracker: tracker)
        }
        catch {
            print("Can't add new tracker to category!")
        }
    }
    
    func deleteTracker(id: UUID) {
        do {
            try trackerRecordStore?.deleteRecords(id: id)
            try trackerStore?.deleteTracker(withId: id)
        }
        catch {
            print("Can't delete tracker: \(error)")
        }
    }
    
    func updateTracker(tracker: Tracker, newCategory: String? = nil) {
        do {
            try trackerStore?.updateExistingTracker(tracker: tracker)
            
            if let newCategory {
                try trackerCategoryStore?.changeTrackersCategory(for: tracker, newCategory: newCategory)
            }
        }
        catch {
            print("Can't update tracker: \(error)")
        }
    }
    
    func getTracker(id: UUID) -> (tracker: Tracker, category: String?)? {
        do {
            let trackerAndCategory = try trackerStore?.getTracker(withId: id)
            
            return trackerAndCategory
        } catch {
            
            print("Can't get tracker!")
            
            return nil
        }
    }
    
    func getTrackersStreakCount(id: UUID) -> Int {
            let streak = trackerRecordStore?.getRecordsCount(trackerId: id)
            return streak ?? 0
    }
    
    func markTrackerAsCompleted(id: UUID) {
        if !completedTrackerIds.contains(id) {
            completedTrackerIds.insert(id)
            setTrackerRecord(id: id)
        }
    }
    
    func unmarkTrackerAsCompleted(id: UUID) {
        if completedTrackerIds.contains(id) {
            completedTrackerIds.remove(id)
            removeTrackerRecord(id: id)
        }
    }
    
    func pinTracker(id: UUID) {
        trackerStore?.pinTracker(withId: id)
    }
    
    func unpinTracker(id: UUID) {
        trackerStore?.unpinTracker(withId: id)
    }
    
    func getTrackerWithCategoryAndDay(category: String, day: Int) -> [Tracker] {
        guard let trackers = try? trackerStore?.getTrackersWithCategory(category: category) else { return [] }
        return trackers.filter { $0.schedule.contains(day) }
    }
    
    private func setTrackerRecord(id: UUID) {
        let record = TrackerRecord(id: id, date: Date())
        do {
            try trackerRecordStore?.addNewRecord(record: record)
        }
        catch {
            print("Can't add new record!")
        }
        print("Added new record!")
    }
    
    private func removeTrackerRecord(id: UUID) {
        do {
            try trackerRecordStore?.deleteRecord(id: id, date: Date())
        } catch {
            print("Can't delete record!")
        }
        print("Deleted new record!")
    }
    
    private func generateId() -> UUID {
        return UUID()
    }
}

extension TrackerStorage: GlobalStoreDelegate {
    func didUpdate(type: StoreType, changes: FetchedStorageChanges) {
        switch type {
        case .category:
            NotificationCenter.default.post(name: TrackerStorage.didAddCategory, object: self, userInfo: ["Categories": self.categoriesArray, "Changes": changes])
            print("Notified Category!")
        case .record:
            NotificationCenter.default.post(name: TrackerStorage.didAddRecord, object: self)
            
        case .tracker:
            NotificationCenter.default.post(name: TrackerStorage.didAddTracker, object: self, userInfo: ["Changes": changes])
        }
    }
}

extension TrackerStorage: CategoryStoreDelegate {
    func didUpdate(changes: FetchedStorageChanges) {
//      MARK: Данное решение создано, чтобы поддерживать работу главного экрана с трекерами, поскольку он не переписан под MVVM
        NotificationCenter.default.post(name: TrackerStorage.didAddCategory, object: self, userInfo: ["Categories": self.categoriesArray, "Changes": changes])
    }
}
