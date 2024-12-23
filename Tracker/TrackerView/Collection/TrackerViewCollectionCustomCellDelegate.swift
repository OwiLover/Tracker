//
//  TrackerViewCollectionCustomCellDelegate.swift
//  Tracker
//
//  Created by Owi Lover on 12/9/24.
//

import Foundation

protocol TrackerViewCollectionCustomCellDelegate: AnyObject {
    func streakButtonWasPressed(buttonState: Bool, trackerId: UInt32)
}
