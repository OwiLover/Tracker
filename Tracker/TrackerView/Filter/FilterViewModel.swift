//
//  FilterViewModel.swift
//  Tracker
//
//  Created by Owi Lover on 6/23/25.
//

import Foundation


protocol FilterViewModelProtocol: AnyObject {
    typealias Binding<T> = (T) -> Void
    
    var onFilterSelected: Binding<String?>? { get set }
    
    var pickedFilter: String? { get set }
    var filtersArray: [FilterType] { get }
    
    func didPickFilter(name: String)
}

final class FilterViewModel: FilterViewModelProtocol {
    
    typealias Binding<T> = (T) -> Void
    
    private let model: FilterModelProtocol
    
    var onFilterSelected: Binding<String?>?
    
    var filtersArray: [FilterType] {
        get {
            model.getFilters()
        }
    }
    
    var pickedFilter: String? {
        didSet {
            onFilterSelected?(pickedFilter)
        }
    }
    
    func didPickFilter(name: String) {
        pickedFilter = name
    }
    
    init(model: FilterModelProtocol = FilterModel()) {
        self.model = model
    }
}
