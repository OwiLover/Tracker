//
//  File.swift
//  Tracker
//
//  Created by Owi Lover on 3/4/25.
//

import Foundation

protocol StoreProtocol {
    associatedtype returnType
    
    var fetchedElements: [returnType] { get }
    
    func addNewElement(element: returnType) throws
    func deleteElement(element: returnType) throws
}
