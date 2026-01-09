//
//  CoreDataManager.swift
//  reflect
//
//  Created by Austin English on 12/16/25.
//

import Foundation
@preconcurrency import CoreData

/// Actor for thread-safe Core Data operations
actor CoreDataManager {
    
    // MARK: - Singleton
    
    static let shared = CoreDataManager()
    
    // MARK: - Properties
    
    private let container: NSPersistentContainer
    
    /// Main thread view context for UI updates
    nonisolated var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    // MARK: - Initialization
    
    private init(inMemory: Bool = false) {
        // Load the model - create a COPY for in-memory stores to avoid conflicts
        guard let modelURL = Bundle.main.url(forResource: "ReflectDataModel", withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to load Core Data model")
        }
        
        container = NSPersistentContainer(name: "ReflectDataModel", managedObjectModel: model)
        
        // Configure for in-memory store if testing
        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
        }
        
        // Configure container for local-only storage (Phase 1-8)
        // In Phase 9, we'll switch to NSPersistentCloudKitContainer
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                // In production, handle this more gracefully
                fatalError("Core Data failed to load: \(error), \(error.userInfo)")
            }
            
            #if DEBUG
            print("✅ Core Data loaded successfully")
            print("Store URL: \(storeDescription.url?.absoluteString ?? "unknown")")
            #endif
        }
        
        // Configure view context
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // MARK: - Context Management
    
    /// Creates a new background context for background operations
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
    
    // MARK: - Save Operations
    
    /// Saves the main view context if it has changes
    func save() async throws {
        let context = viewContext
        guard context.hasChanges else { return }
        
        try await context.perform {
            do {
                try context.save()
                #if DEBUG
                print("✅ Core Data saved successfully")
                #endif
            } catch {
                #if DEBUG
                print("❌ Core Data save failed: \(error)")
                #endif
                throw CoreDataError.saveFailed(error)
            }
        }
    }
    
    /// Saves a specific context if it has changes
    func save(context: NSManagedObjectContext) async throws {
        guard context.hasChanges else { return }
        
        try await context.perform {
            do {
                try context.save()
                #if DEBUG
                print("✅ Background context saved successfully")
                #endif
            } catch {
                #if DEBUG
                print("❌ Background context save failed: \(error)")
                #endif
                throw CoreDataError.saveFailed(error)
            }
        }
    }
    
    // MARK: - Fetch Operations
    
    /// Fetches entities matching the given fetch request
    func fetch<T: NSManagedObject>(
        _ request: NSFetchRequest<T>,
        context: NSManagedObjectContext? = nil
    ) async throws -> [T] {
        let targetContext = context ?? viewContext
        let fetchRequest = request.copy() as! NSFetchRequest<T>
        
        return try await targetContext.perform {
            do {
                let results = try targetContext.fetch(fetchRequest)
                #if DEBUG
                print("✅ Fetched \(results.count) \(T.self) entities")
                #endif
                return results
            } catch {
                #if DEBUG
                print("❌ Fetch failed for \(T.self): \(error)")
                #endif
                throw CoreDataError.fetchFailed(error)
            }
        }
    }
    
    /// Fetches a single entity by ID
    func fetchByID<T: NSManagedObject>(
        _ type: T.Type,
        id: UUID,
        context: NSManagedObjectContext? = nil
    ) async throws -> T? {
        let targetContext = context ?? viewContext
        
        let request = NSFetchRequest<T>(entityName: String(describing: type))
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        let results = try await fetch(request, context: targetContext)
        return results.first
    }
    
    /// Fetches all entities of a given type
    func fetchAll<T: NSManagedObject>(
        _ type: T.Type,
        sortDescriptors: [NSSortDescriptor]? = nil,
        context: NSManagedObjectContext? = nil
    ) async throws -> [T] {
        let request = NSFetchRequest<T>(entityName: String(describing: type))
        request.sortDescriptors = sortDescriptors
        return try await fetch(request, context: context)
    }
    
    /// Counts entities matching the given fetch request
    func count<T: NSManagedObject>(
        _ request: NSFetchRequest<T>,
        context: NSManagedObjectContext? = nil
    ) async throws -> Int {
        let targetContext = context ?? viewContext
        let countRequest = request.copy() as! NSFetchRequest<T>
        
        return try await targetContext.perform {
            do {
                let count = try targetContext.count(for: countRequest)
                #if DEBUG
                print("✅ Counted \(count) \(T.self) entities")
                #endif
                return count
            } catch {
                #if DEBUG
                print("❌ Count failed for \(T.self): \(error)")
                #endif
                throw CoreDataError.countFailed(error)
            }
        }
    }
    
    // MARK: - Delete Operations
    
    /// Deletes a single entity
    func delete(_ object: NSManagedObject) async throws {
        let objectID = object.objectID
        let targetContext = object.managedObjectContext ?? viewContext
        
        await targetContext.perform {
            if let objectToDelete = try? targetContext.existingObject(with: objectID) {
                targetContext.delete(objectToDelete)
            }
        }
        
        try await save(context: targetContext)
    }
    
    /// Deletes multiple entities
    func delete(_ objects: [NSManagedObject]) async throws {
        guard !objects.isEmpty else { return }
        
        let objectIDs = objects.map { $0.objectID }
        let targetContext = objects.first?.managedObjectContext ?? viewContext
        
        await targetContext.perform {
            for objectID in objectIDs {
                if let objectToDelete = try? targetContext.existingObject(with: objectID) {
                    targetContext.delete(objectToDelete)
                }
            }
        }
        
        try await save(context: targetContext)
    }
    
    /// Deletes all entities matching the fetch request (batch delete)
    /// Note: Falls back to regular delete for in-memory stores
    func batchDelete<T: NSManagedObject>(
        _ type: T.Type,
        predicate: NSPredicate? = nil,
        context: NSManagedObjectContext? = nil
    ) async throws {
        let targetContext = context ?? viewContext
        
        // Check if this is an in-memory store
        let isInMemory = container.persistentStoreDescriptions.first?.type == NSInMemoryStoreType
        
        if isInMemory {
            // In-memory stores don't support batch delete, use regular delete
            let fetchRequest = NSFetchRequest<T>(entityName: String(describing: type))
            fetchRequest.predicate = predicate
            
            let objects = try await fetch(fetchRequest, context: targetContext)
            try await delete(objects)
            
            #if DEBUG
            print("✅ Deleted \(objects.count) \(T.self) entities (in-memory fallback)")
            #endif
        } else {
            // Use batch delete for persistent stores (faster)
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: type))
            fetchRequest.predicate = predicate
            
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            batchDeleteRequest.resultType = .resultTypeObjectIDs
            
            try await targetContext.perform {
                do {
                    let result = try targetContext.execute(batchDeleteRequest) as? NSBatchDeleteResult
                    
                    // Merge changes into view context
                    if let objectIDArray = result?.result as? [NSManagedObjectID] {
                        let changes = [NSDeletedObjectsKey: objectIDArray]
                        NSManagedObjectContext.mergeChanges(
                            fromRemoteContextSave: changes,
                            into: [self.container.viewContext]
                        )
                    }
                    
                    #if DEBUG
                    print("✅ Batch deleted \(T.self) entities")
                    #endif
                } catch {
                    #if DEBUG
                    print("❌ Batch delete failed for \(T.self): \(error)")
                    #endif
                    throw CoreDataError.deleteFailed(error)
                }
            }
        }
    }
    
    // MARK: - Batch Operations
    
    /// Performs a batch operation in the background
    func performBatchOperation(_ operation: @escaping (NSManagedObjectContext) async throws -> Void) async throws {
        let backgroundContext = newBackgroundContext()
        
        try await operation(backgroundContext)
        try await save(context: backgroundContext)
    }
    
    // MARK: - Reset
    
    /// Deletes all data from the store (use with caution!)
    func resetStore() async throws {
        guard let storeURL = container.persistentStoreDescriptions.first?.url else {
            throw CoreDataError.storeNotFound
        }
        
        let coordinator = container.persistentStoreCoordinator
        
        try await coordinator.perform {
            do {
                // Remove all stores
                for store in coordinator.persistentStores {
                    try coordinator.remove(store)
                }
                
                // Delete the store file
                try FileManager.default.removeItem(at: storeURL)
                
                // Reload stores
                self.container.loadPersistentStores { _, error in
                    if let error = error {
                        #if DEBUG
                        print("❌ Failed to reload store after reset: \(error)")
                        #endif
                    }
                }
                
                #if DEBUG
                print("✅ Core Data store reset successfully")
                #endif
            } catch {
                #if DEBUG
                print("❌ Store reset failed: \(error)")
                #endif
                throw CoreDataError.resetFailed(error)
            }
        }
    }
}

// MARK: - Core Data Errors

extension CoreDataManager {
    enum CoreDataError: LocalizedError {
        case saveFailed(Error)
        case fetchFailed(Error)
        case countFailed(Error)
        case deleteFailed(Error)
        case resetFailed(Error)
        case storeNotFound
        
        var errorDescription: String? {
            switch self {
            case .saveFailed(let error):
                return "Failed to save data: \(error.localizedDescription)"
            case .fetchFailed(let error):
                return "Failed to fetch data: \(error.localizedDescription)"
            case .countFailed(let error):
                return "Failed to count data: \(error.localizedDescription)"
            case .deleteFailed(let error):
                return "Failed to delete data: \(error.localizedDescription)"
            case .resetFailed(let error):
                return "Failed to reset store: \(error.localizedDescription)"
            case .storeNotFound:
                return "Core Data store not found"
            }
        }
    }
}

// MARK: - Preview Helper

#if DEBUG
extension CoreDataManager {
    /// Creates an in-memory Core Data stack for previews and testing
    static let preview: CoreDataManager = {
        CoreDataManager(inMemory: true)
    }()
    
    /// Creates a new in-memory instance for testing
    static func inMemory() -> CoreDataManager {
        CoreDataManager(inMemory: true)
    }
}
#endif
