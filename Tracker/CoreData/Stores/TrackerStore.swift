//
//  TrackerStore.swift
//  Tracker
//
//  Created by Owi Lover on 2/22/25.
//

import UIKit

import CoreData

class TrackerStore: NSObject {
    
    var fetchedElements: [Tracker] {
        guard let elements = fetchController?.fetchedObjects else { return [] }
        
        let marshal = ColorMarshal()
        return elements.map { element in
            guard let id = element.id, let name = element.name, let color = element.color, let emoji = element.emoji, let schedule = element.schedule else { fatalError("Can't convert something in Trackers!")}
            
            return Tracker(id: id, name: name, color: marshal.getUIColorFromHex(hex: color), emoji: emoji, schedule: schedule)
        }
    }
    
    private (set) var context: NSManagedObjectContext?
    private let fetchController: NSFetchedResultsController<TrackerCoreData>?
    
    private var insertSet: IndexSet?
    private var deleteSet: IndexSet?
    
    private weak var delegate: StoreDelegate?
    
    convenience init(delegate: StoreDelegate? = nil) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            self.init(context: nil, delegate: nil)
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        
        self.init(context: context, delegate: delegate)
    }
    
    init(context: NSManagedObjectContext?, delegate: StoreDelegate?) {
        
        guard let context else {
            self.context = nil
            self.fetchController = nil
            super.init()
            return
        }
        
        self.context = context
        
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
    
    func deleteTracker(element: Tracker) throws {
        guard let context, let keyPath = (\TrackerCoreData.id)._kvcKeyPathString else {
            print("no context or wrong keyPath!")
            return
        }
        let fetchRequest = TrackerCoreData.fetchRequest()
        
        ///пытался побороть проблему, однако #keyPath(TrackerCoreData.id) выдаёт ошибку "Ambiguous reference to member 'id'"
        ///вероятнее всего это связано с тем, что id в CoreData уже зарезервировано и при перезаписи на свой элемент происходит несостыковка
        ///что в таком случае лучше делать?
        ///Возможно, стоит не создавать id вообще в CoreData вручную и переписать логику для работы с ObjectIdentifier?
        fetchRequest.predicate = NSPredicate(format: "%K == %@", keyPath, element.id as NSUUID)
        
        if let result = try? context.fetch(fetchRequest) {
            for element in result {
                context.delete(element)
            }
        }

        do {
            try context.save()
        } catch {
            print("Can't delete element from TrackerCoreData!")
            context.rollback()
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
        
        return trackers.map { element in
            guard let id = element.id, let name = element.name, let color = element.color, let emoji = element.emoji, let schedule = element.schedule else { fatalError("Can't convert something in Trackers!")}
            
            return Tracker(id: id, name: name, color: marshal.getUIColorFromHex(hex: color), emoji: emoji, schedule: schedule)
        }
    }
    
    
//    func getTrackerWithCategoryAndDay(category: String, day: Int) throws -> [Tracker] {
//        guard let context, let categoryKeyPath = (\TrackerCoreData.category?.category)._kvcKeyPathString,
//              let scheduleKeyPath = (\TrackerCoreData.schedule)._kvcKeyPathString else {
//            print("no context or wrong keyPath!")
//            return []
//        }
//        let fetchRequest = TrackerCoreData.fetchRequest()
//
//        fetchRequest.predicate = NSPredicate(format: "%K == %@ AND %K CONTAINS %ld", categoryKeyPath, category, scheduleKeyPath, day)
//        
//        //   К сожалению, данная функция не сработает, расписание, хранящееся в виде Transformable [Int] вызывает ошибку при данном запросе
//        
//        let trackers = try context.fetch(fetchRequest)
//        
//        let marshal = ColorMarshal()
//        
//        return trackers.map { element in
//            guard let id = element.id, let name = element.name, let color = element.color, let emoji = element.emoji, let schedule = element.schedule else { fatalError("Can't convert something in Trackers!")}
//            
//            return Tracker(id: id, name: name, color: marshal.getUIColorFromHex(hex: color), emoji: emoji, schedule: schedule)
//        }
//    }
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
            guard let indexPath = newIndexPath else { fatalError( "New index don't exist!") }
            insertSet?.insert(indexPath.item)
        case .delete:
            guard let indexPath = newIndexPath else { fatalError( "New index don't exist!") }
            deleteSet?.insert(indexPath.item)
        default:
            return
        }
    }
}
