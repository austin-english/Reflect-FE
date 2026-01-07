//
//  MediaItemRepositoryImpl.swift
//  reflect
//
//  Created by Austin English on 12/16/25.
//

import Foundation
import CoreData

/// Implementation of MediaItemRepository using Core Data
@MainActor
final class MediaItemRepositoryImpl: MediaItemRepository {
    
    // MARK: - Properties
    
    private let coreDataManager: CoreDataManager
    
    // MARK: - Initialization
    
    init(coreDataManager: CoreDataManager = .shared) {
        self.coreDataManager = coreDataManager
    }
    
    // MARK: - Basic CRUD Operations
    
    func create(_ mediaItem: MediaItem) async throws {
        let context = coreDataManager.viewContext
        let entity = try MediaItemEntity.create(from: mediaItem, context: context)
        
        // Link to post if exists
        if let postEntity = try await coreDataManager.fetchByID(PostEntity.self, id: mediaItem.postId) {
            entity.post = postEntity
        }
        
        try await coreDataManager.save()
    }
    
    func fetch(id: UUID) async throws -> MediaItem? {
        guard let entity = try await coreDataManager.fetchByID(MediaItemEntity.self, id: id) else {
            return nil
        }
        return try entity.toDomain()
    }
    
    func fetchAll() async throws -> [MediaItem] {
        let entities = try await coreDataManager.fetchAll(
            MediaItemEntity.self,
            sortDescriptors: [NSSortDescriptor(key: "createdAt", ascending: true)]
        )
        return try entities.toDomain()
    }
    
    func update(_ mediaItem: MediaItem) async throws {
        guard let entity = try await coreDataManager.fetchByID(MediaItemEntity.self, id: mediaItem.id) else {
            throw MediaItemRepositoryError.notFound
        }
        
        let context = coreDataManager.viewContext
        try entity.update(from: mediaItem, context: context)
        try await coreDataManager.save()
    }
    
    func delete(id: UUID) async throws {
        guard let entity = try await coreDataManager.fetchByID(MediaItemEntity.self, id: id) else {
            throw MediaItemRepositoryError.notFound
        }
        
        try await coreDataManager.delete(entity)
    }
    
    // MARK: - Query Operations
    
    func fetchMediaItems(for postId: UUID) async throws -> [MediaItem] {
        let request = MediaItemEntity.fetchRequest()
        request.predicate = NSPredicate(format: "post.id == %@", postId as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        
        let entities = try await coreDataManager.fetch(request)
        return try entities.toDomain()
    }
    
    func fetchPrimaryMediaItem(for postId: UUID) async throws -> MediaItem? {
        let items = try await fetchMediaItems(for: postId)
        return items.first
    }
    
    func fetchMediaItemCount(for postId: UUID) async throws -> Int {
        let request = MediaItemEntity.fetchRequest()
        request.predicate = NSPredicate(format: "post.id == %@", postId as CVarArg)
        return try await coreDataManager.count(request)
    }
    
    func deleteAllMediaItems(for postId: UUID) async throws {
        let predicate = NSPredicate(format: "post.id == %@", postId as CVarArg)
        try await coreDataManager.batchDelete(MediaItemEntity.self, predicate: predicate)
    }
    
    func fetchPhotos() async throws -> [MediaItem] {
        return try await fetchByType(.photo)
    }
    
    func fetchVideos() async throws -> [MediaItem] {
        return try await fetchByType(.video)
    }
    
    func fetchPhotos(for postId: UUID) async throws -> [MediaItem] {
        let items = try await fetchMediaItems(for: postId)
        return items.filter { $0.type == .photo }
    }
    
    func fetchVideos(for postId: UUID) async throws -> [MediaItem] {
        let items = try await fetchMediaItems(for: postId)
        return items.filter { $0.type == .video }
    }
    
    func fetchMediaItems(from startDate: Date, to endDate: Date) async throws -> [MediaItem] {
        let request = MediaItemEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "createdAt >= %@ AND createdAt <= %@",
            startDate as NSDate,
            endDate as NSDate
        )
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        let entities = try await coreDataManager.fetch(request)
        return try entities.toDomain()
    }
    
