//
//  AppCoordinator.swift
//  reflect
//
//  Created by Austin English on 1/22/26.
//

import SwiftUI

/// Main app coordinator that manages tab-based navigation
@MainActor
@Observable
final class AppCoordinator {
    
    // MARK: - Navigation State
    
    /// Currently selected tab
    var selectedTab: Tab = .feed
    
    /// Available tabs in the app
    enum Tab: String, CaseIterable, Identifiable {
        case feed
        case create
        case profile
        
        var id: String { rawValue }
        
        var title: String {
            switch self {
            case .feed: return "Feed"
            case .create: return "Create"
            case .profile: return "Profile"
            }
        }
        
        var icon: String {
            switch self {
            case .feed: return "rectangle.grid.1x2.fill"
            case .create: return "plus.circle.fill"
            case .profile: return "person.circle.fill"
            }
        }
    }
    
    // MARK: - Navigation Actions
    
    /// Navigate to a specific tab
    func navigateTo(_ tab: Tab) {
        selectedTab = tab
    }
    
    /// Navigate to create post (convenience method)
    func showCreatePost() {
        selectedTab = .create
    }
    
    /// Navigate to feed (convenience method)
    func showFeed() {
        selectedTab = .feed
    }
    
    /// Navigate to profile (convenience method)
    func showProfile() {
        selectedTab = .profile
    }
}

// MARK: - Main App View

/// Root view that coordinates tab navigation
struct AppCoordinatorView: View {
    @State private var coordinator = AppCoordinator()
    @State private var isPreviewDataReady = false
    
    var body: some View {
        #if DEBUG
        // In debug mode, ensure preview data is loaded first
        Group {
            if isPreviewDataReady {
                tabView
            } else {
                loadingView
                    .task {
                        // Ensure preview data is populated
                        await PreviewContainer.shared.populateSampleDataIfNeeded()
                        isPreviewDataReady = true
                    }
            }
        }
        #else
        // In release mode, show immediately
        tabView
        #endif
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Loading preview data...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var tabView: some View {
        TabView(selection: $coordinator.selectedTab) {
            // Feed Tab
            NavigationStack {
                #if DEBUG
                // Use preview data during development
                FeedView(viewModel: FeedViewModel.preview)
                #else
                // Use real data in production
                FeedView(viewModel: DependencyContainer.shared.makeFeedViewModel())
                #endif
            }
            .tabItem {
                Label(AppCoordinator.Tab.feed.title, 
                      systemImage: AppCoordinator.Tab.feed.icon)
            }
            .tag(AppCoordinator.Tab.feed)
            
            // Create Tab (Placeholder for Phase 4)
            NavigationStack {
                CreatePostPlaceholderView()
            }
            .tabItem {
                Label(AppCoordinator.Tab.create.title,
                      systemImage: AppCoordinator.Tab.create.icon)
            }
            .tag(AppCoordinator.Tab.create)
            
            // Profile Tab (Placeholder for Phase 5)
            NavigationStack {
                #if DEBUG
                // Use preview data during development
                ProfileView(viewModel: FeedViewModel.preview)
                #else
                // Use real data in production
                ProfileView(viewModel: DependencyContainer.shared.makeFeedViewModel())
                #endif
            }
            .tabItem {
                Label(AppCoordinator.Tab.profile.title,
                      systemImage: AppCoordinator.Tab.profile.icon)
            }
            .tag(AppCoordinator.Tab.profile)
        }
        .tint(.reflectPrimary)
        .environment(coordinator)
    }
}

// MARK: - Placeholder Views

/// Placeholder for Create Post screen (Phase 4)
private struct CreatePostPlaceholderView: View {
    var body: some View {
        VStack(spacing: Spacing.large.rawValue) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 64))
                .foregroundStyle(Color.reflectPrimary.opacity(0.5))
            
            Text("Create Post")
                .font(.headlineLarge)
            
            Text("Post creation coming in Phase 4")
                .font(.bodyMedium)
                .foregroundStyle(Color.reflectTextSecondary)
        }
        .navigationTitle("Create")
    }
}

/// Placeholder for Profile screen (Phase 5)
private struct ProfilePlaceholderView: View {
    var body: some View {
        VStack(spacing: Spacing.large.rawValue) {
            Image(systemName: "person.circle")
                .font(.system(size: 64))
                .foregroundStyle(Color.reflectPrimary.opacity(0.5))
            
            Text("Profile")
                .font(.headlineLarge)
            
            Text("Profile & settings coming in Phase 5")
                .font(.bodyMedium)
                .foregroundStyle(Color.reflectTextSecondary)
        }
        .navigationTitle("Profile")
    }
}

// MARK: - Preview

#Preview("App Coordinator") {
    AppCoordinatorView()
}


