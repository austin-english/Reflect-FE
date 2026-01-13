//
//  CompleteOnboardingUseCaseTests.swift
//  reflectTests
//
//  Created by Austin English on 1/13/26.
//

import Testing
import Foundation
@testable import reflect

/// Comprehensive tests for CompleteOnboardingUseCase
/// Tests cover validation, user creation, persona creation, and error handling
@Suite("Complete Onboarding Use Case Tests")
struct CompleteOnboardingUseCaseTests {
    
    // MARK: - Success Cases
    
    @Test("Successfully completes onboarding with valid name")
    @MainActor
    func testSuccessfulOnboardingWithValidName() async throws {
        // Given
        let mockUserRepo = MockUserRepository()
        let mockPersonaRepo = MockPersonaRepository()
        let useCase = CompleteOnboardingUseCase(
            userRepository: mockUserRepo,
            personaRepository: mockPersonaRepo
        )
        
        // When
        let result = try await useCase.execute(
            name: "John Doe",
            email: nil,
            personaName: "Personal",
            personaColor: .blue
        )
        
        // Then
        #expect(result.user.name == "John Doe")
        #expect(result.user.bio == nil)
        #expect(result.user.email == nil)
        #expect(result.persona.name == "Personal")
        #expect(result.persona.color == .blue)
        #expect(result.persona.isDefault == true)
        #expect(mockUserRepo.createdUsers.count == 1)
        #expect(mockPersonaRepo.createdPersonas.count == 1)
    }
    
    @Test("Successfully completes onboarding with email")
    @MainActor
    func testSuccessfulOnboardingWithEmail() async throws {
        // Given
        let mockUserRepo = MockUserRepository()
        let mockPersonaRepo = MockPersonaRepository()
        let useCase = CompleteOnboardingUseCase(
            userRepository: mockUserRepo,
            personaRepository: mockPersonaRepo
        )
        
        // When
        let result = try await useCase.execute(
            name: "Jane Smith",
            email: "jane@example.com",
            personaName: "Personal",
            personaColor: .purple
        )
        
        // Then
        #expect(result.user.name == "Jane Smith")
        #expect(result.user.email == "jane@example.com")
        #expect(result.persona.color == .purple)
    }
    
    @Test("Successfully completes onboarding with custom persona")
    @MainActor
    func testSuccessfulOnboardingWithCustomPersona() async throws {
        // Given
        let mockUserRepo = MockUserRepository()
        let mockPersonaRepo = MockPersonaRepository()
        let useCase = CompleteOnboardingUseCase(
            userRepository: mockUserRepo,
            personaRepository: mockPersonaRepo
        )
        
        // When
        let result = try await useCase.execute(
            name: "Alex Johnson",
            email: nil,
            personaName: "Work Life",
            personaColor: .red
        )
        
        // Then
        #expect(result.persona.name == "Work Life")
        #expect(result.persona.color == .red)
        #expect(result.persona.userId == result.user.id)
    }
    
    @Test("Trims whitespace from name")
    @MainActor
    func testTrimsWhitespaceFromName() async throws {
        // Given
        let mockUserRepo = MockUserRepository()
        let mockPersonaRepo = MockPersonaRepository()
        let useCase = CompleteOnboardingUseCase(
            userRepository: mockUserRepo,
            personaRepository: mockPersonaRepo
        )
        
        // When
        let result = try await useCase.execute(
            name: "  John Doe  ",
            email: nil
        )
        
        // Then
        #expect(result.user.name == "John Doe")
    }
    
    @Test("Trims whitespace from email")
    @MainActor
    func testTrimsWhitespaceFromEmail() async throws {
        // Given
        let mockUserRepo = MockUserRepository()
        let mockPersonaRepo = MockPersonaRepository()
        let useCase = CompleteOnboardingUseCase(
            userRepository: mockUserRepo,
            personaRepository: mockPersonaRepo
        )
        
        // When
        let result = try await useCase.execute(
            name: "John Doe",
            email: "  john@example.com  "
        )
        
        // Then
        #expect(result.user.email == "john@example.com")
    }
    
