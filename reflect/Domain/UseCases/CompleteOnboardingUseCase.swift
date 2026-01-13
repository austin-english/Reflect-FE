//
//  CompleteOnboardingUseCase.swift
//  reflect
//
//  Created by Austin English on 12/16/25.
//

import Foundation

/// Use case for completing the onboarding flow
/// Handles user creation and initial persona setup
@MainActor
final class CompleteOnboardingUseCase {
    
    // MARK: - Properties
    
    private let userRepository: UserRepository
    private let personaRepository: PersonaRepository
    
    // MARK: - Initialization
    
    init(
        userRepository: UserRepository,
        personaRepository: PersonaRepository
    ) {
        self.userRepository = userRepository
        self.personaRepository = personaRepository
    }
    
    // MARK: - Execution
    
    /// Completes onboarding by creating user and default persona
    /// - Parameters:
    ///   - name: User's name (required)
    ///   - bio: User's bio (optional)
    ///   - email: User's email (optional)
    ///   - personaName: Name for the default persona (defaults to "Personal")
    ///   - personaColor: Color for the default persona (defaults to .blue)
    /// - Returns: The created user and persona
    /// - Throws: OnboardingError if validation fails or creation fails
    func execute(
        name: String,
        bio: String? = nil,
        email: String? = nil,
        personaName: String = "Personal",
        personaColor: Persona.PersonaColor = .blue
    ) async throws -> (user: User, persona: Persona) {
        
        // Validate input
        try validateInput(name: name, email: email)
        
        // Check if user already exists (shouldn't happen, but safety check)
        let hasExistingUser = try await userRepository.hasUser()
        guard !hasExistingUser else {
            throw OnboardingError.userAlreadyExists
        }
        
        // Create user
        let user = User(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            bio: bio?.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email?.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        try await userRepository.create(user)
        
        // Create default persona
        let persona = Persona(
            name: personaName.trimmingCharacters(in: .whitespacesAndNewlines),
            color: personaColor,
            icon: .person,
            description: "Your default persona",
            isDefault: true,
            userId: user.id
        )
        
        try await personaRepository.create(persona)
        
        // Mark onboarding as complete
        markOnboardingComplete()
        
        return (user, persona)
    }
    
    // MARK: - Validation
    
    private func validateInput(name: String, email: String?) throws {
        // Validate name
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw OnboardingError.nameRequired
        }
        
        guard trimmedName.count >= 2 else {
            throw OnboardingError.nameTooShort
        }
        
        guard trimmedName.count <= 50 else {
            throw OnboardingError.nameTooLong
        }
        
        // Validate email if provided
        if let email = email, !email.isEmpty {
            let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
            guard emailPredicate.evaluate(with: email) else {
                throw OnboardingError.invalidEmail
            }
        }
    }
    
    // MARK: - Persistence
    
    private func markOnboardingComplete() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
    
    /// Check if onboarding has been completed
    static func hasCompletedOnboarding() -> Bool {
        return UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
    
    /// Reset onboarding state (for testing/debugging)
    static func resetOnboarding() {
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
    }
}

// MARK: - Errors

enum OnboardingError: LocalizedError {
    case nameRequired
    case nameTooShort
    case nameTooLong
    case invalidEmail
    case userAlreadyExists
    
    var errorDescription: String? {
        switch self {
        case .nameRequired:
            return "Please enter your name"
        case .nameTooShort:
            return "Name must be at least 2 characters"
        case .nameTooLong:
            return "Name must be less than 50 characters"
        case .invalidEmail:
            return "Please enter a valid email address"
        case .userAlreadyExists:
            return "User already exists. Onboarding has already been completed."
        }
    }
}

