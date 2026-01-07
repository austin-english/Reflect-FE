//
//  PostRepositoryImpl.swift
//  reflect
//
//  Created by Austin English on 12/16/25.
//

import Foundation
import CoreData

/// Implementation of PostRepository using Core Data
@MainActor
final class PostRepositoryImpl: PostRepository {
    
    // MARK: - Properties
    
    private let coreDataManager: CoreDataManager
    
    // MARK: - Initialization
    
    init(coreDataManager: CoreDataManager = .shared) {
        self.coreDataManager = coreDataManager
    }
    
    // MARK: - Basic CRUD Operations
    
    func create(_ post: Post) async throws {
        let context = coreDataManager.viewContext
        
        // Fetch the persona entity
        guard let personaEntity = try await coreDataManager.fetchByID(PersonaEntity.self, id: post.personaId) else {
            throw PostRepositoryError.personaNotFound
        }
        
        // Create the post entity
        let postEntity = try PostEntity.create(from: post, context: context)
        postEntity.persona = personaEntity
        
        // Create media item entities if any
        for mediaItem in post.mediaItems {
            let mediaEntity = try MediaItemEntity.create(from: mediaItem, context: context)
            mediaEntity.post = postEntity
        }
        
        try await coreDataManager.save()
    }
    
    func fetch(id: UUID) async throws -> Post? {
        guard let entity = try await coreDataManager.fetchByID(PostEntity.self, id: id) else {
            return nil
        }
        return try entity.toDomain()
    }
    
    func fetchAll() async throws -> [Post] {
        return try await fetchAllPosts()
    }
    
    func update(_ post: Post) async throws {
        guard let entity = try await coreDataManager.fetchByID(PostEntity.self, id: post.id) else {
            throw PostRepositoryError.notFound
        }
        
        // Fetch the persona entity if it changed
        if entity.persona?.id != post.personaId {
            guard let personaEntity = try await coreDataManager.fetchByID(PersonaEntity.self, id: post.personaId) else {
                throw PostRepositoryError.personaNotFound
            }
            entity.persona = personaEntity
        }
        
        let context = coreDataManager.viewContext
        try entity.update(from: post, context: context)
        try await coreDataManager.save()
    }
    
    func delete(id: UUID) async throws {
        guard let entity = try await coreDataManager.fetchByID(PostEntity.self, id: id) else {
            throw PostRepositoryError.notFound
        }
        
        try await coreDataManager.delete(entity)
    }
    
    // MARK: - Query Operations
    
    func fetchPosts(for personaId: UUID, limit: Int?, offset: Int?) async throws -> [Post] {
        let request = PostEntity.fetchRequest()
        request.predicate = NSPredicate(format: "persona.id == %@", personaId as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        if let limit = limit {
            request.fetchLimit = limit
        }
        if let offset = offset {
            request.fetchOffset = offset
        }
        
        let entities = try await coreDataManager.fetch(request)
        return try entities.toDomain()
    }
    
    func fetchPosts(from startDate: Date, to endDate: Date) async throws -> [Post] {
        let request = PostEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "createdAt >= %@ AND createdAt <= %@",
            startDate as NSDate,
            endDate as NSDate
        )
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        let entities = try await coreDataManager.fetch(request)
        return try entities.toDomain()
    }
    
    func fetchPosts(with mood: Int) async throws -> [Post] {
        let request = PostEntity.fetchRequest()
        request.predicate = NSPredicate(format: "mood == %d", mood)
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        let entities = try await coreDataManager.fetch(request)
        return try entities.toDomain()
    }
    
