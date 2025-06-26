//
//  TrackerStorageProtocol.swift
//  Tracker
//
//  Created by Owi Lover on 11/29/24.
//

import UIKit

protocol TrackerStorageProtocol {
    var categoriesArray: [TrackerCategory] { get }
    var completedTrackers: [TrackerRecord] { get }
    
    func addCategory(category: String)
    func addTrackerToCategory(name: String, color: UIColor, emoji: String, schedule: [Int], category: String)
    func deleteTracker(id: UUID)
    func updateTracker(tracker: Tracker, newCategory: String?)
    func getTracker(id: UUID) -> (tracker: Tracker, category: String?)?
    func getTrackersStreakCount(id: UUID) -> Int
    
    func pinTracker(id: UUID)
    func unpinTracker(id: UUID)
    
    func markTrackerAsCompleted(id: UUID)
    func unmarkTrackerAsCompleted(id: UUID)
}
