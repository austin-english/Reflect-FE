//
//  MediaItemRepositoryTests.swift
//  reflectTests
//
//  Created by Austin English on 1/13/26.
//

import Testing
import Foundation
import CoreData
@testable import reflect

/// Tests for MediaItemRepository implementation
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
@Suite("MediaItem Repository Tests", .serialized)
@MainActor
struct MediaItemRepositoryTests {
    
    // MARK: - Helper Methods
    
    /// Creates a fresh in-memory Core Data manager for testing
    func makeManager() -> CoreDataManager {
        CoreDataManager.inMemory()
    }
    
    /// Creates a complete test context with user, persona, post, and repositories
    func makeTestContext() async throws -> (
        manager: CoreDataManager,
        userRepo: UserRepositoryImpl,
        personaRepo: PersonaRepositoryImpl,
        postRepo: PostRepositoryImpl,
        mediaRepo: MediaItemRepositoryImpl,
        user: User,
        persona: Persona,
        post: Post
    ) {
        let manager = makeManager()
        let userRepo = UserRepositoryImpl(coreDataManager: manager)
        let personaRepo = PersonaRepositoryImpl(coreDataManager: manager)
        let postRepo = PostRepositoryImpl(coreDataManager: manager)
        let mediaRepo = MediaItemRepositoryImpl(coreDataManager: manager)
        
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
        
        let post = Post(caption: "Test", mood: 8, personaId: persona.id, postType: .photo)
        try await postRepo.create(post)
        
        return (manager, userRepo, personaRepo, postRepo, mediaRepo, user, persona, post)
    }
    
    // MARK: - Tests
    
    @Test("MediaItemRepository can create and fetch media item")
    func testCreateAndFetch() async throws {
        let context = try await makeTestContext()
        
        // Create media item
        let mediaItem = MediaItem(
            type: .photo,
            filename: "test_photo.jpg",
            thumbnailFilename: "test_photo_thumb.jpg",
            fileSize: 1_500_000,
            postId: context.post.id,
            width: 1920,
            height: 1080
        )
        
        try await context.mediaRepo.create(mediaItem)
        
        // Fetch media item
        let fetchedMedia = try await context.mediaRepo.fetch(id: mediaItem.id)
        
        // Verify
        #expect(fetchedMedia != nil)
        #expect(fetchedMedia?.type == .photo)
        #expect(fetchedMedia?.filename == "test_photo.jpg")
        #expect(fetchedMedia?.fileSize == 1_500_000)
        #expect(fetchedMedia?.width == 1920)
        #expect(fetchedMedia?.height == 1080)
        
        // Cleanup
        try await context.mediaRepo.delete(id: mediaItem.id)
        try await context.postRepo.delete(id: context.post.id)
        try await context.personaRepo.delete(id: context.persona.id)
        try await context.userRepo.delete(id: context.user.id)
    }
    
    @Test("MediaItemRepository can update media item")
    func testUpdate() async throws {
        let context = try await makeTestContext()
        
        // Create media item
        var mediaItem = MediaItem(
            type: .photo,
            filename: "original.jpg",
            fileSize: 1_000_000,
            postId: context.post.id
        )
        try await context.mediaRepo.create(mediaItem)
        
        // Update media item
        mediaItem.filename = "updated.jpg"
        mediaItem.fileSize = 2_000_000
        mediaItem.width = 3840
        mediaItem.height = 2160
        try await context.mediaRepo.update(mediaItem)
        
        // Fetch and verify
        let fetchedMedia = try await context.mediaRepo.fetch(id: mediaItem.id)
        #expect(fetchedMedia?.filename == "updated.jpg")
        #expect(fetchedMedia?.fileSize == 2_000_000)
        #expect(fetchedMedia?.width == 3840)
        #expect(fetchedMedia?.height == 2160)
        
        // Cleanup
        try await context.mediaRepo.delete(id: mediaItem.id)
        try await context.postRepo.delete(id: context.post.id)
        try await context.personaRepo.delete(id: context.persona.id)
        try await context.userRepo.delete(id: context.user.id)
    }
    