    func fetchPosts(withMoodBetween minMood: Int, and maxMood: Int) async throws -> [Post] {
        let request = PostEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "mood >= %d AND mood <= %d",
            minMood,
            maxMood
        )
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        let entities = try await coreDataManager.fetch(request)
        return try entities.toDomain()
    }
    
    // MARK: - Search Operations
    
    func searchPosts(query: String) async throws -> [Post] {
        let request = PostEntity.fetchRequest()
        request.predicate = NSPredicate(format: "caption CONTAINS[cd] %@", query)
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        let entities = try await coreDataManager.fetch(request)
        return try entities.toDomain()
    }
    
    func searchPosts(
        query: String?,
        personaIds: [UUID]?,
        moodRange: (min: Int, max: Int)?,
        dateRange: (start: Date, end: Date)?,
        tags: [String]?,
        hasMedia: Bool?
    ) async throws -> [Post] {
        var allPosts = try await fetchAllPosts()
        
        // Apply text query filter
        if let query = query, !query.isEmpty {
            allPosts = allPosts.filter { $0.caption.localizedCaseInsensitiveContains(query) }
        }
        
        // Apply persona filter
        if let personaIds = personaIds, !personaIds.isEmpty {
            allPosts = allPosts.filter { personaIds.contains($0.personaId) }
        }
        
        // Apply mood range filter
        if let moodRange = moodRange {
            allPosts = allPosts.filter { $0.mood >= moodRange.min && $0.mood <= moodRange.max }
        }
        
        // Apply date range filter
        if let dateRange = dateRange {
            allPosts = allPosts.filter {
                $0.createdAt >= dateRange.start && $0.createdAt <= dateRange.end
            }
        }
        
        // Apply tags filter
        if let tags = tags, !tags.isEmpty {
            allPosts = allPosts.filter { post in
                let allTags = Set(post.activityTags + post.peopleTags)
                return !Set(tags).intersection(allTags).isEmpty
            }
        }
        
        // Apply media filter
        if let hasMedia = hasMedia {
            allPosts = allPosts.filter { post in
                hasMedia ? !post.mediaItems.isEmpty : post.mediaItems.isEmpty
            }
        }
        
        return allPosts
    }
    
    func fetchPosts(containing tags: [String]) async throws -> [Post] {
        // Fetch all and filter in memory
        let allPosts = try await fetchAllPosts()
        
        return allPosts.filter { post in
            let allTags = post.activityTags + post.peopleTags
            return !Set(tags).intersection(Set(allTags)).isEmpty
        }
    }
    
    func fetchPosts(containingAll tags: [String]) async throws -> [Post] {
        let allPosts = try await fetchAllPosts()
        
        return allPosts.filter { post in
            let allTags = Set(post.activityTags + post.peopleTags)
            return Set(tags).isSubset(of: allTags)
        }
    }
    
    func fetchPosts(mentioning people: [String]) async throws -> [Post] {
        let allPosts = try await fetchAllPosts()
        
        return allPosts.filter { post in
            let peopleTags = Set(post.peopleTags)
            return !Set(people).intersection(peopleTags).isEmpty
        }
    }
    
    func fetchPostsWithMedia() async throws -> [Post] {
        let allPosts = try await fetchAllPosts()
        return allPosts.filter { !$0.mediaItems.isEmpty }
    }
    
    func fetchPostsWithoutMedia() async throws -> [Post] {
        let allPosts = try await fetchAllPosts()
        return allPosts.filter { $0.mediaItems.isEmpty }
    }
    
    func fetchSpecialPosts() async throws -> [Post] {
        let allPosts = try await fetchAllPosts()
        return allPosts.filter {
            $0.isGratitude || $0.isRant || $0.isDream || $0.isFutureYou
        }
    }
    
    // MARK: - Private Helpers
    
    private func fetchAllPosts() async throws -> [Post] {
        let entities = try await coreDataManager.fetchAll(
            PostEntity.self,
            sortDescriptors: [NSSortDescriptor(key: "createdAt", ascending: false)]
        )
        return try entities.toDomain()
    }
    
    // MARK: - Memory Operations
    
    func fetchPostsOnThisDay(date: Date) async throws -> [Post] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month, .day], from: date)
        
        guard let month = components.month, let day = components.day else {
            return []
        }
        
        // Fetch all posts
        let allPosts = try await fetchAllPosts()
        
        // Filter for same month/day, different year
        let currentYear = calendar.component(.year, from: date)
        return allPosts.filter { post in
            let postComponents = calendar.dateComponents([.year, .month, .day], from: post.createdAt)
            guard let postYear = postComponents.year,
                  let postMonth = postComponents.month,
                  let postDay = postComponents.day else {
                return false
            }
            
            return postMonth == month && postDay == day && postYear != currentYear
        }
    }
    
    func fetchPostsFromThisWeekLastYear(date: Date) async throws -> [Post] {
        let calendar = Calendar.current
        
        // Get the week of year for the reference date
        guard let weekOfYear = calendar.dateComponents([.weekOfYear], from: date).weekOfYear else {
            return []
        }
        
        // Calculate last year
        guard let lastYear = calendar.date(byAdding: .year, value: -1, to: date) else {
            return []
        }
        
        let lastYearYear = calendar.component(.year, from: lastYear)
        
        // Fetch all posts
        let allPosts = try await fetchAllPosts()
        
        // Filter for same week last year
        return allPosts.filter { post in
            let postComponents = calendar.dateComponents([.year, .weekOfYear], from: post.createdAt)
            guard let postYear = postComponents.year,
                  let postWeek = postComponents.weekOfYear else {
                return false
            }
            
            return postYear == lastYearYear && postWeek == weekOfYear
        }
    }
    
    func fetchRandomOldPosts(olderThan date: Date, count: Int) async throws -> [Post] {
        let allPosts = try await fetchAllPosts()
        let oldPosts = allPosts.filter { $0.createdAt < date }
        
        // Shuffle and take requested count
        return Array(oldPosts.shuffled().prefix(count))
    }
    
    // MARK: - Statistics Operations
    
    func fetchMoodDistribution() async throws -> [Int: Int] {
        let posts = try await fetchAllPosts()
        
        var distribution: [Int: Int] = [:]
        for post in posts {
            distribution[post.mood, default: 0] += 1
        }
        
        return distribution
    }
    
    func fetchAverageMood() async throws -> Double? {
        let posts = try await fetchAllPosts()
        guard !posts.isEmpty else { return nil }
        
        let totalMood = posts.reduce(0) { $0 + $1.mood }
        return Double(totalMood) / Double(posts.count)
    }
    
    func fetchAverageMood(from startDate: Date, to endDate: Date) async throws -> Double? {
        let posts = try await fetchPosts(from: startDate, to: endDate)
        guard !posts.isEmpty else { return nil }
        
        let totalMood = posts.reduce(0) { $0 + $1.mood }
        return Double(totalMood) / Double(posts.count)
    }
    
    func fetchPostCount() async throws -> Int {
        let request = PostEntity.fetchRequest()
        return try await coreDataManager.count(request)
    }
    
    func fetchPostCount(for personaId: UUID) async throws -> Int {
        let request = PostEntity.fetchRequest()
        request.predicate = NSPredicate(format: "persona.id == %@", personaId as CVarArg)
        return try await coreDataManager.count(request)
    }
    
    func fetchPostCount(from startDate: Date, to endDate: Date) async throws -> Int {
        let request = PostEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "createdAt >= %@ AND createdAt <= %@",
            startDate as NSDate,
            endDate as NSDate
        )
        return try await coreDataManager.count(request)
    }
    
    func fetchPostingDates() async throws -> [Date] {
        let posts = try await fetchAllPosts()
        return posts.map { Calendar.current.startOfDay(for: $0.createdAt) }
    }
    
    func fetchMostUsedTags(limit: Int) async throws -> [(tag: String, count: Int)] {
        let posts = try await fetchAllPosts()
        
        var tagCounts: [String: Int] = [:]
        for post in posts {
            for tag in post.activityTags + post.peopleTags {
                tagCounts[tag, default: 0] += 1
            }
        }
        
        return tagCounts
            .sorted { $0.value > $1.value }
            .prefix(limit)
            .map { (tag: $0.key, count: $0.value) }
    }
    
    func fetchMostMentionedPeople(limit: Int) async throws -> [(person: String, count: Int)] {
        let posts = try await fetchAllPosts()
        
        var peopleCounts: [String: Int] = [:]
        for post in posts {
            for person in post.peopleTags {
                peopleCounts[person, default: 0] += 1
            }
        }
        
        return peopleCounts
            .sorted { $0.value > $1.value }
            .prefix(limit)
            .map { (person: $0.key, count: $0.value) }
    }
    
    func fetchFirstPostDate() async throws -> Date? {
        let posts = try await fetchAllPosts()
        return posts.map { $0.createdAt }.min()
    }
    
    func fetchMostRecentPostDate() async throws -> Date? {
        let posts = try await fetchAllPosts()
        return posts.map { $0.createdAt }.max()
    }
    
    // MARK: - Batch Operations
    
    func deletePosts(ids: [UUID]) async throws {
        for id in ids {
            guard let entity = try await coreDataManager.fetchByID(PostEntity.self, id: id) else {
                continue // Skip if not found
            }
            try await coreDataManager.delete(entity)
        }
    }
    
    func deleteAllPosts(for personaId: UUID) async throws {
        let predicate = NSPredicate(format: "persona.id == %@", personaId as CVarArg)
        try await coreDataManager.batchDelete(PostEntity.self, predicate: predicate)
    }
    
    func deleteAllPosts(olderThan date: Date) async throws -> Int {
        // Fetch posts to count them first
        let request = PostEntity.fetchRequest()
        request.predicate = NSPredicate(format: "createdAt < %@", date as NSDate)
        let postsToDelete = try await coreDataManager.fetch(request)
        let count = postsToDelete.count
        
        // Perform batch delete
        let predicate = NSPredicate(format: "createdAt < %@", date as NSDate)
        try await coreDataManager.batchDelete(PostEntity.self, predicate: predicate)
        
        return count
    }
}

// MARK: - Repository Errors

enum PostRepositoryError: LocalizedError {
    case notFound
    case personaNotFound
    case invalidData
    case saveFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Post not found"
        case .personaNotFound:
            return "Persona not found for post"
        case .invalidData:
            return "Invalid post data provided"
        case .saveFailed(let error):
            return "Failed to save post: \(error.localizedDescription)"
        }
    }
}
