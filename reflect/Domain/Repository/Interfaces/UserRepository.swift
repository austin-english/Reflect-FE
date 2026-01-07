//
//  UserRepository.swift
//  reflect
//
//  Created on 12/11/25.
//

import Foundation

/// Protocol defining the contract for User data operations
/// Implementations will handle persistence details (Core Data, etc.)
protocol UserRepository {
    // MARK: - CRUD Operations
    
    /// Creates a new user
    /// - Parameter user: The user to create
    /// - Throws: Repository error if creation fails
    func create(_ user: User) async throws
    
    /// Fetches a user by ID
    /// - Parameter id: The unique identifier of the user
    /// - Returns: The user if found, nil otherwise
    /// - Throws: Repository error if fetch fails
    func fetch(id: UUID) async throws -> User?
    
    /// Fetches the current user (assumes single-user app)
    /// - Returns: The current user, or nil if not set up
    /// - Throws: Repository error if fetch fails
    func fetchCurrentUser() async throws -> User?
    
    /// Updates an existing user
    /// - Parameter user: The user with updated values
    /// - Throws: Repository error if update fails
    func update(_ user: User) async throws
    
    /// Deletes a user by ID
    /// - Parameter id: The unique identifier of the user to delete
    /// - Throws: Repository error if deletion fails
    func delete(id: UUID) async throws
    
    // MARK: - User Setup
    
    /// Checks if a user has been created (for onboarding)
    /// - Returns: True if a user exists, false otherwise
    /// - Throws: Repository error if check fails
    func hasUser() async throws -> Bool
    
    /// Creates the initial user during onboarding
    /// - Parameters:
    ///   - name: User's name
    ///   - bio: Optional bio
    ///   - email: Optional email
    /// - Returns: The newly created user
    /// - Throws: Repository error if creation fails
    func createInitialUser(
        name: String,
        bio: String?,
        email: String?
    ) async throws -> User
    
    // MARK: - Preferences
    
    /// Updates user preferences
    /// - Parameters:
    ///   - userId: The user identifier
    ///   - preferences: The updated preferences
    /// - Throws: Repository error if update fails
    func updatePreferences(
        for userId: UUID,
        preferences: User.UserPreferences
    ) async throws
    
    /// Fetches user preferences
    /// - Parameter userId: The user identifier
    /// - Returns: The user's preferences
    /// - Throws: Repository error if fetch fails
    func fetchPreferences(for userId: UUID) async throws -> User.UserPreferences
    
    // MARK: - Premium Status
    
    /// Updates premium status
    /// - Parameters:
    ///   - userId: The user identifier
    ///   - isPremium: Whether user has premium
    ///   - expiresAt: Optional expiration date
    /// - Throws: Repository error if update fails
    func updatePremiumStatus(
        for userId: UUID,
        isPremium: Bool,
        expiresAt: Date?
    ) async throws
    
    /// Checks if user has active premium
    /// - Parameter userId: The user identifier
    /// - Returns: True if user has active premium
    /// - Throws: Repository error if check fails
    func hasActivePremium(for userId: UUID) async throws -> Bool
    
    // MARK: - Statistics
    
    /// Updates user statistics (post count, streak, etc.)
    /// - Parameters:
    ///   - userId: The user identifier
    ///   - totalPosts: Total number of posts
    ///   - currentStreak: Current posting streak in days
    ///   - longestStreak: Longest posting streak in days
    /// - Throws: Repository error if update fails
    func updateStatistics(
        for userId: UUID,
        totalPosts: Int,
        currentStreak: Int,
        longestStreak: Int
    ) async throws
    
    /// Fetches user statistics
    /// - Parameter userId: The user identifier
    /// - Returns: Tuple of (totalPosts, currentStreak, longestStreak)
    /// - Throws: Repository error if fetch fails
    func fetchStatistics(
        for userId: UUID
    ) async throws -> (totalPosts: Int, currentStreak: Int, longestStreak: Int)
    
    /// Increments total post count
    /// - Parameter userId: The user identifier
    /// - Throws: Repository error if update fails
    func incrementPostCount(for userId: UUID) async throws
    
    /// Decrements total post count
    /// - Parameter userId: The user identifier
    /// - Throws: Repository error if update fails
    func decrementPostCount(for userId: UUID) async throws
    
    /// Updates streak values
    /// - Parameters:
    ///   - userId: The user identifier
    ///   - currentStreak: New current streak value
    ///   - longestStreak: New longest streak value
    /// - Throws: Repository error if update fails
    func updateStreaks(
        for userId: UUID,
        currentStreak: Int,
        longestStreak: Int
    ) async throws
    
    // MARK: - Profile
    
    /// Updates user profile information
    /// - Parameters:
    ///   - userId: The user identifier
    ///   - name: Updated name
    ///   - bio: Updated bio
    /// - Throws: Repository error if update fails
    func updateProfile(
        for userId: UUID,
        name: String,
        bio: String?
    ) async throws
    
    /// Updates user profile photo
    /// - Parameters:
    ///   - userId: The user identifier
    ///   - filename: The filename of the profile photo
    /// - Throws: Repository error if update fails
    func updateProfilePhoto(
        for userId: UUID,
        filename: String?
    ) async throws
    
    // MARK: - Persona Management
    
    /// Adds a persona to the user's personas list
    /// - Parameters:
    ///   - userId: The user identifier
    ///   - personaId: The persona identifier to add
    /// - Throws: Repository error if update fails
    func addPersona(
        to userId: UUID,
        personaId: UUID
    ) async throws
    
    /// Removes a persona from the user's personas list
    /// - Parameters:
    ///   - userId: The user identifier
    ///   - personaId: The persona identifier to remove
    /// - Throws: Repository error if update fails
    func removePersona(
        from userId: UUID,
        personaId: UUID
    ) async throws
    
    /// Fetches all persona IDs for a user
    /// - Parameter userId: The user identifier
    /// - Returns: Array of persona IDs
    /// - Throws: Repository error if fetch fails
    func fetchPersonaIds(for userId: UUID) async throws -> [UUID]
    
    // MARK: - Account Management
    
    /// Deletes all user data (for account deletion)
    /// - Parameter userId: The user identifier
    /// - Throws: Repository error if deletion fails
    func deleteUserData(for userId: UUID) async throws
    
    /// Exports all user data
    /// - Parameter userId: The user identifier
    /// - Returns: The complete user object with all data
    /// - Throws: Repository error if export fails
    func exportUserData(for userId: UUID) async throws -> User
}
