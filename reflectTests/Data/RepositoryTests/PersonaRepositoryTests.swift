//
//  PersonaRepositoryTests.swift
//  reflectTests
//
//  Created by Austin English on 1/13/26.
//

import Testing
import Foundation
import CoreData
@testable import reflect

/// Tests for PersonaRepository implementation
///
/// **Testing Strategy:**
/// These tests use in-memory Core Data stores for fast unit testing.
/// In-memory stores test business logic, data mapping, and relationships.
///
/// ⚠️ **TODO (Before Phase 9 - CloudKit):**
/// Add PersistentStoreIntegrationTests suite to verify:
/// - Data persists across app restarts
/// - Batch operations work on SQLite
/// - Migrations work correctly
/// - Concurrent saves are handled
///
/// See ARCHITECTURE.md "Testing Architecture" section for details.
///
@Suite("Persona Repository Tests", .serialized)
@MainActor
struct PersonaRepositoryTests {
    
    // MARK: - Helper Methods
    
    /// Creates a fresh in-memory Core Data manager for testing
    func makeManager() -> CoreDataManager {
        CoreDataManager.inMemory()
    }
    
    /// Creates a test user for persona tests
    func makeTestUser(name: String = "Test User") async throws -> (manager: CoreDataManager, userRepo: UserRepositoryImpl, personaRepo: PersonaRepositoryImpl, user: User) {
        let manager = makeManager()
        let userRepo = UserRepositoryImpl(coreDataManager: manager)
        let personaRepo = PersonaRepositoryImpl(coreDataManager: manager)
        let user = User(name: name)
        try await userRepo.create(user)
        return (manager, userRepo, personaRepo, user)
    }
    
    // MARK: - Tests
    
    @Test("PersonaRepository can create and fetch persona")
    func testCreateAndFetch() async throws {
        let (_, userRepo, personaRepo, user) = try await makeTestUser()
        
        // Create persona
        let persona = Persona(
            name: "Work",
            color: .blue,
            icon: .briefcase,
            description: "Work stuff",
            isDefault: true,
            userId: user.id
        )
        
        try await personaRepo.create(persona)
        
        // Fetch persona
        let fetchedPersona = try await personaRepo.fetch(id: persona.id)
        
        // Verify
        #expect(fetchedPersona != nil)
        #expect(fetchedPersona?.name == "Work")
        #expect(fetchedPersona?.color == .blue)
        #expect(fetchedPersona?.isDefault == true)
        
        // Cleanup
        try await personaRepo.delete(id: persona.id)
        try await userRepo.delete(id: user.id)
    }
    
    @Test("PersonaRepository can fetch all personas for user")
    func testFetchAll() async throws {
        let (_, userRepo, personaRepo, user) = try await makeTestUser()
        
        // Create multiple personas
        let persona1 = Persona(
            name: "Personal",
            color: .blue,
            icon: .person,
            isDefault: true,
            userId: user.id
        )
        let persona2 = Persona(
            name: "Work",
            color: .gray,
            icon: .briefcase,
            userId: user.id
        )
        
        try await personaRepo.create(persona1)
        try await personaRepo.create(persona2)
        
        // Fetch all
        let personas = try await personaRepo.fetchPersonas(for: user.id)
        
        // Verify
        #expect(personas.count == 2)
        #expect(personas.contains { $0.name == "Personal" })
        #expect(personas.contains { $0.name == "Work" })
        
        // Cleanup
        try await personaRepo.delete(id: persona1.id)
        try await personaRepo.delete(id: persona2.id)
        try await userRepo.delete(id: user.id)
    }
    
    @Test("PersonaRepository can update persona")
    func testUpdate() async throws {
        let (_, userRepo, personaRepo, user) = try await makeTestUser()
        
        // Create persona
        var persona = Persona(
            name: "Original Name",
            color: .blue,
            icon: .person,
            userId: user.id
        )
        try await personaRepo.create(persona)
        
        // Update persona
        persona.name = "Updated Name"
        persona.color = .green
        persona.icon = .briefcase
        persona.description = "New description"
        try await personaRepo.update(persona)
        
        // Fetch and verify
        let fetchedPersona = try await personaRepo.fetch(id: persona.id)
        #expect(fetchedPersona?.name == "Updated Name")
        #expect(fetchedPersona?.color == .green)
        #expect(fetchedPersona?.icon == .briefcase)
        #expect(fetchedPersona?.description == "New description")
        
        // Cleanup
        try await personaRepo.delete(id: persona.id)
        try await userRepo.delete(id: user.id)
    }
    
