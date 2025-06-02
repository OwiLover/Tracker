//
//  DefaultsStorage.swift
//  Tracker
//
//  Created by Owi Lover on 3/31/25.
//

import Foundation

final class DefaultsStorage {
    
    enum Keys: String {
        case checkedOnboardView = "checkedOnboardView"
    }
    
    static let shared = DefaultsStorage()
    
    private init() {}
    
    let storage: UserDefaults = .standard
    
    func checkedOnboardView() -> Bool {
        storage.bool(forKey: Keys.checkedOnboardView.rawValue)
    }
    
    func setCheckedOnboardView(_ value: Bool) {
        storage.set(value, forKey: Keys.checkedOnboardView.rawValue)
    }
}
