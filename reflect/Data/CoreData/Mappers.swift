//
//  CoreDataMappers.swift
//  reflect
//
//  Created by Austin English on 12/16/25.
//

import Foundation
import CoreData

// MARK: - Post Mapping

extension PostEntity {
    /// Converts Core Data entity to domain model
    func toDomain() throws -> Post {
        guard let id = self.id,
              let caption = self.caption,
              let personaEntity = self.persona,
              let personaId = personaEntity.id,
              let createdAt = self.createdAt,
              let postType = self.postType else {
            throw MappingError.missingRequiredField("Post")
        }
        
        // Map media items
        let mediaItems = (self.mediaItems?.array as? [MediaItemEntity] ?? [])
            .compactMap { try? $0.toDomain() }
        
        // Decode tags (from Transformable attributes)
        let activityTags = (self.value(forKey: "activityTags") as? [String]) ?? []
        let peopleTags = (self.value(forKey: "peopleTags") as? [String]) ?? []
        
        return Post(
            id: id,
            caption: caption,
            mood: Int(self.mood),
            experienceRating: self.experienceRating > 0 ? Int(self.experienceRating) : nil,
            createdAt: createdAt,
            updatedAt: self.updatedAt,
            location: self.location,
            personaId: personaId,
            mediaItems: mediaItems,
            activityTags: activityTags,
            peopleTags: peopleTags,
            postType: Post.PostType(rawValue: postType) ?? .text,
            isGratitude: self.isGratitude,
            isRant: self.isRant,
            isDream: self.isDream,
            isFutureYou: self.isFutureYou,
            scheduledFor: self.scheduledFor,
            autoDeleteDate: self.autoDeleteDate,
            voiceMemoFilename: self.voiceMemoFilename,
            voiceMemoDuration: self.voiceMemoDuration > 0 ? self.voiceMemoDuration : nil,
            voiceMemoTranscription: self.voiceMemoTranscription,
            memoryNotes: self.memoryNotes
        )
    }
    
    /// Updates entity from domain model
    func update(from post: Post, context: NSManagedObjectContext) throws {
        self.id = post.id
        self.caption = post.caption
        self.mood = Int16(post.mood)
        self.experienceRating = Int16(post.experienceRating ?? 0)
        self.createdAt = post.createdAt
        self.updatedAt = post.updatedAt
        self.location = post.location
        self.postType = post.postType.rawValue
        self.setValue(post.activityTags, forKey: "activityTags")
        self.setValue(post.peopleTags, forKey: "peopleTags")
        self.isGratitude = post.isGratitude
        self.isRant = post.isRant
        self.isDream = post.isDream
        self.isFutureYou = post.isFutureYou
        self.scheduledFor = post.scheduledFor
        self.autoDeleteDate = post.autoDeleteDate
        self.voiceMemoFilename = post.voiceMemoFilename
        self.voiceMemoDuration = post.voiceMemoDuration ?? 0
        self.voiceMemoTranscription = post.voiceMemoTranscription
        self.memoryNotes = post.memoryNotes
        
        // Note: Persona relationship should be set by the caller after creating/fetching the PersonaEntity
        // We don't set it here because we only have the personaId, not the actual entity
    }
    
    /// Creates new entity from domain model
    static func create(from post: Post, context: NSManagedObjectContext) throws -> PostEntity {
        let entity = PostEntity(context: context)
        try entity.update(from: post, context: context)
        return entity
    }
}

// MARK: - User Mapping

extension UserEntity {
    /// Converts Core Data entity to domain model
    func toDomain() throws -> User {
        guard let id = self.id,
              let name = self.name,
              let createdAt = self.createdAt else {
            throw MappingError.missingRequiredField("User")
        }
        
        // Decode preferences
        var preferences = User.UserPreferences()
        if let preferencesData = self.preferencesData {
            preferences = try JSONDecoder().decode(User.UserPreferences.self, from: preferencesData)
        }
        
        // Get persona IDs
        let personaIds = (self.personas as? Set<PersonaEntity> ?? [])
            .compactMap { $0.id }
        
        return User(
            id: id,
            name: name,
            bio: self.bio,
            email: self.email,
            profilePhotoFilename: self.profilePhotoFilename,
            createdAt: createdAt,
            updatedAt: self.updatedAt,
            personas: personaIds,
            preferences: preferences,
            isPremium: self.isPremium,
            premiumExpiresAt: self.premiumExpiresAt,
            totalPosts: Int(self.totalPosts),
            currentStreak: Int(self.currentStreak),
            longestStreak: Int(self.longestStreak)
        )
    }
    
    /// Updates entity from domain model
    func update(from user: User) throws {
        self.id = user.id
        self.name = user.name
        self.bio = user.bio
        self.email = user.email
        self.profilePhotoFilename = user.profilePhotoFilename
        self.createdAt = user.createdAt
        self.updatedAt = user.updatedAt
        self.isPremium = user.isPremium
        self.premiumExpiresAt = user.premiumExpiresAt
        self.totalPosts = Int32(user.totalPosts)
        self.currentStreak = Int32(user.currentStreak)
        self.longestStreak = Int32(user.longestStreak)
        
        // Encode preferences
        self.preferencesData = try JSONEncoder().encode(user.preferences)
    }
    
