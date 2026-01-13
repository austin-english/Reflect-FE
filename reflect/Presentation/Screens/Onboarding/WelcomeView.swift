//
//  WelcomeView.swift
//  reflect
//
//  Created by Austin English on 12/16/25.
//

import SwiftUI

/// Welcome screen - first step in onboarding
struct WelcomeView: View {
    
    @Bindable var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: Spacing.extraLarge.rawValue) {
            Spacer()
            
            // App logo
            ReflectLogo(size: 100, animated: true)
                .padding(.bottom, Spacing.medium.rawValue)
            
            // Title
            Text("Welcome to Reflect")
                .font(.displayLarge)
                .foregroundStyle(Color.reflectTextPrimary)
                .multilineTextAlignment(.center)
            
            // Tagline
            Text("Social media where you're the only follower")
                .font(.headlineMedium)
                .foregroundStyle(Color.reflectPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, Spacing.extraLarge.rawValue)
                .padding(.bottom, Spacing.large.rawValue)
            
            // Feature highlights
            VStack(alignment: .leading, spacing: Spacing.large.rawValue) {
                FeatureRow(
                    icon: "photo.stack",
                    title: "Familiar & Beautiful",
                    description: "Post like social media, just for you"
                )
                
                FeatureRow(
                    icon: "heart.circle",
                    title: "Track Your Well-Being",
                    description: "Moods, activities, and memories"
                )
                
                FeatureRow(
                    icon: "calendar.badge.clock",
                    title: "Relive Your Moments",
                    description: "See what you posted on this day"
                )
                
                FeatureRow(
                    icon: "chart.xyaxis.line",
                    title: "Understand Yourself",
                    description: "Patterns and insights over time"
                )
                
                FeatureRow(
                    icon: "square.and.arrow.up",
                    title: "Share When Ready",
                    description: "Export to Instagram, Twitter, or anywhere"
                )
            }
            .padding(.horizontal, Spacing.extraLarge.rawValue)
            .padding(.bottom, Spacing.extraLarge.rawValue)
            
            // Get Started button
            Button("Get Started") {
                viewModel.nextStep()
            }
            .primaryButton()
            .padding(.horizontal, Spacing.extraLarge.rawValue)
            .padding(.bottom, Spacing.huge.rawValue)
        }
    }
}

// MARK: - Feature Row Component

private struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: Spacing.medium.rawValue) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(Color.reflectPrimary)
                .frame(width: 44, height: 44)
                .background(Color.reflectPrimary.opacity(0.1))
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
    WelcomeView(viewModel: OnboardingViewModel())
}
