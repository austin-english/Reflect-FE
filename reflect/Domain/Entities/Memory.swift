//
//  Memory.swift
//  reflect
//
//  Created by Austin English on 12/4/25.
//

import Foundation

/// Domain entity representing a memory (a post from the past shown "on this day")
struct Memory: Identifiable, Codable {
    // MARK: - Properties
    
    let id: UUID
    var post: Post
    var memoryType: MemoryType
    var presentedAt: Date
    var wasViewed: Bool
    var notes: String? // User can add notes when viewing memories
    
    // MARK: - Initialization
    
    init(
        id: UUID = UUID(),
        post: Post,
        memoryType: MemoryType,
        presentedAt: Date = Date(),
        wasViewed: Bool = false,
        notes: String? = nil
    ) {
        self.id = id
        self.post = post
        self.memoryType = memoryType
        self.presentedAt = presentedAt
        self.wasViewed = wasViewed
        self.notes = notes
    }
}

// MARK: - Memory Type

extension Memory {
    enum MemoryType: Codable {
        case onThisDay(yearsAgo: Int)
        case thisWeekLastYear
        case randomThrowback
        
        var displayName: String {
            switch self {
            case .onThisDay(let years):
                return years == 1 ? "1 year ago" : "\(years) years ago"
            case .thisWeekLastYear:
                return "This week last year"
            case .randomThrowback:
                return "Throwback"
            }
        }
        
        var emoji: String {
            switch self {
            case .onThisDay:
                return "📅"
            case .thisWeekLastYear:
                return "📆"
            case .randomThrowback:
                return "✨"
            }
        }
        
        var title: String {
            switch self {
            case .onThisDay(let years):
                return "On This Day • \(years) Year\(years == 1 ? "" : "s") Ago"
            case .thisWeekLastYear:
                return "This Week Last Year"
            case .randomThrowback:
                return "Random Memory"
            }
        }
    }
}

// MARK: - Computed Properties

extension Memory {
    /// Returns the date of the original post
    var originalPostDate: Date {
        post.createdAt
    }
    
    /// Returns how many days ago the original post was created
    var daysAgo: Int {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: post.createdAt, to: Date()).day ?? 0
        return days
    }
    
    /// Returns how many years ago the original post was created
    var yearsAgo: Int {
        let calendar = Calendar.current
        let years = calendar.dateComponents([.year], from: post.createdAt, to: Date()).year ?? 0
        return years
    }
    
    /// Returns formatted date of original post
    var originalDateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: post.createdAt)
    }
    
    /// Returns a human-readable time ago string
    var timeAgoFormatted: String {
        if yearsAgo > 0 {
            return "\(yearsAgo) year\(yearsAgo == 1 ? "" : "s") ago"
        } else if daysAgo >= 30 {
            let months = daysAgo / 30
            return "\(months) month\(months == 1 ? "" : "s") ago"
        } else if daysAgo >= 7 {
            let weeks = daysAgo / 7
            return "\(weeks) week\(weeks == 1 ? "" : "s") ago"
        } else {
            return "\(daysAgo) day\(daysAgo == 1 ? "" : "s") ago"
        }
    }
}

// MARK: - Memory Generation Logic

extension Memory {
    /// Generates "On This Day" memories from a collection of posts
    static func generateOnThisDayMemories(from posts: [Post]) -> [Memory] {
        let calendar = Calendar.current
        let today = Date()
        let todayComponents = calendar.dateComponents([.month, .day], from: today)
        
        return posts.compactMap { post -> Memory? in
            let postComponents = calendar.dateComponents([.month, .day, .year], from: post.createdAt)
            
            // Check if same month and day, but different year
            guard postComponents.month == todayComponents.month,
                  postComponents.day == todayComponents.day,
                  let postYear = postComponents.year else {
                return nil
            }
            
            let currentYear = calendar.component(.year, from: today)
            let yearsAgo = currentYear - postYear
            
            guard yearsAgo > 0 else { return nil }
            
            return Memory(
                post: post,
                memoryType: .onThisDay(yearsAgo: yearsAgo)
            )
        }
    }
    
