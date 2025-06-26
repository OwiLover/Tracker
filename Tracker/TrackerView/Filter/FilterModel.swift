//
//  FilterModel.swift
//  Tracker
//
//  Created by Owi Lover on 6/23/25.
//

import Foundation

enum FilterType: String, CaseIterable {
    case all = "Все трекеры"
    case today = "Трекеры на сегодня"
    case completed = "Завершенные"
    case notCompleted = "Не завершенные"
}

final class FilterModel: FilterModelProtocol {
    private let filters: [FilterType] = {
       return FilterType.allCases
    }()
    
    func getFilterNames() -> [String] {
        return filters.map { $0.rawValue }
    }
    
    func getFilters() -> [FilterType] {
        return filters
    }
}

protocol FilterModelProtocol {
    func getFilterNames() -> [String]
    func getFilters() -> [FilterType]
}
