//
//  RepositoryTests.swift
//  reflectTests
//
//  Created by Austin English on 12/16/25.
//

import Testing
import Foundation
@testable import reflect

/// Tests for repository implementations
@Suite("Repository Tests")
@MainActor
struct RepositoryTests {
    
    // MARK: - Helper Methods
    
    /// Creates a fresh in-memory Core Data manager for testing
    func makeManager() -> CoreDataManager {
        CoreDataManager.inMemory()
    }
    
    // MARK: - User Repository Tests
    
    @Test("UserRepository can create and fetch user")
    func testUserRepositoryCreateAndFetch() async throws {
        let manager = makeManager()
        let repository = UserRepositoryImpl(coreDataManager: manager)
        
        // Create user
        let user = User(
            name: "Test User",
            bio: "Test bio",
            email: "test@example.com"
        )
        
        try await repository.create(user)
        
        // Fetch user
        let fetchedUser = try await repository.fetch(id: user.id)
        
        // Verify
        #expect(fetchedUser != nil)
        #expect(fetchedUser?.name == "Test User")
        #expect(fetchedUser?.bio == "Test bio")
        #expect(fetchedUser?.email == "test@example.com")
        
        // Cleanup
        try await repository.delete(id: user.id)
    }
    
    @Test("UserRepository can update user")
    func testUserRepositoryUpdate() async throws {
        let manager = makeManager()
        let repository = UserRepositoryImpl(coreDataManager: manager)
        
        // Create user
        var user = User(name: "Original Name")
        try await repository.create(user)
        
        // Update user
        user.name = "Updated Name"
        user.bio = "New bio"
        try await repository.update(user)
        
        // Fetch and verify
        let fetchedUser = try await repository.fetch(id: user.id)
        #expect(fetchedUser?.name == "Updated Name")
        #expect(fetchedUser?.bio == "New bio")
        
        // Cleanup
        try await repository.delete(id: user.id)
    }
    
    @Test("UserRepository can check if user exists")
    func testUserRepositoryHasUser() async throws {
        let manager = makeManager()
        let repository = UserRepositoryImpl(coreDataManager: manager)
        
        // Initially should be false
        let hasUserBefore = try await repository.hasUser()
        #expect(hasUserBefore == false)
        
        // Create user
        let user = User(name: "Test User")
        try await repository.create(user)
        
        // Should be true now
        let hasUserAfter = try await repository.hasUser()
        #expect(hasUserAfter == true)
        
        // Cleanup
        try await repository.delete(id: user.id)
    }
    
    @Test("UserRepository can fetch current user")
    func testUserRepositoryFetchCurrentUser() async throws {
        let manager = makeManager()
        let repository = UserRepositoryImpl(coreDataManager: manager)
        
        // Create user
        let user = User(name: "Current User")
        try await repository.create(user)
        
        // Fetch current user
        let currentUser = try await repository.fetchCurrentUser()
        
        // Verify
        #expect(currentUser != nil)
        #expect(currentUser?.name == "Current User")
        
        // Cleanup
        try await repository.delete(id: user.id)
    }
    
    @Test("UserRepository can update preferences")
    func testUserRepositoryUpdatePreferences() async throws {
        let manager = makeManager()
        let repository = UserRepositoryImpl(coreDataManager: manager)
        
        // Create user
        let user = User(name: "Test User")
        try await repository.create(user)
        
        // Update preferences
        var newPrefs = User.UserPreferences()
        newPrefs.notificationsEnabled = false
        newPrefs.appLockEnabled = true
        newPrefs.lockTimeout = .fiveMinutes
        
        try await repository.updatePreferences(for: user.id, preferences: newPrefs)
        
        // Fetch and verify
        let fetchedPrefs = try await repository.fetchPreferences(for: user.id)
        #expect(fetchedPrefs.notificationsEnabled == false)
        #expect(fetchedPrefs.appLockEnabled == true)
        #expect(fetchedPrefs.lockTimeout == .fiveMinutes)
        
        // Cleanup
        try await repository.delete(id: user.id)
    }
    
