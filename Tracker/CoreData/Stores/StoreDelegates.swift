//
//  StoreProtocol.swift
//  Tracker
//
//  Created by Owi Lover on 3/4/25.
//

import Foundation

enum StoreType {
    case tracker
    case category
    case record
}

protocol StoreDelegate: AnyObject {
    func didUpdate(type: StoreType, changes: FetchedStorageChanges)
}