    @Test("PersonaRepository can fetch default persona")
    func testFetchDefault() async throws {
        let (_, userRepo, personaRepo, user) = try await makeTestUser()
        
        // Create personas (one default, one not)
        let persona1 = Persona(
            name: "Not Default",
            color: .blue,
            icon: .person,
            isDefault: false,
            userId: user.id
        )
        let persona2 = Persona(
            name: "Default Persona",
            color: .green,
            icon: .briefcase,
            isDefault: true,
            userId: user.id
        )
        
        try await personaRepo.create(persona1)
        try await personaRepo.create(persona2)
        
        // Fetch default
        let defaultPersona = try await personaRepo.fetchDefaultPersona(for: user.id)
        
        // Verify
        #expect(defaultPersona != nil)
        #expect(defaultPersona?.name == "Default Persona")
        #expect(defaultPersona?.isDefault == true)
        
        // Cleanup
        try await personaRepo.delete(id: persona1.id)
        try await personaRepo.delete(id: persona2.id)
        try await userRepo.delete(id: user.id)
    }
    
    @Test("PersonaRepository can set default persona")
    func testSetDefault() async throws {
        let (_, userRepo, personaRepo, user) = try await makeTestUser()
        
        // Create personas
        let persona1 = Persona(
            name: "First",
            color: .blue,
            icon: .person,
            isDefault: true,
            userId: user.id
        )
        let persona2 = Persona(
            name: "Second",
            color: .green,
            icon: .briefcase,
            isDefault: false,
            userId: user.id
        )
        
        try await personaRepo.create(persona1)
        try await personaRepo.create(persona2)
        
        // Set second persona as default
        try await personaRepo.setDefaultPersona(personaId: persona2.id, for: user.id)
        
        // Fetch default
        let defaultPersona = try await personaRepo.fetchDefaultPersona(for: user.id)
        
        // Verify
        #expect(defaultPersona?.id == persona2.id)
        #expect(defaultPersona?.name == "Second")
        
        // Verify first persona is no longer default
        let firstPersona = try await personaRepo.fetch(id: persona1.id)
        #expect(firstPersona?.isDefault == false)
        
        // Cleanup
        try await personaRepo.delete(id: persona1.id)
        try await personaRepo.delete(id: persona2.id)
        try await userRepo.delete(id: user.id)
    }
    
    @Test("PersonaRepository can check name uniqueness")
    func testNameUniqueness() async throws {
        let (_, userRepo, personaRepo, user) = try await makeTestUser()
        
        // Create persona with name "Work"
        let persona = Persona(
            name: "Work",
            color: .blue,
            icon: .briefcase,
            userId: user.id
        )
        try await personaRepo.create(persona)
        
        // Check that "Work" is not unique
        let isUniqueWork = try await personaRepo.isPersonaNameUnique(
            name: "Work",
            for: user.id,
            excludingId: nil
        )
        #expect(isUniqueWork == false)
        
        // Check that "Personal" is unique
        let isUniquePersonal = try await personaRepo.isPersonaNameUnique(
            name: "Personal",
            for: user.id,
            excludingId: nil
        )
        #expect(isUniquePersonal == true)
        
        // Check that "Work" is unique when excluding the existing persona (for updates)
        let isUniqueExcluding = try await personaRepo.isPersonaNameUnique(
            name: "Work",
            for: user.id,
            excludingId: persona.id
        )
        #expect(isUniqueExcluding == true)
        
        // Cleanup
        try await personaRepo.delete(id: persona.id)
        try await userRepo.delete(id: user.id)
    }
    
