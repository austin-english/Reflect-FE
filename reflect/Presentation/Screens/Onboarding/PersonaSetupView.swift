//
//  PersonaSetupView.swift
//  reflect
//
//  Created by Austin English on 12/16/25.
//

import SwiftUI

/// Persona setup screen - user creates their first persona
struct PersonaSetupView: View {
    
    @Bindable var viewModel: OnboardingViewModel
    @FocusState private var isNameFieldFocused: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.extraLarge.rawValue) {
                // Header
                VStack(spacing: Spacing.medium.rawValue) {
                    Image(systemName: "person.2.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(Color.personaColor(viewModel.personaColor))
                    
                    Text("Create Your First Persona")
                        .font(.displayLarge)
                        .foregroundStyle(Color.reflectTextPrimary)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("Personas help you organize different aspects of your life")
                        .font(.bodyLarge)
                        .foregroundStyle(Color.reflectTextSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, Spacing.huge.rawValue)
                .padding(.horizontal, Spacing.extraLarge.rawValue)
                
                // Persona customization
                VStack(spacing: Spacing.large.rawValue) {
                    // Name field
                    VStack(alignment: .leading, spacing: Spacing.small.rawValue) {
                        Text("Persona Name")
                            .font(.labelLarge)
                            .foregroundStyle(Color.reflectTextSecondary)
                        
                        TextField("Personal", text: $viewModel.personaName)
                            .textFieldStyle(.roundedBorder)
                            .focused($isNameFieldFocused)
                            .textInputAutocapitalization(.words)
                    }
                    
                    // Color picker
                    VStack(alignment: .leading, spacing: Spacing.medium.rawValue) {
                        Text("Color")
                            .font(.labelLarge)
                            .foregroundStyle(Color.reflectTextSecondary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: Spacing.medium.rawValue) {
                            ForEach(Persona.PersonaColor.allCases, id: \.self) { color in
                                ColorButton(
                                    color: color,
                                    isSelected: viewModel.personaColor == color,
                                    action: {
                                        viewModel.personaColor = color
                                    }
                                )
                            }
                        }
                    }
                    
                    // Info box
                    HStack(spacing: Spacing.medium.rawValue) {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(Color.reflectPrimary)
                        
                        VStack(alignment: .leading, spacing: Spacing.extraSmall.rawValue) {
                            Text("You can create more personas later")
                                .font(.labelLarge)
                                .foregroundStyle(Color.reflectTextPrimary)
                            
                            Text("Premium users can create up to 5 personas")
                                .font(.captionLarge)
                                .foregroundStyle(Color.reflectTextSecondary)
                        }
                        
                        Spacer()
                    }
                    .padding(Spacing.medium.rawValue)
                    .background(Color.reflectPrimary.opacity(0.1))
                    .cornerRadius(CornerRadius.medium.rawValue)
                }
                .padding(.horizontal, Spacing.extraLarge.rawValue)
                
                // Error message
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.bodySmall)
                        .foregroundStyle(Color.reflectError)
                        .padding(.horizontal, Spacing.extraLarge.rawValue)
                }
                
                Spacer(minLength: Spacing.huge.rawValue)
                
                // Navigation buttons
                VStack(spacing: Spacing.small.rawValue) {
                    Button(action: {
                        Task {
                            await viewModel.completeOnboarding()
                        }
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            Text("Complete Setup")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(isEnabled: viewModel.canProceed && !viewModel.isLoading))
                    .disabled(!viewModel.canProceed || viewModel.isLoading)
                    
                    Button("Back") {
                        viewModel.previousStep()
                    }
                    .textButton()
                    .disabled(viewModel.isLoading)
                    .padding(.bottom, Spacing.small.rawValue)
                }
                .padding(.horizontal, Spacing.extraLarge.rawValue)
                .padding(.bottom, Spacing.large.rawValue)
            }
        }
    }
}

// MARK: - Color Button Component

private struct ColorButton: View {
    let color: Persona.PersonaColor
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.personaColor(color))
                    .frame(width: 50, height: 50)
                
                if isSelected {
                    Circle()
                        .stroke(Color.reflectTextPrimary, lineWidth: 3)
                        .frame(width: 58, height: 58)
                    
                    Image(systemName: "checkmark")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    PersonaSetupView(viewModel: OnboardingViewModel())
}
