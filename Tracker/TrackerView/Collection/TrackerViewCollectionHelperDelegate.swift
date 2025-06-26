//
//  TrackerViewCollectionHelperDelegate.swift
//  Tracker
//
//  Created by Owi Lover on 12/2/24.
//

import Foundation

protocol TrackerViewCollectionHelperDelegate: AnyObject {
    func updateStreak(shouldIncrease: Bool, trackerId: UUID)
    func deleteTracker(trackerId: UUID)
    func pinTracker(trackerId: UUID)
    func unpinTracker(trackerId: UUID)
    func editTracker(trackerId: UUID)
}
