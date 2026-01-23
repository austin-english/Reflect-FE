//
//  PreviewHelpers.swift
//  reflect
//
//  Created by Austin English on 1/23/26.
//

import Foundation
import CoreData

/// Preview helpers for SwiftUI previews
/// Provides in-memory Core Data stack with sample data
@MainActor
final class PreviewContainer {
    
    // MARK: - Singleton
    
    static let shared = PreviewContainer()
    
    // MARK: - Core Data
    
    private let coreDataManager: CoreDataManager
    
    // MARK: - Repositories
    
    let postRepository: PostRepository
    let personaRepository: PersonaRepository
    let userRepository: UserRepository
    let mediaItemRepository: MediaItemRepository
    
    // MARK: - Sample Data IDs
    
    private(set) var sampleUserId: UUID!
    private(set) var samplePersonaIds: [UUID] = []
    private(set) var samplePostIds: [UUID] = []
    
    // Track if data has been populated
    private var isDataPopulated = false
    
    // MARK: - Initialization
    
    /// Main initializer (called by singleton)
    private convenience init() {
        self.init(isEmpty: false)
    }
    
    /// Internal designated initializer for creating empty or populated container
    private init(isEmpty: Bool) {
        // Create separate in-memory Core Data stack
        self.coreDataManager = isEmpty ? CoreDataManager.emptyPreview : CoreDataManager.preview
        
        // Initialize repositories
        self.postRepository = PostRepositoryImpl(coreDataManager: coreDataManager)
        self.personaRepository = PersonaRepositoryImpl(coreDataManager: coreDataManager)
        self.userRepository = UserRepositoryImpl(coreDataManager: coreDataManager)
        self.mediaItemRepository = MediaItemRepositoryImpl(coreDataManager: coreDataManager)
        
        // Only populate sample data if not empty
        if !isEmpty {
            // Populate data synchronously on init (for previews/debug)
            Task { @MainActor in
                await populateSampleDataIfNeeded()
            }
        }
    }
    
    // MARK: - Data Population
    
    /// Ensures sample data is populated (can be called multiple times safely)
    func populateSampleDataIfNeeded() async {
        guard !isDataPopulated else { 
            print("✅ Preview data already populated")
            return 
        }
        
        print("🔄 Populating preview data...")
        await populateSampleData()
        isDataPopulated = true
        print("✅ Preview data population complete!")
    }
    
    // MARK: - Sample Data Population
    
    private func populateSampleData() async {
        do {
            // Create sample user
            let user = User(
                id: UUID(),
                name: "Preview User",
                email: "preview@reflect.app",
                createdAt: Date(),
                isPremium: false
            )
            try await userRepository.create(user)
            sampleUserId = user.id
            
            // Create sample personas
            let personas = createSamplePersonas(userId: user.id)
            for persona in personas {
                try await personaRepository.create(persona)
                samplePersonaIds.append(persona.id)
            }
            
            // Create sample posts
            let posts = createSamplePosts(personaIds: samplePersonaIds)
            for post in posts {
                try await postRepository.create(post)
                samplePostIds.append(post.id)
            }
            
        } catch {
            print("⚠️ Preview data population failed: \(error)")
        }
    }
    
    // MARK: - Sample Data Factories
    
    private func createSamplePersonas(userId: UUID) -> [Persona] {
        [
            Persona(
                id: UUID(),
                name: "Personal",
                color: .blue,
                icon: .personCircle,
                description: "My personal life",
                createdAt: Date(),
                isDefault: true,
                userId: userId
            ),
            Persona(
                id: UUID(),
                name: "Work",
                color: .purple,
                icon: .briefcase,
                description: "Professional life",
                createdAt: Date(),
                isDefault: false,
                userId: userId
            ),
            Persona(
                id: UUID(),
                name: "Creative",
                color: .pink,
                icon: .paintpalette,
                description: "Art and creative projects",
                createdAt: Date(),
                isDefault: false,
                userId: userId
            )
        ]
    }
    
