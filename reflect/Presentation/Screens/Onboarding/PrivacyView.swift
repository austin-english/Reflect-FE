//
//
//  PrivacyView.swift
//  reflect
//
//  Created by Austin English on 12/16/25.
//

import SwiftUI

/// Privacy explanation screen - second step in onboarding
struct PrivacyView: View {
    
    @Bindable var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: Spacing.extraLarge.rawValue) {
            Spacer()
            
            // Privacy icon
            Image(systemName: "lock.shield")
                .font(.system(size: 80))
                .foregroundStyle(Color.reflectSuccess)
                .padding(.bottom, Spacing.medium.rawValue)
            
            // Title
            Text("100% Private, 0% Social")
                .font(.displayLarge)
                .foregroundStyle(Color.reflectTextPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            
            // Subtitle
            Text("All the features of social media, none of the anxiety")
                .font(.bodyLarge)
                .foregroundStyle(Color.reflectTextSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, Spacing.extraLarge.rawValue)
                .padding(.bottom, Spacing.large.rawValue)
            
            // Privacy features
            VStack(alignment: .leading, spacing: Spacing.large.rawValue) {
                PrivacyFeature(
                    icon: "person.fill.xmark",
                    title: "No Social Pressure",
                    description: "No followers, likes, or comments"
                )
                
                PrivacyFeature(
                    icon: "lock.shield.fill",
                    title: "Private by Default",
                    description: "Your posts stay on your device"
                )
                
                PrivacyFeature(
                    icon: "eye.slash.fill",
                    title: "No Data Collection",
                    description: "We don't track or sell your info"
                )
                
                PrivacyFeature(
                    icon: "icloud.fill",
                    title: "Optional Sync",
                    description: "Backup to your iCloud if you want"
                )
            }
            .padding(.horizontal, Spacing.extraLarge.rawValue)
            .padding(.bottom, Spacing.extraLarge.rawValue)
            
            // Navigation buttons
            VStack(spacing: Spacing.small.rawValue) {
                Button("Continue") {
                    viewModel.nextStep()
                }
                .buttonStyle(PrimaryButtonStyle(isEnabled: true))
                
                Button("Back") {
                    viewModel.previousStep()
                }
                .textButton()
                .padding(.bottom, Spacing.small.rawValue)
            }
            .padding(.horizontal, Spacing.extraLarge.rawValue)
            .padding(.bottom, Spacing.huge.rawValue)
        }
    }
}

// MARK: - Privacy Feature Component

private struct PrivacyFeature: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: Spacing.medium.rawValue) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(Color.reflectSuccess)
                .frame(width: 44, height: 44)
                .background(Color.reflectSuccess.opacity(0.1))
                .cornerRadius(CornerRadius.small.rawValue)
            
            VStack(alignment: .leading, spacing: Spacing.extraSmall.rawValue) {
                Text(title)
                    .font(.headlineMedium)
                    .foregroundStyle(Color.reflectTextPrimary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(description)
                    .font(.bodySmall)
                    .foregroundStyle(Color.reflectTextSecondary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    PrivacyView(viewModel: OnboardingViewModel())
}

