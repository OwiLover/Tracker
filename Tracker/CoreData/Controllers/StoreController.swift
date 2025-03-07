//
//  TrackerStoreController.swift
//  Tracker
//
//  Created by Owi Lover on 2/27/25.
//

// MARK: Изначальной идеей было создание единого контроллера, подходящего для всех Store, однако столкнулся с проблемой преобразования данных при запросе. В качестве идеи можно было вставить в инициализатор помимо контекста также функцию - преобразователь и с помощью протокола обозначить возвращаемое значение, однако я решил не экспериментировать и реализовал всю логику внутри каждого Store-а

//import CoreData
//import UIKit
//
//class TrackerStoreController: NSObject, FetchStoreControllerProtocol {
//    
////    private let store: any StoreProtocol
//    
//    private var insertSet: IndexSet?
//    private var deleteSet: IndexSet?
//    
//    
//    private let fetchController: NSFetchedResultsController<TrackerCoreData>
//    private let delegate: TrackerStoreControllerDelegate
//    
//    var fetchedElements: [Tracker] {
//        guard let elements = fetchController.fetchedObjects else { return [] }
//        let marshal = ColorMarshal()
//        return elements.map { element in
//            guard let id = element.id, let name = element.name, let color = element.color, let emoji = element.emoji, let schedule = element.schedule else { fatalError("Can't convert something in Trackers!")}
//            return Tracker(id: id, name: name, color: marshal.getUIColorFromHex(hex: color), emoji: emoji, schedule: schedule)
//        }
//    }
//    
//    init(context: NSManagedObjectContext, delegate: TrackerStoreControllerDelegate) {
//        self.delegate = delegate
//        self.fetchController = {
//            let request = TrackerCoreData.fetchRequest()
//            
//            request.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCoreData.id, ascending: true)]
//            
//            let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
//            
//            try? controller.performFetch()
//            return controller
//        }()
//        super.init()
//        self.fetchController.delegate = self
//    }
//}
//
//extension TrackerStoreController: NSFetchedResultsControllerDelegate {
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
//        let fetchChanges = FetchedStorageChanges(insertIndexSet: insertSet, deleteIndexSet: deleteSet)
//        delegate.didUpdate(controller: self, changes: fetchChanges)
//        
//        insertSet = nil
//        deleteSet = nil
//    }
//    
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
//        insertSet = IndexSet()
//        deleteSet = IndexSet()
//    }
//    
//    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        switch type {
//        case .insert:
//            guard let indexPath = newIndexPath else { fatalError( "New index don't exist!") }
//            insertSet?.insert(indexPath.item)
//        case .delete:
//            guard let indexPath = newIndexPath else { fatalError( "Deleted index don't exist!") }
//            deleteSet?.insert(indexPath.item)
//        default:
//            return
//        }
//    }
//}
