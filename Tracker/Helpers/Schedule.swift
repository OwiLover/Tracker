//
//  IntArrayTransformer.swift
//  Tracker
//
//  Created by Owi Lover on 6/3/25.

import Foundation

public class Schedule: NSObject {
    var array: [Int]
    init(array: [Int]) {
        self.array = array
    }
}

class ScheduleTransformer: ValueTransformer {

    override public func transformedValue(_ value: Any?) -> Any? {
        guard let array = value as? [Int] else { return nil }
        return Schedule(array: array)
    }
    
    override public func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let schedule = value as? Schedule else { return nil }
        return schedule.array
    }
    
    override public class func allowsReverseTransformation() -> Bool {
        return true
    }
}
