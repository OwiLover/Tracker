//
//  mocks.swift
//  Tracker
//
//  Created by Owi Lover on 6/15/25.
//

@testable import Tracker
import UIKit

class TrackerStorageMock: TrackerStorageProtocol {
    func deleteTracker(id: UUID) {
        
    }
    
    func updateTracker(tracker: Tracker, newCategory: String?) {
        
    }
    
    func getTracker(id: UUID) -> (tracker: Tracker, category: String?)? {
        return nil
    }
    
    func getTrackersStreakCount(id: UUID) -> Int {
        return 0
    }
    
    func pinTracker(id: UUID) {
        
    }
    
    func unpinTracker(id: UUID) {
        
    }
    
    
    var categoriesArray: [TrackerCategory] = [TrackerCategory(category: "Vegies", array: [Tracker(id: UUID(), name: "Broccoli", color: .colorSelection18, emoji: "🥦", schedule: [1,2,3,4,5,6,7])])]
    
    var completedTrackers: [TrackerRecord] = []
    
    func addCategory(category: String) {
        
    }
    
    
    
    func addTrackerToCategory(name: String, color: UIColor, emoji: String, schedule: [Int], category: String) {
        
    }
    
    func markTrackerAsCompleted(id: UUID) {
        
    }
    
    func unmarkTrackerAsCompleted(id: UUID) {
        
    }
}