    @Test("PersonaRepository can check creation limits")
    func testCreationLimits() async throws {
        let (_, userRepo, personaRepo, user) = try await makeTestUser()
        
        // Free user should be able to create 1 persona
        let canCreateFree = try await personaRepo.canCreatePersona(for: user.id, isPremium: false)
        #expect(canCreateFree == true)
        
        // Create one persona
        let persona = Persona(
            name: "Personal",
            color: .blue,
            icon: .person,
            userId: user.id
        )
        try await personaRepo.create(persona)
        
        // Free user should NOT be able to create more
        let canCreateAfterOne = try await personaRepo.canCreatePersona(for: user.id, isPremium: false)
        #expect(canCreateAfterOne == false)
        
        // Premium user should still be able to create more (limit is 5)
        let canCreatePremium = try await personaRepo.canCreatePersona(for: user.id, isPremium: true)
        #expect(canCreatePremium == true)
        
        // Cleanup
        try await personaRepo.delete(id: persona.id)
        try await userRepo.delete(id: user.id)
    }
    
    @Test("PersonaRepository can create from preset")
    func testCreateFromPreset() async throws {
        let (_, userRepo, personaRepo, user) = try await makeTestUser()
        
        // Create persona from work preset
        let workPersona = try await personaRepo.createFromPreset(
            .work,
            for: user.id,
            isDefault: true
        )
        
        // Verify
        #expect(workPersona.name == "Work")
        #expect(workPersona.color == .gray)
        #expect(workPersona.icon == .briefcase)
        #expect(workPersona.isDefault == true)
        #expect(workPersona.description == "Career, projects, and professional growth")
        
        // Verify it was saved
        let fetchedPersona = try await personaRepo.fetch(id: workPersona.id)
        #expect(fetchedPersona != nil)
        #expect(fetchedPersona?.name == "Work")
        
        // Cleanup
        try await personaRepo.delete(id: workPersona.id)
        try await userRepo.delete(id: user.id)
    }
    
    @Test("PersonaRepository can fetch personas by color")
    func testFetchByColor() async throws {
        let (_, userRepo, personaRepo, user) = try await makeTestUser()
        
        // Create personas with different colors
        let bluePersona = Persona(
            name: "Blue One",
            color: .blue,
            icon: .person,
            userId: user.id
        )
        let greenPersona = Persona(
            name: "Green One",
            color: .green,
            icon: .briefcase,
            userId: user.id
        )
        let bluePersona2 = Persona(
            name: "Blue Two",
            color: .blue,
            icon: .heart,
            userId: user.id
        )
        
        try await personaRepo.create(bluePersona)
        try await personaRepo.create(greenPersona)
        try await personaRepo.create(bluePersona2)
        
        // Fetch blue personas
        let bluePersonas = try await personaRepo.fetchPersonas(withColor: .blue, for: user.id)
        
        // Verify
        #expect(bluePersonas.count == 2)
        #expect(bluePersonas.allSatisfy { $0.color == .blue })
        #expect(bluePersonas.contains { $0.name == "Blue One" })
        #expect(bluePersonas.contains { $0.name == "Blue Two" })
        
        // Cleanup
        try await personaRepo.delete(id: bluePersona.id)
        try await personaRepo.delete(id: greenPersona.id)
        try await personaRepo.delete(id: bluePersona2.id)
        try await userRepo.delete(id: user.id)
    }
    
    @Test("PersonaRepository can fetch persona count")
    func testFetchCount() async throws {
        let (_, userRepo, personaRepo, user) = try await makeTestUser()
        
        // Initially should be 0
        let initialCount = try await personaRepo.fetchPersonaCount(for: user.id)
        #expect(initialCount == 0)
        
        // Create personas
        let persona1 = Persona(name: "First", color: .blue, icon: .person, userId: user.id)
        let persona2 = Persona(name: "Second", color: .green, icon: .briefcase, userId: user.id)
        
        try await personaRepo.create(persona1)
        try await personaRepo.create(persona2)
        
        // Should be 2
        let count = try await personaRepo.fetchPersonaCount(for: user.id)
        #expect(count == 2)
        
        // Cleanup
        try await personaRepo.delete(id: persona1.id)
        try await personaRepo.delete(id: persona2.id)
        try await userRepo.delete(id: user.id)
    }
    
