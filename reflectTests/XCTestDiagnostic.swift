//
//  XCTestDiagnostic.swift
//  reflectTests
//
//  XCTest version to diagnose test issues
//

import XCTest
import CoreData
@testable import reflect

final class XCTestDiagnostic: XCTestCase {
    
    func testBasicXCTest() {
        print("✅✅✅ XCTEST IS RUNNING! ✅✅✅")
        XCTAssertEqual(1 + 1, 2, "Math works")
    }
    
    func testCoreDataManagerXCTest() async throws {
        print("🔍 XCTest attempting CoreDataManager...")
        let manager = CoreDataManager.inMemory()
        let context = manager.viewContext
        
        XCTAssertNotNil(context, "Context should exist")
        print("✅ XCTest: CoreDataManager works!")
    }
    
    func testPostEntityXCTest() async throws {
        print("🔍 XCTest creating PostEntity...")
        let manager = CoreDataManager.inMemory()
        let context = manager.viewContext
        
        let postEntity = PostEntity(context: context)
        postEntity.id = UUID()
        postEntity.caption = "XCTest diagnostic"
        postEntity.mood = 8
        postEntity.createdAt = Date()
        postEntity.postType = "text"
        
        XCTAssertEqual(postEntity.caption, "XCTest diagnostic")
        print("✅ XCTest: PostEntity created!")
        
        try await manager.save()
        print("✅ XCTest: PostEntity saved!")
    }
}