    // MARK: - Name Validation Tests
    
    @Test("Throws error when name is empty")
    @MainActor
    func testThrowsErrorWhenNameIsEmpty() async throws {
        // Given
        let mockUserRepo = MockUserRepository()
        let mockPersonaRepo = MockPersonaRepository()
        let useCase = CompleteOnboardingUseCase(
            userRepository: mockUserRepo,
            personaRepository: mockPersonaRepo
        )
        
        // When/Then
        await #expect(throws: OnboardingError.nameRequired) {
            try await useCase.execute(name: "", email: nil)
        }
    }
    
    @Test("Throws error when name is only whitespace")
    @MainActor
    func testThrowsErrorWhenNameIsOnlyWhitespace() async throws {
        // Given
        let mockUserRepo = MockUserRepository()
        let mockPersonaRepo = MockPersonaRepository()
        let useCase = CompleteOnboardingUseCase(
            userRepository: mockUserRepo,
            personaRepository: mockPersonaRepo
        )
        
        // When/Then
        await #expect(throws: OnboardingError.nameRequired) {
            try await useCase.execute(name: "   ", email: nil)
        }
    }
    
    @Test("Throws error when name is too short")
    @MainActor
    func testThrowsErrorWhenNameIsTooShort() async throws {
        // Given
        let mockUserRepo = MockUserRepository()
        let mockPersonaRepo = MockPersonaRepository()
        let useCase = CompleteOnboardingUseCase(
            userRepository: mockUserRepo,
            personaRepository: mockPersonaRepo
        )
        
        // When/Then
        await #expect(throws: OnboardingError.nameTooShort) {
            try await useCase.execute(name: "A", email: nil)
        }
    }
    
    @Test("Throws error when name is too long")
    @MainActor
    func testThrowsErrorWhenNameIsTooLong() async throws {
        // Given
        let mockUserRepo = MockUserRepository()
        let mockPersonaRepo = MockPersonaRepository()
        let useCase = CompleteOnboardingUseCase(
            userRepository: mockUserRepo,
            personaRepository: mockPersonaRepo
        )
        let longName = String(repeating: "A", count: 51)
        
        // When/Then
        await #expect(throws: OnboardingError.nameTooLong) {
            try await useCase.execute(name: longName, email: nil)
        }
    }
    
    @Test("Accepts name at minimum length (2 characters)")
    @MainActor
    func testAcceptsNameAtMinimumLength() async throws {
        // Given
        let mockUserRepo = MockUserRepository()
        let mockPersonaRepo = MockPersonaRepository()
        let useCase = CompleteOnboardingUseCase(
            userRepository: mockUserRepo,
            personaRepository: mockPersonaRepo
        )
        
        // When
        let result = try await useCase.execute(name: "Jo", email: nil)
        
        // Then
        #expect(result.user.name == "Jo")
    }
    
    @Test("Accepts name at maximum length (50 characters)")
    @MainActor
    func testAcceptsNameAtMaximumLength() async throws {
        // Given
        let mockUserRepo = MockUserRepository()
        let mockPersonaRepo = MockPersonaRepository()
        let useCase = CompleteOnboardingUseCase(
            userRepository: mockUserRepo,
            personaRepository: mockPersonaRepo
        )
        let maxName = String(repeating: "A", count: 50)
        
        // When
        let result = try await useCase.execute(name: maxName, email: nil)
        
        // Then
        #expect(result.user.name.count == 50)
    }
    
    // MARK: - Email Validation Tests
    
    @Test("Accepts valid email addresses")
    @MainActor
    func testAcceptsValidEmailAddresses() async throws {
        // Given
        let mockUserRepo = MockUserRepository()
        let mockPersonaRepo = MockPersonaRepository()
        let useCase = CompleteOnboardingUseCase(
            userRepository: mockUserRepo,
            personaRepository: mockPersonaRepo
        )
        
        let validEmails = [
            "user@example.com",
            "john.doe@company.co.uk",
            "test+tag@email.com",
            "user123@test-domain.org"
        ]
        
        // When/Then
        for email in validEmails {
            let result = try await useCase.execute(
                name: "Test User",
                email: email
            )
            #expect(result.user.email == email)
        }
    }
    
    @Test("Throws error for invalid email addresses")
    @MainActor
    func testThrowsErrorForInvalidEmailAddresses() async throws {
        // Given
        let mockUserRepo = MockUserRepository()
        let mockPersonaRepo = MockPersonaRepository()
        let useCase = CompleteOnboardingUseCase(
            userRepository: mockUserRepo,
            personaRepository: mockPersonaRepo
        )
        
        let invalidEmails = [
            "notanemail",
            "missing@domain",
            "@nodomain.com",
            "spaces in@email.com",
            "double@@domain.com"
        ]
        
        // When/Then
        for email in invalidEmails {
            await #expect(throws: OnboardingError.invalidEmail) {
                try await useCase.execute(name: "Test User", email: email)
            }
        }
    }
    
    @Test("Accepts empty email (optional field)")
    @MainActor
    func testAcceptsEmptyEmail() async throws {
        // Given
        let mockUserRepo = MockUserRepository()
        let mockPersonaRepo = MockPersonaRepository()
        let useCase = CompleteOnboardingUseCase(
            userRepository: mockUserRepo,
            personaRepository: mockPersonaRepo
        )
        
        // When
        let result = try await useCase.execute(
            name: "Test User",
            email: ""
        )
        
        // Then
        #expect(result.user.email == nil)
    }
    
    @Test("Accepts nil email (optional field)")
    @MainActor
    func testAcceptsNilEmail() async throws {
        // Given
        let mockUserRepo = MockUserRepository()
        let mockPersonaRepo = MockPersonaRepository()
        let useCase = CompleteOnboardingUseCase(
            userRepository: mockUserRepo,
            personaRepository: mockPersonaRepo
        )
        
        // When
        let result = try await useCase.execute(
            name: "Test User",
            email: nil
        )
        
        // Then
        #expect(result.user.email == nil)
    }
    
    // MARK: - User Already Exists Tests
    
    @Test("Throws error when user already exists")
    @MainActor
    func testThrowsErrorWhenUserAlreadyExists() async throws {
        // Given
        let mockUserRepo = MockUserRepository()
        mockUserRepo.userExists = true  // Simulate existing user
        let mockPersonaRepo = MockPersonaRepository()
        let useCase = CompleteOnboardingUseCase(
            userRepository: mockUserRepo,
            personaRepository: mockPersonaRepo
        )
        
        // When/Then
        await #expect(throws: OnboardingError.userAlreadyExists) {
            try await useCase.execute(name: "Test User", email: nil)
        }
    }
    
    // MARK: - Onboarding Completion State Tests
    
    @Test("Marks onboarding as complete after successful execution")
    @MainActor
    func testMarksOnboardingAsComplete() async throws {
        // Given
        let mockUserRepo = MockUserRepository()
        let mockPersonaRepo = MockPersonaRepository()
        let useCase = CompleteOnboardingUseCase(
            userRepository: mockUserRepo,
            personaRepository: mockPersonaRepo
        )
        
        // Reset onboarding state
        CompleteOnboardingUseCase.resetOnboarding()
        #expect(CompleteOnboardingUseCase.hasCompletedOnboarding() == false)
        
        // When
        _ = try await useCase.execute(name: "Test User", email: nil)
        
        // Then
        #expect(CompleteOnboardingUseCase.hasCompletedOnboarding() == true)
    }
    
    @Test("Can reset onboarding state")
    @MainActor
    func testCanResetOnboardingState() async throws {
        // Given
        let mockUserRepo = MockUserRepository()
        let mockPersonaRepo = MockPersonaRepository()
        let useCase = CompleteOnboardingUseCase(
            userRepository: mockUserRepo,
            personaRepository: mockPersonaRepo
        )
        
        // Complete onboarding
        _ = try await useCase.execute(name: "Test User", email: nil)
        #expect(CompleteOnboardingUseCase.hasCompletedOnboarding() == true)
        
        // When
        CompleteOnboardingUseCase.resetOnboarding()
        
        // Then
        #expect(CompleteOnboardingUseCase.hasCompletedOnboarding() == false)
    }
    
    // MARK: - Persona Tests
    
    @Test("Creates default persona with correct properties")
    @MainActor
    func testCreatesDefaultPersonaWithCorrectProperties() async throws {
        // Given
        let mockUserRepo = MockUserRepository()
        let mockPersonaRepo = MockPersonaRepository()
        let useCase = CompleteOnboardingUseCase(
            userRepository: mockUserRepo,
            personaRepository: mockPersonaRepo
        )
        
        // When
        let result = try await useCase.execute(
            name: "Test User",
            email: nil
        )
        
        // Then
        #expect(result.persona.name == "Personal")
        #expect(result.persona.color == .blue)
        #expect(result.persona.icon == .person)
        #expect(result.persona.description == "Your default persona")
        #expect(result.persona.isDefault == true)
        #expect(result.persona.userId == result.user.id)
    }
    
    @Test("Trims whitespace from persona name")
    @MainActor
    func testTrimsWhitespaceFromPersonaName() async throws {
        // Given
        let mockUserRepo = MockUserRepository()
        let mockPersonaRepo = MockPersonaRepository()
        let useCase = CompleteOnboardingUseCase(
            userRepository: mockUserRepo,
            personaRepository: mockPersonaRepo
        )
        
        // When
        let result = try await useCase.execute(
            name: "Test User",
            email: nil,
            personaName: "  Work Life  ",
            personaColor: .green
        )
        
        // Then
        #expect(result.persona.name == "Work Life")
    }
}

