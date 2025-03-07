//
//  TrackerRecordDictionary.swift
//  Tracker
//
//  Created by Owi Lover on 12/21/24.
//

import Foundation

struct TrackerRecordDictionary {
    let dictionary: [UUID: (streakCount: UInt16, isChecked: Bool)]
    
    init(trackerRecords: [TrackerRecord]? = nil) {
        var dictionary = Dictionary<UUID, (streakCount: UInt16, isChecked: Bool)>()
        guard let trackerRecords else {
            self.dictionary = dictionary
            return
        }
        
        let date = Date()
        let calendar = NSCalendar.current
        
        trackerRecords.forEach({
            element in
            let elementCount = (dictionary[element.id]?.streakCount ?? 0) + 1
            
//            MARK: По идее нет необходимости дополнительно проверять даты на порядок, поскольку последней всегда будет самая актуальная
            
            let isChecked = calendar.isDate(element.date, equalTo: date, toGranularity: .day) ? true : false
            dictionary[element.id] = (elementCount, isChecked)
        })
        self.dictionary = dictionary
    }
}
