//
//  PersistentContainer.swift
//  Tracker
//
//  Created by Owi Lover on 3/8/25.
//

import CoreData

class PersistentContainerStorage {
    static let shared = PersistentContainerStorage()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataBase")

        container.loadPersistentStores() { description, error in
            if let error = error as NSError? {
                assertionFailure("Something went wrong with Data Base: \(error)")
            }
        }
        return container
    }()
}