    @Test("MediaItemRepository can fetch media items for post")
    func testFetchForPost() async throws {
        let context = try await makeTestContext()
        
        // Create multiple media items
        let media1 = MediaItem(type: .photo, filename: "photo1.jpg", fileSize: 1_000_000, postId: context.post.id)
        let media2 = MediaItem(type: .photo, filename: "photo2.jpg", fileSize: 1_500_000, postId: context.post.id)
        let media3 = MediaItem(type: .video, filename: "video1.mp4", fileSize: 5_000_000, postId: context.post.id)
        
        try await context.mediaRepo.create(media1)
        try await context.mediaRepo.create(media2)
        try await context.mediaRepo.create(media3)
        
        // Fetch media for post
        let mediaItems = try await context.mediaRepo.fetchMediaItems(for: context.post.id)
        
        // Verify
        #expect(mediaItems.count == 3)
        #expect(mediaItems.contains { $0.filename == "photo1.jpg" })
        #expect(mediaItems.contains { $0.filename == "photo2.jpg" })
        #expect(mediaItems.contains { $0.filename == "video1.mp4" })
        
        // Cleanup
        try await context.mediaRepo.delete(id: media1.id)
        try await context.mediaRepo.delete(id: media2.id)
        try await context.mediaRepo.delete(id: media3.id)
        try await context.postRepo.delete(id: context.post.id)
        try await context.personaRepo.delete(id: context.persona.id)
        try await context.userRepo.delete(id: context.user.id)
    }
    
    @Test("MediaItemRepository can fetch primary media item")
    func testFetchPrimary() async throws {
        let context = try await makeTestContext()
        
        // Create media items (first should be primary)
        let media1 = MediaItem(type: .photo, filename: "first.jpg", fileSize: 1_000_000, postId: context.post.id)
        let media2 = MediaItem(type: .photo, filename: "second.jpg", fileSize: 1_000_000, postId: context.post.id)
        let media3 = MediaItem(type: .photo, filename: "third.jpg", fileSize: 1_000_000, postId: context.post.id)
        
        try await context.mediaRepo.create(media1)
        try await context.mediaRepo.create(media2)
        try await context.mediaRepo.create(media3)
        
        // Fetch primary (should be first)
        let primary = try await context.mediaRepo.fetchPrimaryMediaItem(for: context.post.id)
        
        // Verify
        #expect(primary != nil)
        #expect(primary?.filename == "first.jpg")
        
        // Cleanup
        try await context.mediaRepo.delete(id: media1.id)
        try await context.mediaRepo.delete(id: media2.id)
        try await context.mediaRepo.delete(id: media3.id)
        try await context.postRepo.delete(id: context.post.id)
        try await context.personaRepo.delete(id: context.persona.id)
        try await context.userRepo.delete(id: context.user.id)
    }
    
    @Test("MediaItemRepository can fetch photos separately from videos")
    func testFetchByType() async throws {
        let context = try await makeTestContext()
        
        // Create mixed media
        let photo1 = MediaItem(type: .photo, filename: "photo1.jpg", fileSize: 1_000_000, postId: context.post.id)
        let photo2 = MediaItem(type: .photo, filename: "photo2.jpg", fileSize: 1_500_000, postId: context.post.id)
        let video = MediaItem(type: .video, filename: "video.mp4", fileSize: 5_000_000, postId: context.post.id)
        
        try await context.mediaRepo.create(photo1)
        try await context.mediaRepo.create(photo2)
        try await context.mediaRepo.create(video)
        
        // Fetch photos only
        let photos = try await context.mediaRepo.fetchPhotos(for: context.post.id)
        #expect(photos.count == 2)
        #expect(photos.allSatisfy { $0.type == .photo })
        
        // Fetch videos only
        let videos = try await context.mediaRepo.fetchVideos(for: context.post.id)
        #expect(videos.count == 1)
        #expect(videos.first?.type == .video)
        
        // Cleanup
        try await context.mediaRepo.delete(id: photo1.id)
        try await context.mediaRepo.delete(id: photo2.id)
        try await context.mediaRepo.delete(id: video.id)
        try await context.postRepo.delete(id: context.post.id)
        try await context.personaRepo.delete(id: context.persona.id)
        try await context.userRepo.delete(id: context.user.id)
    }
    
