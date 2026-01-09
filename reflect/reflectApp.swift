//
//  reflectApp.swift
//  reflect
//
//  Created by Austin English on 12/4/25.
//

import SwiftUI

@main
struct reflectApp: App {
    
    @State private var hasCompletedOnboarding = CompleteOnboardingUseCase.hasCompletedOnboarding()
    
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
