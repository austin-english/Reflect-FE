//
//  PostRepositoryTests.swift
//  reflectTests
//
//  Created by Austin English on 1/13/26.
//

import Testing
import Foundation
import CoreData
@testable import reflect

/// Tests for PostRepository implementation
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
@Suite("Post Repository Tests", .serialized)
@MainActor
struct PostRepositoryTests {
    
    // MARK: - Helper Methods
    
    /// Creates a fresh in-memory Core Data manager for testing
    func makeManager() -> CoreDataManager {
        CoreDataManager.inMemory()
    }
    
    /// Creates a complete test context with user, persona, and repositories
    func makeTestContext() async throws -> (
        manager: CoreDataManager,
        userRepo: UserRepositoryImpl,
        personaRepo: PersonaRepositoryImpl,
        postRepo: PostRepositoryImpl,
        user: User,
        persona: Persona
    ) {
        let manager = makeManager()
        let userRepo = UserRepositoryImpl(coreDataManager: manager)
        let personaRepo = PersonaRepositoryImpl(coreDataManager: manager)
        let postRepo = PostRepositoryImpl(coreDataManager: manager)
        
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
        
        return (manager, userRepo, personaRepo, postRepo, user, persona)
    }
    
    // MARK: - Tests
    
    @Test("PostRepository can create and fetch post")
    func testCreateAndFetch() async throws {
        let context = try await makeTestContext()
        
        // Create post
        let post = Post(
            caption: "Test post",
            mood: 8,
            experienceRating: 9,
            personaId: context.persona.id,
            activityTags: ["test", "swift"],
            peopleTags: ["friends"],
            postType: .text
        )
        
        try await context.postRepo.create(post)
        
        // Fetch post
        let fetchedPost = try await context.postRepo.fetch(id: post.id)
        
        // Verify
        #expect(fetchedPost != nil)
        #expect(fetchedPost?.caption == "Test post")
        #expect(fetchedPost?.mood == 8)
        #expect(fetchedPost?.experienceRating == 9)
        #expect(fetchedPost?.activityTags == ["test", "swift"])
        #expect(fetchedPost?.peopleTags == ["friends"])
        
        // Cleanup
        try await context.postRepo.delete(id: post.id)
        try await context.personaRepo.delete(id: context.persona.id)
        try await context.userRepo.delete(id: context.user.id)
    }
    
    @Test("PostRepository can update post")
    func testUpdate() async throws {
        let context = try await makeTestContext()
        
        // Create post
        var post = Post(
            caption: "Original caption",
            mood: 7,
            personaId: context.persona.id,
            postType: .text
        )
        try await context.postRepo.create(post)
        
        // Update post
        post.caption = "Updated caption"
        post.mood = 9
        post.activityTags = ["updated", "tags"]
        try await context.postRepo.update(post)
        
        // Fetch and verify
        let fetchedPost = try await context.postRepo.fetch(id: post.id)
        #expect(fetchedPost?.caption == "Updated caption")
        #expect(fetchedPost?.mood == 9)
        #expect(fetchedPost?.activityTags == ["updated", "tags"])
        
        // Cleanup
        try await context.postRepo.delete(id: post.id)
        try await context.personaRepo.delete(id: context.persona.id)
        try await context.userRepo.delete(id: context.user.id)
    }
    
    @Test("PostRepository can fetch posts by persona")
    func testFetchByPersona() async throws {
        let context = try await makeTestContext()
        
        // Create posts
        let post1 = Post(caption: "Post 1", mood: 8, personaId: context.persona.id, postType: .text)
        let post2 = Post(caption: "Post 2", mood: 7, personaId: context.persona.id, postType: .text)
        
        try await context.postRepo.create(post1)
        try await context.postRepo.create(post2)
        
        // Fetch posts for persona
        let posts = try await context.postRepo.fetchPosts(for: context.persona.id, limit: nil, offset: nil)
        
        // Verify
        #expect(posts.count == 2)
        #expect(posts.allSatisfy { $0.personaId == context.persona.id })
        
        // Cleanup
        try await context.postRepo.delete(id: post1.id)
        try await context.postRepo.delete(id: post2.id)
        try await context.personaRepo.delete(id: context.persona.id)
        try await context.userRepo.delete(id: context.user.id)
    }
    
