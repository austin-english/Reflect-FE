//
//  PostRepository.swift
//  reflect
//
//  Created on 12/11/25.
//

import Foundation

/// Protocol defining the contract for Post data operations
/// Implementations will handle persistence details (Core Data, etc.)
protocol PostRepository {
    // MARK: - CRUD Operations
    
    /// Creates a new post
    /// - Parameter post: The post to create
    /// - Throws: Repository error if creation fails
    func create(_ post: Post) async throws
    
    /// Fetches a post by ID
    /// - Parameter id: The unique identifier of the post
    /// - Returns: The post if found, nil otherwise
    /// - Throws: Repository error if fetch fails
    func fetch(id: UUID) async throws -> Post?
    
    /// Fetches all posts
    /// - Returns: Array of all posts, ordered by creation date (newest first)
    /// - Throws: Repository error if fetch fails
    func fetchAll() async throws -> [Post]
    
    /// Updates an existing post
    /// - Parameter post: The post with updated values
    /// - Throws: Repository error if update fails
    func update(_ post: Post) async throws
    
    /// Deletes a post by ID
    /// - Parameter id: The unique identifier of the post to delete
    /// - Throws: Repository error if deletion fails
    func delete(id: UUID) async throws
    
    // MARK: - Filtered Queries
    
    /// Fetches posts for a specific persona
    /// - Parameters:
    ///   - personaId: The persona identifier
    ///   - limit: Optional maximum number of posts to return
    ///   - offset: Optional number of posts to skip (for pagination)
    /// - Returns: Array of posts for the persona
    /// - Throws: Repository error if fetch fails
    func fetchPosts(
        for personaId: UUID,
        limit: Int?,
        offset: Int?
    ) async throws -> [Post]
    
    /// Fetches posts within a date range
    /// - Parameters:
    ///   - startDate: Start of the date range (inclusive)
    ///   - endDate: End of the date range (inclusive)
    /// - Returns: Array of posts in the date range
    /// - Throws: Repository error if fetch fails
    func fetchPosts(
        from startDate: Date,
        to endDate: Date
    ) async throws -> [Post]
    
    /// Fetches posts with a specific mood value
    /// - Parameter mood: The mood value (1-10)
    /// - Returns: Array of posts with the specified mood
    /// - Throws: Repository error if fetch fails
    func fetchPosts(
        with mood: Int
    ) async throws -> [Post]
    
    /// Fetches posts with a mood in a specific range
    /// - Parameters:
    ///   - minMood: Minimum mood value (inclusive)
    ///   - maxMood: Maximum mood value (inclusive)
    /// - Returns: Array of posts within the mood range
    /// - Throws: Repository error if fetch fails
    func fetchPosts(
        withMoodBetween minMood: Int,
        and maxMood: Int
    ) async throws -> [Post]
    
    /// Fetches posts containing any of the specified tags
    /// - Parameter tags: Array of tag strings to search for
    /// - Returns: Array of posts containing at least one of the tags
    /// - Throws: Repository error if fetch fails
    func fetchPosts(
        containing tags: [String]
    ) async throws -> [Post]
    
    /// Fetches posts containing all of the specified tags
    /// - Parameter tags: Array of tag strings that must all be present
    /// - Returns: Array of posts containing all specified tags
    /// - Throws: Repository error if fetch fails
    func fetchPosts(
        containingAll tags: [String]
    ) async throws -> [Post]
    
    /// Fetches posts mentioning specific people
    /// - Parameter people: Array of people tags to search for
    /// - Returns: Array of posts mentioning the specified people
    /// - Throws: Repository error if fetch fails
    func fetchPosts(
        mentioning people: [String]
    ) async throws -> [Post]
    
    /// Fetches posts with media items
    /// - Returns: Array of posts that have at least one media item
    /// - Throws: Repository error if fetch fails
    func fetchPostsWithMedia() async throws -> [Post]
    
    /// Fetches posts without media items (text-only)
    /// - Returns: Array of posts with no media items
    /// - Throws: Repository error if fetch fails
    func fetchPostsWithoutMedia() async throws -> [Post]
    
    /// Fetches special posts (gratitude, rant, dream, future you)
    /// - Returns: Array of posts marked as special
    /// - Throws: Repository error if fetch fails
    func fetchSpecialPosts() async throws -> [Post]
    
    // MARK: - Search
    
    /// Searches posts by caption text
    /// - Parameter query: The search query string
    /// - Returns: Array of posts whose captions contain the query
    /// - Throws: Repository error if search fails
    func searchPosts(
        query: String
    ) async throws -> [Post]
    
    /// Advanced search with multiple criteria
    /// - Parameters:
    ///   - query: Optional text search query
    ///   - personaIds: Optional array of persona IDs to filter by
    ///   - moodRange: Optional mood range (min, max)
    ///   - dateRange: Optional date range (start, end)
    ///   - tags: Optional array of tags to filter by
    ///   - hasMedia: Optional filter for posts with/without media
    /// - Returns: Array of posts matching all specified criteria
    /// - Throws: Repository error if search fails
    func searchPosts(
        query: String?,
        personaIds: [UUID]?,
        moodRange: (min: Int, max: Int)?,
        dateRange: (start: Date, end: Date)?,
        tags: [String]?,
        hasMedia: Bool?
    ) async throws -> [Post]
    
