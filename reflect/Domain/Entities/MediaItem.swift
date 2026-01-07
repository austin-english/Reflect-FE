//
//  MediaItem.swift
//  reflect
//
//  Created by Austin English on 12/4/25.
//

import Foundation

/// Domain entity representing a photo or video attached to a post
struct MediaItem: Identifiable, Codable {
    // MARK: - Properties
    
    let id: UUID
    var type: MediaType
    var filename: String // Original file stored locally
    var thumbnailFilename: String? // Compressed thumbnail
    var createdAt: Date
    var fileSize: Int64 // Size in bytes
    
    // MARK: - Relationships
    
    var postId: UUID // Reference to Post
    
    // MARK: - Media Metadata
    
    var width: Int?
    var height: Int?
    var duration: TimeInterval? // For videos
    
    // MARK: - Initialization
    
    init(
        id: UUID = UUID(),
        type: MediaType,
        filename: String,
        thumbnailFilename: String? = nil,
        createdAt: Date = Date(),
        fileSize: Int64,
        postId: UUID,
        width: Int? = nil,
        height: Int? = nil,
        duration: TimeInterval? = nil
    ) {
        self.id = id
        self.type = type
        self.filename = filename
        self.thumbnailFilename = thumbnailFilename
        self.createdAt = createdAt
        self.fileSize = fileSize
        self.postId = postId
        self.width = width
        self.height = height
        self.duration = duration
    }
}

// MARK: - Media Type

extension MediaItem {
    enum MediaType: String, Codable {
        case photo
        case video
        
        var displayName: String {
            rawValue.capitalized
        }
        
        var symbolName: String {
            switch self {
            case .photo: return "photo.fill"
            case .video: return "video.fill"
            }
        }
    }
}

// MARK: - Computed Properties

extension MediaItem {
    /// Returns true if this is a photo
    var isPhoto: Bool {
        type == .photo
    }
    
    /// Returns true if this is a video
    var isVideo: Bool {
        type == .video
    }
    
    /// Returns file size formatted as human-readable string
    var fileSizeFormatted: String {
        ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
    }
    
    /// Returns aspect ratio if dimensions are available
    var aspectRatio: CGFloat? {
        guard let width = width, let height = height, height > 0 else {
            return nil
        }
        return CGFloat(width) / CGFloat(height)
    }
    
    /// Returns true if media is landscape orientation
    var isLandscape: Bool {
        guard let ratio = aspectRatio else { return false }
        return ratio > 1.0
    }
    
    /// Returns true if media is portrait orientation
    var isPortrait: Bool {
        guard let ratio = aspectRatio else { return false }
        return ratio < 1.0
    }
    
    /// Returns true if media is square
    var isSquare: Bool {
        guard let ratio = aspectRatio else { return false }
        return abs(ratio - 1.0) < 0.01
    }
    