    @Test("PostRepository can fetch all posts")
    func testFetchAll() async throws {
        let context = try await makeTestContext()
        
        // Create posts
        let post1 = Post(caption: "Post 1", mood: 8, personaId: context.persona.id, postType: .text)
        let post2 = Post(caption: "Post 2", mood: 7, personaId: context.persona.id, postType: .text)
        let post3 = Post(caption: "Post 3", mood: 9, personaId: context.persona.id, postType: .text)
        
        try await context.postRepo.create(post1)
        try await context.postRepo.create(post2)
        try await context.postRepo.create(post3)
        
        // Fetch all posts
        let posts = try await context.postRepo.fetchAll()
        
        // Verify
        #expect(posts.count == 3)
        
        // Cleanup
        try await context.postRepo.delete(id: post1.id)
        try await context.postRepo.delete(id: post2.id)
        try await context.postRepo.delete(id: post3.id)
        try await context.personaRepo.delete(id: context.persona.id)
        try await context.userRepo.delete(id: context.user.id)
    }
    
    @Test("PostRepository can fetch posts with pagination")
    func testFetchWithPagination() async throws {
        let context = try await makeTestContext()
        
        // Create 5 posts
        let posts = (1...5).map { i in
            Post(caption: "Post \(i)", mood: i + 5, personaId: context.persona.id, postType: .text)
        }
        
        for post in posts {
            try await context.postRepo.create(post)
        }
        
        // Fetch first page using persona-specific query (limit 2)
        let page1 = try await context.postRepo.fetchPosts(for: context.persona.id, limit: 2, offset: 0)
        #expect(page1.count == 2)
        
        // Fetch second page
        let page2 = try await context.postRepo.fetchPosts(for: context.persona.id, limit: 2, offset: 2)
        #expect(page2.count == 2)
        
        // Fetch third page
        let page3 = try await context.postRepo.fetchPosts(for: context.persona.id, limit: 2, offset: 4)
        #expect(page3.count == 1)
        
        // Cleanup
        for post in posts {
            try await context.postRepo.delete(id: post.id)
        }
        try await context.personaRepo.delete(id: context.persona.id)
        try await context.userRepo.delete(id: context.user.id)
    }
    
    @Test("PostRepository can search posts")
    func testSearch() async throws {
        let context = try await makeTestContext()
        
        // Create posts
        let post1 = Post(caption: "Beautiful sunset at the beach", mood: 9, personaId: context.persona.id, postType: .text)
        let post2 = Post(caption: "Morning coffee", mood: 7, personaId: context.persona.id, postType: .text)
        let post3 = Post(caption: "Sunset walk in the park", mood: 8, personaId: context.persona.id, postType: .text)
        
        try await context.postRepo.create(post1)
        try await context.postRepo.create(post2)
        try await context.postRepo.create(post3)
        
        // Search for "sunset"
        let results = try await context.postRepo.searchPosts(query: "sunset")
        
        // Verify
        #expect(results.count == 2)
        #expect(results.allSatisfy { $0.caption.localizedCaseInsensitiveContains("sunset") })
        
        // Cleanup
        try await context.postRepo.delete(id: post1.id)
        try await context.postRepo.delete(id: post2.id)
        try await context.postRepo.delete(id: post3.id)
        try await context.personaRepo.delete(id: context.persona.id)
        try await context.userRepo.delete(id: context.user.id)
    }
    
    @Test("PostRepository can fetch posts by date range")
    func testFetchByDateRange() async throws {
        let context = try await makeTestContext()
        
        let calendar = Calendar.current
        let now = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: now)!
        
        // Create posts with different dates
        var post1 = Post(caption: "Two days ago", mood: 7, personaId: context.persona.id, postType: .text)
        post1.createdAt = twoDaysAgo
        
        var post2 = Post(caption: "Yesterday", mood: 8, personaId: context.persona.id, postType: .text)
        post2.createdAt = yesterday
        
        var post3 = Post(caption: "Today", mood: 9, personaId: context.persona.id, postType: .text)
        post3.createdAt = now
        
        try await context.postRepo.create(post1)
        try await context.postRepo.create(post2)
        try await context.postRepo.create(post3)
        