    private func createSamplePosts(personaIds: [UUID]) -> [Post] {
        guard personaIds.count >= 2 else { return [] }
        
        let persona1 = personaIds[0]
        let persona2 = personaIds[1]
        
        // Create sample posts with placeholder images
        let posts = [
            Post(
                id: UUID(),
                caption: "Beautiful sunset at the beach today. Feeling grateful for moments like these. 🌅",
                mood: 9,
                experienceRating: 8,
                createdAt: Date().addingTimeInterval(-3600), // 1 hour ago
                location: "Santa Monica Beach",
                personaId: persona1,
                mediaItems: [
                    MediaItem(
                        id: UUID(),
                        type: .photo,
                        filename: "sunset_beach.jpg",
                        thumbnailFilename: "sunset_beach_thumb.jpg",
                        createdAt: Date().addingTimeInterval(-3600),
                        fileSize: 524288, // 512 KB
                        postId: UUID(), // Will be set when post is created
                        width: 1920,
                        height: 1080
                    )
                ],
                activityTags: ["Beach", "Sunset", "Photography"],
                peopleTags: ["Sarah"]
            ),
            Post(
                id: UUID(),
                caption: "Great workout this morning! Pushed myself harder than usual.",
                mood: 8,
                experienceRating: 9,
                createdAt: Date().addingTimeInterval(-86400), // 1 day ago
                location: "Gold's Gym",
                personaId: persona1,
                mediaItems: [
                    MediaItem(
                        id: UUID(),
                        type: .photo,
                        filename: "workout_gym.jpg",
                        thumbnailFilename: "workout_gym_thumb.jpg",
                        createdAt: Date().addingTimeInterval(-86400),
                        fileSize: 412000,
                        postId: UUID(),
                        width: 1080,
                        height: 1920
                    )
                ],
                activityTags: ["Exercise", "Gym", "Morning"],
                peopleTags: []
            ),
            Post(
                id: UUID(),
                caption: "Coffee and coding. The perfect Sunday combination. ☕️💻",
                mood: 7,
                experienceRating: 7,
                createdAt: Date().addingTimeInterval(-172800), // 2 days ago
                location: "Home",
                personaId: persona2,
                mediaItems: [
                    MediaItem(
                        id: UUID(),
                        type: .photo,
                        filename: "coffee_coding.jpg",
                        thumbnailFilename: "coffee_coding_thumb.jpg",
                        createdAt: Date().addingTimeInterval(-172800),
                        fileSize: 380000,
                        postId: UUID(),
                        width: 1920,
                        height: 1080
                    )
                ],
                activityTags: ["Work", "Coding", "Coffee"],
                peopleTags: []
            ),
            Post(
                id: UUID(),
                caption: "Dinner with the family. Always the best part of my week. ❤️",
                mood: 10,
                experienceRating: 10,
                createdAt: Date().addingTimeInterval(-259200), // 3 days ago
                location: "Home",
                personaId: persona1,
                mediaItems: [
                    MediaItem(
                        id: UUID(),
                        type: .photo,
                        filename: "family_dinner.jpg",
                        thumbnailFilename: "family_dinner_thumb.jpg",
                        createdAt: Date().addingTimeInterval(-259200),
                        fileSize: 456000,
                        postId: UUID(),
                        width: 1920,
                        height: 1440
                    )
                ],
                activityTags: ["Family", "Dinner", "Quality Time"],
                peopleTags: ["Mom", "Dad", "Emma"]
            ),
            Post(
                id: UUID(),
                caption: "Rainy day vibes. Perfect for reading and reflection. 📚",
                mood: 6,
                experienceRating: 6,
                createdAt: Date().addingTimeInterval(-345600), // 4 days ago
                location: nil,
                personaId: persona2,
                mediaItems: [
                    MediaItem(
                        id: UUID(),
                        type: .photo,
                        filename: "rainy_reading.jpg",
                        thumbnailFilename: "rainy_reading_thumb.jpg",
                        createdAt: Date().addingTimeInterval(-345600),
                        fileSize: 390000,
                        postId: UUID(),
                        width: 1080,
                        height: 1350
                    )
                ],
                activityTags: ["Reading", "Relaxation", "Indoor"],
                peopleTags: []
            )
        ]
        
        // Update mediaItems postId to match their parent post
        return posts.map { post in
            var updatedPost = post
            updatedPost.mediaItems = post.mediaItems.map { media in
                var updatedMedia = media
                updatedMedia.postId = post.id
                return updatedMedia
            }
            return updatedPost
        }
    }
    
    // MARK: - Empty Container
    
    /// Cached empty preview container (for testing empty states)
    private static let _emptyContainer: PreviewContainer = {
        PreviewContainer(isEmpty: true)
    }()
    
    /// Creates an empty preview container (for testing empty states)
    static func empty() -> PreviewContainer {
        _emptyContainer
    }
}

// MARK: - CoreDataManager Preview Extension

extension CoreDataManager {
    /// Shared in-memory preview instance with sample data
    @MainActor
    static let preview: CoreDataManager = {
        let manager = CoreDataManager(inMemory: true, identifier: "preview")
        return manager
    }()
    
    /// Separate in-memory instance for empty state previews
    @MainActor
    static let emptyPreview: CoreDataManager = {
        let manager = CoreDataManager(inMemory: true, identifier: "empty-preview")
        return manager
    }()
}

// MARK: - FeedViewModel Preview Extension

extension FeedViewModel {
    /// Preview instance with populated sample data
    @MainActor
    static var preview: FeedViewModel {
        let container = PreviewContainer.shared
        
        // Ensure data is populated before returning
        Task {
            await container.populateSampleDataIfNeeded()
        }
        
        let viewModel = FeedViewModel(
            postRepository: container.postRepository,
            personaRepository: container.personaRepository
        )
        
        print("📱 Created FeedViewModel.preview")
        
        return viewModel
    }
    
    /// Preview instance with empty data (for empty states)
    @MainActor
    static var emptyPreview: FeedViewModel {
        let container = PreviewContainer.empty()
        return FeedViewModel(
            postRepository: container.postRepository,
            personaRepository: container.personaRepository
        )
    }
}
