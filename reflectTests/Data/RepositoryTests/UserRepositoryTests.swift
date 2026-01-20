//
//  UserRepositoryTests.swift
//  reflectTests
//
//  Created by Austin English on 1/13/26.
//

import Testing
import Foundation
import CoreData
@testable import reflect

/// Tests for UserRepository implementation
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
@Suite("User Repository Tests", .serialized)
@MainActor
struct UserRepositoryTests {
    
    // MARK: - Helper Methods
    
    /// Creates a fresh in-memory Core Data manager for testing
    func makeManager() -> CoreDataManager {
        CoreDataManager.inMemory()
    }
    
    /// Creates a test user with default values
    func makeTestUser(name: String = "Test User") async throws -> (manager: CoreDataManager, repository: UserRepositoryImpl, user: User) {
        let manager = makeManager()
        let repository = UserRepositoryImpl(coreDataManager: manager)
        let user = User(name: name)
        try await repository.create(user)
        return (manager, repository, user)
    }
    
    // MARK: - Tests
    
    @Test("UserRepository can create and fetch user")
    func testCreateAndFetch() async throws {
        let manager = makeManager()
        let repository = UserRepositoryImpl(coreDataManager: manager)
        
        // Create user with specific fields
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
    func testUpdate() async throws {
        let (_, repository, user) = try await makeTestUser(name: "Original Name")
        
        // Update user (create mutable copy)
        var updatedUser = user
        updatedUser.name = "Updated Name"
        updatedUser.bio = "New bio"
        try await repository.update(updatedUser)
        
        // Fetch and verify
        let fetchedUser = try await repository.fetch(id: user.id)
        #expect(fetchedUser?.name == "Updated Name")
        #expect(fetchedUser?.bio == "New bio")
        
        // Cleanup
        try await repository.delete(id: user.id)
    }
    
    @Test("UserRepository can check if user exists")
    func testHasUser() async throws {
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
    func testFetchCurrentUser() async throws {
        let (_, repository, user) = try await makeTestUser(name: "Current User")
        
        // Fetch current user
        let currentUser = try await repository.fetchCurrentUser()
        
        // Verify
        #expect(currentUser != nil)
        #expect(currentUser?.name == "Current User")
        
        // Cleanup
        try await repository.delete(id: user.id)
    }
    
    @Test("UserRepository can update preferences")
    func testUpdatePreferences() async throws {
        let (_, repository, user) = try await makeTestUser()
        
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
    func testUpdatePremiumStatus() async throws {
        let (_, repository, user) = try await makeTestUser()
        
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
    func testUpdateStatistics() async throws {
        let (_, repository, user) = try await makeTestUser()
        
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
    func testPostCountOperations() async throws {
        let (_, repository, user) = try await makeTestUser()
        
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
    func testUpdateProfile() async throws {
        let manager = makeManager()
        let repository = UserRepositoryImpl(coreDataManager: manager)
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
    func testUpdateProfilePhoto() async throws {
        let (_, repository, user) = try await makeTestUser()
        
        // Update profile photo
        try await repository.updateProfilePhoto(for: user.id, filename: "profile_123.jpg")
        
        // Fetch and verify
        let fetchedUser = try await repository.fetch(id: user.id)
        #expect(fetchedUser?.profilePhotoFilename == "profile_123.jpg")
        
        // Cleanup
        try await repository.delete(id: user.id)
    }
    
    @Test("UserRepository can update streaks")
    func testUpdateStreaks() async throws {
        let (_, repository, user) = try await makeTestUser()
        
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
}
