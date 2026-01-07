//
//  MediaItemRepository.swift
//  reflect
//
//  Created on 12/11/25.
//

import Foundation

/// Protocol defining the contract for MediaItem data operations
/// Implementations will handle persistence details (Core Data, etc.)
protocol MediaItemRepository {
    // MARK: - CRUD Operations
    
    /// Creates a new media item
    /// - Parameter mediaItem: The media item to create
    /// - Throws: Repository error if creation fails
    func create(_ mediaItem: MediaItem) async throws
    
    /// Fetches a media item by ID
    /// - Parameter id: The unique identifier of the media item
    /// - Returns: The media item if found, nil otherwise
    /// - Throws: Repository error if fetch fails
    func fetch(id: UUID) async throws -> MediaItem?
    
    /// Fetches all media items
    /// - Returns: Array of all media items
    /// - Throws: Repository error if fetch fails
    func fetchAll() async throws -> [MediaItem]
    
    /// Updates an existing media item
    /// - Parameter mediaItem: The media item with updated values
    /// - Throws: Repository error if update fails
    func update(_ mediaItem: MediaItem) async throws
    
    /// Deletes a media item by ID
    /// - Parameter id: The unique identifier of the media item to delete
    /// - Throws: Repository error if deletion fails
    func delete(id: UUID) async throws
    
    // MARK: - Post-Specific Queries
    
    /// Fetches all media items for a specific post
    /// - Parameter postId: The post identifier
    /// - Returns: Array of media items belonging to the post
    /// - Throws: Repository error if fetch fails
    func fetchMediaItems(for postId: UUID) async throws -> [MediaItem]
    
    /// Fetches the primary (first) media item for a post
    /// - Parameter postId: The post identifier
    /// - Returns: The first media item, or nil if post has no media
    /// - Throws: Repository error if fetch fails
    func fetchPrimaryMediaItem(for postId: UUID) async throws -> MediaItem?
    
    /// Fetches the number of media items for a post
    /// - Parameter postId: The post identifier
    /// - Returns: Count of media items
    /// - Throws: Repository error if fetch fails
    func fetchMediaItemCount(for postId: UUID) async throws -> Int
    
    /// Deletes all media items for a specific post
    /// - Parameter postId: The post identifier
    /// - Throws: Repository error if deletion fails
    func deleteAllMediaItems(for postId: UUID) async throws
    
    // MARK: - Type-Specific Queries
    
    /// Fetches all photos
    /// - Returns: Array of photo media items
    /// - Throws: Repository error if fetch fails
    func fetchPhotos() async throws -> [MediaItem]
    
    /// Fetches all videos
    /// - Returns: Array of video media items
    /// - Throws: Repository error if fetch fails
    func fetchVideos() async throws -> [MediaItem]
    
    /// Fetches photos for a specific post
    /// - Parameter postId: The post identifier
    /// - Returns: Array of photo media items for the post
    /// - Throws: Repository error if fetch fails
    func fetchPhotos(for postId: UUID) async throws -> [MediaItem]
    
    /// Fetches videos for a specific post
    /// - Parameter postId: The post identifier
    /// - Returns: Array of video media items for the post
    /// - Throws: Repository error if fetch fails
    func fetchVideos(for postId: UUID) async throws -> [MediaItem]
    
    // MARK: - Date Queries
    
    /// Fetches media items created within a date range
    /// - Parameters:
    ///   - startDate: Start of the date range
    ///   - endDate: End of the date range
    /// - Returns: Array of media items in the date range
    /// - Throws: Repository error if fetch fails
    func fetchMediaItems(
        from startDate: Date,
        to endDate: Date
    ) async throws -> [MediaItem]
    
    /// Fetches media items created on a specific date
    /// - Parameter date: The date to filter by
    /// - Returns: Array of media items created on that date
    /// - Throws: Repository error if fetch fails
    func fetchMediaItems(on date: Date) async throws -> [MediaItem]
    