    @Test("PersonaRepository can fetch most used persona")
    func testMostUsed() async throws {
        let (manager, userRepo, personaRepo, user) = try await makeTestUser()
        let postRepo = PostRepositoryImpl(coreDataManager: manager)
        
        // Create personas
        let persona1 = Persona(name: "Less Used", color: .blue, icon: .person, userId: user.id)
        let persona2 = Persona(name: "Most Used", color: .green, icon: .briefcase, userId: user.id)
        
        try await personaRepo.create(persona1)
        try await personaRepo.create(persona2)
        
        // Create posts (more for persona2)
        let post1 = Post(caption: "Post 1", mood: 7, personaId: persona1.id, postType: .text)
        let post2 = Post(caption: "Post 2", mood: 8, personaId: persona2.id, postType: .text)
        let post3 = Post(caption: "Post 3", mood: 9, personaId: persona2.id, postType: .text)
        let post4 = Post(caption: "Post 4", mood: 8, personaId: persona2.id, postType: .text)
        
        try await postRepo.create(post1)
        try await postRepo.create(post2)
        try await postRepo.create(post3)
        try await postRepo.create(post4)
        
        // Fetch most used persona
        let mostUsed = try await personaRepo.fetchMostUsedPersona(for: user.id)
        
        // Verify
        #expect(mostUsed != nil)
        #expect(mostUsed?.persona.name == "Most Used")
        #expect(mostUsed?.postCount == 3)
        
        // Cleanup
        try await postRepo.delete(id: post1.id)
        try await postRepo.delete(id: post2.id)
        try await postRepo.delete(id: post3.id)
        try await postRepo.delete(id: post4.id)
        try await personaRepo.delete(id: persona1.id)
        try await personaRepo.delete(id: persona2.id)
        try await userRepo.delete(id: user.id)
    }
    
    @Test("PersonaRepository can fetch post counts by persona")
    func testPostCounts() async throws {
        let (manager, userRepo, personaRepo, user) = try await makeTestUser()
        let postRepo = PostRepositoryImpl(coreDataManager: manager)
        
        // Create personas
        let persona1 = Persona(name: "First", color: .blue, icon: .person, userId: user.id)
        let persona2 = Persona(name: "Second", color: .green, icon: .briefcase, userId: user.id)
        
        try await personaRepo.create(persona1)
        try await personaRepo.create(persona2)
        
        // Create posts
        let post1 = Post(caption: "Post 1", mood: 7, personaId: persona1.id, postType: .text)
        let post2 = Post(caption: "Post 2", mood: 8, personaId: persona1.id, postType: .text)
        let post3 = Post(caption: "Post 3", mood: 9, personaId: persona2.id, postType: .text)
        
        try await postRepo.create(post1)
        try await postRepo.create(post2)
        try await postRepo.create(post3)
        
        // Fetch post counts
        let postCounts = try await personaRepo.fetchPostCountsByPersona(for: user.id)
        
        // Verify
        #expect(postCounts[persona1.id] == 2)
        #expect(postCounts[persona2.id] == 1)
        
        // Cleanup
        try await postRepo.delete(id: post1.id)
        try await postRepo.delete(id: post2.id)
        try await postRepo.delete(id: post3.id)
        try await personaRepo.delete(id: persona1.id)
        try await personaRepo.delete(id: persona2.id)
        try await userRepo.delete(id: user.id)
    }
    
    @Test("PersonaRepository can delete all personas for user")
    func testDeleteAll() async throws {
        let (_, userRepo, personaRepo, user) = try await makeTestUser()
        
        // Create personas
        let persona1 = Persona(name: "First", color: .blue, icon: .person, userId: user.id)
        let persona2 = Persona(name: "Second", color: .green, icon: .briefcase, userId: user.id)
        
        try await personaRepo.create(persona1)
        try await personaRepo.create(persona2)
        
        // Verify they exist
        let countBefore = try await personaRepo.fetchPersonaCount(for: user.id)
        #expect(countBefore == 2)
        
        // Delete all
        try await personaRepo.deleteAllPersonas(for: user.id)
        
        // Verify they're gone
        let countAfter = try await personaRepo.fetchPersonaCount(for: user.id)
        #expect(countAfter == 0)
        
        // Cleanup
        try await userRepo.delete(id: user.id)
    }
}
