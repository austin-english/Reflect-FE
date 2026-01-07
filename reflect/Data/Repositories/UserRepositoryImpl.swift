//
//  UserRepositoryImpl.swift
//  reflect
//
//  Created by Austin English on 12/16/25.
//

import Foundation
import CoreData

/// Implementation of UserRepository using Core Data
@MainActor
final class UserRepositoryImpl: UserRepository {
    
    // MARK: - Properties
    
    private let coreDataManager: CoreDataManager
    
    // MARK: - Initialization
    
    init(coreDataManager: CoreDataManager = .shared) {
        self.coreDataManager = coreDataManager
    }
    
    // MARK: - Basic CRUD Operations
    
    func create(_ user: User) async throws {
        let context = coreDataManager.viewContext
        _ = try UserEntity.create(from: user, context: context)
        try await coreDataManager.save()
    }
    
    func fetch(id: UUID) async throws -> User? {
        guard let entity = try await coreDataManager.fetchByID(UserEntity.self, id: id) else {
            return nil
        }
        return try entity.toDomain()
    }
    
    func fetchCurrentUser() async throws -> User? {
        // For now, just fetch the first user (single-user app in Phase 1-8)
        let entities = try await coreDataManager.fetchAll(
            UserEntity.self,
            sortDescriptors: [NSSortDescriptor(key: "createdAt", ascending: true)]
        )
        
        return try entities.first?.toDomain()
    }
    
    func update(_ user: User) async throws {
        guard let entity = try await coreDataManager.fetchByID(UserEntity.self, id: user.id) else {
            throw UserRepositoryError.notFound
        }
        
        try entity.update(from: user)
        try await coreDataManager.save()
    }
    
    func delete(id: UUID) async throws {
        guard let entity = try await coreDataManager.fetchByID(UserEntity.self, id: id) else {
            throw UserRepositoryError.notFound
        }
        
        try await coreDataManager.delete(entity)
    }
    
    // MARK: - Query Operations
    
    func hasUser() async throws -> Bool {
        let request = UserEntity.fetchRequest()
        let count = try await coreDataManager.count(request)
        return count > 0
    }
    
    func createInitialUser(name: String, bio: String?, email: String?) async throws -> User {
        let user = User(
            name: name,
            bio: bio,
            email: email
        )
        
        try await create(user)
        return user
    }
    
    // MARK: - Preferences Operations
    
    func updatePreferences(for userId: UUID, preferences: User.UserPreferences) async throws {
        guard let entity = try await coreDataManager.fetchByID(UserEntity.self, id: userId) else {
            throw UserRepositoryError.notFound
        }
        
        let encodedData = try JSONEncoder().encode(preferences)
        entity.preferencesData = encodedData
        try await coreDataManager.save()
    }
    
    func fetchPreferences(for userId: UUID) async throws -> User.UserPreferences {
        guard let entity = try await coreDataManager.fetchByID(UserEntity.self, id: userId) else {
            throw UserRepositoryError.notFound
        }
        
        // Access preferencesData in the same statement to avoid actor isolation issues
        if let preferencesData = entity.preferencesData {
            return try JSONDecoder().decode(User.UserPreferences.self, from: preferencesData)
        }
        
        return User.UserPreferences() // Return default
    }
    
    // MARK: - Premium Operations
    
    func updatePremiumStatus(for userId: UUID, isPremium: Bool, expiresAt: Date?) async throws {
        guard let entity = try await coreDataManager.fetchByID(UserEntity.self, id: userId) else {
            throw UserRepositoryError.notFound
        }
        
        entity.isPremium = isPremium
        entity.premiumExpiresAt = expiresAt
        try await coreDataManager.save()
    }
    
    func hasActivePremium(for userId: UUID) async throws -> Bool {
        guard let user = try await fetch(id: userId) else {
            return false
        }
        
        return user.hasActivePremium
    }
    
    // MARK: - Statistics Operations
    
    func updateStatistics(for userId: UUID, totalPosts: Int, currentStreak: Int, longestStreak: Int) async throws {
        guard let entity = try await coreDataManager.fetchByID(UserEntity.self, id: userId) else {
            throw UserRepositoryError.notFound
        }
        
        entity.totalPosts = Int32(totalPosts)
        entity.currentStreak = Int32(currentStreak)
        entity.longestStreak = Int32(longestStreak)
        try await coreDataManager.save()
    }
    