    // MARK: - Storage Statistics
    
    /// Fetches total storage used by all media items
    /// - Returns: Total size in bytes
    /// - Throws: Repository error if fetch fails
    func fetchTotalStorageUsed() async throws -> Int64
    
    /// Fetches storage used by photos
    /// - Returns: Total photo storage in bytes
    /// - Throws: Repository error if fetch fails
    func fetchPhotoStorageUsed() async throws -> Int64
    
    /// Fetches storage used by videos
    /// - Returns: Total video storage in bytes
    /// - Throws: Repository error if fetch fails
    func fetchVideoStorageUsed() async throws -> Int64
    
    /// Fetches storage used by thumbnails
    /// - Returns: Total thumbnail storage in bytes
    /// - Throws: Repository error if fetch fails
    func fetchThumbnailStorageUsed() async throws -> Int64
    
    /// Fetches the largest media items
    /// - Parameter limit: Maximum number of items to return
    /// - Returns: Array of largest media items, sorted by size descending
    /// - Throws: Repository error if fetch fails
    func fetchLargestMediaItems(limit: Int) async throws -> [MediaItem]
    
    // MARK: - Media Counts
    
    /// Fetches total number of photos
    /// - Returns: Count of photo media items
    /// - Throws: Repository error if fetch fails
    func fetchPhotoCount() async throws -> Int
    
    /// Fetches total number of videos
    /// - Returns: Count of video media items
    /// - Throws: Repository error if fetch fails
    func fetchVideoCount() async throws -> Int
    
    /// Fetches total number of all media items
    /// - Returns: Total count of media items
    /// - Throws: Repository error if fetch fails
    func fetchTotalMediaCount() async throws -> Int
    
    // MARK: - Cleanup Operations
    
    /// Fetches orphaned media items (not attached to any post)
    /// - Returns: Array of media items with no post reference
    /// - Throws: Repository error if fetch fails
    func fetchOrphanedMediaItems() async throws -> [MediaItem]
    
    /// Deletes orphaned media items
    /// - Returns: Number of items deleted
    /// - Throws: Repository error if deletion fails
    func deleteOrphanedMediaItems() async throws -> Int
    
    /// Fetches media items older than a specified date
    /// - Parameter date: Media items before this date
    /// - Returns: Array of old media items
    /// - Throws: Repository error if fetch fails
    func fetchMediaItems(olderThan date: Date) async throws -> [MediaItem]
    
    /// Deletes media items older than a specified date
    /// - Parameter date: Delete media items before this date
    /// - Returns: Number of items deleted
    /// - Throws: Repository error if deletion fails
    func deleteMediaItems(olderThan date: Date) async throws -> Int
    
    // MARK: - Batch Operations
    
    /// Creates multiple media items at once
    /// - Parameter mediaItems: Array of media items to create
    /// - Throws: Repository error if creation fails
    func createBatch(_ mediaItems: [MediaItem]) async throws
    
    /// Deletes multiple media items at once
    /// - Parameter ids: Array of media item IDs to delete
    /// - Throws: Repository error if deletion fails
    func deleteBatch(ids: [UUID]) async throws
    
    // MARK: - File Management Integration
    
    /// Fetches all unique filenames (for file system cleanup)
    /// - Returns: Set of all media filenames
    /// - Throws: Repository error if fetch fails
    func fetchAllFilenames() async throws -> Set<String>
    
    /// Fetches all unique thumbnail filenames
    /// - Returns: Set of all thumbnail filenames
    /// - Throws: Repository error if fetch fails
    func fetchAllThumbnailFilenames() async throws -> Set<String>
    
    /// Checks if a filename is in use
    /// - Parameter filename: The filename to check
    /// - Returns: True if the filename exists in the database
    /// - Throws: Repository error if check fails
    func isFilenameInUse(_ filename: String) async throws -> Bool
}