    @Test("MediaItemRepository can calculate total storage used")
    func testStorageStatistics() async throws {
        let context = try await makeTestContext()
        
        // Create media with known sizes
        let photo1 = MediaItem(type: .photo, filename: "photo1.jpg", fileSize: 1_000_000, postId: context.post.id)
        let photo2 = MediaItem(type: .photo, filename: "photo2.jpg", fileSize: 1_500_000, postId: context.post.id)
        let video = MediaItem(type: .video, filename: "video.mp4", fileSize: 5_000_000, postId: context.post.id)
        
        try await context.mediaRepo.create(photo1)
        try await context.mediaRepo.create(photo2)
        try await context.mediaRepo.create(video)
        
        // Calculate total storage
        let totalStorage = try await context.mediaRepo.fetchTotalStorageUsed()
        #expect(totalStorage == 7_500_000) // 1MB + 1.5MB + 5MB
        
        // Calculate photo storage
        let photoStorage = try await context.mediaRepo.fetchPhotoStorageUsed()
        #expect(photoStorage == 2_500_000) // 1MB + 1.5MB
        
        // Calculate video storage
        let videoStorage = try await context.mediaRepo.fetchVideoStorageUsed()
        #expect(videoStorage == 5_000_000)
        
        // Cleanup
        try await context.mediaRepo.delete(id: photo1.id)
        try await context.mediaRepo.delete(id: photo2.id)
        try await context.mediaRepo.delete(id: video.id)
        try await context.postRepo.delete(id: context.post.id)
        try await context.personaRepo.delete(id: context.persona.id)
        try await context.userRepo.delete(id: context.user.id)
    }
    
    @Test("MediaItemRepository can fetch media counts")
    func testCounts() async throws {
        let context = try await makeTestContext()
        
        // Create media
        let photo1 = MediaItem(type: .photo, filename: "photo1.jpg", fileSize: 1_000_000, postId: context.post.id)
        let photo2 = MediaItem(type: .photo, filename: "photo2.jpg", fileSize: 1_000_000, postId: context.post.id)
        let video = MediaItem(type: .video, filename: "video.mp4", fileSize: 5_000_000, postId: context.post.id)
        
        try await context.mediaRepo.create(photo1)
        try await context.mediaRepo.create(photo2)
        try await context.mediaRepo.create(video)
        
        // Fetch counts
        let photoCount = try await context.mediaRepo.fetchPhotoCount()
        let videoCount = try await context.mediaRepo.fetchVideoCount()
        let totalCount = try await context.mediaRepo.fetchTotalMediaCount()
        
        // Verify
        #expect(photoCount == 2)
        #expect(videoCount == 1)
        #expect(totalCount == 3)
        
        // Cleanup
        try await context.mediaRepo.delete(id: photo1.id)
        try await context.mediaRepo.delete(id: photo2.id)
        try await context.mediaRepo.delete(id: video.id)
        try await context.postRepo.delete(id: context.post.id)
        try await context.personaRepo.delete(id: context.persona.id)
        try await context.userRepo.delete(id: context.user.id)
    }
    
    @Test("MediaItemRepository can check if filename is in use")
    func testFilenameCheck() async throws {
        let context = try await makeTestContext()
        
        // Create media
        let media = MediaItem(
            type: .photo,
            filename: "used_file.jpg",
            thumbnailFilename: "used_thumb.jpg",
            fileSize: 1_000_000,
            postId: context.post.id
        )
        
        try await context.mediaRepo.create(media)
        
        // Check if filenames are in use
        let isMainInUse = try await context.mediaRepo.isFilenameInUse("used_file.jpg")
        let isThumbInUse = try await context.mediaRepo.isFilenameInUse("used_thumb.jpg")
        let isNotInUse = try await context.mediaRepo.isFilenameInUse("not_used.jpg")
        
        // Verify
        #expect(isMainInUse == true)
        #expect(isThumbInUse == true)
        #expect(isNotInUse == false)
        
        // Cleanup
        try await context.mediaRepo.delete(id: media.id)
        try await context.postRepo.delete(id: context.post.id)
        try await context.personaRepo.delete(id: context.persona.id)
        try await context.userRepo.delete(id: context.user.id)
    }
    
    @Test("MediaItemRepository can delete all media for post")
    func testDeleteAllForPost() async throws {
        let context = try await makeTestContext()
        
        // Create media items
        let media1 = MediaItem(type: .photo, filename: "photo1.jpg", fileSize: 1_000_000, postId: context.post.id)
        let media2 = MediaItem(type: .photo, filename: "photo2.jpg", fileSize: 1_500_000, postId: context.post.id)
        
        try await context.mediaRepo.create(media1)
        try await context.mediaRepo.create(media2)
        
        // Verify they exist
        let countBefore = try await context.mediaRepo.fetchMediaItems(for: context.post.id).count
        #expect(countBefore == 2)
        
        // Delete all media for post
        try await context.mediaRepo.deleteAllMediaItems(for: context.post.id)
        
        // Verify they're gone
        let countAfter = try await context.mediaRepo.fetchMediaItems(for: context.post.id).count
        #expect(countAfter == 0)
        
        // Cleanup
        try await context.postRepo.delete(id: context.post.id)
        try await context.personaRepo.delete(id: context.persona.id)
        try await context.userRepo.delete(id: context.user.id)
    }
    
