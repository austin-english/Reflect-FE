//
//  SignUpView.swift
//  reflect
//
//  Created by Austin English on 12/16/25.
//

import SwiftUI

/// Sign up screen - user creates their account
struct SignUpView: View {
    
    @Bindable var viewModel: OnboardingViewModel
    @FocusState private var focusedField: Field?
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.extraLarge.rawValue) {
                // Header
                VStack(spacing: Spacing.medium.rawValue) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(Color.reflectPrimary)
                    
                    Text("Create Your Account")
                        .font(.displayLarge)
                        .foregroundStyle(Color.reflectTextPrimary)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("Tell us a bit about yourself")
                        .font(.bodyLarge)
                        .foregroundStyle(Color.reflectTextSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, Spacing.huge.rawValue)
                .padding(.horizontal, Spacing.extraLarge.rawValue)
                
                // Form fields
                VStack(spacing: Spacing.large.rawValue) {
                    // Name field (required)
                    VStack(alignment: .leading, spacing: Spacing.small.rawValue) {
                        Text("Name *")
                            .font(.labelLarge)
                            .foregroundStyle(Color.reflectTextSecondary)
                        
                        TextField("Your name", text: $viewModel.name)
                            .textFieldStyle(.roundedBorder)
                            .focused($focusedField, equals: .name)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled()
                    }
                    
                    // Email field (optional)
                    VStack(alignment: .leading, spacing: Spacing.small.rawValue) {
                        Text("Email (Optional)")
                            .font(.labelLarge)
                            .foregroundStyle(Color.reflectTextSecondary)
                        
                        TextField("your@email.com", text: $viewModel.email)
                            .textFieldStyle(.roundedBorder)
                            .focused($focusedField, equals: .email)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                    }
                    
                    Text("Your email is only used for account recovery")
                        .font(.captionLarge)
                        .foregroundStyle(Color.reflectTextSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
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
                    Button("Continue") {
                        viewModel.nextStep()
                    }
                    .buttonStyle(PrimaryButtonStyle(isEnabled: viewModel.canProceed))
                    .disabled(!viewModel.canProceed)
                    
                    Button("Back") {
                        viewModel.previousStep()
                    }
                    .textButton()
                    .padding(.bottom, Spacing.small.rawValue)
                }
                .padding(.horizontal, Spacing.extraLarge.rawValue)
                .padding(.bottom, Spacing.large.rawValue)
            }
        }
    }
    
    // MARK: - Focus Fields
    
    private enum Field: Hashable {
        case name
        case email
    }
}

// MARK: - Preview

#Preview {
    SignUpView(viewModel: OnboardingViewModel())
}
