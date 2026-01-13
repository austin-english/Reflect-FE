//
//  OnboardingViewModel.swift
//  reflect
//
//  Created by Austin English on 12/16/25.
//

import Foundation
import Observation

/// ViewModel for managing onboarding flow state
@Observable
@MainActor
final class OnboardingViewModel {
    
    // MARK: - State
    
    /// Current step in the onboarding flow
    var currentStep: OnboardingStep = .welcome
    
    /// User input: name
    var name: String = ""
    
    /// User input: email (optional)
    var email: String = ""
    
    /// Persona customization: name
    var personaName: String = "Personal"
    
    /// Persona customization: color
    var personaColor: Persona.PersonaColor = .blue
    
    /// Loading state
    var isLoading: Bool = false
    
    /// Error message to display
    var errorMessage: String?
    
    /// Completion state
    var isCompleted: Bool = false
    
    // MARK: - Dependencies
    
    private let completeOnboardingUseCase: CompleteOnboardingUseCase
    
    // MARK: - Initialization
    
    init(completeOnboardingUseCase: CompleteOnboardingUseCase) {
        self.completeOnboardingUseCase = completeOnboardingUseCase
    }
    
    /// Convenience initializer with default dependencies
    convenience init() {
        let userRepo = UserRepositoryImpl()
        let personaRepo = PersonaRepositoryImpl()
        let useCase = CompleteOnboardingUseCase(
            userRepository: userRepo,
            personaRepository: personaRepo
        )
        self.init(completeOnboardingUseCase: useCase)
    }
    
    // MARK: - Navigation
    
    /// Move to the next step in onboarding
    func nextStep() {
        errorMessage = nil
        
        switch currentStep {
        case .welcome:
            currentStep = .privacy
        case .privacy:
            currentStep = .signUp
        case .signUp:
            // Validate before moving forward
            if validateSignUpInput() {
                currentStep = .personaSetup
            }
        case .personaSetup:
            // Will trigger completion
            break
        }
    }
    
    /// Move to the previous step
    func previousStep() {
        errorMessage = nil
        
        switch currentStep {
        case .welcome:
            break // Can't go back from welcome
        case .privacy:
            currentStep = .welcome
        case .signUp:
            currentStep = .privacy
        case .personaSetup:
            currentStep = .signUp
        }
    }
    
    // MARK: - Actions
    
    /// Complete the onboarding process
    func completeOnboarding() async {
        errorMessage = nil
        isLoading = true
        
        do {
            // Execute the use case
            _ = try await completeOnboardingUseCase.execute(
                name: name,
                email: email.isEmpty ? nil : email,
                personaName: personaName,
                personaColor: personaColor
            )
            
            // Success!
            isCompleted = true
            isLoading = false
            
        } catch let error as OnboardingError {
            errorMessage = error.errorDescription
            isLoading = false
        } catch {
            errorMessage = "An unexpected error occurred. Please try again."
            isLoading = false
        }
    }
    
    // MARK: - Validation
    
    private func validateSignUpInput() -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedName.isEmpty {
            errorMessage = "Please enter your name"
            return false
        }
        
        if trimmedName.count < 2 {
            errorMessage = "Name must be at least 2 characters"
            return false
        }
        
        if trimmedName.count > 50 {
            errorMessage = "Name must be less than 50 characters"
            return false
        }
        
        // Validate email if provided
        if !email.isEmpty {
            let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
            if !emailPredicate.evaluate(with: email) {
                errorMessage = "Please enter a valid email address"
                return false
            }
        }
        
        return true
    }
    
    /// Check if the current step can proceed
    var canProceed: Bool {
        switch currentStep {
        case .welcome, .privacy:
            return true
        case .signUp:
            return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .personaSetup:
            return !personaName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
}

// MARK: - Onboarding Steps

enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case privacy = 1
    case signUp = 2
    case personaSetup = 3
    
    var title: String {
        switch self {
        case .welcome:
            return "Welcome to Reflect"
        case .privacy:
            return "Your Privacy Matters"
        case .signUp:
            return "Create Your Account"
        case .personaSetup:
            return "Create Your First Persona"
        }
    }
    
    var progress: Double {
        Double(rawValue) / Double(OnboardingStep.allCases.count - 1)
    }
}