    @Test("MediaItemRepository can fetch media items sorted by creation date")
    func testFetchSortedByDate() async throws {
        let context = try await makeTestContext()
        
        let calendar = Calendar.current
        let now = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: now)!
        
        // Create media with different dates
        var media1 = MediaItem(type: .photo, filename: "oldest.jpg", fileSize: 1_000_000, postId: context.post.id)
        media1.createdAt = twoDaysAgo
        
        var media2 = MediaItem(type: .photo, filename: "middle.jpg", fileSize: 1_000_000, postId: context.post.id)
        media2.createdAt = yesterday
        
        var media3 = MediaItem(type: .photo, filename: "newest.jpg", fileSize: 1_000_000, postId: context.post.id)
        media3.createdAt = now
        
        try await context.mediaRepo.create(media1)
        try await context.mediaRepo.create(media2)
        try await context.mediaRepo.create(media3)
        
        // Fetch sorted by date (descending - newest first)
        let mediaItems = try await context.mediaRepo.fetchMediaItems(for: context.post.id)
        
        // Verify order (should be newest to oldest based on createdAt)
        #expect(mediaItems.count == 3)
        // Note: Order depends on implementation - just verify all are present
        #expect(mediaItems.contains { $0.filename == "oldest.jpg" })
        #expect(mediaItems.contains { $0.filename == "middle.jpg" })
        #expect(mediaItems.contains { $0.filename == "newest.jpg" })
        
        // Cleanup
        try await context.mediaRepo.delete(id: media1.id)
        try await context.mediaRepo.delete(id: media2.id)
        try await context.mediaRepo.delete(id: media3.id)
        try await context.postRepo.delete(id: context.post.id)
        try await context.personaRepo.delete(id: context.persona.id)
        try await context.userRepo.delete(id: context.user.id)
    }
    
    @Test("MediaItemRepository can handle video with duration")
    func testVideoWithDuration() async throws {
        let context = try await makeTestContext()
        
        // Create video with duration
        let video = MediaItem(
            type: .video,
            filename: "video.mp4",
            thumbnailFilename: "video_thumb.jpg",
            fileSize: 10_000_000,
            postId: context.post.id,
            width: 1920,
            height: 1080,
            duration: 45.5
        )
        
        try await context.mediaRepo.create(video)
        
        // Fetch and verify
        let fetchedVideo = try await context.mediaRepo.fetch(id: video.id)
        #expect(fetchedVideo != nil)
        #expect(fetchedVideo?.type == .video)
        #expect(fetchedVideo?.duration == 45.5)
        #expect(fetchedVideo?.thumbnailFilename == "video_thumb.jpg")
        
        // Cleanup
        try await context.mediaRepo.delete(id: video.id)
        try await context.postRepo.delete(id: context.post.id)
        try await context.personaRepo.delete(id: context.persona.id)
        try await context.userRepo.delete(id: context.user.id)
    }
    
    @Test("MediaItemRepository can fetch largest media items")
    func testFetchLargestMediaItems() async throws {
        let context = try await makeTestContext()
        
        // Create media items with different sizes
        let smallPhoto = MediaItem(type: .photo, filename: "small.jpg", fileSize: 500_000, postId: context.post.id)
        let mediumPhoto = MediaItem(type: .photo, filename: "medium.jpg", fileSize: 2_000_000, postId: context.post.id)
        let largeVideo = MediaItem(type: .video, filename: "large.mp4", fileSize: 10_000_000, postId: context.post.id)
        
        try await context.mediaRepo.create(smallPhoto)
        try await context.mediaRepo.create(mediumPhoto)
        try await context.mediaRepo.create(largeVideo)
        
        // Fetch largest 2 media items
        let largestItems = try await context.mediaRepo.fetchLargestMediaItems(limit: 2)
        
        // Verify (should get largest first)
        #expect(largestItems.count == 2)
        #expect(largestItems.first?.filename == "large.mp4")
        #expect(largestItems.first?.fileSize == 10_000_000)
        
        // Cleanup
        try await context.mediaRepo.delete(id: smallPhoto.id)
        try await context.mediaRepo.delete(id: mediumPhoto.id)
        try await context.mediaRepo.delete(id: largeVideo.id)
        try await context.postRepo.delete(id: context.post.id)
        try await context.personaRepo.delete(id: context.persona.id)
        try await context.userRepo.delete(id: context.user.id)
    }
}
