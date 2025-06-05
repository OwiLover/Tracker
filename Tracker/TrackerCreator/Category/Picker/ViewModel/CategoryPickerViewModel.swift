//
//  CategoryPickerViewModel.swift
//  Tracker
//
//  Created by Owi Lover on 5/7/25.
//

import Foundation

protocol CategoryPickerViewModelProtocol {
    typealias Binding<T> = (T) -> Void
    
    var pickedCategory: String? { get set }
    var categoriesArray: [String] { get }
    func didPickCategory(name: String)
    
    var onCategorySelected: Binding<String?>? { get set }
    var onUpdateShowCategories: Binding<Bool>? { get set }
    var onUpdateCategoriesArray: Binding<[String]>? { get set }
    var onUpdateCategories: Binding<FetchedStorageChanges>? { get set }
}

final class CategoryPickerViewModel: CategoryPickerViewModelProtocol {

    private let model: TrackerCategoryStoreProtocol
    
    var pickedCategory: String? {
        didSet {
            onCategorySelected?(pickedCategory)
        }
    }
    
    private(set) var categoriesArray: [String] {
        get {
            model.getCategoriesNames()
        }
        set(value){
            didUpdateCategories(categoriesArray: value)
        }
    }
    
    typealias Binding<T> = (T) -> Void

    var onCategorySelected: Binding<String?>?
    var onUpdateShowCategories: Binding<Bool>?
    var onUpdateCategoriesArray: Binding<[String]>?
    var onUpdateCategories: Binding<FetchedStorageChanges>?
    
    init(model: TrackerCategoryStoreProtocol = TrackerCategoryStore()) {
        self.model = model
        self.model.setDelegate(self)
        self.categoriesArray = model.getCategoriesNames()
    }
    
    func didPickCategory(name category: String) {
        self.pickedCategory = category
    }
    
    private func didUpdateCategories(categoriesArray: [String]) {
        print("Updated! Array: \(categoriesArray)")
        onUpdateShowCategories?(!categoriesArray.isEmpty)
        onUpdateCategoriesArray?(categoriesArray)
    }
}

extension CategoryPickerViewModel: CategoryStoreDelegate{
    func didUpdate(changes: FetchedStorageChanges) {
        let names = self.model.getCategoriesNames()
        !names.isEmpty ? onUpdateShowCategories?(true) : onUpdateShowCategories?(false)
        onUpdateCategories?(changes)
    }
}
