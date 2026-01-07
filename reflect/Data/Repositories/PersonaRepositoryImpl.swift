//
//  PersonaRepositoryImpl.swift
//  reflect
//
//  Created by Austin English on 12/16/25.
//

import Foundation
import CoreData

/// Implementation of PersonaRepository using Core Data
@MainActor
final class PersonaRepositoryImpl: PersonaRepository {
    
    // MARK: - Properties
    
    private let coreDataManager: CoreDataManager
    
    // MARK: - Initialization
    
    init(coreDataManager: CoreDataManager = .shared) {
        self.coreDataManager = coreDataManager
    }
    
    // MARK: - Basic CRUD Operations
    
    func create(_ persona: Persona) async throws {
        let context = coreDataManager.viewContext
        let entity = try PersonaEntity.create(from: persona, context: context)
        
        // Link to user if exists
        if let userEntity = try await coreDataManager.fetchByID(UserEntity.self, id: persona.userId) {
            entity.user = userEntity
        }
        
        try await coreDataManager.save()
    }
    
    func fetch(id: UUID) async throws -> Persona? {
        guard let entity = try await coreDataManager.fetchByID(PersonaEntity.self, id: id) else {
            return nil
        }
        return try entity.toDomain()
    }
    
    func fetchAll() async throws -> [Persona] {
        let entities = try await coreDataManager.fetchAll(
            PersonaEntity.self,
            sortDescriptors: [NSSortDescriptor(key: "createdAt", ascending: true)]
        )
        return try entities.toDomain()
    }
    
    func update(_ persona: Persona) async throws {
        guard let entity = try await coreDataManager.fetchByID(PersonaEntity.self, id: persona.id) else {
            throw PersonaRepositoryError.notFound
        }
        
        let context = coreDataManager.viewContext
        try entity.update(from: persona, context: context)
        try await coreDataManager.save()
    }
    
    func delete(id: UUID) async throws {
        guard let entity = try await coreDataManager.fetchByID(PersonaEntity.self, id: id) else {
            throw PersonaRepositoryError.notFound
        }
        
        try await coreDataManager.delete(entity)
    }
    
    // MARK: - Query Operations
    
    func fetchPersonas(for userId: UUID) async throws -> [Persona] {
        let request = PersonaEntity.fetchRequest()
        request.predicate = NSPredicate(format: "user.id == %@", userId as CVarArg)
        request.sortDescriptors = [
            NSSortDescriptor(key: "isDefault", ascending: false),
            NSSortDescriptor(key: "createdAt", ascending: true)
        ]
        
        let entities = try await coreDataManager.fetch(request)
        return try entities.toDomain()
    }
    
    func fetchDefaultPersona(for userId: UUID) async throws -> Persona? {
        let request = PersonaEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "user.id == %@ AND isDefault == YES",
            userId as CVarArg
        )
        request.fetchLimit = 1
        
        let entities = try await coreDataManager.fetch(request)
        return try entities.first?.toDomain()
    }
    
    func fetchPersonaCount(for userId: UUID) async throws -> Int {
        let request = PersonaEntity.fetchRequest()
        request.predicate = NSPredicate(format: "user.id == %@", userId as CVarArg)
        return try await coreDataManager.count(request)
    }
    
    // MARK: - Default Persona Management
    
    func setDefaultPersona(personaId: UUID, for userId: UUID) async throws {
        // First, unset all current default personas for this user
        let allPersonas = try await fetchPersonas(for: userId)
        for persona in allPersonas {
            if let entity = try await coreDataManager.fetchByID(PersonaEntity.self, id: persona.id) {
                entity.isDefault = false
            }
        }
        
        // Set the new default
        guard let entity = try await coreDataManager.fetchByID(PersonaEntity.self, id: personaId) else {
            throw PersonaRepositoryError.notFound
        }
        
        entity.isDefault = true
        try await coreDataManager.save()
    }
    
    func clearDefaultPersona(for userId: UUID) async throws {
        let personas = try await fetchPersonas(for: userId)
        for persona in personas {
            if let entity = try await coreDataManager.fetchByID(PersonaEntity.self, id: persona.id) {
                entity.isDefault = false
            }
        }
        try await coreDataManager.save()
    }
    
    // MARK: - Validation Operations
    
    func isPersonaNameUnique(name: String, for userId: UUID, excludingId: UUID?) async throws -> Bool {
        let request = PersonaEntity.fetchRequest()
        
        if let excludingId = excludingId {
            request.predicate = NSPredicate(
                format: "user.id == %@ AND name ==[c] %@ AND id != %@",
                userId as CVarArg,
                name,
                excludingId as CVarArg
            )
        } else {
            request.predicate = NSPredicate(
                format: "user.id == %@ AND name ==[c] %@",
                userId as CVarArg,
                name
            )
        }
        
        let count = try await coreDataManager.count(request)
        return count == 0 // True if name is unique
    }
    
    func canCreatePersona(for userId: UUID, isPremium: Bool) async throws -> Bool {
        let count = try await fetchPersonaCount(for: userId)
        let limit = isPremium ? User.premiumPersonaLimit : User.freePersonaLimit
        return count < limit
    }
    
    // MARK: - Preset Operations
    
    func createFromPreset(_ preset: Persona.Preset, for userId: UUID, isDefault: Bool) async throws -> Persona {
        let persona = Persona.from(preset: preset, userId: userId, isDefault: isDefault)
        try await create(persona)
        return persona
    }
    
    // MARK: - Bulk Operations
    
    func deleteAllPersonas(for userId: UUID) async throws {
        let predicate = NSPredicate(format: "user.id == %@", userId as CVarArg)
        try await coreDataManager.batchDelete(PersonaEntity.self, predicate: predicate)
    }
    
    func fetchPersonas(withColor color: Persona.PersonaColor, for userId: UUID) async throws -> [Persona] {
        let allPersonas = try await fetchPersonas(for: userId)
        return allPersonas.filter { $0.color == color }
    }
    
    // MARK: - Statistics
    
    func fetchMostUsedPersona(for userId: UUID) async throws -> (persona: Persona, postCount: Int)? {
        let postCounts = try await fetchPostCountsByPersona(for: userId)
        
        guard let mostUsedId = postCounts.max(by: { $0.value < $1.value })?.key,
              let persona = try await fetch(id: mostUsedId) else {
            return nil
        }
        
        return (persona: persona, postCount: postCounts[mostUsedId] ?? 0)
    }
    
    func fetchPostCountsByPersona(for userId: UUID) async throws -> [UUID: Int] {
        let personas = try await fetchPersonas(for: userId)
        var postCounts: [UUID: Int] = [:]
        
        // Initialize counts for all personas
        for persona in personas {
            postCounts[persona.id] = 0
        }
        
        // Count posts for each persona
        for persona in personas {
            let request = PostEntity.fetchRequest()
            request.predicate = NSPredicate(format: "persona.id == %@", persona.id as CVarArg)
            let count = try await coreDataManager.count(request)
            postCounts[persona.id] = count
        }
        
        return postCounts
    }
}

// MARK: - Errors

enum PersonaRepositoryError: LocalizedError {
    case notFound
    
    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Persona not found"
        }
    }
}
