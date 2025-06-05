//
//  CategoryPickerModel.swift
//  Tracker
//
//  Created by Owi Lover on 5/7/25.
//

import Foundation

// MARK: изначально была идея создать модель-прослойку между ViewModel и Storage, специально заточенной под CategoryPicker, однако посчитал её лишней и использовал в качестве модели TrackerCategoryStore

final class CategoryPickerModel {
    
    let storage: TrackerStorageProtocol
    
    var getCategories: [TrackerCategory] {
        storage.categoriesArray
    }
    
    var getCategoriesString: [String] {
        storage.categoriesArray.map({ $0.category })
    }
    
    var getRecords: [TrackerRecord] {
        storage.completedTrackers
    }
    
    init(storage: TrackerStorageProtocol = TrackerStorage.shared) {
        self.storage = storage
    }
    
    func addCategory(_ category: String) {
        storage.addCategory(category: category)
    }
    
    func didPickCategory(name category: String) {
    }
}
