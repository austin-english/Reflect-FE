//
//  OnboardingCoordinator.swift
//  reflect
//
//  Created by Austin English on 12/16/25.
//

import SwiftUI

/// Main coordinator view for the onboarding flow
/// Manages navigation between onboarding screens
struct OnboardingCoordinator: View {
    
    @State private var viewModel = OnboardingViewModel()
    
    /// Callback when onboarding is completed
    let onComplete: () -> Void
    
    var body: some View {
        ZStack {
            // Background
            Color.reflectBackground
                .ignoresSafeArea()
            
            // Content - show current step only
            Group {
                switch viewModel.currentStep {
                case .welcome:
                    WelcomeView(viewModel: viewModel)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                    
                case .privacy:
                    PrivacyView(viewModel: viewModel)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                    
                case .signUp:
                    SignUpView(viewModel: viewModel)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                    
                case .personaSetup:
                    PersonaSetupView(viewModel: viewModel)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                }
            }
            .id(viewModel.currentStep)  // Help SwiftUI track view identity
            .animation(.easeInOut(duration: 0.3), value: viewModel.currentStep)
            
            // Progress indicator at top
            VStack {
                ProgressBar(progress: viewModel.currentStep.progress)
                    .frame(height: 4)
                    .padding(.horizontal, Spacing.medium.rawValue)
                    .padding(.top, Spacing.small.rawValue)
                
                Spacer()
            }
        }
        .onChange(of: viewModel.isCompleted) { oldValue, newValue in
            if newValue {
                onComplete()
            }
        }
    }
}

// MARK: - Progress Bar

private struct ProgressBar: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                Rectangle()
                    .fill(Color.reflectTextSecondary.opacity(0.2))
                    .cornerRadius(CornerRadius.small.rawValue)
                
                // Progress
                Rectangle()
                    .fill(Color.reflectPrimary)
                    .frame(width: geometry.size.width * progress)
                    .cornerRadius(CornerRadius.small.rawValue)
                    .animation(.easeInOut, value: progress)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingCoordinator {
        print("Onboarding completed")
    }
}
