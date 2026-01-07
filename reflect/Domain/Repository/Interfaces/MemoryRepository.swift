//
//  MemoryRepository.swift
//  reflect
//
//  Created on 12/11/25.
//

import Foundation

/// Protocol defining the contract for Memory data operations
/// Memories are generated from posts but their state (viewed, notes) is persisted
protocol MemoryRepository {
    // MARK: - CRUD Operations
    
    /// Creates a new memory
    /// - Parameter memory: The memory to create
    /// - Throws: Repository error if creation fails
    func create(_ memory: Memory) async throws
    
    /// Fetches a memory by ID
    /// - Parameter id: The unique identifier of the memory
    /// - Returns: The memory if found, nil otherwise
    /// - Throws: Repository error if fetch fails
    func fetch(id: UUID) async throws -> Memory?
    
    /// Updates an existing memory
    /// - Parameter memory: The memory with updated values
    /// - Throws: Repository error if update fails
    func update(_ memory: Memory) async throws
    
    /// Deletes a memory by ID
    /// - Parameter id: The unique identifier of the memory to delete
    /// - Throws: Repository error if deletion fails
    func delete(id: UUID) async throws
    
    // MARK: - Daily Memory Management
    
    /// Saves a batch of daily memories (generated from posts)
    /// - Parameter memories: Array of memories to save
    /// - Throws: Repository error if save fails
    func saveDailyMemories(_ memories: [Memory]) async throws
    
    /// Fetches today's memories
    /// - Returns: Array of memories presented today
    /// - Throws: Repository error if fetch fails
    func fetchTodaysMemories() async throws -> [Memory]
    
    /// Fetches memories for a specific date
    /// - Parameter date: The date to fetch memories for
    /// - Returns: Array of memories presented on that date
    /// - Throws: Repository error if fetch fails
    func fetchMemories(for date: Date) async throws -> [Memory]
    
    /// Checks if memories have been generated for today
    /// - Returns: True if today's memories already exist
    /// - Throws: Repository error if check fails
    func hasTodaysMemories() async throws -> Bool
    
    // MARK: - Memory State Updates
    
    /// Marks a memory as viewed by the user
    /// - Parameter memoryId: The memory identifier
    /// - Throws: Repository error if update fails
    func markAsViewed(memoryId: UUID) async throws
    
    /// Marks multiple memories as viewed
    /// - Parameter memoryIds: Array of memory identifiers
    /// - Throws: Repository error if update fails
    func markAsViewed(memoryIds: [UUID]) async throws
    
    /// Updates user notes for a memory
    /// - Parameters:
    ///   - memoryId: The memory identifier
    ///   - notes: The notes text to save
    /// - Throws: Repository error if update fails
    func updateNotes(
        for memoryId: UUID,
        notes: String?
    ) async throws
    
    // MARK: - Memory History Queries
    
    /// Fetches memories within a date range
    /// - Parameters:
    ///   - startDate: Start of the date range
    ///   - endDate: End of the date range
    /// - Returns: Array of memories in the date range
    /// - Throws: Repository error if fetch fails
    func fetchMemories(
        from startDate: Date,
        to endDate: Date
    ) async throws -> [Memory]
    
    /// Fetches all memories ever presented
    /// - Returns: Array of all memories
    /// - Throws: Repository error if fetch fails
    func fetchAllMemories() async throws -> [Memory]
    
    /// Fetches memories for a specific post
    /// - Parameter postId: The post identifier
    /// - Returns: Array of memories featuring this post
    /// - Throws: Repository error if fetch fails
    func fetchMemories(for postId: UUID) async throws -> [Memory]
    
    // MARK: - Memory Type Queries
    
    /// Fetches memories of a specific type
    /// - Parameter type: The memory type to filter by
    /// - Returns: Array of memories of that type
    /// - Throws: Repository error if fetch fails
    func fetchMemories(ofType type: Memory.MemoryType) async throws -> [Memory]
    
    /// Fetches "On This Day" memories
    /// - Returns: Array of all "On This Day" memories
    /// - Throws: Repository error if fetch fails
    func fetchOnThisDayMemories() async throws -> [Memory]
    
    /// Fetches "This Week Last Year" memories
    /// - Returns: Array of all "This Week Last Year" memories
    /// - Throws: Repository error if fetch fails
    func fetchThisWeekLastYearMemories() async throws -> [Memory]
    
    /// Fetches random throwback memories
    /// - Returns: Array of all random throwback memories
    /// - Throws: Repository error if fetch fails
    func fetchRandomThrowbackMemories() async throws -> [Memory]
    
    // MARK: - Viewed/Unviewed Queries
    
    /// Fetches unviewed memories
    /// - Returns: Array of memories not yet viewed by user
    /// - Throws: Repository error if fetch fails
    func fetchUnviewedMemories() async throws -> [Memory]
    
    /// Fetches viewed memories
    /// - Returns: Array of memories viewed by user
    /// - Throws: Repository error if fetch fails
    func fetchViewedMemories() async throws -> [Memory]
    
