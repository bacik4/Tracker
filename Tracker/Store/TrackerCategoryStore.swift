//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Игорь Глебов on 04.06.2026.
//
import CoreData
import UIKit

struct TrackerCategoryStoreUpdate {
    struct Move: Hashable {
        let oldIndex: Int
        let newIndex: Int
    }
    
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let movedIndexes: Set<Move>
}

protocol TrackerCategoryStoreDelegate: AnyObject {
    func store(
        _ store: TrackerCategoryStore,
        didUpdate update: TrackerCategoryStoreUpdate
    )
}

enum TrackerCategoryStoreError: Error {
    case decodingErrorInvalidTitle
}

final class TrackerCategoryStore: NSObject {
    // MARK: - Private Properties
    
    private let context: NSManagedObjectContext
    
    private let fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>
    
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<TrackerCategoryStoreUpdate.Move>?
    
    // MARK: - Public Properties
    
    weak var delegate: TrackerCategoryStoreDelegate?
    
    var numberOfCategories: Int {
        fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    // MARK: - Init
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        
        let request = TrackerCategoryCoreData.fetchRequest()
        
        request.sortDescriptors = [
            NSSortDescriptor(key: "title", ascending: true)
        ]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        self.fetchedResultsController = fetchedResultsController
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            assertionFailure("Failed to fetch categories: \(error)")
        }
        
        super.init()
        fetchedResultsController.delegate = self
    }
    
    // MARK: - Public Methods
    
    func category(at index: Int) throws -> TrackerCategory {
        let categoryCoreData = fetchedResultsController.object(
            at: IndexPath(row: index, section: 0)
        )
        
        return try makeCategory(from: categoryCoreData)
    }
    
    func categories() throws -> [TrackerCategory] {
        let categoryCoreDataObjects = fetchedResultsController.fetchedObjects ?? []
        
        return try categoryCoreDataObjects.map { categoryCoreData in
            try makeCategory(from: categoryCoreData)
        }
    }
    
    func addCategory(title: String) throws {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        request.fetchLimit = 1
        
        if try context.fetch(request).first != nil {
            return
        }
        
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.title = title
        
        try context.save()
    }
    
    // MARK: - Private Methods
    
    private func makeCategory(from categoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let title = categoryCoreData.title else {
            throw TrackerCategoryStoreError.decodingErrorInvalidTitle
        }
        
        let trackerCoreDataSet = categoryCoreData.trackers as? Set<TrackerCoreData> ?? []
        
        let trackers = try trackerCoreDataSet
            .map { trackerCoreData in
                try makeTracker(from: trackerCoreData)
            }
            .sorted { $0.title < $1.title }
        
        return TrackerCategory(
            title: title,
            trackers: trackers
        )
    }
    
    private func makeTracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
        guard let id = trackerCoreData.id else {
            throw TrackerStoreError.decodingErrorInvalidId
        }
        
        guard let title = trackerCoreData.title else {
            throw TrackerStoreError.decodingErrorInvalidTitle
        }
        
        guard let colorHex = trackerCoreData.colorHex else {
            throw TrackerStoreError.decodingErrorInvalidColorHex
        }
        
        guard let emoji = trackerCoreData.emoji else {
            throw TrackerStoreError.decodingErrorInvalidEmoji
        }
        
        guard let scheduleString = trackerCoreData.schedule else {
            throw TrackerStoreError.decodingErrorInvalidSchedule
        }
        
        let color = UIColor(hex: colorHex)
        
        let scheduleArray = try scheduleString
            .split(separator: ",")
            .map { value -> WeekDay in
                guard
                    let rawValue = Int(value),
                    let weekDay = WeekDay(rawValue: rawValue)
                else {
                    throw TrackerStoreError.decodingErrorInvalidSchedule
                }
                
                return weekDay
            }
        
        let schedule = Set(scheduleArray)
        
        return Tracker(
            id: id,
            title: title,
            color: color,
            emoji: emoji,
            schedule: schedule
        )
    }
    
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        movedIndexes = Set<TrackerCategoryStoreUpdate.Move>()
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
                    TrackerCategoryStoreUpdate.Move(
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
        
        let update = TrackerCategoryStoreUpdate(
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
