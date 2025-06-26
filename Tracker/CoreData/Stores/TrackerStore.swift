//
//  TrackerStore.swift
//  Tracker
//
//  Created by Owi Lover on 2/22/25.
//

import CoreData

final class TrackerStore: NSObject {
    
    var fetchedElements: [Tracker] {
        guard let elements = fetchController?.fetchedObjects else { return [] }
        
        let marshal = ColorMarshal()
        return elements.compactMap { element in
            guard let id = element.id, let name = element.name, let color = element.color, let emoji = element.emoji, let schedule = element.schedule else { assertionFailure("Can't convert something in Trackers!")
                return nil
            }
            
            return Tracker(id: id, name: name, color: marshal.getUIColorFromHex(hex: color), emoji: emoji, schedule: schedule, isPinned: element.isPinned)
        }
    }
    
    private(set) var context: NSManagedObjectContext?
    private let fetchController: NSFetchedResultsController<TrackerCoreData>?
    
    private var insertSet: IndexSet?
    private var deleteSet: IndexSet?
    
    private weak var delegate: GlobalStoreDelegate?
    
    convenience init(delegate: GlobalStoreDelegate? = nil) {
        
        let persistentContainer = PersistentContainerStorage.shared.persistentContainer
        
        let context = persistentContainer.viewContext
        
        self.init(context: context, delegate: delegate)
    }
    
    init(context: NSManagedObjectContext?, delegate: GlobalStoreDelegate?) {
        
        guard let context else {
            self.context = nil
            self.fetchController = nil
            super.init()
            return
        }
        
        self.context = context
        self.delegate = delegate
        
        self.fetchController = {
            let request = TrackerCoreData.fetchRequest()
            
            request.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCoreData.id, ascending: true)]
            
            let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            
            try? controller.performFetch()
            return controller
        }()
        
        super.init()
        
        self.fetchController?.delegate = self
    }
    
    func addNewTracker(element tracker: Tracker) throws {
        guard let context else {
            print("no context!")
            return
        }
        
        let marshal = ColorMarshal()
        
        let color = marshal.getHexFromUIColor(color: tracker.color)
        
        let newTracker = TrackerCoreData(context: context)
        newTracker.id = tracker.id
        newTracker.name = tracker.name
        newTracker.color = color
        newTracker.emoji = tracker.emoji
        newTracker.schedule = tracker.schedule
        
        do {
            try context.save()
        }
        catch {
            context.rollback()
            print("Can't add new category!")
        }
    }
    
    func updateExistingTracker(tracker: Tracker) throws {
        guard let context, let keyPath = (\TrackerCoreData.id)._kvcKeyPathString else {
            print("No context!")
            return
        }
        
        let fetchRequest = TrackerCoreData.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "%K == %@", keyPath, tracker.id as NSUUID)
        fetchRequest.fetchLimit = 1
        
        if let result = try? context.fetch(fetchRequest) {
            guard let originalTracker = result.first else { return }
            
            let marshal = ColorMarshal()
            let color = marshal.getHexFromUIColor(color: tracker.color)
            
            originalTracker.name = tracker.name
            originalTracker.color = color
            originalTracker.emoji = tracker.emoji
            originalTracker.schedule = tracker.schedule
        }
        
        do {
            try context.save()
        } catch {
            print("Can't update tracker from TrackerCoreData! Error: \(error)")
            context.rollback()
        }
    }
    
    func deleteTracker(withId id: UUID) throws {
        guard let context, let keyPath = (\TrackerCoreData.id)._kvcKeyPathString else {
            print("no context or wrong keyPath!")
            return
        }
        let fetchRequest = TrackerCoreData.fetchRequest()

        fetchRequest.predicate = NSPredicate(format: "%K == %@", keyPath, id as NSUUID)
        
        if let result = try? context.fetch(fetchRequest) {
            for element in result {
                context.delete(element)
            }
        }

        do {
            try context.save()
        } catch {
            print("Can't delete element from TrackerCoreData! Error: \(error)")
            context.rollback()
        }
    }
    
    func getTracker(withId id: UUID) throws -> (tracker: Tracker, category: String?)? {
        guard let context, let keyPath = (\TrackerCoreData.id)._kvcKeyPathString else {
            print("no context or wrong keyPath!")
            return nil
        }
        let fetchRequest = TrackerCoreData.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "%K == %@", keyPath, id as NSUUID)
        
        if let result = try? context.fetch(fetchRequest), let trackerCD = result.first {
            guard let id = trackerCD.id, let name = trackerCD.name, let colorHex = trackerCD.color, let emoji = trackerCD.emoji, let schedule = trackerCD.schedule else {
                return nil
            }
            
            let category = trackerCD.category?.category
            
            let marshal = ColorMarshal()
            
            let color = marshal.getUIColorFromHex(hex: colorHex)
            
            let tracker = Tracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule)
            
            return (tracker, category)
            
        } else {
            return nil
        }
    }
    
    func getTrackersWithCategory(category: String) throws -> [Tracker] {
        guard let context, let keyPath = (\TrackerCoreData.category?.category)._kvcKeyPathString else {
            print("no context or wrong keyPath!")
            return []
        }
        let fetchRequest = TrackerCoreData.fetchRequest()

        fetchRequest.predicate = NSPredicate(format: "%K == %@", keyPath, category)
        
        let trackers = try context.fetch(fetchRequest)
        
        let marshal = ColorMarshal()
        
        return trackers.compactMap { element in
            guard let id = element.id, let name = element.name, let color = element.color, let emoji = element.emoji, let schedule = element.schedule else { assertionFailure("Can't convert something in Trackers!")
                return nil
            }
            
            return Tracker(id: id, name: name, color: marshal.getUIColorFromHex(hex: color), emoji: emoji, schedule: schedule)
        }
    }
    
    func pinTracker(withId id: UUID) {
        guard let context, let keyPath = (\TrackerCoreData.id)._kvcKeyPathString else {
            print("No context!")
            return
        }
        
        let fetchRequest = TrackerCoreData.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "%K == %@", keyPath, id as NSUUID)
        fetchRequest.fetchLimit = 1
        
        if let result = try? context.fetch(fetchRequest) {
            guard let originalTracker = result.first else { return }
            
            originalTracker.isPinned = true
        }
        do {
            try context.save()
        } catch {
            print("Can't pin tracker from TrackerCoreData! Error: \(error)")
            context.rollback()
        }
    }
    
    func unpinTracker(withId id: UUID) {
        guard let context, let keyPath = (\TrackerCoreData.id)._kvcKeyPathString else {
            print("No context!")
            return
        }
        
        let fetchRequest = TrackerCoreData.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "%K == %@", keyPath, id as NSUUID)
        fetchRequest.fetchLimit = 1
        
        if let result = try? context.fetch(fetchRequest) {
            guard let originalTracker = result.first else { return }
            
            originalTracker.isPinned = false
        }
        do {
            try context.save()
        } catch {
            print("Can't unpin tracker from TrackerCoreData! Error: \(error)")
            context.rollback()
        }
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        
        let fetchChanges = FetchedStorageChanges(insertIndexSet: insertSet, deleteIndexSet: deleteSet)
        
        delegate?.didUpdate(type: .tracker, changes: fetchChanges)
        
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