// MARK: - Mock Repositories

/// Mock UserRepository for testing
@MainActor
final class MockUserRepository: UserRepository {
    var createdUsers: [User] = []
    var userExists: Bool = false
    
    // MARK: - CRUD Operations
    
    func create(_ user: User) async throws {
        createdUsers.append(user)
    }
    
    func fetch(id: UUID) async throws -> User? {
        return createdUsers.first { $0.id == id }
    }
    
    func fetchCurrentUser() async throws -> User? {
        return createdUsers.first
    }
    
    func update(_ user: User) async throws {
        // Not needed for onboarding tests
    }
    
    func delete(id: UUID) async throws {
        // Not needed for onboarding tests
    }
    
    // MARK: - User Setup
    
    func hasUser() async throws -> Bool {
        return userExists
    }
    
    func createInitialUser(name: String, bio: String?, email: String?) async throws -> User {
        let user = User(name: name, bio: bio, email: email)
        createdUsers.append(user)
        return user
    }
    
    // MARK: - Preferences
    
    func fetchPreferences(for userId: UUID) async throws -> User.UserPreferences {
        return User.UserPreferences()
    }
    
    func updatePreferences(for userId: UUID, preferences: User.UserPreferences) async throws {
        // Not needed for onboarding tests
    }
    
    // MARK: - Premium Status
    