    /// Fetches unviewed memories for today
    /// - Returns: Array of today's unviewed memories
    /// - Throws: Repository error if fetch fails
    func fetchTodaysUnviewedMemories() async throws -> [Memory]
    
    /// Fetches memories with user notes
    /// - Returns: Array of memories that have notes added
    /// - Throws: Repository error if fetch fails
    func fetchMemoriesWithNotes() async throws -> [Memory]
    
    // MARK: - Statistics
    
    /// Fetches the total number of memories
    /// - Returns: Total memory count
    /// - Throws: Repository error if fetch fails
    func fetchMemoryCount() async throws -> Int
    
    /// Fetches the number of viewed memories
    /// - Returns: Count of memories viewed by user
    /// - Throws: Repository error if fetch fails
    func fetchViewedMemoryCount() async throws -> Int
    
    /// Fetches the number of memories with notes
    /// - Returns: Count of memories with user notes
    /// - Throws: Repository error if fetch fails
    func fetchMemoriesWithNotesCount() async throws -> Int
    
    /// Fetches memory engagement rate
    /// - Returns: Percentage of memories that were viewed (0.0 to 1.0)
    /// - Throws: Repository error if fetch fails
    func fetchEngagementRate() async throws -> Double
    
    /// Fetches count of memories by type
    /// - Returns: Dictionary mapping memory types to counts
    /// - Throws: Repository error if fetch fails
    func fetchMemoryCountsByType() async throws -> [String: Int]
    
    /// Fetches the most viewed memory years ago count
    /// (e.g., do users engage more with 1 year ago vs 3 years ago?)
    /// - Returns: Dictionary mapping years ago to view counts
    /// - Throws: Repository error if fetch fails
    func fetchEngagementByYearsAgo() async throws -> [Int: Int]
    
    // MARK: - Cleanup Operations
    
    /// Deletes memories older than a specified date
    /// - Parameter date: Memories before this date will be deleted
    /// - Returns: Number of memories deleted
    /// - Throws: Repository error if deletion fails
    func deleteMemories(olderThan date: Date) async throws -> Int
    
    /// Deletes all memories for a specific post
    /// (e.g., when a post is deleted)
    /// - Parameter postId: The post identifier
    /// - Throws: Repository error if deletion fails
    func deleteMemories(for postId: UUID) async throws
    
    /// Deletes all memories
    /// - Throws: Repository error if deletion fails
    func deleteAllMemories() async throws
    
    /// Deletes viewed memories older than a specified date
    /// (keep unviewed memories even if old)
    /// - Parameter date: Viewed memories before this date will be deleted
    /// - Returns: Number of memories deleted
    /// - Throws: Repository error if deletion fails
    func deleteViewedMemories(olderThan date: Date) async throws -> Int
    
    // MARK: - Batch Operations
    
    /// Creates multiple memories at once
    /// - Parameter memories: Array of memories to create
    /// - Throws: Repository error if creation fails
    func createBatch(_ memories: [Memory]) async throws
    
    /// Deletes multiple memories at once
    /// - Parameter ids: Array of memory IDs to delete
    /// - Throws: Repository error if deletion fails
    func deleteBatch(ids: [UUID]) async throws
    
    // MARK: - Memory Generation Support
    
    /// Checks if a post has already been presented as a memory today
    /// (to avoid showing the same post twice)
    /// - Parameters:
    ///   - postId: The post identifier
    ///   - date: The date to check (default: today)
    /// - Returns: True if the post was already shown as a memory on that date
    /// - Throws: Repository error if check fails
    func hasPostBeenPresentedAsMemory(
        postId: UUID,
        on date: Date
    ) async throws -> Bool
    
    /// Fetches post IDs that have already been presented as memories today
    /// - Returns: Set of post IDs shown as memories today
    /// - Throws: Repository error if fetch fails
    func fetchTodaysMemoryPostIds() async throws -> Set<UUID>
    
    /// Fetches the last date a post was shown as a memory
    /// - Parameter postId: The post identifier
    /// - Returns: The last presentation date, or nil if never shown
    /// - Throws: Repository error if fetch fails
    func fetchLastPresentationDate(for postId: UUID) async throws -> Date?
}

// MARK: - Memory Type Comparable Extension

extension Memory.MemoryType {
    /// Returns a string identifier for the memory type (for database storage)
    var identifier: String {
        switch self {
        case .onThisDay(let years):
            return "onThisDay_\(years)"
        case .thisWeekLastYear:
            return "thisWeekLastYear"
        case .randomThrowback:
            return "randomThrowback"
        }
    }
    
    /// Creates a MemoryType from a string identifier
    static func from(identifier: String) -> Memory.MemoryType? {
        if identifier.hasPrefix("onThisDay_") {
            let yearsString = identifier.replacingOccurrences(of: "onThisDay_", with: "")
            if let years = Int(yearsString) {
                return .onThisDay(yearsAgo: years)
            }
        }
        
        switch identifier {
        case "thisWeekLastYear":
            return .thisWeekLastYear
        case "randomThrowback":
            return .randomThrowback
        default:
            return nil
        }
    }
}