    // MARK: - Memory Queries
    
    /// Fetches posts from the same date in previous years (for "On This Day")
    /// - Parameter date: The reference date
    /// - Returns: Array of posts from the same month/day in previous years
    /// - Throws: Repository error if fetch fails
    func fetchPostsOnThisDay(date: Date) async throws -> [Post]
    
    /// Fetches posts from a specific week in a previous year
    /// - Parameter date: The reference date
    /// - Returns: Array of posts from the same week last year
    /// - Throws: Repository error if fetch fails
    func fetchPostsFromThisWeekLastYear(date: Date) async throws -> [Post]
    
    /// Fetches random posts older than a specified date
    /// - Parameters:
    ///   - olderThan: Only return posts before this date
    ///   - count: Maximum number of posts to return
    /// - Returns: Array of random old posts
    /// - Throws: Repository error if fetch fails
    func fetchRandomOldPosts(
        olderThan date: Date,
        count: Int
    ) async throws -> [Post]
    
    // MARK: - Statistics
    
    /// Fetches the total number of posts
    /// - Returns: Total post count
    /// - Throws: Repository error if fetch fails
    func fetchPostCount() async throws -> Int
    
    /// Fetches the number of posts for a specific persona
    /// - Parameter personaId: The persona identifier
    /// - Returns: Post count for the persona
    /// - Throws: Repository error if fetch fails
    func fetchPostCount(for personaId: UUID) async throws -> Int
    
    /// Fetches the number of posts in a date range
    /// - Parameters:
    ///   - startDate: Start of the date range
    ///   - endDate: End of the date range
    /// - Returns: Post count in the date range
    /// - Throws: Repository error if fetch fails
    func fetchPostCount(
        from startDate: Date,
        to endDate: Date
    ) async throws -> Int
    
    /// Fetches average mood across all posts
    /// - Returns: Average mood value, or nil if no posts exist
    /// - Throws: Repository error if fetch fails
    func fetchAverageMood() async throws -> Double?
    
    /// Fetches average mood for a specific time period
    /// - Parameters:
    ///   - startDate: Start of the date range
    ///   - endDate: End of the date range
    /// - Returns: Average mood value in the date range, or nil if no posts
    /// - Throws: Repository error if fetch fails
    func fetchAverageMood(
        from startDate: Date,
        to endDate: Date
    ) async throws -> Double?
    
    /// Fetches mood distribution (count of posts per mood value)
    /// - Returns: Dictionary mapping mood values (1-10) to post counts
    /// - Throws: Repository error if fetch fails
    func fetchMoodDistribution() async throws -> [Int: Int]
    
    /// Fetches the most used activity tags
    /// - Parameter limit: Maximum number of tags to return
    /// - Returns: Array of (tag, count) tuples, sorted by frequency
    /// - Throws: Repository error if fetch fails
    func fetchMostUsedTags(limit: Int) async throws -> [(tag: String, count: Int)]
    
    /// Fetches the most mentioned people
    /// - Parameter limit: Maximum number of people to return
    /// - Returns: Array of (person, count) tuples, sorted by frequency
    /// - Throws: Repository error if fetch fails
    func fetchMostMentionedPeople(limit: Int) async throws -> [(person: String, count: Int)]
    
    // MARK: - Streak Calculations
    
    /// Fetches dates when posts were created (for streak calculation)
    /// - Returns: Array of unique dates (day precision) with posts
    /// - Throws: Repository error if fetch fails
    func fetchPostingDates() async throws -> [Date]
    
    /// Fetches the first post date
    /// - Returns: The creation date of the earliest post, or nil if no posts
    /// - Throws: Repository error if fetch fails
    func fetchFirstPostDate() async throws -> Date?
    
    /// Fetches the most recent post date
    /// - Returns: The creation date of the most recent post, or nil if no posts
    /// - Throws: Repository error if fetch fails
    func fetchMostRecentPostDate() async throws -> Date?
    
    // MARK: - Batch Operations
    
    /// Deletes multiple posts at once
    /// - Parameter ids: Array of post IDs to delete
    /// - Throws: Repository error if deletion fails
    func deletePosts(ids: [UUID]) async throws
    
    /// Deletes all posts for a specific persona
    /// - Parameter personaId: The persona identifier
    /// - Throws: Repository error if deletion fails
    func deleteAllPosts(for personaId: UUID) async throws
    
    /// Deletes all posts older than a specified date
    /// - Parameter date: Posts before this date will be deleted
    /// - Returns: Number of posts deleted
    /// - Throws: Repository error if deletion fails
    func deleteAllPosts(olderThan date: Date) async throws -> Int
}

// No shared RepositoryError enum needed - each implementation has its own

