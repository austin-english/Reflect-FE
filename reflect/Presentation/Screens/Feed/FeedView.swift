//
//  FeedView.swift
//  reflect
//
//  Created by Austin English on 1/22/26.
//

import SwiftUI

/// Main feed screen displaying posts chronologically in modern scrapbook style
struct FeedView: View {
    @State private var viewModel: FeedViewModel
    
    init(viewModel: FeedViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            // Subtle paper texture background
            Color.reflectBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Content
                    if viewModel.isLoading {
                        // Loading state
                        loadingView
                            .padding(.top, Spacing.huge.rawValue)
                    } else if viewModel.posts.isEmpty {
                        // Empty state
                        emptyStateContent
                    } else {
                        // Posts list
                        postsListContent
                    }
                }
                .padding(.vertical, Spacing.medium.rawValue)
            }
            .refreshable {
                if !viewModel.posts.isEmpty || !viewModel.isLoading {
                    await viewModel.refresh()
                }
            }
        }
        .navigationTitle("Feed")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.loadInitialData()
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.clearError()
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Subviews
    
    /// Loading indicator
    private var loadingView: some View {
        VStack(spacing: Spacing.medium.rawValue) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Loading your memories...")
                .font(.bodyMedium)
                .foregroundStyle(Color.reflectTextSecondary)
        }
    }
    
    // MARK: - Content Sections
    
    /// Empty state content (without Spacers, since profile is above)
    private var emptyStateContent: some View {
        VStack(spacing: Spacing.large.rawValue) {
            // Scrapbook-style empty state
            ZStack {
                // Background paper
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.reflectSurface)
                    .frame(width: 280, height: 280)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                
                VStack(spacing: Spacing.medium.rawValue) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 64))
                        .foregroundStyle(Color.reflectPrimary.opacity(0.3))
                    
                    VStack(spacing: Spacing.small.rawValue) {
                        Text("Your Story Starts Here")
                            .font(.headlineLarge)
                            .foregroundStyle(Color.reflectTextPrimary)
                        
                        Text("Capture life's moments,\none memory at a time")
                            .font(.bodyMedium)
                            .foregroundStyle(Color.reflectTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(Spacing.large.rawValue)
            }
            .padding(.top, Spacing.huge.rawValue)
            
            Text("Tap the + button below to create your first entry")
                .font(.bodySmall)
                .foregroundStyle(Color.reflectTextTertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.large.rawValue)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, Spacing.huge.rawValue)
    }
    
    /// Posts list content (just the posts, profile is above)
    private var postsListContent: some View {
        LazyVStack(spacing: Spacing.large.rawValue) {
            ForEach(viewModel.posts) { post in
                NavigationLink(value: post) {
                    ScrapbookPostCard(post: post)
                }
                .buttonStyle(.plain) // Prevents blue tint
            }
        }
        .navigationDestination(for: Post.self) { post in
            PostDetailView(post: post)
        }
    }
}

// MARK: - Post Detail View

/// Full-screen post detail view
private struct PostDetailView: View {
    let post: Post
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.medium.rawValue) {
                // Use the existing scrapbook card design
                ScrapbookPostCard(post: post)
                
                // TODO: Add edit/delete actions in future phase
                // TODO: Add media gallery if photos exist
                // TODO: Add comments section in future phase
            }
            .padding(.vertical, Spacing.medium.rawValue)
        }
        .background(Color.reflectBackground)
        .navigationTitle("Post Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview

#Preview("Feed with Posts") {
    NavigationStack {
        FeedView(viewModel: FeedViewModel.preview)
    }
}

#Preview("Feed Empty") {
    NavigationStack {
        FeedView(viewModel: FeedViewModel.emptyPreview)
    }
}

