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
    
    /// UserDefaults key for tracking onboarding completion
    private static let hasCompletedOnboardingKey = "hasCompletedOnboarding"
    
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
    ///   - email: User's email (optional)
    ///   - personaName: Name for the default persona (defaults to "Personal")
    ///   - personaColor: Color for the default persona (defaults to .blue)
    /// - Returns: The created user and persona
    /// - Throws: OnboardingError if validation fails or creation fails
    func execute(
        name: String,
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
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Convert empty email to nil
        let finalEmail = trimmedEmail?.isEmpty == true ? nil : trimmedEmail
        
        let user = User(
            name: trimmedName,
            bio: nil,
            email: finalEmail
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
        
        // Validate email if provided and not empty after trimming
        if let email = email {
            let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Only validate if not empty after trimming (empty is ok, it's optional)
            if !trimmedEmail.isEmpty {
                let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
                let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
                guard emailPredicate.evaluate(with: trimmedEmail) else {
                    throw OnboardingError.invalidEmail
                }
            }
        }
    }
    
    // MARK: - Persistence
    
    private func markOnboardingComplete() {
        UserDefaults.standard.set(true, forKey: Self.hasCompletedOnboardingKey)
    }
    
    /// Check if onboarding has been completed
    static func hasCompletedOnboarding() -> Bool {
        return UserDefaults.standard.bool(forKey: hasCompletedOnboardingKey)
    }
    
    /// Reset onboarding state (for testing/debugging)
    static func resetOnboarding() {
        UserDefaults.standard.removeObject(forKey: hasCompletedOnboardingKey)
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

