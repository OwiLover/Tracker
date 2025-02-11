//
//  DatePicker + Extensions.swift
//  Tracker
//
//  Created by Owi Lover on 11/8/24.
//

import Foundation

extension Date {
    func dayNumberOfWeek() -> Int? {
        let customCalendar = Calendar(identifier: .iso8601)

        return customCalendar.ordinality(of: .weekday, in: .weekOfYear, for: self)
    }
}
