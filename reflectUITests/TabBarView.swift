//
//  TabBarView.swift
//  reflect
//
//  Created on 1/22/26.
//

import SwiftUI

/// Main tab bar navigation for the app
/// Contains Feed, Create, and Profile tabs
struct TabBarView: View {
    
    @State private var selectedTab: Tab = .feed
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Feed Tab
            FeedView()
                .tabItem {
                    Label("Feed", systemImage: selectedTab == .feed ? "house.fill" : "house")
                }
                .tag(Tab.feed)
            
            // Create Tab (Placeholder for Phase 4)
            CreatePostPlaceholderView()
                .tabItem {
                    Label("Create", systemImage: selectedTab == .create ? "plus.circle.fill" : "plus.circle")
                }
                .tag(Tab.create)
            
            // Profile Tab (Placeholder for Phase 5)
            ProfilePlaceholderView()
                .tabItem {
                    Label("Profile", systemImage: selectedTab == .profile ? "person.fill" : "person")
                }
                .tag(Tab.profile)
        }
        .tint(.reflectPrimary)
    }
    
    // MARK: - Tab Enum
    
    enum Tab {
        case feed
        case create
        case profile
    }
}

// MARK: - Placeholder Views

/// Placeholder for Create Post screen (Phase 4)
private struct CreatePostPlaceholderView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.large.rawValue) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.reflectPrimary)
                
                Text("Create Post")
                    .font(.headlineLarge)
                
                Text("Coming in Phase 4")
                    .font(.bodyMedium)
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Create")
        }
    }
}

/// Placeholder for Profile screen (Phase 5)
private struct ProfilePlaceholderView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.large.rawValue) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.reflectPrimary)
                
                Text("Profile")
                    .font(.headlineLarge)
                
                Text("Coming in Phase 5")
                    .font(.bodyMedium)
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Profile")
        }
    }
}

// MARK: - Preview

#Preview("Tab Bar") {
    TabBarView()
}

#Preview("Create Placeholder") {
    CreatePostPlaceholderView()
}

#Preview("Profile Placeholder") {
    ProfilePlaceholderView()
}
