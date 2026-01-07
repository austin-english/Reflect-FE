//
//  SimpleDiagnosticTest.swift
//  reflectTests
//
//  Simple diagnostic to verify test setup
//

import Testing
import Foundation
@preconcurrency import CoreData
@testable import reflect

@Suite("Diagnostic Tests")
@MainActor
struct SimpleDiagnosticTest {
    
    @Test("Basic test runs")
    func testBasic() {
        print("✅ Test is actually running!")
        #expect(1 + 1 == 2)
    }
    
    @Test("Can create CoreDataManager")
    func testCoreDataManager() async throws {
        print("🔍 Attempting to create CoreDataManager...")
        let manager = CoreDataManager.inMemory()
        print("✅ CoreDataManager created!")
        
        let context = manager.viewContext
        #expect(context != nil)
        print("✅ ViewContext is accessible!")
    }
    
    @Test("Can create PostEntity")
    func testPostEntity() async throws {
        print("🔍 Testing PostEntity creation...")
        let manager = CoreDataManager.inMemory()
        let context = manager.viewContext
        
        let postEntity = PostEntity(context: context)
        postEntity.id = UUID()
        postEntity.caption = "Diagnostic test"
        postEntity.mood = 8
        postEntity.createdAt = Date()
        postEntity.postType = "text"
        
        print("✅ PostEntity created!")
        #expect(postEntity.caption == "Diagnostic test")
        
        try await manager.save()
        print("✅ PostEntity saved!")
    }
}