    func fetchMediaItems(on date: Date) async throws -> [MediaItem] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return try await fetchMediaItems(from: startOfDay, to: endOfDay)
    }
    
    // MARK: - Storage Statistics
    
    func fetchTotalStorageUsed() async throws -> Int64 {
        let request = MediaItemEntity.fetchRequest()
        let entities = try await coreDataManager.fetch(request)
        
        return entities.reduce(0) { $0 + $1.fileSize }
    }
    
    func fetchPhotoStorageUsed() async throws -> Int64 {
        let photos = try await fetchPhotos()
        return photos.reduce(0) { $0 + $1.fileSize }
    }
    
    func fetchVideoStorageUsed() async throws -> Int64 {
        let videos = try await fetchVideos()
        return videos.reduce(0) { $0 + $1.fileSize }
    }
    
    func fetchThumbnailStorageUsed() async throws -> Int64 {
        // Estimate: thumbnails are typically 50KB, count all items with thumbnails
        let allItems = try await fetchAll()
        let itemsWithThumbnails = allItems.filter { $0.thumbnailFilename != nil }
        return Int64(itemsWithThumbnails.count * 50_000) // 50KB estimate per thumbnail
    }
    
    func fetchLargestMediaItems(limit: Int) async throws -> [MediaItem] {
        let request = MediaItemEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "fileSize", ascending: false)]
        request.fetchLimit = limit
        
        let entities = try await coreDataManager.fetch(request)
        return try entities.toDomain()
    }
    
    // MARK: - Media Counts
    
    func fetchPhotoCount() async throws -> Int {
        let request = MediaItemEntity.fetchRequest()
        request.predicate = NSPredicate(format: "type == %@", MediaItem.MediaType.photo.rawValue)
        return try await coreDataManager.count(request)
    }
    
    func fetchVideoCount() async throws -> Int {
        let request = MediaItemEntity.fetchRequest()
        request.predicate = NSPredicate(format: "type == %@", MediaItem.MediaType.video.rawValue)
        return try await coreDataManager.count(request)
    }
    
    func fetchTotalMediaCount() async throws -> Int {
        let request = MediaItemEntity.fetchRequest()
        return try await coreDataManager.count(request)
    }
    
    // MARK: - Cleanup Operations
    
    func fetchOrphanedMediaItems() async throws -> [MediaItem] {
        let request = MediaItemEntity.fetchRequest()
        request.predicate = NSPredicate(format: "post == nil")
        
        let entities = try await coreDataManager.fetch(request)
        return try entities.toDomain()
    }
    
    func deleteOrphanedMediaItems() async throws -> Int {
        let orphaned = try await fetchOrphanedMediaItems()
        let count = orphaned.count
        
        if count > 0 {
            let request = MediaItemEntity.fetchRequest()
            request.predicate = NSPredicate(format: "post == nil")
            let entities = try await coreDataManager.fetch(request)
            try await coreDataManager.delete(entities)
        }
        
        return count
    }
    
    func fetchMediaItems(olderThan date: Date) async throws -> [MediaItem] {
        let request = MediaItemEntity.fetchRequest()
        request.predicate = NSPredicate(format: "createdAt < %@", date as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        
        let entities = try await coreDataManager.fetch(request)
        return try entities.toDomain()
    }
    
    func deleteMediaItems(olderThan date: Date) async throws -> Int {
        let oldItems = try await fetchMediaItems(olderThan: date)
        let count = oldItems.count
        
        if count > 0 {
            let predicate = NSPredicate(format: "createdAt < %@", date as NSDate)
            try await coreDataManager.batchDelete(MediaItemEntity.self, predicate: predicate)
        }
        
        return count
    }
    
    // MARK: - Batch Operations
    
    func createBatch(_ mediaItems: [MediaItem]) async throws {
        for mediaItem in mediaItems {
            try await create(mediaItem)
        }
    }
    
    func deleteBatch(ids: [UUID]) async throws {
        for id in ids {
            try await delete(id: id)
        }
    }
    
    // MARK: - File Management Integration
    
    func fetchAllFilenames() async throws -> Set<String> {
        let allItems = try await fetchAll()
        return Set(allItems.map { $0.filename })
    }
    
    func fetchAllThumbnailFilenames() async throws -> Set<String> {
        let allItems = try await fetchAll()
        return Set(allItems.compactMap { $0.thumbnailFilename })
    }
    
    func isFilenameInUse(_ filename: String) async throws -> Bool {
        let request = MediaItemEntity.fetchRequest()
        request.predicate = NSPredicate(format: "filename == %@ OR thumbnailFilename == %@", filename, filename)
        let count = try await coreDataManager.count(request)
        return count > 0
    }
    
    // MARK: - Private Helpers
    
    private func fetchByType(_ type: MediaItem.MediaType) async throws -> [MediaItem] {
        let request = MediaItemEntity.fetchRequest()
        request.predicate = NSPredicate(format: "type == %@", type.rawValue)
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        let entities = try await coreDataManager.fetch(request)
        return try entities.toDomain()
    }
}

// MARK: - Errors

enum MediaItemRepositoryError: LocalizedError {
    case notFound
    
    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Media item not found"
        }
    }
}
