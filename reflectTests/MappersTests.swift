//
//  MappersTests.swift
//  reflectTests
//
//  Created by Austin English on 12/16/25.
//

import Testing
import Foundation
import CoreData
@testable import reflect

/// Tests for Core Data entity mappers
@Suite("Entity Mappers Tests")
@MainActor
struct MappersTests {
    
    /// Creates a fresh in-memory Core Data manager for each test
    func makeManager() -> CoreDataManager {
        CoreDataManager.inMemory()
    }
    
    @Test("PostEntity can map to domain Post and back")
    func testPostEntityMapping() async throws {
        let manager = makeManager()
        let context = manager.viewContext
        
        // Create a user first
        let userEntity = UserEntity(context: context)
        userEntity.id = UUID()
        userEntity.name = "Test User"
        userEntity.createdAt = Date()
        
        // Create a persona
        let personaEntity = PersonaEntity(context: context)
        personaEntity.id = UUID()
        personaEntity.name = "Test Persona"
        personaEntity.color = "blue"
        personaEntity.icon = "person.fill"
        personaEntity.createdAt = Date()
        personaEntity.isDefault = true
        personaEntity.user = userEntity
        
        try await manager.save()
        
        // Create domain post
        let domainPost = Post(
            caption: "Test post for mapping",
            mood: 8,
            experienceRating: 9,
            personaId: personaEntity.id!,
            activityTags: ["test", "mapping"],
            peopleTags: ["friend"],
            postType: .text
        )
        
        // Map to entity
        let postEntity = try PostEntity.create(from: domainPost, context: context)
        postEntity.persona = personaEntity
        try await manager.save()
        
        // Map back to domain
        let mappedPost = try postEntity.toDomain()
        
        // Verify
        #expect(mappedPost.id == domainPost.id)
        #expect(mappedPost.caption == domainPost.caption)
        #expect(mappedPost.mood == domainPost.mood)
        #expect(mappedPost.experienceRating == domainPost.experienceRating)
        #expect(mappedPost.activityTags == domainPost.activityTags)
        #expect(mappedPost.peopleTags == domainPost.peopleTags)
        #expect(mappedPost.personaId == personaEntity.id!)
        
        // Cleanup
        try await manager.delete([postEntity, personaEntity, userEntity])
    }
    
    @Test("UserEntity can map to domain User and back")
    func testUserEntityMapping() async throws {
        let manager = makeManager()
        let context = manager.viewContext
        
        // Create domain user
        let domainUser = User(
            name: "John Doe",
            bio: "Test bio",
            email: "john@example.com"
        )
        
        // Map to entity
        let userEntity = try UserEntity.create(from: domainUser, context: context)
        try await manager.save()
        
        // Map back to domain
        let mappedUser = try userEntity.toDomain()
        
        // Verify
        #expect(mappedUser.id == domainUser.id)
        #expect(mappedUser.name == domainUser.name)
        #expect(mappedUser.bio == domainUser.bio)
        #expect(mappedUser.email == domainUser.email)
        
        // Cleanup
        try await manager.delete(userEntity)
    }
    
    @Test("PersonaEntity can map to domain Persona and back")
    func testPersonaEntityMapping() async throws {
        let manager = makeManager()
        let context = manager.viewContext
        
        // Create user first
        let userEntity = UserEntity(context: context)
        let userId = UUID()
        userEntity.id = userId
        userEntity.name = "Test User"
        userEntity.createdAt = Date()
        try await manager.save()
        
        // Create domain persona
        let domainPersona = Persona(
            name: "Work",
            color: .blue,
            icon: .briefcase,
            description: "Work stuff",
            isDefault: false,
            userId: userId
        )
        
        // Map to entity
        let personaEntity = try PersonaEntity.create(from: domainPersona, context: context)
        personaEntity.user = userEntity
        try await manager.save()
        
        // Map back to domain
        let mappedPersona = try personaEntity.toDomain()
        
        // Verify
        #expect(mappedPersona.id == domainPersona.id)
        #expect(mappedPersona.name == domainPersona.name)
        #expect(mappedPersona.color == domainPersona.color)
        #expect(mappedPersona.icon == domainPersona.icon)
        #expect(mappedPersona.description == domainPersona.description)
        #expect(mappedPersona.userId == userId)
        
        // Cleanup
        try await manager.delete([personaEntity, userEntity])
    }
}
