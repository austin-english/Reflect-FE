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
                // Use the existing scrapbook card design
                ScrapbookPostCard(post: post)
                    .padding(.horizontal, Spacing.medium.rawValue)
                
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

// MARK: - Scrapbook Post Card (Shared Component)

/// Modern scrapbook-style post card
/// Note: This is duplicated from FeedView - TODO: Move to shared Components folder
private struct ScrapbookPostCard: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with persona badge and date
            headerView
            
            // Main content area
            contentView
            
            // Footer with mood and tags
            footerView
        }
        .background(Color.reflectSurface)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
        .overlay(
            // Mood-colored accent strip (like washi tape)
            moodAccentStrip,
            alignment: .leading
        )
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack(spacing: Spacing.small.rawValue) {
            // Persona badge (sticker-style)
            personaBadge
            
            Spacer()
            
            // Journal-style date
            journalDate
        }
        .padding(.horizontal, Spacing.medium.rawValue)
        .padding(.top, Spacing.medium.rawValue)
        .padding(.bottom, Spacing.small.rawValue)
    }
    
    private var personaBadge: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(personaColor)
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.white)
                )
            
            Text("Personal") // TODO: Lookup persona name
                .font(.labelLarge)
                .foregroundStyle(Color.reflectTextPrimary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(personaColor.opacity(0.1))
        .cornerRadius(20)
    }
    
    private var journalDate: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(post.createdAt.formatted(date: .abbreviated, time: .omitted))
                .font(.captionLarge)
                .foregroundStyle(Color.reflectTextSecondary)
            
            Text(post.createdAt.formatted(date: .omitted, time: .shortened))
                .font(.captionSmall)
                .foregroundStyle(Color.reflectTextTertiary)
        }
    }
    
    // MARK: - Content
    
    private var contentView: some View {
        VStack(alignment: .leading, spacing: Spacing.small.rawValue) {
            // Caption
            Text(post.caption)
                .font(.bodyLarge)
                .foregroundStyle(Color.reflectTextPrimary)
                .padding(.horizontal, Spacing.medium.rawValue)
            
            // Media items (photos/videos)
            if !post.mediaItems.isEmpty {
                mediaGallery
            }
            
            // Location if present
            if let location = post.location {
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.caption)
                        .foregroundStyle(Color.reflectTextTertiary)
                    
                    Text(location)
                        .font(.captionLarge)
                        .foregroundStyle(Color.reflectTextSecondary)
                }
                .padding(.horizontal, Spacing.medium.rawValue)
            }
        }
        .padding(.vertical, Spacing.small.rawValue)
    }
    
    // MARK: - Media Gallery
    
    private var mediaGallery: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.small.rawValue) {
                ForEach(post.mediaItems) { mediaItem in
                    placeholderImage(for: mediaItem)
                }
            }
            .padding(.horizontal, Spacing.medium.rawValue)
        }
    }
    
    private func placeholderImage(for mediaItem: MediaItem) -> some View {
        ZStack {
            // Placeholder with gradient based on media type
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: mediaItem.type == .photo
                            ? [Color.reflectPrimary.opacity(0.3), Color.reflectSecondary.opacity(0.3)]
                            : [Color.orange.opacity(0.3), Color.red.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 200, height: 200)
            
            // Icon overlay
            VStack(spacing: 8) {
                Image(systemName: mediaItem.type == .photo ? "photo.fill" : "video.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.white.opacity(0.8))
                
                Text(mediaItem.filename)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.6))
                    .lineLimit(1)
                    .frame(maxWidth: 180)
            }
        }
    }
    
    // MARK: - Footer
    
    private var footerView: some View {
        VStack(alignment: .leading, spacing: Spacing.small.rawValue) {
            // Mood indicator (enhanced with color)
            moodIndicator
            
            // Tags (if any)
            if !post.activityTags.isEmpty || !post.peopleTags.isEmpty {
                tagsView
            }
        }
        .padding(.horizontal, Spacing.medium.rawValue)
        .padding(.vertical, Spacing.medium.rawValue)
        .background(Color.reflectBackground.opacity(0.5))
    }
    
    private var moodIndicator: some View {
        HStack(spacing: Spacing.small.rawValue) {
            // Mood text with gradient
            Text("Feeling \(moodText(for: post.mood))")
                .font(.labelLarge)
                .foregroundStyle(Color.moodColor(for: post.mood))
            
            Spacer()
            
            // Mood rating (e.g., "9/10")
            Text("\(post.mood)/10")
                .font(.labelLarge)
                .fontWeight(.semibold)
                .foregroundStyle(Color.moodColor(for: post.mood))
        }
    }
    
    private var tagsView: some View {
        VStack(alignment: .leading, spacing: Spacing.xsmall.rawValue) {
            // Activity tags (look like label stickers)
            if !post.activityTags.isEmpty {
                tagRow(tags: Array(post.activityTags.prefix(4)), icon: "tag.fill", color: Color.reflectPrimary)
            }
            
            // People tags
            if !post.peopleTags.isEmpty {
                tagRow(tags: Array(post.peopleTags.prefix(4)), icon: "person.fill", color: Color.reflectSecondary)
            }
        }
    }
    
    private func tagRow(tags: [String], icon: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundStyle(color)
            
            ForEach(tags, id: \.self) { tag in
                tagLabel(tag, color: color)
            }
            
            if tags.count < (icon == "tag.fill" ? post.activityTags.count : post.peopleTags.count) {
                Text("+\((icon == "tag.fill" ? post.activityTags.count : post.peopleTags.count) - tags.count)")
                    .font(.captionSmall)
                    .foregroundStyle(Color.reflectTextTertiary)
            }
        }
    }
    
    private func tagLabel(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.captionLarge)
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(color.opacity(0.3), lineWidth: 1)
            )
            .cornerRadius(6)
    }
    
    // MARK: - Mood Accent Strip
    
    private var moodAccentStrip: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        Color.moodColor(for: post.mood),
                        Color.moodColor(for: post.mood).opacity(0.6)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: 4)
            .cornerRadius(2)
    }
    
    // MARK: - Helpers
    
    private var personaColor: Color {
        // TODO: Get actual persona color from repository
        Color.reflectPrimary
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
    
    private func moodText(for mood: Int) -> String {
        switch mood {
        case 1...2: return "down"
        case 3...4: return "low"
        case 5...6: return "okay"
        case 7...8: return "good"
        case 9: return "great"
        case 10: return "amazing"
        default: return "okay"
        }
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
