//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Owi Lover on 2/22/25.
//

import CoreData

final class TrackerRecordStore: NSObject {
    
    var fetchedElements: [TrackerRecord] {
        guard let elements = fetchController?.fetchedObjects else { return [] }
        
        return elements.compactMap { element in
            guard let id = element.id, let date = element.date else { assertionFailure("Can't convert something in TrackerRecords!")
                return nil
            }
            return TrackerRecord(id: id, date: date)
        }
    }
    
    private(set) var context: NSManagedObjectContext?
    private let fetchController: NSFetchedResultsController<TrackerRecordCoreData>?
    
    private var insertSet: IndexSet?
    private var deleteSet: IndexSet?
    
    private weak var delegate: StoreDelegate?
    
    convenience init(delegate: StoreDelegate? = nil) {
        let persistentContainer = PersistentContainerStorage.shared.persistentContainer
        let context = persistentContainer.viewContext
        
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
        self.delegate = delegate
        
        self.fetchController = {
            let request = TrackerRecordCoreData.fetchRequest()
            
            request.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerRecordCoreData.date, ascending: true)]
            
            let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            
            try? controller.performFetch()
            return controller
        }()
        
        super.init()
        
        self.fetchController?.delegate = self
    }
    
    func addNewRecord(record: TrackerRecord) throws {
        guard let context, let trackerKeyPath = (\TrackerCoreData.id)._kvcKeyPathString else {
            print("no context!")
            return
        }
        
        let trackerSearch = TrackerCoreData.fetchRequest()
        trackerSearch.predicate = NSPredicate(format: "%K == %@", trackerKeyPath, record.id as NSUUID)
        trackerSearch.fetchLimit = 1
        
        guard let trackers = try? context.fetch(trackerSearch), let tracker = trackers.first else {
            print("Can't add tracker to Records, wrong ID!")
            return
        }
        
        print(trackers)
        
        let newRecord = TrackerRecordCoreData(context: context)
        
        newRecord.date = record.date
        newRecord.id = tracker.id
        newRecord.tracker = tracker
        
        do {
            try context.save()
        }
        catch {
            context.rollback()
            print("Can't add new record!")
        }
    }
    
    func deleteRecord(id: UUID, date: Date) throws {
        guard let context, let idKeyPath = (\TrackerRecordCoreData.id)._kvcKeyPathString, let dateKeyPath = (\TrackerRecordCoreData.date)._kvcKeyPathString  else {
            print("no context or wrong keyPath!")
            return
        }
        
        let calendar = NSCalendar.current
        let startDate = calendar.startOfDay(for: date)
        
        var components = DateComponents()
        components.day = 1
        components.second = -1
        
        let endDate = calendar.date(byAdding: components, to: startDate) ?? Date()
        
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "%K == %@ AND %K >= %@ AND %K <= %@",
            idKeyPath, id as NSUUID,
            dateKeyPath, startDate as NSDate,
            dateKeyPath, endDate as NSDate
        )
        
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
    
    func deleteRecords(id: UUID) throws {
        guard let context, let keyPath = (\TrackerRecordCoreData.id)._kvcKeyPathString else {
            print("no context or wrong keyPath!")
            return
        }
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "%K == %@", keyPath, id as NSUUID)
        
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
    
    func getDateRecordsIds(date: Date) -> Set<UUID> {
        guard let context, let dateKeyPath = (\TrackerRecordCoreData.date)._kvcKeyPathString  else {
            print("no context or wrong keyPath!")
            return []
        }
        
        let calendar = NSCalendar.current
        let startDate = calendar.startOfDay(for: date)
        
        var components = DateComponents()
        components.day = 1
        components.second = -1
        
        let endDate = calendar.date(byAdding: components, to: startDate) ?? Date()
        
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "%K >= %@ AND %K <= %@",
            dateKeyPath, startDate as NSDate,
            dateKeyPath, endDate as NSDate
        )
        
        var idSet: Set<UUID> = .init()
        
        if let result = try? context.fetch(fetchRequest) {
            for element in result {
                guard let id = element.id else { continue }
                idSet.insert(id)
            }
        }
        return idSet
    }
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        
        let fetchChanges = FetchedStorageChanges(insertIndexSet: insertSet, deleteIndexSet: deleteSet)
        
        delegate?.didUpdate(type: .record, changes: fetchChanges)
        
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
