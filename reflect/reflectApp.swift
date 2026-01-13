//
//  reflectApp.swift
//  reflect
//
//  Created by Austin English on 12/4/25.
//

import SwiftUI

@main
struct reflectApp: App {
    
    @State private var hasCompletedOnboarding: Bool
    
    init() {
        // Handle UI testing arguments
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--reset-onboarding") {
            CompleteOnboardingUseCase.resetOnboarding()
        }
        #endif
        
        // Initialize state after handling test arguments
        _hasCompletedOnboarding = State(initialValue: CompleteOnboardingUseCase.hasCompletedOnboarding())
    }
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                // Main app (currently showing component showcase)
                ContentView()
            } else {
                // Show onboarding
                OnboardingCoordinator {
                    // When onboarding completes, update state
                    hasCompletedOnboarding = true
                }
            }
        }
    }
}