    @Test("UserRepository can update premium status")
    func testUserRepositoryUpdatePremiumStatus() async throws {
        let manager = makeManager()
        let repository = UserRepositoryImpl(coreDataManager: manager)
        
        // Create user
        let user = User(name: "Test User")
        try await repository.create(user)
        
        // User should not be premium initially
        let hasPremiumBefore = try await repository.hasActivePremium(for: user.id)
        #expect(hasPremiumBefore == false)
        
        // Update to premium
        let expiresAt = Date().addingTimeInterval(30 * 24 * 60 * 60) // 30 days
        try await repository.updatePremiumStatus(for: user.id, isPremium: true, expiresAt: expiresAt)
        
        // Verify premium is active
        let hasPremiumAfter = try await repository.hasActivePremium(for: user.id)
        #expect(hasPremiumAfter == true)
        
        // Cleanup
        try await repository.delete(id: user.id)
    }
    
    @Test("UserRepository can update statistics")
    func testUserRepositoryUpdateStatistics() async throws {
        let manager = makeManager()
        let repository = UserRepositoryImpl(coreDataManager: manager)
        
        // Create user
        let user = User(name: "Test User")
        try await repository.create(user)
        
        // Update statistics
        try await repository.updateStatistics(
            for: user.id,
            totalPosts: 42,
            currentStreak: 7,
            longestStreak: 15
        )
        
        // Fetch and verify
        let stats = try await repository.fetchStatistics(for: user.id)
        #expect(stats.totalPosts == 42)
        #expect(stats.currentStreak == 7)
        #expect(stats.longestStreak == 15)
        
        // Cleanup
        try await repository.delete(id: user.id)
    }
    
    @Test("UserRepository can increment and decrement post count")
    func testUserRepositoryPostCountOperations() async throws {
        let manager = makeManager()
        let repository = UserRepositoryImpl(coreDataManager: manager)
        
        // Create user
        let user = User(name: "Test User")
        try await repository.create(user)
        
        // Increment post count
        try await repository.incrementPostCount(for: user.id)
        try await repository.incrementPostCount(for: user.id)
        try await repository.incrementPostCount(for: user.id)
        
        // Verify count is 3
        var stats = try await repository.fetchStatistics(for: user.id)
        #expect(stats.totalPosts == 3)
        
        // Decrement post count
        try await repository.decrementPostCount(for: user.id)
        
        // Verify count is 2
        stats = try await repository.fetchStatistics(for: user.id)
        #expect(stats.totalPosts == 2)
        
        // Cleanup
        try await repository.delete(id: user.id)
    }
    
    @Test("UserRepository can update profile")
    func testUserRepositoryUpdateProfile() async throws {
        let manager = makeManager()
        let repository = UserRepositoryImpl(coreDataManager: manager)
        
        // Create user
        let user = User(name: "Original Name", bio: "Original bio")
        try await repository.create(user)
        
        // Update profile
        try await repository.updateProfile(
            for: user.id,
            name: "New Name",
            bio: "New bio text"
        )
        
        // Fetch and verify
        let fetchedUser = try await repository.fetch(id: user.id)
        #expect(fetchedUser?.name == "New Name")
        #expect(fetchedUser?.bio == "New bio text")
        #expect(fetchedUser?.updatedAt != nil)
        
        // Cleanup
        try await repository.delete(id: user.id)
    }
    
    @Test("UserRepository can update profile photo")
    func testUserRepositoryUpdateProfilePhoto() async throws {
        let manager = makeManager()
        let repository = UserRepositoryImpl(coreDataManager: manager)
        
        // Create user
        let user = User(name: "Test User")
        try await repository.create(user)
        
        // Update profile photo
        try await repository.updateProfilePhoto(for: user.id, filename: "profile_123.jpg")
        
        // Fetch and verify
        let fetchedUser = try await repository.fetch(id: user.id)
        #expect(fetchedUser?.profilePhotoFilename == "profile_123.jpg")
        
        // Cleanup
        try await repository.delete(id: user.id)
    }
    
