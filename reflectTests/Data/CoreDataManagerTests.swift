//
//  CoreDataManagerTests.swift
//  reflectTests
//
//  Created by Austin English on 12/16/25.
//

import Testing
import Foundation
@preconcurrency import CoreData
@testable import reflect

/// Tests for CoreDataManager actor
@Suite("Core Data Manager Tests", .serialized)
@MainActor
struct CoreDataManagerTests {
    
    /// Creates a fresh in-memory Core Data manager for each test
    func makeManager() -> CoreDataManager {
        CoreDataManager.inMemory()
    }
    
    @Test("CoreDataManager can save and fetch a PostEntity")
    func testSaveAndFetchPostEntity() async throws {
        let manager = makeManager()
        let context = manager.viewContext
        
        // Create a test post entity
        let postEntity = PostEntity(context: context)
        postEntity.id = UUID()
        postEntity.caption = "Test post"
        postEntity.mood = 8
        postEntity.createdAt = Date()
        postEntity.postType = "text"
        
        // Save
        try await manager.save()
        
        // Fetch back
        let fetchedEntity = try await manager.fetchByID(PostEntity.self, id: postEntity.id!)
        
        // Verify
        #expect(fetchedEntity != nil)
        #expect(fetchedEntity?.caption == "Test post")
        #expect(fetchedEntity?.mood == 8)
        
        // Cleanup
        if let entity = fetchedEntity {
            try await manager.delete(entity)
        }
    }
    
    @Test("CoreDataManager can delete entities")
    func testDeleteEntity() async throws {
        let manager = makeManager()
        let context = manager.viewContext
        
        // Create entity
        let postEntity = PostEntity(context: context)
        postEntity.id = UUID()
        postEntity.caption = "To be deleted"
        postEntity.mood = 5
        postEntity.createdAt = Date()
        postEntity.postType = "text"
        
        try await manager.save()
        let entityId = postEntity.id!
        
        // Delete
        try await manager.delete(postEntity)
        
        // Verify it's gone
        let fetchedEntity = try await manager.fetchByID(PostEntity.self, id: entityId)
        #expect(fetchedEntity == nil)
    }
    
    @Test("CoreDataManager can count entities")
    func testCountEntities() async throws {
        let manager = makeManager()
        let context = manager.viewContext
        
        // Create multiple entities
        let id1 = UUID()
        let id2 = UUID()
        
        let post1 = PostEntity(context: context)
        post1.id = id1
        post1.caption = "Post 1"
        post1.mood = 7
        post1.createdAt = Date()
        post1.postType = "text"
        
        let post2 = PostEntity(context: context)
        post2.id = id2
        post2.caption = "Post 2"
        post2.mood = 9
        post2.createdAt = Date()
        post2.postType = "text"
        
        try await manager.save()
        
        // Count
        let request = PostEntity.fetchRequest()
        let count = try await manager.count(request)
        
        #expect(count == 2)
        
        // Cleanup
        try await manager.delete([post1, post2])
    }
}
