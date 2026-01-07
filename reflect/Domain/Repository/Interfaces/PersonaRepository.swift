//
//  PersonaRepository.swift
//  reflect
//
//  Created on 12/11/25.
//

import Foundation

/// Protocol defining the contract for Persona data operations
/// Implementations will handle persistence details (Core Data, etc.)
protocol PersonaRepository {
    // MARK: - CRUD Operations
    
    /// Creates a new persona
    /// - Parameter persona: The persona to create
    /// - Throws: Repository error if creation fails
    func create(_ persona: Persona) async throws
    
    /// Fetches a persona by ID
    /// - Parameter id: The unique identifier of the persona
    /// - Returns: The persona if found, nil otherwise
    /// - Throws: Repository error if fetch fails
    func fetch(id: UUID) async throws -> Persona?
    
    /// Fetches all personas
    /// - Returns: Array of all personas
    /// - Throws: Repository error if fetch fails
    func fetchAll() async throws -> [Persona]
    
    /// Updates an existing persona
    /// - Parameter persona: The persona with updated values
    /// - Throws: Repository error if update fails
    func update(_ persona: Persona) async throws
    
    /// Deletes a persona by ID
    /// - Parameter id: The unique identifier of the persona to delete
    /// - Throws: Repository error if deletion fails
    func delete(id: UUID) async throws
    
    // MARK: - User-Specific Queries
    
    /// Fetches all personas for a specific user
    /// - Parameter userId: The user identifier
    /// - Returns: Array of personas belonging to the user
    /// - Throws: Repository error if fetch fails
    func fetchPersonas(for userId: UUID) async throws -> [Persona]
    
    /// Fetches the default persona for a user
    /// - Parameter userId: The user identifier
    /// - Returns: The default persona, or nil if none is set
    /// - Throws: Repository error if fetch fails
    func fetchDefaultPersona(for userId: UUID) async throws -> Persona?
    
    /// Fetches the number of personas for a user
    /// - Parameter userId: The user identifier
    /// - Returns: Count of personas
    /// - Throws: Repository error if fetch fails
    func fetchPersonaCount(for userId: UUID) async throws -> Int
    
    // MARK: - Default Persona Management
    
    /// Sets a persona as the default for a user
    /// - Parameters:
    ///   - personaId: The persona to set as default
    ///   - userId: The user identifier
    /// - Throws: Repository error if update fails
    func setDefaultPersona(
        personaId: UUID,
        for userId: UUID
    ) async throws
    
    /// Clears the default persona flag from all personas for a user
    /// - Parameter userId: The user identifier
    /// - Throws: Repository error if update fails
    func clearDefaultPersona(for userId: UUID) async throws
    
    // MARK: - Validation
    
    /// Checks if a persona name is unique for a user
    /// - Parameters:
    ///   - name: The persona name to check
    ///   - userId: The user identifier
    ///   - excludingId: Optional persona ID to exclude from check (for updates)
    /// - Returns: True if the name is unique
    /// - Throws: Repository error if check fails
    func isPersonaNameUnique(
        name: String,
        for userId: UUID,
        excludingId: UUID?
    ) async throws -> Bool
    
    /// Checks if a user can create more personas (based on tier limits)
    /// - Parameters:
    ///   - userId: The user identifier
    ///   - isPremium: Whether the user has premium
    /// - Returns: True if user can create more personas
    /// - Throws: Repository error if check fails
    func canCreatePersona(
        for userId: UUID,
        isPremium: Bool
    ) async throws -> Bool
    
    // MARK: - Preset Management
    
    /// Creates a persona from a preset template
    /// - Parameters:
    ///   - preset: The preset type
    ///   - userId: The user identifier
    ///   - isDefault: Whether this should be the default persona
    /// - Returns: The newly created persona
    /// - Throws: Repository error if creation fails
    func createFromPreset(
        _ preset: Persona.Preset,
        for userId: UUID,
        isDefault: Bool
    ) async throws -> Persona
    
    // MARK: - Bulk Operations
    
    /// Deletes all personas for a user
    /// - Parameter userId: The user identifier
    /// - Throws: Repository error if deletion fails
    func deleteAllPersonas(for userId: UUID) async throws
    
    /// Fetches personas by color
    /// - Parameters:
    ///   - color: The persona color
    ///   - userId: The user identifier
    /// - Returns: Array of personas with the specified color
    /// - Throws: Repository error if fetch fails
    func fetchPersonas(
        withColor color: Persona.PersonaColor,
        for userId: UUID
    ) async throws -> [Persona]
    
    // MARK: - Statistics
    
    /// Fetches the persona with the most posts
    /// - Parameter userId: The user identifier
    /// - Returns: The most used persona and its post count, or nil if no personas
    /// - Throws: Repository error if fetch fails
    func fetchMostUsedPersona(
        for userId: UUID
    ) async throws -> (persona: Persona, postCount: Int)?
    
    /// Fetches post count for each persona
    /// - Parameter userId: The user identifier
    /// - Returns: Dictionary mapping persona IDs to post counts
    /// - Throws: Repository error if fetch fails
    func fetchPostCountsByPersona(
        for userId: UUID
    ) async throws -> [UUID: Int]
}