    @Test("UserRepository can update streaks")
    func testUserRepositoryUpdateStreaks() async throws {
        let manager = makeManager()
        let repository = UserRepositoryImpl(coreDataManager: manager)
        
        // Create user
        let user = User(name: "Test User")
        try await repository.create(user)
        
        // Update streaks
        try await repository.updateStreaks(
            for: user.id,
            currentStreak: 10,
            longestStreak: 25
        )
        
        // Fetch and verify
        let stats = try await repository.fetchStatistics(for: user.id)
        #expect(stats.currentStreak == 10)
        #expect(stats.longestStreak == 25)
        
        // Cleanup
        try await repository.delete(id: user.id)
    }
    
    // MARK: - Persona Repository Tests
    
    @Test("PersonaRepository can create and fetch persona")
    func testPersonaRepositoryCreateAndFetch() async throws {
        let manager = makeManager()
        let userRepo = UserRepositoryImpl(coreDataManager: manager)
        let personaRepo = PersonaRepositoryImpl(coreDataManager: manager)
        
        // Create user first
        let user = User(name: "Test User")
        try await userRepo.create(user)
        
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
    func testPersonaRepositoryFetchAll() async throws {
        let manager = makeManager()
        let userRepo = UserRepositoryImpl(coreDataManager: manager)
        let personaRepo = PersonaRepositoryImpl(coreDataManager: manager)
        
        // Create user
        let user = User(name: "Test User")
        try await userRepo.create(user)
        
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
    func testPersonaRepositoryUpdate() async throws {
        let manager = makeManager()
        let userRepo = UserRepositoryImpl(coreDataManager: manager)
        let personaRepo = PersonaRepositoryImpl(coreDataManager: manager)
        
        // Create user
        let user = User(name: "Test User")
        try await userRepo.create(user)
        
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
    func testPersonaRepositoryFetchDefault() async throws {
        let manager = makeManager()
        let userRepo = UserRepositoryImpl(coreDataManager: manager)
        let personaRepo = PersonaRepositoryImpl(coreDataManager: manager)
        
        // Create user
        let user = User(name: "Test User")
        try await userRepo.create(user)
        
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
    func testPersonaRepositorySetDefault() async throws {
        let manager = makeManager()
        let userRepo = UserRepositoryImpl(coreDataManager: manager)
        let personaRepo = PersonaRepositoryImpl(coreDataManager: manager)
        
        // Create user
        let user = User(name: "Test User")
        try await userRepo.create(user)
        
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
    func testPersonaRepositoryNameUniqueness() async throws {
        let manager = makeManager()
        let userRepo = UserRepositoryImpl(coreDataManager: manager)
        let personaRepo = PersonaRepositoryImpl(coreDataManager: manager)
        
        // Create user
        let user = User(name: "Test User")
        try await userRepo.create(user)
        
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
    func testPersonaRepositoryCreationLimits() async throws {
        let manager = makeManager()
        let userRepo = UserRepositoryImpl(coreDataManager: manager)
        let personaRepo = PersonaRepositoryImpl(coreDataManager: manager)
        
        // Create user
        let user = User(name: "Test User")
        try await userRepo.create(user)
        
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
    func testPersonaRepositoryCreateFromPreset() async throws {
        let manager = makeManager()
        let userRepo = UserRepositoryImpl(coreDataManager: manager)
        let personaRepo = PersonaRepositoryImpl(coreDataManager: manager)
        
        // Create user
        let user = User(name: "Test User")
        try await userRepo.create(user)
        
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
    func testPersonaRepositoryFetchByColor() async throws {
        let manager = makeManager()
        let userRepo = UserRepositoryImpl(coreDataManager: manager)
        let personaRepo = PersonaRepositoryImpl(coreDataManager: manager)
        
        // Create user
        let user = User(name: "Test User")
        try await userRepo.create(user)
        
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
    func testPersonaRepositoryFetchCount() async throws {
        let manager = makeManager()
        let userRepo = UserRepositoryImpl(coreDataManager: manager)
        let personaRepo = PersonaRepositoryImpl(coreDataManager: manager)
        
        // Create user
        let user = User(name: "Test User")
        try await userRepo.create(user)
        
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
    func testPersonaRepositoryMostUsed() async throws {
        let manager = makeManager()
        let userRepo = UserRepositoryImpl(coreDataManager: manager)
        let personaRepo = PersonaRepositoryImpl(coreDataManager: manager)
        let postRepo = PostRepositoryImpl(coreDataManager: manager)
        
        // Create user
        let user = User(name: "Test User")
        try await userRepo.create(user)
        
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
    func testPersonaRepositoryPostCounts() async throws {
        let manager = makeManager()
        let userRepo = UserRepositoryImpl(coreDataManager: manager)
        let personaRepo = PersonaRepositoryImpl(coreDataManager: manager)
        let postRepo = PostRepositoryImpl(coreDataManager: manager)
        
        // Create user
        let user = User(name: "Test User")
        try await userRepo.create(user)
        
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
    func testPersonaRepositoryDeleteAll() async throws {
        let manager = makeManager()
        let userRepo = UserRepositoryImpl(coreDataManager: manager)
        let personaRepo = PersonaRepositoryImpl(coreDataManager: manager)
        
        // Create user
        let user = User(name: "Test User")
        try await userRepo.create(user)
        
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
    
    // MARK: - Post Repository Tests
    
    @Test("PostRepository can create and fetch post")
    func testPostRepositoryCreateAndFetch() async throws {
        let manager = makeManager()
        let userRepo = UserRepositoryImpl(coreDataManager: manager)
        let personaRepo = PersonaRepositoryImpl(coreDataManager: manager)
        let postRepo = PostRepositoryImpl(coreDataManager: manager)
        
        // Setup user and persona
        let user = User(name: "Test User")
        try await userRepo.create(user)
        
        let persona = Persona(
            name: "Personal",
            color: .blue,
            icon: .person,
            isDefault: true,
            userId: user.id
        )
        try await personaRepo.create(persona)
        
        // Create post
        let post = Post(
            caption: "Test post",
            mood: 8,
            experienceRating: 9,
            personaId: persona.id,
            activityTags: ["test", "swift"],
            peopleTags: ["friends"],
            postType: .text
        )
        
        try await postRepo.create(post)
        
        // Fetch post
        let fetchedPost = try await postRepo.fetch(id: post.id)
        
        // Verify
        #expect(fetchedPost != nil)
        #expect(fetchedPost?.caption == "Test post")
        #expect(fetchedPost?.mood == 8)
        #expect(fetchedPost?.experienceRating == 9)
        #expect(fetchedPost?.activityTags == ["test", "swift"])
        #expect(fetchedPost?.peopleTags == ["friends"])
        
        // Cleanup
        try await postRepo.delete(id: post.id)
        try await personaRepo.delete(id: persona.id)
        try await userRepo.delete(id: user.id)
    }
    
    @Test("PostRepository can fetch posts by persona")
    func testPostRepositoryFetchByPersona() async throws {
        let manager = makeManager()
        let userRepo = UserRepositoryImpl(coreDataManager: manager)
        let personaRepo = PersonaRepositoryImpl(coreDataManager: manager)
        let postRepo = PostRepositoryImpl(coreDataManager: manager)
        
        // Setup
        let user = User(name: "Test User")
        try await userRepo.create(user)
        
        let persona = Persona(
            name: "Personal",
            color: .blue,
            icon: .person,
            userId: user.id
        )
        try await personaRepo.create(persona)
        
        // Create posts
        let post1 = Post(
            caption: "Post 1",
            mood: 8,
            personaId: persona.id,
            postType: .text
        )
        let post2 = Post(
            caption: "Post 2",
            mood: 7,
            personaId: persona.id,
            postType: .text
        )
        
        try await postRepo.create(post1)
        try await postRepo.create(post2)
        
        // Fetch posts for persona
        let posts = try await postRepo.fetchPosts(for: persona.id, limit: nil, offset: nil)
        
        // Verify
        #expect(posts.count == 2)
        #expect(posts.allSatisfy { $0.personaId == persona.id })
        
        // Cleanup
        try await postRepo.delete(id: post1.id)
        try await postRepo.delete(id: post2.id)
        try await personaRepo.delete(id: persona.id)
        try await userRepo.delete(id: user.id)
    }
    
    @Test("PostRepository can search posts")
    func testPostRepositorySearch() async throws {
        let manager = makeManager()
        let userRepo = UserRepositoryImpl(coreDataManager: manager)
        let personaRepo = PersonaRepositoryImpl(coreDataManager: manager)
        let postRepo = PostRepositoryImpl(coreDataManager: manager)
        
        // Setup
        let user = User(name: "Test User")
        try await userRepo.create(user)
        
        let persona = Persona(
            name: "Personal",
            color: .blue,
            icon: .person,
            userId: user.id
        )
        try await personaRepo.create(persona)
        
        // Create posts
        let post1 = Post(
            caption: "Beautiful sunset at the beach",
            mood: 9,
            personaId: persona.id,
            postType: .text
        )
        let post2 = Post(
            caption: "Morning coffee",
            mood: 7,
            personaId: persona.id,
            postType: .text
        )
        
        try await postRepo.create(post1)
        try await postRepo.create(post2)
        
        // Search
        let results = try await postRepo.searchPosts(query: "sunset")
        
        // Verify
        #expect(results.count == 1)
        #expect(results.first?.caption.contains("sunset") == true)
        
        // Cleanup
        try await postRepo.delete(id: post1.id)
        try await postRepo.delete(id: post2.id)
        try await personaRepo.delete(id: persona.id)
        try await userRepo.delete(id: user.id)
    }
    
    @Test("PostRepository can calculate mood statistics")
    func testPostRepositoryMoodStatistics() async throws {
        let manager = makeManager()
        let userRepo = UserRepositoryImpl(coreDataManager: manager)
        let personaRepo = PersonaRepositoryImpl(coreDataManager: manager)
        let postRepo = PostRepositoryImpl(coreDataManager: manager)
        
        // Setup
        let user = User(name: "Test User")
        try await userRepo.create(user)
        
        let persona = Persona(
            name: "Personal",
            color: .blue,
            icon: .person,
            userId: user.id
        )
        try await personaRepo.create(persona)
        
        // Create posts with different moods
        let post1 = Post(caption: "Happy", mood: 8, personaId: persona.id, postType: .text)
        let post2 = Post(caption: "Good", mood: 7, personaId: persona.id, postType: .text)
        let post3 = Post(caption: "Great", mood: 9, personaId: persona.id, postType: .text)
        
        try await postRepo.create(post1)
        try await postRepo.create(post2)
        try await postRepo.create(post3)
        
        // Calculate average mood
        let averageMood = try await postRepo.fetchAverageMood()
        
        // Verify (8 + 7 + 9) / 3 = 8.0
        #expect(averageMood == 8.0)
        
        // Fetch mood distribution
        let distribution = try await postRepo.fetchMoodDistribution()
        #expect(distribution[7] == 1)
        #expect(distribution[8] == 1)
        #expect(distribution[9] == 1)
        
        // Cleanup
        try await postRepo.delete(id: post1.id)
        try await postRepo.delete(id: post2.id)
        try await postRepo.delete(id: post3.id)
        try await personaRepo.delete(id: persona.id)
        try await userRepo.delete(id: user.id)
    }
    
    // MARK: - MediaItem Repository Tests
    
    @Test("MediaItemRepository can create and fetch media item")
    func testMediaItemRepositoryCreateAndFetch() async throws {
        let manager = makeManager()
        let userRepo = UserRepositoryImpl(coreDataManager: manager)
        let personaRepo = PersonaRepositoryImpl(coreDataManager: manager)
        let postRepo = PostRepositoryImpl(coreDataManager: manager)
        let mediaRepo = MediaItemRepositoryImpl(coreDataManager: manager)
        
        // Setup
        let user = User(name: "Test User")
        try await userRepo.create(user)
        
        let persona = Persona(name: "Personal", color: .blue, icon: .person, userId: user.id)
        try await personaRepo.create(persona)
        
        let post = Post(caption: "Test", mood: 8, personaId: persona.id, postType: .photo)
        try await postRepo.create(post)
        
        // Create media item
        let mediaItem = MediaItem(
            type: .photo,
            filename: "test_photo.jpg",
            thumbnailFilename: "test_photo_thumb.jpg",
            fileSize: 1_500_000,
            postId: post.id,
            width: 1920,
            height: 1080
        )
        
        try await mediaRepo.create(mediaItem)
        
        // Fetch media item
        let fetchedMedia = try await mediaRepo.fetch(id: mediaItem.id)
        
        // Verify
        #expect(fetchedMedia != nil)
        #expect(fetchedMedia?.type == .photo)
        #expect(fetchedMedia?.filename == "test_photo.jpg")
        #expect(fetchedMedia?.fileSize == 1_500_000)
        #expect(fetchedMedia?.width == 1920)
        #expect(fetchedMedia?.height == 1080)
        
        // Cleanup
        try await mediaRepo.delete(id: mediaItem.id)
        try await postRepo.delete(id: post.id)
        try await personaRepo.delete(id: persona.id)
        try await userRepo.delete(id: user.id)
    }
    
    @Test("MediaItemRepository can fetch media items for post")
    func testMediaItemRepositoryFetchForPost() async throws {
        let manager = makeManager()
        let userRepo = UserRepositoryImpl(coreDataManager: manager)
        let personaRepo = PersonaRepositoryImpl(coreDataManager: manager)
        let postRepo = PostRepositoryImpl(coreDataManager: manager)
        let mediaRepo = MediaItemRepositoryImpl(coreDataManager: manager)
        
        // Setup
        let user = User(name: "Test User")
        try await userRepo.create(user)
        
        let persona = Persona(name: "Personal", color: .blue, icon: .person, userId: user.id)
        try await personaRepo.create(persona)
        
        let post = Post(caption: "Test", mood: 8, personaId: persona.id, postType: .photo)
        try await postRepo.create(post)
        
        // Create multiple media items
        let media1 = MediaItem(
            type: .photo,
            filename: "photo1.jpg",
            fileSize: 1_000_000,
            postId: post.id
        )
        let media2 = MediaItem(
            type: .photo,
            filename: "photo2.jpg",
            fileSize: 1_500_000,
            postId: post.id
        )
        
        try await mediaRepo.create(media1)
        try await mediaRepo.create(media2)
        
        // Fetch media for post
        let mediaItems = try await mediaRepo.fetchMediaItems(for: post.id)
        
        // Verify
        #expect(mediaItems.count == 2)
        #expect(mediaItems.contains { $0.filename == "photo1.jpg" })
        #expect(mediaItems.contains { $0.filename == "photo2.jpg" })
        
        // Cleanup
        try await mediaRepo.delete(id: media1.id)
        try await mediaRepo.delete(id: media2.id)
        try await postRepo.delete(id: post.id)
        try await personaRepo.delete(id: persona.id)
        try await userRepo.delete(id: user.id)
    }
    
    @Test("MediaItemRepository can fetch primary media item")
    func testMediaItemRepositoryFetchPrimary() async throws {
        let manager = makeManager()
        let userRepo = UserRepositoryImpl(coreDataManager: manager)
        let personaRepo = PersonaRepositoryImpl(coreDataManager: manager)
        let postRepo = PostRepositoryImpl(coreDataManager: manager)
        let mediaRepo = MediaItemRepositoryImpl(coreDataManager: manager)
        
        // Setup
        let user = User(name: "Test User")
        try await userRepo.create(user)
        
        let persona = Persona(name: "Personal", color: .blue, icon: .person, userId: user.id)
        try await personaRepo.create(persona)
        
        let post = Post(caption: "Test", mood: 8, personaId: persona.id, postType: .photo)
        try await postRepo.create(post)
        
        // Create media items
        let media1 = MediaItem(type: .photo, filename: "first.jpg", fileSize: 1_000_000, postId: post.id)
        let media2 = MediaItem(type: .photo, filename: "second.jpg", fileSize: 1_000_000, postId: post.id)
        
        try await mediaRepo.create(media1)
        try await mediaRepo.create(media2)
        
        // Fetch primary (should be first)
        let primary = try await mediaRepo.fetchPrimaryMediaItem(for: post.id)
        
        // Verify
        #expect(primary != nil)
        #expect(primary?.filename == "first.jpg")
        
        // Cleanup
        try await mediaRepo.delete(id: media1.id)
        try await mediaRepo.delete(id: media2.id)
        try await postRepo.delete(id: post.id)
        try await personaRepo.delete(id: persona.id)
        try await userRepo.delete(id: user.id)
    }
    
    @Test("MediaItemRepository can fetch photos and videos separately")
    func testMediaItemRepositoryFetchByType() async throws {
        let manager = makeManager()
        let userRepo = UserRepositoryImpl(coreDataManager: manager)
        let personaRepo = PersonaRepositoryImpl(coreDataManager: manager)
        let postRepo = PostRepositoryImpl(coreDataManager: manager)
        let mediaRepo = MediaItemRepositoryImpl(coreDataManager: manager)
        
        // Setup
        let user = User(name: "Test User")
        try await userRepo.create(user)
        
        let persona = Persona(name: "Personal", color: .blue, icon: .person, userId: user.id)
        try await personaRepo.create(persona)
        
        let post = Post(caption: "Test", mood: 8, personaId: persona.id, postType: .photo)
        try await postRepo.create(post)
        
        // Create mixed media
        let photo = MediaItem(type: .photo, filename: "photo.jpg", fileSize: 1_000_000, postId: post.id)
        let video = MediaItem(type: .video, filename: "video.mp4", fileSize: 5_000_000, postId: post.id)
        
        try await mediaRepo.create(photo)
        try await mediaRepo.create(video)
        
        // Fetch photos only
        let photos = try await mediaRepo.fetchPhotos(for: post.id)
        #expect(photos.count == 1)
        #expect(photos.first?.type == .photo)
        
        // Fetch videos only
        let videos = try await mediaRepo.fetchVideos(for: post.id)
        #expect(videos.count == 1)
        #expect(videos.first?.type == .video)
        
        // Cleanup
        try await mediaRepo.delete(id: photo.id)
        try await mediaRepo.delete(id: video.id)
        try await postRepo.delete(id: post.id)
        try await personaRepo.delete(id: persona.id)
        try await userRepo.delete(id: user.id)
    }
    
    @Test("MediaItemRepository can calculate total storage used")
    func testMediaItemRepositoryStorageStatistics() async throws {
        let manager = makeManager()
        let userRepo = UserRepositoryImpl(coreDataManager: manager)
        let personaRepo = PersonaRepositoryImpl(coreDataManager: manager)
        let postRepo = PostRepositoryImpl(coreDataManager: manager)
        let mediaRepo = MediaItemRepositoryImpl(coreDataManager: manager)
        
        // Setup
        let user = User(name: "Test User")
        try await userRepo.create(user)
        
        let persona = Persona(name: "Personal", color: .blue, icon: .person, userId: user.id)
        try await personaRepo.create(persona)
        
        let post = Post(caption: "Test", mood: 8, personaId: persona.id, postType: .photo)
        try await postRepo.create(post)
        
        // Create media with known sizes
        let photo = MediaItem(type: .photo, filename: "photo.jpg", fileSize: 1_000_000, postId: post.id)
        let video = MediaItem(type: .video, filename: "video.mp4", fileSize: 5_000_000, postId: post.id)
        
        try await mediaRepo.create(photo)
        try await mediaRepo.create(video)
        
        // Calculate total storage
        let totalStorage = try await mediaRepo.fetchTotalStorageUsed()
        #expect(totalStorage == 6_000_000) // 1MB + 5MB
        
        // Calculate photo storage
        let photoStorage = try await mediaRepo.fetchPhotoStorageUsed()
        #expect(photoStorage == 1_000_000)
        
        // Calculate video storage
        let videoStorage = try await mediaRepo.fetchVideoStorageUsed()
        #expect(videoStorage == 5_000_000)
        
        // Cleanup
        try await mediaRepo.delete(id: photo.id)
        try await mediaRepo.delete(id: video.id)
        try await postRepo.delete(id: post.id)
        try await personaRepo.delete(id: persona.id)
        try await userRepo.delete(id: user.id)
    }
    
    @Test("MediaItemRepository can fetch media counts")
    func testMediaItemRepositoryCounts() async throws {
        let manager = makeManager()
        let userRepo = UserRepositoryImpl(coreDataManager: manager)
        let personaRepo = PersonaRepositoryImpl(coreDataManager: manager)
        let postRepo = PostRepositoryImpl(coreDataManager: manager)
        let mediaRepo = MediaItemRepositoryImpl(coreDataManager: manager)
        
        // Setup
        let user = User(name: "Test User")
        try await userRepo.create(user)
        
        let persona = Persona(name: "Personal", color: .blue, icon: .person, userId: user.id)
        try await personaRepo.create(persona)
        
        let post = Post(caption: "Test", mood: 8, personaId: persona.id, postType: .photo)
        try await postRepo.create(post)
        
        // Create media
        let photo1 = MediaItem(type: .photo, filename: "photo1.jpg", fileSize: 1_000_000, postId: post.id)
        let photo2 = MediaItem(type: .photo, filename: "photo2.jpg", fileSize: 1_000_000, postId: post.id)
        let video = MediaItem(type: .video, filename: "video.mp4", fileSize: 5_000_000, postId: post.id)
        
        try await mediaRepo.create(photo1)
        try await mediaRepo.create(photo2)
        try await mediaRepo.create(video)
        
        // Fetch counts
        let photoCount = try await mediaRepo.fetchPhotoCount()
        let videoCount = try await mediaRepo.fetchVideoCount()
        let totalCount = try await mediaRepo.fetchTotalMediaCount()
        
        // Verify
        #expect(photoCount == 2)
        #expect(videoCount == 1)
        #expect(totalCount == 3)
        
        // Cleanup
        try await mediaRepo.delete(id: photo1.id)
        try await mediaRepo.delete(id: photo2.id)
        try await mediaRepo.delete(id: video.id)
        try await postRepo.delete(id: post.id)
        try await personaRepo.delete(id: persona.id)
        try await userRepo.delete(id: user.id)
    }
    
    @Test("MediaItemRepository can check if filename is in use")
    func testMediaItemRepositoryFilenameCheck() async throws {
        let manager = makeManager()
        let userRepo = UserRepositoryImpl(coreDataManager: manager)
        let personaRepo = PersonaRepositoryImpl(coreDataManager: manager)
        let postRepo = PostRepositoryImpl(coreDataManager: manager)
        let mediaRepo = MediaItemRepositoryImpl(coreDataManager: manager)
        
        // Setup
        let user = User(name: "Test User")
        try await userRepo.create(user)
        
        let persona = Persona(name: "Personal", color: .blue, icon: .person, userId: user.id)
        try await personaRepo.create(persona)
        
        let post = Post(caption: "Test", mood: 8, personaId: persona.id, postType: .photo)
        try await postRepo.create(post)
        
        // Create media
        let media = MediaItem(
            type: .photo,
            filename: "used_file.jpg",
            thumbnailFilename: "used_thumb.jpg",
            fileSize: 1_000_000,
            postId: post.id
        )
        
        try await mediaRepo.create(media)
        
        // Check if filenames are in use
        let isMainInUse = try await mediaRepo.isFilenameInUse("used_file.jpg")
        let isThumbInUse = try await mediaRepo.isFilenameInUse("used_thumb.jpg")
        let isNotInUse = try await mediaRepo.isFilenameInUse("not_used.jpg")
        
        // Verify
        #expect(isMainInUse == true)
        #expect(isThumbInUse == true)
        #expect(isNotInUse == false)
        
        // Cleanup
        try await mediaRepo.delete(id: media.id)
        try await postRepo.delete(id: post.id)
        try await personaRepo.delete(id: persona.id)
        try await userRepo.delete(id: user.id)
    }
}
