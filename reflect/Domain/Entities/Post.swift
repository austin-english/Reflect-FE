//
//  Post.swift
//  reflect
//
//  Created by Austin English on 12/4/25.
//

import Foundation

/// Domain entity representing a user's journal post
struct Post: Identifiable, Codable, Hashable {
    // MARK: - Properties
    
    let id: UUID
    var caption: String
    var mood: Int // 1-10 scale
    var experienceRating: Int? // Optional 1-10 rating
    var createdAt: Date
    var updatedAt: Date?
    var location: String?
    
    // MARK: - Relationships
    
    var personaId: UUID // Reference to Persona
    var mediaItems: [MediaItem]
    
    // MARK: - Tags
    
    var activityTags: [String]
    var peopleTags: [String]
    
    // MARK: - Post Type
    
    var postType: PostType
    
    // MARK: - Special Post Metadata
    
    var isGratitude: Bool
    var isRant: Bool
    var isDream: Bool
    var isFutureYou: Bool
    var scheduledFor: Date? // For "Future You" posts
    var autoDeleteDate: Date? // For rants with auto-delete
    
    // MARK: - Voice Memo
    
    var voiceMemoFilename: String?
    var voiceMemoDuration: TimeInterval?
    var voiceMemoTranscription: String? // Premium feature
    
    // MARK: - Memory Metadata
    
    var memoryNotes: String? // Notes added when viewing as memory
    
    // MARK: - Initialization
    
    init(
        id: UUID = UUID(),
        caption: String,
        mood: Int,
        experienceRating: Int? = nil,
        createdAt: Date = Date(),
        updatedAt: Date? = nil,
        location: String? = nil,
        personaId: UUID,
        mediaItems: [MediaItem] = [],
        activityTags: [String] = [],
        peopleTags: [String] = [],
        postType: PostType = .photo,
        isGratitude: Bool = false,
        isRant: Bool = false,
        isDream: Bool = false,
        isFutureYou: Bool = false,
        scheduledFor: Date? = nil,
        autoDeleteDate: Date? = nil,
        voiceMemoFilename: String? = nil,
        voiceMemoDuration: TimeInterval? = nil,
        voiceMemoTranscription: String? = nil,
        memoryNotes: String? = nil
    ) {
        self.id = id
        self.caption = caption
        self.mood = mood
        self.experienceRating = experienceRating
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.location = location
        self.personaId = personaId
        self.mediaItems = mediaItems
        self.activityTags = activityTags
        self.peopleTags = peopleTags
        self.postType = postType
        self.isGratitude = isGratitude
        self.isRant = isRant
        self.isDream = isDream
        self.isFutureYou = isFutureYou
        self.scheduledFor = scheduledFor
        self.autoDeleteDate = autoDeleteDate
        self.voiceMemoFilename = voiceMemoFilename
        self.voiceMemoDuration = voiceMemoDuration
        self.voiceMemoTranscription = voiceMemoTranscription
        self.memoryNotes = memoryNotes
    }
}

// MARK: - Post Type

extension Post {
    enum PostType: String, Codable, Hashable {
        case photo
        case video
        case text
        case voiceMemo
        case photoVideo // Multiple media items
    }
}

// MARK: - Computed Properties

extension Post {
    /// Returns true if the post has any media items
    var hasMedia: Bool {
        !mediaItems.isEmpty
    }
    
    /// Returns the primary media item (first in array)
    var primaryMedia: MediaItem? {
        mediaItems.first
    }
    
    /// Returns true if this is a special post type (gratitude, rant, dream, future)
    var isSpecialPost: Bool {
        isGratitude || isRant || isDream || isFutureYou
    }
    
    /// Returns the special post type name
    var specialPostTypeName: String? {
        if isGratitude { return "Gratitude" }
        if isRant { return "Rant" }
        if isDream { return "Dream" }
        if isFutureYou { return "Future You" }
        return nil
    }
    
    /// Returns true if the post should be auto-deleted
    var shouldAutoDelete: Bool {
        guard let deleteDate = autoDeleteDate else { return false }
        return Date() >= deleteDate
    }
    
    /// Validates that mood is in valid range (1-10)
    var isValidMood: Bool {
        (1...10).contains(mood)
    }
    
    /// Validates that experience rating is in valid range (1-10) if present
    var isValidExperienceRating: Bool {
        if let rating = experienceRating {
            return (1...10).contains(rating)
        }
        return true
    }
}

// MARK: - Mock Data (for previews and testing)

#if DEBUG
extension Post {
    static let mockPhoto = Post(
        caption: "Beautiful sunset at the beach 🌅",
        mood: 8,
        experienceRating: 9,
        personaId: Persona.mockPersonal.id,
        mediaItems: [MediaItem.mockPhoto],
        activityTags: ["beach", "sunset", "walk"],
        peopleTags: ["solo"]
    )
    
    static let mockText = Post(
        caption: "Just finished a great workout session! Feeling accomplished and energized. It's amazing how exercise can completely shift your mood.",
        mood: 9,
        personaId: Persona.mockPersonal.id,
        activityTags: ["gym", "workout", "fitness"],
        postType: .text,
    )
    
    static let mockGratitude = Post(
        caption: "Today I'm grateful for:\n• Good health\n• Supportive friends\n• Coffee ☕️",
        mood: 8,
        personaId: Persona.mockPersonal.id,
        activityTags: ["gratitude"],
        postType: .text,
        isGratitude: true,
    )
    
    static let mockRant = Post(
        caption: "Ugh, traffic was absolutely terrible today. Took 2 hours to get home!",
        mood: 3,
        personaId: Persona.mockPersonal.id,
        postType: .text,
        isRant: true,
        autoDeleteDate: Date().addingTimeInterval(86400) // Delete after 24 hours
    )
    
    static let mockDream = Post(
        caption: "Had the weirdest dream... I was flying over a city made of clouds",
        mood: 6,
        personaId: Persona.mockPersonal.id,
        postType: .text,
        isDream: true
    )
    
    static let mockMultiplePhotos = Post(
        caption: "Weekend hiking trip! 🥾⛰️",
        mood: 9,
        experienceRating: 10,
        personaId: Persona.mockPersonal.id,
        mediaItems: [
            MediaItem.mockPhoto,
            MediaItem.mockPhoto2,
            MediaItem.mockPhoto3
        ],
        activityTags: ["hiking", "nature", "adventure"],
        peopleTags: ["friends"]
    )
    
    static let mockOldPost = Post(
        caption: "One year ago today...",
        mood: 7,
        createdAt: Calendar.current.date(byAdding: .year, value: -1, to: Date())!,
        personaId: Persona.mockPersonal.id,
        mediaItems: [MediaItem.mockPhoto],
        activityTags: ["throwback"]
    )
}
#endif
