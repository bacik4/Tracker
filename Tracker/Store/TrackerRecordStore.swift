//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Игорь Глебов on 04.06.2026.
//
import CoreData
import UIKit

struct TrackerRecordStoreUpdate {
    struct Move: Hashable {
        let oldIndex: Int
        let newIndex: Int
    }
    
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let movedIndexes: Set<Move>
}

protocol TrackerRecordStoreDelegate: AnyObject {
    func store(
        _ store: TrackerRecordStore,
        didUpdate update: TrackerRecordStoreUpdate
    )
}

enum TrackerRecordStoreError: Error {
    case decodingErrorInvalidTrackerId
    case decodingErrorInvalidDate
}

final class TrackerRecordStore: NSObject {
    // MARK: - Private Properties
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>!
    
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<TrackerRecordStoreUpdate.Move>?
    
    // MARK: - Public Properties
    
    weak var delegate: TrackerRecordStoreDelegate?
    
    var numberOfRecords: Int {
        fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    // MARK: - Init
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    // MARK: - Public Methods
    
    func record(at index: Int) throws -> TrackerRecord {
        let recordCoreData = fetchedResultsController.object(
            at: IndexPath(row: index, section: 0)
        )
        
        return try makeRecord(from: recordCoreData)
    }
    
    func records() throws -> [TrackerRecord] {
        let recordCoreDataObjects = fetchedResultsController.fetchedObjects ?? []
        
        return try recordCoreDataObjects.map { recordCoreData in
            try makeRecord(from: recordCoreData)
        }
    }
    
    func addRecord(_ record: TrackerRecord) throws {
        if try isTrackerCompleted(record.trackerId, on: record.date) {
            return
        }
        
        let recordCoreData = TrackerRecordCoreData(context: context)
        recordCoreData.trackerId = record.trackerId
        recordCoreData.date = record.date
        
        try context.save()
    }
    
    func deleteRecord(trackerId: UUID, on date: Date) throws {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return
        }
        
        request.predicate = NSPredicate(
            format: "trackerId == %@ AND date >= %@ AND date < %@",
            trackerId as CVarArg,
            startOfDay as NSDate,
            endOfDay as NSDate
        )
        
        let records = try context.fetch(request)
        
        records.forEach { record in
            context.delete(record)
        }
        
        try context.save()
    }
    
    func isTrackerCompleted(_ trackerId: UUID, on date: Date) throws -> Bool {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return false
        }
        
        request.predicate = NSPredicate(
            format: "trackerId == %@ AND date >= %@ AND date < %@",
            trackerId as CVarArg,
            startOfDay as NSDate,
            endOfDay as NSDate
        )
        
        request.fetchLimit = 1
        
        return try context.count(for: request) > 0
    }
    
    func completedDaysCount(for trackerId: UUID) throws -> Int {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "trackerId == %@", trackerId as CVarArg)
        
        return try context.count(for: request)
    }
    
    // MARK: - Private Methods
    
    private func setupFetchedResultsController() {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        
        request.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: true)
        ]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        fetchedResultsController.delegate = self
        self.fetchedResultsController = fetchedResultsController
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            assertionFailure("Failed to fetch records: \(error)")
        }
    }
    
    private func makeRecord(from recordCoreData: TrackerRecordCoreData) throws -> TrackerRecord {
        guard let trackerId = recordCoreData.trackerId else {
            throw TrackerRecordStoreError.decodingErrorInvalidTrackerId
        }
        
        guard let date = recordCoreData.date else {
            throw TrackerRecordStoreError.decodingErrorInvalidDate
        }
        
        return TrackerRecord(
            trackerId: trackerId,
            date: date
        )
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        movedIndexes = Set<TrackerRecordStoreUpdate.Move>()
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            if let newIndexPath {
                insertedIndexes?.insert(newIndexPath.row)
            }
            
        case .delete:
            if let indexPath {
                deletedIndexes?.insert(indexPath.row)
            }
            
        case .update:
            if let indexPath {
                updatedIndexes?.insert(indexPath.row)
            }
            
        case .move:
            if let indexPath, let newIndexPath {
                movedIndexes?.insert(
                    TrackerRecordStoreUpdate.Move(
                        oldIndex: indexPath.row,
                        newIndex: newIndexPath.row
                    )
                )
            }
            
        @unknown default:
            break
        }
    }
    
    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
        guard
            let insertedIndexes,
            let deletedIndexes,
            let updatedIndexes,
            let movedIndexes
        else {
            return
        }
        
        let update = TrackerRecordStoreUpdate(
            insertedIndexes: insertedIndexes,
            deletedIndexes: deletedIndexes,
            updatedIndexes: updatedIndexes,
            movedIndexes: movedIndexes
        )
        
        delegate?.store(self, didUpdate: update)
        
        self.insertedIndexes = nil
        self.deletedIndexes = nil
        self.updatedIndexes = nil
        self.movedIndexes = nil
    }
}

