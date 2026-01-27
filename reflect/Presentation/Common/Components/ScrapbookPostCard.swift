//
//  ScrapbookPostCard.swift
//  reflect
//
//  Created by Austin English on 1/27/26.
//

import SwiftUI

/// Modern Polaroid-style post card for displaying journal entries
/// Used in Feed, Profile, and Post Detail views
struct ScrapbookPostCard: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Polaroid photo section (aged paper border on top and sides)
            VStack(spacing: 0) {
                // Top aged paper border
                Color.agedPaper.opacity(0.75)
                    .frame(height: 12)
                
                // Photo content
                if !post.mediaItems.isEmpty {
                    photoContent
                } else {
                    emptyPhotoPlaceholder
                }
                
                // Bottom "writing" section (aged paper, like real Polaroid)
                polaroidBottomSection
            }
            .background(Color.agedPaper.opacity(0.75))
            .cornerRadius(4)
            .shadow(.polaroid)
        }
        .background(Color.clear)
    }
    
    // MARK: - Photo Section
    
    private var photoContent: some View {
        TabView {
            ForEach(post.mediaItems) { mediaItem in
                ZStack {
                    // Placeholder with gradient
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.moodColor(for: post.mood).opacity(0.3),
                                    Color.moodColor(for: post.mood).opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Icon overlay
                    VStack(spacing: 8) {
                        Image(systemName: mediaItem.type == .photo ? "photo.fill" : "video.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(.white.opacity(0.7))
                        
                        Text(mediaItem.filename)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.5))
                            .lineLimit(1)
                            .padding(.horizontal, 20)
                    }
                }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: post.mediaItems.count > 1 ? .always : .never))
        .frame(height: 320)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
    
    private var emptyPhotoPlaceholder: some View {
        ZStack {
            Rectangle()
                .fill(Color.reflectBackground)
            
            VStack(spacing: 8) {
                Image(systemName: "text.bubble.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.reflectTextTertiary.opacity(0.3))
                
                Text("Text Entry")
                    .font(.caption)
                    .foregroundStyle(Color.reflectTextTertiary)
            }
        }
        .frame(height: 320)
    }
    
    // MARK: - Polaroid Bottom Section
    
    private var polaroidBottomSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Handwritten-style caption
            Text(post.caption)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundStyle(Color.black.opacity(0.8))
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
            // Metadata row (date, location, mood)
            HStack(spacing: 8) {
                // Date
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.system(size: 10))
                    Text(post.createdAt.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(size: 11))
                }
                .foregroundStyle(Color.black.opacity(0.5))
                
                if let location = post.location {
                    // Dot separator
                    Text("•")
                        .foregroundStyle(Color.black.opacity(0.3))
                    
                    // Location
                    HStack(spacing: 4) {
                        Image(systemName: "mappin")
                            .font(.system(size: 10))
                        Text(location)
                            .font(.system(size: 11))
                            .lineLimit(1)
                    }
                    .foregroundStyle(Color.black.opacity(0.5))
                }
                
                Spacer()
                
                // Mood rating
                HStack(spacing: 4) {
                    Text("\(post.mood)/10")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.moodColor(for: post.mood))
                }
            }
            
            // Tags row (if any)
            if !post.activityTags.isEmpty || !post.peopleTags.isEmpty {
                HStack(spacing: 6) {
                    ForEach(Array(post.activityTags.prefix(3)), id: \.self) { tag in
                        compactTag(tag, color: Color.reflectPrimary)
                    }
                    
                    ForEach(Array(post.peopleTags.prefix(2)), id: \.self) { person in
                        compactTag(person, color: Color.reflectSecondary, icon: "person")
                    }
                    
                    let totalTags = post.activityTags.count + post.peopleTags.count
                    if totalTags > 5 {
                        Text("+\(totalTags - 5)")
                            .font(.system(size: 10))
                            .foregroundStyle(Color.black.opacity(0.4))
                    }
                }
            }
            
            // Persona badge (subtle, small)
            HStack(spacing: 6) {
                Circle()
                    .fill(personaColor)
                    .frame(width: 8, height: 8)
                
                Text("Personal")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.black.opacity(0.5))
                
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .frame(minHeight: 100)
        .background(Color.agedPaper.opacity(0.85))
    }
    
    // MARK: - Helper Views
    
    private func compactTag(_ text: String, color: Color, icon: String? = nil) -> some View {
        HStack(spacing: 3) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 8))
            }
            Text(text)
                .font(.system(size: 10))
        }
        .foregroundStyle(color)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(color.opacity(0.1))
        .cornerRadius(4)
    }
    
    // MARK: - Helpers
    
    private var personaColor: Color {
        // TODO: Get actual persona color from repository
        Color.reflectPrimary
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

// Note: Previews will work once connected to FeedViewModel.preview
// which provides mock Post data through the preview container
