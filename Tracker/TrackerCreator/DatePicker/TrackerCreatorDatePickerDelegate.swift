//
//  TrackerCreatorDatePickerDelegate.swift
//  Tracker
//
//  Created by Owi Lover on 11/26/24.
//

import Foundation

protocol TrackerCreatorDatePickerDelegate: AnyObject {
    func receivePickedDays(days: [(dayOfWeekNum: Int, nameOfDay: String)])
}