    /// Returns duration formatted as string (MM:SS) for videos
    var durationFormatted: String? {
        guard let duration = duration else { return nil }
        
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - File Management

extension MediaItem {
    /// Returns the full file URL for this media item
    func fileURL(in directory: URL) -> URL {
        directory.appendingPathComponent(filename)
    }
    
    /// Returns the full file URL for the thumbnail
    func thumbnailURL(in directory: URL) -> URL? {
        guard let thumbnailFilename = thumbnailFilename else { return nil }
        return directory.appendingPathComponent(thumbnailFilename)
    }
    
    /// Generates a unique filename with appropriate extension
    static func generateFilename(for type: MediaType) -> String {
        let uuid = UUID().uuidString
        let ext = type == .photo ? "jpg" : "mp4"
        return "\(uuid).\(ext)"
    }
    
    /// Generates a thumbnail filename based on original filename
    static func generateThumbnailFilename(from filename: String) -> String {
        let components = filename.split(separator: ".")
        if components.count > 1 {
            let name = components.dropLast().joined(separator: ".")
            let ext = components.last!
            return "\(name)_thumb.\(ext)"
        }
        return "\(filename)_thumb"
    }
}

// MARK: - Size Constraints

extension MediaItem {
    /// Maximum file size for free tier (10 MB per media item)
    static let maxFileSizeFree: Int64 = 10_485_760
    
    /// Maximum file size for premium tier (100 MB per media item)
    static let maxFileSizePremium: Int64 = 104_857_600
    
    /// Maximum video duration for free tier (60 seconds)
    static let maxVideoDurationFree: TimeInterval = 60
    
    /// Maximum video duration for premium tier (10 minutes)
    static let maxVideoDurationPremium: TimeInterval = 600
    
    /// Returns true if file size is within free tier limits
    var isWithinFreeTierSize: Bool {
        fileSize <= MediaItem.maxFileSizeFree
    }
    
    /// Returns true if file size is within premium tier limits
    var isWithinPremiumTierSize: Bool {
        fileSize <= MediaItem.maxFileSizePremium
    }
    
    /// Returns true if video duration is within free tier limits
    var isWithinFreeTierDuration: Bool {
        guard let duration = duration else { return true }
        return duration <= MediaItem.maxVideoDurationFree
    }
    
    /// Returns true if video duration is within premium tier limits
    var isWithinPremiumTierDuration: Bool {
        guard let duration = duration else { return true }
        return duration <= MediaItem.maxVideoDurationPremium
    }
    
    /// Validates media item for given premium status
    func isValid(isPremium: Bool) -> Bool {
        let sizeLimit = isPremium ? MediaItem.maxFileSizePremium : MediaItem.maxFileSizeFree
        let durationLimit = isPremium ? MediaItem.maxVideoDurationPremium : MediaItem.maxVideoDurationFree
        
        guard fileSize <= sizeLimit else { return false }
        
        if let duration = duration {
            return duration <= durationLimit
        }
        
        return true
    }
}

// MARK: - Mock Data (for previews and testing)

#if DEBUG
extension MediaItem {
    static let mockPhoto = MediaItem(
        type: .photo,
        filename: "mock-photo-1.jpg",
        thumbnailFilename: "mock-photo-1_thumb.jpg",
        fileSize: 2_500_000, // 2.5 MB
        postId: UUID(),
        width: 1920,
        height: 1080
    )
    
    static let mockPhoto2 = MediaItem(
        type: .photo,
        filename: "mock-photo-2.jpg",
        thumbnailFilename: "mock-photo-2_thumb.jpg",
        fileSize: 3_200_000, // 3.2 MB
        postId: UUID(),
        width: 1080,
        height: 1920
    )
    
    static let mockPhoto3 = MediaItem(
        type: .photo,
        filename: "mock-photo-3.jpg",
        thumbnailFilename: "mock-photo-3_thumb.jpg",
        fileSize: 1_800_000, // 1.8 MB
        postId: UUID(),
        width: 1920,
        height: 1080
    )
    
    static let mockVideo = MediaItem(
        type: .video,
        filename: "mock-video-1.mp4",
        thumbnailFilename: "mock-video-1_thumb.jpg",
        fileSize: 8_500_000, // 8.5 MB
        postId: UUID(),
        width: 1920,
        height: 1080,
        duration: 45.5
    )
    
    static let mockSquarePhoto = MediaItem(
        type: .photo,
        filename: "mock-square-photo.jpg",
        thumbnailFilename: "mock-square-photo_thumb.jpg",
        fileSize: 2_000_000, // 2 MB
        postId: UUID(),
        width: 1080,
        height: 1080
    )
    
    static let mockPortraitPhoto = MediaItem(
        type: .photo,
        filename: "mock-portrait-photo.jpg",
        thumbnailFilename: "mock-portrait-photo_thumb.jpg",
        fileSize: 2_700_000, // 2.7 MB
        postId: UUID(),
        width: 1080,
        height: 1920
    )
}
#endif