        // Fetch posts from yesterday onwards
        let startDate = calendar.startOfDay(for: yesterday)
        let endDate = calendar.date(byAdding: .day, value: 1, to: now)!
        let posts = try await context.postRepo.fetchPosts(from: startDate, to: endDate)
        
        // Verify (should get yesterday and today)
        #expect(posts.count == 2)
        
        // Cleanup
        try await context.postRepo.delete(id: post1.id)
        try await context.postRepo.delete(id: post2.id)
        try await context.postRepo.delete(id: post3.id)
        try await context.personaRepo.delete(id: context.persona.id)
        try await context.userRepo.delete(id: context.user.id)
    }
    
    @Test("PostRepository can fetch posts by mood range")
    func testFetchByMoodRange() async throws {
        let context = try await makeTestContext()
        
        // Create posts with different moods
        let post1 = Post(caption: "Low mood", mood: 3, personaId: context.persona.id, postType: .text)
        let post2 = Post(caption: "Medium mood", mood: 6, personaId: context.persona.id, postType: .text)
        let post3 = Post(caption: "High mood", mood: 9, personaId: context.persona.id, postType: .text)
        
        try await context.postRepo.create(post1)
        try await context.postRepo.create(post2)
        try await context.postRepo.create(post3)
        
        // Fetch posts with mood 6-10
        let posts = try await context.postRepo.fetchPosts(withMoodBetween: 6, and: 10)
        
        // Verify
        #expect(posts.count == 2)
        #expect(posts.allSatisfy { $0.mood >= 6 })
        
        // Cleanup
        try await context.postRepo.delete(id: post1.id)
        try await context.postRepo.delete(id: post2.id)
        try await context.postRepo.delete(id: post3.id)
        try await context.personaRepo.delete(id: context.persona.id)
        try await context.userRepo.delete(id: context.user.id)
    }
    
    @Test("PostRepository can fetch posts by tag")
    func testFetchByTag() async throws {
        let context = try await makeTestContext()
        
        // Create posts with different tags
        let post1 = Post(caption: "Post 1", mood: 8, personaId: context.persona.id, activityTags: ["work", "coding"], postType: .text)
        let post2 = Post(caption: "Post 2", mood: 7, personaId: context.persona.id, activityTags: ["exercise", "health"], postType: .text)
        let post3 = Post(caption: "Post 3", mood: 9, personaId: context.persona.id, activityTags: ["work", "meeting"], postType: .text)
        
        try await context.postRepo.create(post1)
        try await context.postRepo.create(post2)
        try await context.postRepo.create(post3)
        
        // Fetch posts containing "work" tag
        let posts = try await context.postRepo.fetchPosts(containing: ["work"])
        
        // Verify
        #expect(posts.count == 2)
        #expect(posts.allSatisfy { $0.activityTags.contains("work") })
        
        // Cleanup
        try await context.postRepo.delete(id: post1.id)
        try await context.postRepo.delete(id: post2.id)
        try await context.postRepo.delete(id: post3.id)
        try await context.personaRepo.delete(id: context.persona.id)
        try await context.userRepo.delete(id: context.user.id)
    }
    
    @Test("PostRepository can calculate mood statistics")
    func testMoodStatistics() async throws {
        let context = try await makeTestContext()
        
        // Create posts with different moods
        let post1 = Post(caption: "Happy", mood: 8, personaId: context.persona.id, postType: .text)
        let post2 = Post(caption: "Good", mood: 7, personaId: context.persona.id, postType: .text)
        let post3 = Post(caption: "Great", mood: 9, personaId: context.persona.id, postType: .text)
        
        try await context.postRepo.create(post1)
        try await context.postRepo.create(post2)
        try await context.postRepo.create(post3)
        
        // Calculate average mood
        let averageMood = try await context.postRepo.fetchAverageMood()
        
        // Verify (8 + 7 + 9) / 3 = 8.0
        #expect(averageMood == 8.0)
        
        // Fetch mood distribution
        let distribution = try await context.postRepo.fetchMoodDistribution()
        #expect(distribution[7] == 1)
        #expect(distribution[8] == 1)
        #expect(distribution[9] == 1)
        
        // Cleanup
        try await context.postRepo.delete(id: post1.id)
        try await context.postRepo.delete(id: post2.id)
        try await context.postRepo.delete(id: post3.id)
        try await context.personaRepo.delete(id: context.persona.id)
        try await context.userRepo.delete(id: context.user.id)
    }
    
    @Test("PostRepository can fetch post count")
    func testFetchCount() async throws {
        let context = try await makeTestContext()
        
        // Initially should be 0
        let initialCount = try await context.postRepo.fetchPostCount()
        #expect(initialCount == 0)
        
        // Create posts
        let post1 = Post(caption: "Post 1", mood: 8, personaId: context.persona.id, postType: .text)
        let post2 = Post(caption: "Post 2", mood: 7, personaId: context.persona.id, postType: .text)
        
        try await context.postRepo.create(post1)
        try await context.postRepo.create(post2)
        
        // Should be 2
        let count = try await context.postRepo.fetchPostCount()
        #expect(count == 2)
        
        // Cleanup
        try await context.postRepo.delete(id: post1.id)
        try await context.postRepo.delete(id: post2.id)
        try await context.personaRepo.delete(id: context.persona.id)
        try await context.userRepo.delete(id: context.user.id)
    }
    
    @Test("PostRepository can fetch posting dates")
    func testFetchPostingDates() async throws {
        let context = try await makeTestContext()
        
        let calendar = Calendar.current
        let now = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        
        // Create posts on different days
        var post1 = Post(caption: "Today", mood: 8, personaId: context.persona.id, postType: .text)
        post1.createdAt = now
        
        var post2 = Post(caption: "Yesterday", mood: 7, personaId: context.persona.id, postType: .text)
        post2.createdAt = yesterday
        
        try await context.postRepo.create(post1)
        try await context.postRepo.create(post2)
        
        // Fetch posting dates
        let dates = try await context.postRepo.fetchPostingDates()
        
        // Verify
        #expect(dates.count == 2)
        
        // Cleanup
        try await context.postRepo.delete(id: post1.id)
        try await context.postRepo.delete(id: post2.id)
        try await context.personaRepo.delete(id: context.persona.id)
        try await context.userRepo.delete(id: context.user.id)
    }
    
    @Test("PostRepository can fetch most used tags")
    func testFetchMostUsedTags() async throws {
        let context = try await makeTestContext()
        
        // Create posts with various tags
        let post1 = Post(caption: "Post 1", mood: 8, personaId: context.persona.id, activityTags: ["work", "coding"], postType: .text)
        let post2 = Post(caption: "Post 2", mood: 7, personaId: context.persona.id, activityTags: ["exercise", "health"], postType: .text)
        let post3 = Post(caption: "Post 3", mood: 9, personaId: context.persona.id, activityTags: ["work", "meeting"], postType: .text)
        
        try await context.postRepo.create(post1)
        try await context.postRepo.create(post2)
        try await context.postRepo.create(post3)
        
        // Fetch most used tags
        let tags = try await context.postRepo.fetchMostUsedTags(limit: 10)
        
        // Verify (work should appear most frequently)
        #expect(tags.count >= 1)
        #expect(tags.contains { $0.tag == "work" && $0.count == 2 })
        
        // Cleanup
        try await context.postRepo.delete(id: post1.id)
        try await context.postRepo.delete(id: post2.id)
        try await context.postRepo.delete(id: post3.id)
        try await context.personaRepo.delete(id: context.persona.id)
        try await context.userRepo.delete(id: context.user.id)
    }
    
    @Test("PostRepository can delete all posts for persona")
    func testDeleteAllForPersona() async throws {
        let context = try await makeTestContext()
        
        // Create posts
        let post1 = Post(caption: "Post 1", mood: 8, personaId: context.persona.id, postType: .text)
        let post2 = Post(caption: "Post 2", mood: 7, personaId: context.persona.id, postType: .text)
        
        try await context.postRepo.create(post1)
        try await context.postRepo.create(post2)
        
        // Verify they exist
        let countBefore = try await context.postRepo.fetchPostCount()
        #expect(countBefore == 2)
        
        // Delete all posts for persona
        try await context.postRepo.deleteAllPosts(for: context.persona.id)
        
        // Verify they're gone
        let countAfter = try await context.postRepo.fetchPostCount()
        #expect(countAfter == 0)
        
        // Cleanup
        try await context.personaRepo.delete(id: context.persona.id)
        try await context.userRepo.delete(id: context.user.id)
    }
}