    func hasActivePremium(for userId: UUID) async throws -> Bool {
        return false
    }
    
    func updatePremiumStatus(for userId: UUID, isPremium: Bool, expiresAt: Date?) async throws {
        // Not needed for onboarding tests
    }
    
    // MARK: - Statistics
    
    func fetchStatistics(for userId: UUID) async throws -> (totalPosts: Int, currentStreak: Int, longestStreak: Int) {
        return (0, 0, 0)
    }
    
    func updateStatistics(for userId: UUID, totalPosts: Int, currentStreak: Int, longestStreak: Int) async throws {
        // Not needed for onboarding tests
    }
    
    func incrementPostCount(for userId: UUID) async throws {
        // Not needed for onboarding tests
    }
    
    func decrementPostCount(for userId: UUID) async throws {
        // Not needed for onboarding tests
    }
    
    func updateStreaks(for userId: UUID, currentStreak: Int, longestStreak: Int) async throws {
        // Not needed for onboarding tests
    }
    
    // MARK: - Profile Updates
    
    func updateProfile(for userId: UUID, name: String, bio: String?) async throws {
        // Not needed for onboarding tests
    }
    
    func updateProfilePhoto(for userId: UUID, filename: String?) async throws {
        // Not needed for onboarding tests
    }
    
    // MARK: - Persona Management
    
