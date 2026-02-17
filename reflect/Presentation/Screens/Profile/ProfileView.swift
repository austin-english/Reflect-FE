//
//  ProfileView.swift
//  reflect
//
//  Created by Austin English on 1/23/26.
//

import SwiftUI

/// Profile screen displaying user info and posts in grid layout
struct ProfileView: View {
    @State private var viewModel: ProfileViewModel
    
    init(viewModel: ProfileViewModel) {
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
                    ProfileHeaderView(viewModel: viewModel)
                        .padding(.horizontal, Spacing.medium.rawValue)
                        .padding(.bottom, Spacing.large.rawValue)
                    
                    // Posts grid
                    if viewModel.isLoading {
                        loadingView
                            .padding(.top, Spacing.huge.rawValue)
                    } else if viewModel.filteredPosts.isEmpty {
                        emptyStateView
                    } else {
                        postsGridView
                    }
                }
                .padding(.vertical, Spacing.medium.rawValue)
            }
            .refreshable {
                if !viewModel.filteredPosts.isEmpty || !viewModel.isLoading {
                    await viewModel.refresh()
                }
            }
        }
        .navigationTitle("Profile")
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
            ForEach(viewModel.filteredPosts) { post in
                NavigationLink(value: post) {
                    PostGridCell(post: post)
                        .aspectRatio(4/5, contentMode: .fill)
                }
                .buttonStyle(.plain)
            }
        }
        .navigationDestination(for: Post.self) { post in
            PostDetailView(post: post)
        }
    }
}

// MARK: - Profile Header

/// Social media-style profile header
private struct ProfileHeaderView: View {
    let viewModel: ProfileViewModel
    
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
                    Text(viewModel.displayName)
                        .font(.headlineLarge)
                        .foregroundStyle(Color.reflectTextPrimary)
                    
                    Text(viewModel.bio)
                        .font(.bodySmall)
                        .foregroundStyle(Color.reflectTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
            }
            
            // Stats row (Instagram-style)
            HStack(spacing: 0) {
                statItem(value: "\(viewModel.postCount)", label: "Posts")
                
                Divider()
                    .frame(height: 30)
                
                statItem(value: "\(viewModel.currentStreak)", label: "Streak")
                
                Divider()
                    .frame(height: 30)
                
                statItem(value: "\(viewModel.personaCount)", label: "Personas")
            }
            .padding(.vertical, Spacing.small.rawValue)
            .padding(.horizontal, Spacing.medium.rawValue)
            .background(.regularMaterial)
            .cornerRadius(12)
            
            // Active persona selector
            if !viewModel.personas.isEmpty {
                personaSelector
            }
        }
    }
    
    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headlineLarge)
                .foregroundStyle(Color.primary)
            
            Text(label)
                .font(.captionLarge)
                .foregroundStyle(Color.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var personaSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.small.rawValue) {
                // "All" option
                personaChip(
                    name: "All Posts",
                    color: Color.gray,
                    isSelected: viewModel.selectedPersonaId == nil
                )
                .onTapGesture {
                    viewModel.selectPersona(nil)
                }
                
                // User's personas
                ForEach(viewModel.personas) { persona in
                    personaChip(
                        name: persona.name,
                        color: Color.personaColor(persona.color),
                        isSelected: viewModel.selectedPersonaId == persona.id
                    )
                    .onTapGesture {
                        viewModel.selectPersona(persona.id)
                    }
                }
            }
            .padding(.horizontal, Spacing.medium.rawValue)
        }
        // Break out of the parent's horizontal padding so it spans full width
        .padding(.horizontal, -Spacing.medium.rawValue)
    }
    
    private func personaChip(name: String, color: Color, isSelected: Bool) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(name)
                .font(.labelMedium)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isSelected ? color.opacity(0.15) : Color(.secondarySystemBackground))
        .foregroundStyle(isSelected ? color : Color.secondary)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(isSelected ? color : Color(.separator), lineWidth: 1)
        )
        .cornerRadius(20)
    }
}

// MARK: - Post Grid Cell

/// Compact grid cell for displaying posts (Instagram-style)
private struct PostGridCell: View {
    let post: Post
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Mood color gradient — matches feed card placeholder style
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.moodColor(for: post.mood).opacity(0.5),
                            Color.moodColor(for: post.mood).opacity(0.15)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Small mood dot in bottom-right corner — subtle, no text
            Circle()
                .fill(Color.moodColor(for: post.mood))
                .frame(width: 8, height: 8)
                .padding(6)
        }
        .clipped()
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
        ProfileView(viewModel: ProfileViewModel.preview)
    }
}

#Preview("Profile Empty") {
    NavigationStack {
        ProfileView(viewModel: ProfileViewModel.emptyPreview)
    }
}
