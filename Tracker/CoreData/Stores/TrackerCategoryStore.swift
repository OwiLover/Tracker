//
//  CategoryStore.swift
//  Tracker
//
//  Created by Owi Lover on 2/22/25.
//

import CoreData

final class TrackerCategoryStore: NSObject {
    
    var fetchedElements: [TrackerCategory] {
        guard let elements = fetchController?.fetchedObjects else { return [] }
        
        return elements.compactMap{ element in
            guard let category = element.category, let trackers = element.trackers else { assertionFailure("Can't convert something in TrackerCategory!")
                return nil
            }
            
            let marshal = ColorMarshal()
            
            let trackerArrayCD = trackers.allObjects as? [TrackerCoreData] ?? []
            
            let trackerArray = trackerArrayCD.compactMap { trackerCD in
                guard let id = trackerCD.id, let name = trackerCD.name,
                      let color = trackerCD.color, let emoji = trackerCD.emoji,
                      let schedule = trackerCD.schedule else { fatalError("Can't convert TrackerCD to normal data!")
                }
                let tracker = Tracker(id: id, name: name, color: marshal.getUIColorFromHex(hex: color), emoji: emoji, schedule: schedule)
                return tracker
            }
            
            return TrackerCategory(category: category, array: trackerArray)
        }
    }
    
    private(set) var context: NSManagedObjectContext?
    private let fetchController: NSFetchedResultsController<TrackerCategoryCoreData>?
    
    private var insertSet: IndexSet?
    private var deleteSet: IndexSet?
    
    private weak var delegate: StoreDelegate?
    
    convenience init(delegate: StoreDelegate? = nil) {
        
        let persistentContainer = PersistentContainerStorage.shared.persistentContainer
        
        let context = persistentContainer.viewContext
        
        self.init(context: context, delegate: delegate)
    }
    
    init(context: NSManagedObjectContext?, delegate: StoreDelegate?) {
        
        guard let context, let idKeyPath = (\TrackerCategoryCoreData.category)._kvcKeyPathString else {
            print("can't init context or keyPath!")
            self.context = nil
            self.fetchController = nil
            super.init()
            return
        }
        
        self.context = context
        self.delegate = delegate
        
        self.fetchController = {
            let request = TrackerCategoryCoreData.fetchRequest()
            
            request.sortDescriptors = [NSSortDescriptor(key: idKeyPath, ascending: true)]
            
            let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            
            try? controller.performFetch()
            return controller
        }()
        
        super.init()
        
        self.fetchController?.delegate = self
    }
    
    func addNewCategory(category: TrackerCategory) throws {
        guard let context else {
            print("no context!")
            return
        }
        let newCategory = TrackerCategoryCoreData(context: context)
        
        newCategory.category = category.category
        
        do {
            try context.save()
        }
        catch {
            context.rollback()
            print("Can't add new category!")
        }
    }
    
    func addNewTracker(for category: String, tracker: Tracker) throws  {
        guard let context, let categoryKeyPath = (\TrackerCategoryCoreData.category)._kvcKeyPathString, let trackerKeyPath = (\TrackerCoreData.id)._kvcKeyPathString else {
            print("No context or wrong keyPath!")
            return
        }
        
        let trackerFetchRequest = TrackerCoreData.fetchRequest()
        
        trackerFetchRequest.predicate = NSPredicate(format: "%K == %@", trackerKeyPath, tracker.id as NSUUID)
        trackerFetchRequest.fetchLimit = 1
        
        guard let trackerSearch = try? context.fetch(trackerFetchRequest), let tracker = trackerSearch.first else { 
            print("Can't add tracker to category, wrong id!")
            return
        }
        
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "%K == %@", categoryKeyPath, category)
        fetchRequest.fetchLimit = 1
        
        if let result = try? context.fetch(fetchRequest), let category = result.first {
            category.addToTrackers(tracker)
        }
        
        do {
            try context.save()
        } catch {
            context.rollback()
            print("Can't add tracker to category!")
        }
    }
    
    func deleteElement(element: TrackerCategory) throws {
        guard let context, let keyPath = (\TrackerCategoryCoreData.category)._kvcKeyPathString else {
            print("no context or wrong keyPath!")
            return
        }
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()

        fetchRequest.predicate = NSPredicate(format: "%K == %@", keyPath, element.category)
        
        if let result = try? context.fetch(fetchRequest) {
            for element in result {
                context.delete(element)
            }
        }
        do {
            try context.save()
        } catch {
            print("Can't delete element from TrackerRecordCoreData!")
            context.rollback()
        }
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        
        let fetchChanges = FetchedStorageChanges(insertIndexSet: insertSet, deleteIndexSet: deleteSet)
        
        print("Changes were made!!!")
        
        delegate?.didUpdate(type: .category, changes: fetchChanges)
        
        insertSet = nil
        deleteSet = nil
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        insertSet = IndexSet()
        deleteSet = IndexSet()
    }
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { assertionFailure( "New index don't exist!")
                return
            }
            insertSet?.insert(indexPath.item)
        case .delete:
            guard let indexPath = indexPath else { assertionFailure("This index don't exist!")
                return
            }
            deleteSet?.insert(indexPath.item)
        default:
            return
        }
    }
}