    func fetchStatistics(for userId: UUID) async throws -> (totalPosts: Int, currentStreak: Int, longestStreak: Int) {
        guard let user = try await fetch(id: userId) else {
            throw UserRepositoryError.notFound
        }
        
        return (user.totalPosts, user.currentStreak, user.longestStreak)
    }
    
    func incrementPostCount(for userId: UUID) async throws {
        guard let entity = try await coreDataManager.fetchByID(UserEntity.self, id: userId) else {
            throw UserRepositoryError.notFound
        }
        
        entity.totalPosts += 1
        try await coreDataManager.save()
    }
    
    func decrementPostCount(for userId: UUID) async throws {
        guard let entity = try await coreDataManager.fetchByID(UserEntity.self, id: userId) else {
            throw UserRepositoryError.notFound
        }
        
        let currentCount = entity.totalPosts
        entity.totalPosts = max(0, currentCount - 1)
        try await coreDataManager.save()
    }
    
    func updateStreaks(for userId: UUID, currentStreak: Int, longestStreak: Int) async throws {
        guard let entity = try await coreDataManager.fetchByID(UserEntity.self, id: userId) else {
            throw UserRepositoryError.notFound
        }
        
        
        entity.currentStreak = Int32(currentStreak)
        entity.longestStreak = Int32(longestStreak)
        try await coreDataManager.save()
    }
    
    // MARK: - Profile Operations
    
    func updateProfile(for userId: UUID, name: String, bio: String?) async throws {
        guard let entity = try await coreDataManager.fetchByID(UserEntity.self, id: userId) else {
            throw UserRepositoryError.notFound
        }
        
        entity.name = name
        entity.bio = bio
        entity.updatedAt = Date()
        try await coreDataManager.save()
    }
    
    func updateProfilePhoto(for userId: UUID, filename: String?) async throws {
        guard let entity = try await coreDataManager.fetchByID(UserEntity.self, id: userId) else {
            throw UserRepositoryError.notFound
        }
        
        entity.profilePhotoFilename = filename
        entity.updatedAt = Date()
        try await coreDataManager.save()
    }
    
    // MARK: - Persona Management
    
    func addPersona(to userId: UUID, personaId: UUID) async throws {
        guard let userEntity = try await coreDataManager.fetchByID(UserEntity.self, id: userId),
              let personaEntity = try await coreDataManager.fetchByID(PersonaEntity.self, id: personaId) else {
            throw UserRepositoryError.notFound
        }
        
        // Link persona to user
        personaEntity.user = userEntity
        try await coreDataManager.save()
    }
    
    func removePersona(from userId: UUID, personaId: UUID) async throws {
        guard let personaEntity = try await coreDataManager.fetchByID(PersonaEntity.self, id: personaId) else {
            throw UserRepositoryError.notFound
        }
        
        // Unlink persona from user
        personaEntity.user = nil
        try await coreDataManager.save()
    }
    
    func fetchPersonaIds(for userId: UUID) async throws -> [UUID] {
        let request = PersonaEntity.fetchRequest()
        request.predicate = NSPredicate(format: "user.id == %@", userId as CVarArg)
        
        let personas = try await coreDataManager.fetch(request)
        return personas.compactMap { $0.id }
    }
    
    // MARK: - Account Management
    
    func deleteUserData(for userId: UUID) async throws {
        // This will cascade delete all related data (personas, posts, etc.)
        // due to Core Data relationships with cascade delete rules
        guard let entity = try await coreDataManager.fetchByID(UserEntity.self, id: userId) else {
            throw UserRepositoryError.notFound
        }
        
        try await coreDataManager.delete(entity)
    }
    
    func exportUserData(for userId: UUID) async throws -> User {
        guard let user = try await fetch(id: userId) else {
            throw UserRepositoryError.notFound
        }
        
        return user
    }
}

// MARK: - Errors

enum UserRepositoryError: LocalizedError {
    case notFound
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .notFound:
            return "User not found"
        case .invalidData:
            return "Invalid user data provided"
        }
    }
}