    /// Generates "This Week Last Year" memories from a collection of posts
    static func generateThisWeekLastYearMemories(from posts: [Post]) -> [Memory] {
        let calendar = Calendar.current
        let today = Date()
        
        guard let lastYear = calendar.date(byAdding: .year, value: -1, to: today),
              let weekAgo = calendar.date(byAdding: .day, value: -7, to: lastYear),
              let weekLater = calendar.date(byAdding: .day, value: 7, to: lastYear) else {
            return []
        }
        
        return posts.compactMap { post -> Memory? in
            guard post.createdAt >= weekAgo && post.createdAt <= weekLater else {
                return nil
            }
            
            return Memory(
                post: post,
                memoryType: .thisWeekLastYear
            )
        }
    }
    
    /// Generates random throwback memories from old posts
    static func generateRandomThrowbacks(from posts: [Post], count: Int = 3) -> [Memory] {
        let calendar = Calendar.current
        let cutoffDate = calendar.date(byAdding: .month, value: -6, to: Date()) ?? Date()
        
        // Filter posts older than 6 months
        let oldPosts = posts.filter { $0.createdAt < cutoffDate }
        
        // Shuffle and take requested count
        let randomPosts = oldPosts.shuffled().prefix(count)
        
        return randomPosts.map { post in
            Memory(
                post: post,
                memoryType: .randomThrowback
            )
        }
    }
    
    /// Generates all daily memories (On This Day + This Week Last Year + Random)
    static func generateDailyMemories(from posts: [Post], maxRandom: Int = 2) -> [Memory] {
        var memories: [Memory] = []
        
        // Add "On This Day" memories
        memories.append(contentsOf: generateOnThisDayMemories(from: posts))
        
        // Add "This Week Last Year" memories
        memories.append(contentsOf: generateThisWeekLastYearMemories(from: posts))
        
        // Add random throwbacks (only if not too many other memories)
        if memories.count < 5 {
            let randomCount = min(maxRandom, 5 - memories.count)
            memories.append(contentsOf: generateRandomThrowbacks(from: posts, count: randomCount))
        }
        
        return memories
    }
}

// MARK: - Premium Limits

extension Memory {
    /// Free tier memory limit per day
    static let freeMemoryLimit = 5
    
    /// Returns true if memory count is within free tier limit
    static func isWithinFreeLimit(count: Int) -> Bool {
        count <= freeMemoryLimit
    }
}

// MARK: - Mock Data (for previews and testing)

#if DEBUG
extension Memory {
    static let mockOnThisDay1Year = Memory(
        post: Post(
            caption: "Started my new job today! So excited for this journey 🎉",
            mood: 9,
            createdAt: Calendar.current.date(byAdding: .year, value: -1, to: Date())!,
            personaId: Persona.mockPersonal.id,
            mediaItems: [MediaItem.mockPhoto],
            activityTags: ["work", "career"]
        ),
        memoryType: .onThisDay(yearsAgo: 1),
        wasViewed: false
    )
    
    static let mockOnThisDay3Years = Memory(
        post: Post(
            caption: "Beach day with friends! Life is good 🌊☀️",
            mood: 10,
            createdAt: Calendar.current.date(byAdding: .year, value: -3, to: Date())!,
            personaId: Persona.mockPersonal.id,
            mediaItems: [MediaItem.mockPhoto, MediaItem.mockPhoto2],
            activityTags: ["beach", "friends", "summer"],
            peopleTags: ["friends"]
        ),
        memoryType: .onThisDay(yearsAgo: 3),
        wasViewed: true,
        notes: "What a perfect day! Miss those times."
    )
    
    static let mockThisWeekLastYear = Memory(
        post: Post(
            caption: "First time trying rock climbing. My arms are so sore! 💪",
            mood: 7,
            createdAt: Calendar.current.date(byAdding: .day, value: -368, to: Date())!,
            personaId: Persona.mockFitness.id,
            mediaItems: [MediaItem.mockPhoto],
            activityTags: ["climbing", "fitness", "adventure"]
        ),
        memoryType: .thisWeekLastYear,
        wasViewed: false
    )
    
    static let mockRandomThrowback = Memory(
        post: Post(
            caption: "Cozy rainy Sunday with a good book ☕📖",
            mood: 8,
            createdAt: Calendar.current.date(byAdding: .month, value: -7, to: Date())!,
            personaId: Persona.mockPersonal.id,
            activityTags: ["reading", "relaxing"],
            postType: .text,
            
        ),
        memoryType: .randomThrowback,
        wasViewed: false
    )
    
    static let allMocks = [
        mockOnThisDay1Year,
        mockOnThisDay3Years,
        mockThisWeekLastYear,
        mockRandomThrowback
    ]
}
#endif
