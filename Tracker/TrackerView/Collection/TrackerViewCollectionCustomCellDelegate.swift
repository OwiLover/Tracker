//
//  TrackerViewCollectionCustomCellDelegate.swift
//  Tracker
//
//  Created by Owi Lover on 12/9/24.
//

import Foundation

protocol TrackerViewCollectionCustomCellDelegate: AnyObject {
    func streakButtonWasPressed(buttonState: Bool, trackerId: UUID)
    func actionMenuDeleteButtonWasPressed(trackerId: UUID)
    func actionMenuEditButtonWasPressed(trackerId: UUID)
    func actionMenuPinButtonWasPressed(trackerId: UUID)
    func actionMenuUnpinButtonWasPressed(trackerId: UUID)
}