    /// Creates new entity from domain model
    static func create(from user: User, context: NSManagedObjectContext) throws -> UserEntity {
        let entity = UserEntity(context: context)
        try entity.update(from: user)
        return entity
    }
}

// MARK: - Persona Mapping

extension PersonaEntity {
    /// Converts Core Data entity to domain model
    func toDomain() throws -> Persona {
        guard let id = self.id,
              let name = self.name,
              let colorString = self.color,
              let iconString = self.icon,
              let createdAt = self.createdAt,
              let userEntity = self.user,
              let userId = userEntity.id else {
            throw MappingError.missingRequiredField("Persona")
        }
        
        let color = Persona.PersonaColor(rawValue: colorString) ?? .blue
        let icon = Persona.PersonaIcon(rawValue: iconString) ?? .person
        
        return Persona(
            id: id,
            name: name,
            color: color,
            icon: icon,
            description: self.descriptionText,
            createdAt: createdAt,
            isDefault: self.isDefault,
            userId: userId
        )
    }
    
    /// Updates entity from domain model
    func update(from persona: Persona, context: NSManagedObjectContext) throws {
        self.id = persona.id
        self.name = persona.name
        self.color = persona.color.rawValue
        self.icon = persona.icon.rawValue
        self.descriptionText = persona.description
        self.createdAt = persona.createdAt
        self.isDefault = persona.isDefault
        
        // Update user relationship if needed
        // Note: This should be handled by the repository
    }
    
    /// Creates new entity from domain model
    static func create(from persona: Persona, context: NSManagedObjectContext) throws -> PersonaEntity {
        let entity = PersonaEntity(context: context)
        try entity.update(from: persona, context: context)
        return entity
    }
}

// MARK: - MediaItem Mapping

extension MediaItemEntity {
    /// Converts Core Data entity to domain model
    func toDomain() throws -> MediaItem {
        guard let id = self.id,
              let typeString = self.type,
              let filename = self.filename,
              let createdAt = self.createdAt,
              let postEntity = self.post,
              let postId = postEntity.id else {
            throw MappingError.missingRequiredField("MediaItem")
        }
        
        let type = MediaItem.MediaType(rawValue: typeString) ?? .photo
        
        return MediaItem(
            id: id,
            type: type,
            filename: filename,
            thumbnailFilename: self.thumbnailFilename,
            createdAt: createdAt,
            fileSize: self.fileSize,
            postId: postId,
            width: self.width > 0 ? Int(self.width) : nil,
            height: self.height > 0 ? Int(self.height) : nil,
            duration: self.duration > 0 ? self.duration : nil
        )
    }
    
    /// Updates entity from domain model
    func update(from mediaItem: MediaItem, context: NSManagedObjectContext) throws {
        self.id = mediaItem.id
        self.type = mediaItem.type.rawValue
        self.filename = mediaItem.filename
        self.thumbnailFilename = mediaItem.thumbnailFilename
        self.createdAt = mediaItem.createdAt
        self.fileSize = mediaItem.fileSize
        self.width = Int32(mediaItem.width ?? 0)
        self.height = Int32(mediaItem.height ?? 0)
        self.duration = mediaItem.duration ?? 0
        
        // Update post relationship if needed
        // Note: This should be handled by the repository
    }
    
    /// Creates new entity from domain model
    static func create(from mediaItem: MediaItem, context: NSManagedObjectContext) throws -> MediaItemEntity {
        let entity = MediaItemEntity(context: context)
        try entity.update(from: mediaItem, context: context)
        return entity
    }
}

// MARK: - Mapping Errors

enum MappingError: LocalizedError {
    case missingRequiredField(String)
    case invalidData(String)
    
    var errorDescription: String? {
        switch self {
        case .missingRequiredField(let entity):
            return "Missing required field in \(entity) entity"
        case .invalidData(let field):
            return "Invalid data for field: \(field)"
        }
    }
}

// MARK: - Batch Mapping Helpers

extension Array where Element == PostEntity {
    /// Maps array of Core Data entities to domain models
    func toDomain() throws -> [Post] {
        try self.map { try $0.toDomain() }
    }
}

extension Array where Element == UserEntity {
    /// Maps array of Core Data entities to domain models
    func toDomain() throws -> [User] {
        try self.map { try $0.toDomain() }
    }
}

extension Array where Element == PersonaEntity {
    /// Maps array of Core Data entities to domain models
    func toDomain() throws -> [Persona] {
        try self.map { try $0.toDomain() }
    }
}

extension Array where Element == MediaItemEntity {
    /// Maps array of Core Data entities to domain models
    func toDomain() throws -> [MediaItem] {
        try self.map { try $0.toDomain() }
    }
}
