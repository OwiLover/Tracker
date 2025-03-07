//
//  File.swift
//  Tracker
//
//  Created by Owi Lover on 3/4/25.
//

import Foundation

protocol StoreProtocol {
    associatedtype ReturnType
    
    var fetchedElements: [ReturnType] { get }
    
    func addNewElement(element: ReturnType) throws
    func deleteElement(element: ReturnType) throws
}
