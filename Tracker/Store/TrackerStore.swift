//
//  TrackerStore.swift
//  Tracker
//
//  Created by Игорь Глебов on 04.06.2026.
//
import CoreData
import UIKit

struct TrackerStoreUpdate {
    struct Move: Hashable {
        let oldIndex: Int
        let newIndex: Int
    }
    
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let movedIndexes: Set<Move>
}

protocol TrackerStoreDelegate: AnyObject {
    func store(
        _ store: TrackerStore,
        didUpdate update: TrackerStoreUpdate
    )
}

enum TrackerStoreError: Error {
    case decodingErrorInvalidId
    case decodingErrorInvalidTitle
    case decodingErrorInvalidColorHex
    case decodingErrorInvalidEmoji
    case decodingErrorInvalidSchedule
}

final class TrackerStore: NSObject {
    // MARK: - Private Properties
    private let context: NSManagedObjectContext
    private let fetchedResultsController: NSFetchedResultsController<TrackerCoreData>
    
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<TrackerStoreUpdate.Move>?
    
    // MARK: - Public Properties
    weak var delegate: TrackerStoreDelegate?
    
    var numberOfTrackers: Int {
        fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    // MARK: - Init
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        
        let request = TrackerCoreData.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "title", ascending: true)
        ]
        
        self.fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        super.init()
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            assertionFailure("Failed to fetch trackers: \(error)")
        }
    }
    
    // MARK: - Public Methods
    
    func tracker(at index: Int) throws -> Tracker {
        let trackerCoreData = fetchedResultsController.object(
            at: IndexPath(row: index, section: 0)
        )
        
        return try makeTracker(from: trackerCoreData)
    }
    
    func addTracker(_ tracker: Tracker, to categoryTitle: String) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        
        trackerCoreData.id = tracker.id
        trackerCoreData.title = tracker.title
        trackerCoreData.colorHex = tracker.color.hexString()
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = tracker.schedule
            .sorted { $0.rawValue < $1.rawValue }
            .map { String($0.rawValue) }
            .joined(separator: ",")
        
        let categoryCoreData = try getOrCreateCategory(with: categoryTitle)
        trackerCoreData.category = categoryCoreData
        
        try context.save()
    }
    
    func deleteTracker(_ tracker: Tracker) throws {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        request.fetchLimit = 1
        
        guard let trackerCoreData = try context.fetch(request).first else {
            return
        }
        
        context.delete(trackerCoreData)
        try context.save()
    }
    
    func updateTracker(_ tracker: Tracker, categoryTitle: String) throws {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        request.fetchLimit = 1
        
        guard let trackerCoreData = try context.fetch(request).first else {
            return
        }
        
        trackerCoreData.title = tracker.title
        trackerCoreData.colorHex = tracker.color.hexString()
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = tracker.schedule
            .sorted { $0.rawValue < $1.rawValue }
            .map { String($0.rawValue) }
            .joined(separator: ",")
        
        let categoryCoreData = try getOrCreateCategory(with: categoryTitle)
        trackerCoreData.category = categoryCoreData
        
        try context.save()
    }
    
    func categories() throws -> [TrackerCategory] {
        let trackerCoreDataObjects = fetchedResultsController.fetchedObjects ?? []
        
        var trackersByCategory: [String: [Tracker]] = [:]
        
        for trackerCoreData in trackerCoreDataObjects {
            let tracker = try makeTracker(from: trackerCoreData)
            let categoryTitle = trackerCoreData.category?.title ?? "Важное"
            
            trackersByCategory[categoryTitle, default: []].append(tracker)
        }
        
        return trackersByCategory
            .map { title, trackers in
                TrackerCategory(title: title, trackers: trackers)
            }
            .sorted { $0.title < $1.title }
    }
    
    // MARK: - Private Methods
    
    private func getOrCreateCategory(with title: String) throws -> TrackerCategoryCoreData {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        request.fetchLimit = 1
        
        if let existingCategory = try context.fetch(request).first {
            return existingCategory
        }
        
        let newCategory = TrackerCategoryCoreData(context: context)
        newCategory.title = title
        
        return newCategory
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
        
        let scheduleArray  = try scheduleString
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

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        movedIndexes = Set<TrackerStoreUpdate.Move>()
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
                    TrackerStoreUpdate.Move(
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
        
        let update = TrackerStoreUpdate(
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
