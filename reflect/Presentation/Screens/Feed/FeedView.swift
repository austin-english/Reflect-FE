//
//  FeedView.swift
//  reflect
//
//  Created by Austin English on 1/22/26.
//

import SwiftUI

/// Main feed screen displaying posts chronologically
struct FeedView: View {
    @State private var viewModel: FeedViewModel
    
    init(viewModel: FeedViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                // Loading state
                loadingView
            } else if viewModel.posts.isEmpty {
                // Empty state
                emptyStateView
            } else {
                // Posts list
                postsListView
            }
        }
        .navigationTitle("Feed")
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
            
            Text("Loading your posts...")
                .font(.bodyMedium)
                .foregroundStyle(Color.reflectTextSecondary)
        }
    }
    
    /// Empty state for new users
    private var emptyStateView: some View {
        VStack(spacing: Spacing.large.rawValue) {
            Spacer()
            
            Image(systemName: "square.and.pencil")
                .font(.system(size: 72))
                .foregroundStyle(Color.reflectPrimary.opacity(0.3))
            
            VStack(spacing: Spacing.small.rawValue) {
                Text("Welcome to Reflect")
                    .font(.headlineLarge)
                
                Text("Start journaling your life")
                    .font(.bodyMedium)
                    .foregroundStyle(Color.reflectTextSecondary)
            }
            
            Text("Tap the + button below to create your first post")
                .font(.bodySmall)
                .foregroundStyle(Color.reflectTextTertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.large.rawValue)
            
            Spacer()
        }
    }
    
    /// Posts list with pull-to-refresh
    private var postsListView: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.medium.rawValue) {
                ForEach(viewModel.posts) { post in
                    PostRowView(post: post)
                        .padding(.horizontal, Spacing.medium.rawValue)
                }
            }
            .padding(.vertical, Spacing.medium.rawValue)
        }
        .refreshable {
            await viewModel.refresh()
        }
    }
}

// MARK: - Post Row View

/// Single post row in the feed
private struct PostRowView: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small.rawValue) {
            // Header: Persona ID and timestamp (persona name lookup would need repository access)
            HStack {
                // Note: Post has personaId, not persona object
                // For now, just show timestamp
                Spacer()
                
                Text(post.createdAt, style: .relative)
                    .font(.caption)
                    .foregroundStyle(Color.reflectTextTertiary)
            }
            
            // Caption
            Text(post.caption)
                .font(.bodyMedium)
                .foregroundStyle(Color.reflectTextPrimary)
                .lineLimit(5)
            
            // Mood indicator
            HStack(spacing: Spacing.small.rawValue) {
                Image(systemName: moodIcon(for: post.mood))
                    .foregroundStyle(Color.moodColor(for: post.mood))
                
                Text("Mood: \(post.mood)/10")
                    .font(.caption)
                    .foregroundStyle(Color.reflectTextSecondary)
            }
            
            // Tags (if any)
            if !post.activityTags.isEmpty || !post.peopleTags.isEmpty {
                tagsView
            }
        }
        .padding(Spacing.medium.rawValue)
        .background(Color.reflectSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    /// Tags display
    private var tagsView: some View {
        HStack(spacing: Spacing.xsmall.rawValue) {
            ForEach(Array(post.activityTags.prefix(3)), id: \.self) { tag in
                tagPill(tag, icon: "tag.fill")
            }
            
            ForEach(Array(post.peopleTags.prefix(3)), id: \.self) { tag in
                tagPill(tag, icon: "person.fill")
            }
            
            let totalTags = post.activityTags.count + post.peopleTags.count
            if totalTags > 6 {
                Text("+\(totalTags - 6)")
                    .font(.caption)
                    .foregroundStyle(Color.reflectTextTertiary)
            }
        }
    }
    
    /// Individual tag pill
    private func tagPill(_ text: String, icon: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
            
            Text(text)
                .font(.caption)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.reflectPrimary.opacity(0.1))
        .foregroundStyle(Color.reflectPrimary)
        .clipShape(Capsule())
    }
    
    /// Get SF Symbol for mood value
    private func moodIcon(for mood: Int) -> String {
        switch mood {
        case 1...3: return "face.frowning"
        case 4...6: return "face.neutral"
        case 7...9: return "face.smiling"
        case 10: return "face.grinning.inverse"
        default: return "face.neutral"
        }
    }
}

// MARK: - Previews

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