    func addPersona(to userId: UUID, personaId: UUID) async throws {
        // Not needed for onboarding tests
    }
    
    func removePersona(from userId: UUID, personaId: UUID) async throws {
        // Not needed for onboarding tests
    }
    
    func fetchPersonaIds(for userId: UUID) async throws -> [UUID] {
        return []
    }
    
    // MARK: - Account Management
    
    func deleteUserData(for userId: UUID) async throws {
        // Not needed for onboarding tests
    }
    
    func exportUserData(for userId: UUID) async throws -> User {
        guard let user = createdUsers.first(where: { $0.id == userId }) else {
            throw NSError(domain: "MockError", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }
        return user
    }
}

/// Mock PersonaRepository for testing
@MainActor
final class MockPersonaRepository: PersonaRepository {
    var createdPersonas: [Persona] = []
    
    // MARK: - CRUD Operations
    
    func create(_ persona: Persona) async throws {
        createdPersonas.append(persona)
    }
    
    func fetch(id: UUID) async throws -> Persona? {
        return createdPersonas.first { $0.id == id }
    }
    
    func fetchAll() async throws -> [Persona] {
        return createdPersonas
    }
    
    func update(_ persona: Persona) async throws {
        // Not needed for onboarding tests
    }
    
    func delete(id: UUID) async throws {
        // Not needed for onboarding tests
    }
    
    // MARK: - User-Specific Queries
    
    func fetchPersonas(for userId: UUID) async throws -> [Persona] {
        return createdPersonas.filter { $0.userId == userId }
    }
    
    func fetchDefaultPersona(for userId: UUID) async throws -> Persona? {
        return createdPersonas.first { $0.userId == userId && $0.isDefault }
    }
    
    func fetchPersonaCount(for userId: UUID) async throws -> Int {
        return createdPersonas.filter { $0.userId == userId }.count
    }
    
    // MARK: - Default Persona Management
    
    func setDefaultPersona(personaId: UUID, for userId: UUID) async throws {
        // Not needed for onboarding tests
    }
    
    func clearDefaultPersona(for userId: UUID) async throws {
        // Not needed for onboarding tests
    }
    
    // MARK: - Validation
    
    func isPersonaNameUnique(name: String, for userId: UUID, excludingId: UUID?) async throws -> Bool {
        return true
    }
    
    func canCreatePersona(for userId: UUID, isPremium: Bool) async throws -> Bool {
        return true
    }
    
    // MARK: - Preset Management
    
    func createFromPreset(_ preset: Persona.Preset, for userId: UUID, isDefault: Bool) async throws -> Persona {
        let persona = Persona(
            name: preset.name,
            color: preset.color,
            icon: preset.icon,
            description: preset.description,
            isDefault: isDefault,
            userId: userId
        )
        createdPersonas.append(persona)
        return persona
    }
    
    // MARK: - Bulk Operations
    
    func deleteAllPersonas(for userId: UUID) async throws {
        // Not needed for onboarding tests
    }
    
    func fetchPersonas(withColor color: Persona.PersonaColor, for userId: UUID) async throws -> [Persona] {
        return createdPersonas.filter { $0.userId == userId && $0.color == color }
    }
    
    // MARK: - Statistics
    
    func fetchMostUsedPersona(for userId: UUID) async throws -> (persona: Persona, postCount: Int)? {
        return nil
    }
    
    func fetchPostCountsByPersona(for userId: UUID) async throws -> [UUID: Int] {
        return [:]
    }
}
