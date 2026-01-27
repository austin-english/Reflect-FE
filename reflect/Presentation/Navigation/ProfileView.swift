//
//  ProfileView.swift
//  reflect
//
//  Created by Austin English on 1/23/26.
//

import SwiftUI

/// Profile screen displaying user info and posts in grid layout
struct ProfileView: View {
    @State private var viewModel: FeedViewModel
    
    init(viewModel: FeedViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.reflectBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Profile header
                    ProfileHeaderView()
                        .padding(.horizontal, Spacing.medium.rawValue)
                        .padding(.bottom, Spacing.large.rawValue)
                    
                    // Posts grid
                    if viewModel.isLoading {
                        loadingView
                            .padding(.top, Spacing.huge.rawValue)
                    } else if viewModel.posts.isEmpty {
                        emptyStateView
                    } else {
                        postsGridView
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
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.loadInitialData()
        }
    }
    
    // MARK: - Subviews
    
    private var loadingView: some View {
        VStack(spacing: Spacing.medium.rawValue) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Loading your profile...")
                .font(.bodyMedium)
                .foregroundStyle(Color.reflectTextSecondary)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: Spacing.large.rawValue) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 64))
                .foregroundStyle(Color.reflectPrimary.opacity(0.3))
            
            VStack(spacing: Spacing.small.rawValue) {
                Text("No Posts Yet")
                    .font(.headlineLarge)
                    .foregroundStyle(Color.reflectTextPrimary)
                
                Text("Start capturing your moments")
                    .font(.bodyMedium)
                    .foregroundStyle(Color.reflectTextSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.huge.rawValue)
    }
    
    private var postsGridView: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 2),
                GridItem(.flexible(), spacing: 2),
                GridItem(.flexible(), spacing: 2)
            ],
            spacing: 2
        ) {
            ForEach(viewModel.posts) { post in
                NavigationLink(value: post) {
                    PostGridCell(post: post)
                }
                .buttonStyle(.plain) // Prevents blue tint on tap
            }
        }
        .padding(.horizontal, 2)
        .navigationDestination(for: Post.self) { post in
            PostDetailView(post: post)
        }
    }
}

// MARK: - Profile Header

/// Social media-style profile header
private struct ProfileHeaderView: View {
    var body: some View {
        VStack(spacing: Spacing.medium.rawValue) {
            // Profile photo and info
            HStack(spacing: Spacing.medium.rawValue) {
                // Profile photo
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.reflectPrimary, Color.reflectSecondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(.white)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                // Name and bio
                VStack(alignment: .leading, spacing: Spacing.xsmall.rawValue) {
                    Text("Preview User") // TODO: Get from user data
                        .font(.headlineLarge)
                        .foregroundStyle(Color.reflectTextPrimary)
                    
                    Text("Capturing life, one moment at a time ✨")
                        .font(.bodySmall)
                        .foregroundStyle(Color.reflectTextSecondary)
                        .lineLimit(2)
                }
                
                Spacer()
            }
            
            // Stats row (Instagram-style)
            HStack(spacing: 0) {
                statItem(value: "127", label: "Posts")
                
                Divider()
                    .frame(height: 30)
                
                statItem(value: "12", label: "Streak")
                
                Divider()
                    .frame(height: 30)
                
                statItem(value: "3", label: "Personas")
            }
            .padding(.vertical, Spacing.small.rawValue)
            .padding(.horizontal, Spacing.medium.rawValue)
            .background(Color.reflectSurface)
            .cornerRadius(12)
            
            // Active persona selector
            personaSelector
        }
    }
    
    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headlineLarge)
                .foregroundStyle(Color.reflectTextPrimary)
            
            Text(label)
                .font(.captionLarge)
                .foregroundStyle(Color.reflectTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var personaSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.small.rawValue) {
                // "All" option
                personaChip(name: "All Posts", color: Color.gray, isSelected: true)
                
                // Mock personas - TODO: Get from viewModel
                personaChip(name: "Personal", color: Color.reflectPrimary, isSelected: false)
                personaChip(name: "Work", color: Color.purple, isSelected: false)
                personaChip(name: "Creative", color: Color.pink, isSelected: false)
            }
        }
    }
    
    private func personaChip(name: String, color: Color, isSelected: Bool) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            Text(name)
                .font(.labelMedium)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isSelected ? color.opacity(0.2) : Color.reflectSurface)
        .foregroundStyle(isSelected ? color : Color.reflectTextSecondary)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(isSelected ? color : Color.clear, lineWidth: 1.5)
        )
        .cornerRadius(20)
    }
}

// MARK: - Post Grid Cell

/// Compact grid cell for displaying posts (Instagram-style)
private struct PostGridCell: View {
    let post: Post
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Background with mood color
            Rectangle()
                .fill(Color.moodColor(for: post.mood).opacity(0.2))
                .aspectRatio(1, contentMode: .fill)
            
            // Content overlay
            VStack(alignment: .leading, spacing: 4) {
                Spacer()
                
                // Caption preview (truncated)
                Text(post.caption)
                    .font(.captionSmall)
                    .foregroundStyle(Color.reflectTextPrimary)
                    .lineLimit(2)
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0),
                                Color.black.opacity(0.4)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            
            // Mood indicator badge
            Text("\(post.mood)/10")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.moodColor(for: post.mood))
                .cornerRadius(8)
                .padding(6)
        }
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Color.reflectTextTertiary.opacity(0.1), lineWidth: 0.5)
        )
    }
    
    private func moodEmoji(for mood: Int) -> String {
        switch mood {
        case 1...2: return "😢"
        case 3...4: return "😕"
        case 5...6: return "😐"
        case 7...8: return "🙂"
        case 9: return "😊"
        case 10: return "🤩"
        default: return "😐"
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
                // Use the Polaroid-style card design
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

#Preview("Profile with Posts") {
    NavigationStack {
        ProfileView(viewModel: FeedViewModel.preview)
    }
}

#Preview("Profile Empty") {
    NavigationStack {
        ProfileView(viewModel: FeedViewModel.emptyPreview)
    }
}
