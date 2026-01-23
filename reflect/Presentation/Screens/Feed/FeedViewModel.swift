//
//  FeedViewModel.swift
//  reflect
//
//  Created by Austin English on 1/22/26.
//

import SwiftUI
/// ViewModel for the main feed screen
@MainActor
@Observable
final class FeedViewModel {
    
    // MARK: - Dependencies
    
    private let postRepository: PostRepository
    private let personaRepository: PersonaRepository
    
    // MARK: - State
    
    /// All posts to display in the feed
    private(set) var posts: [Post] = []
    
    /// Available personas for filtering
    private(set) var personas: [Persona] = []
    
    /// Currently selected persona filter (nil = all personas)
    var selectedPersona: Persona?
    
    /// Loading state
    private(set) var isLoading = false
    
    /// Error message to display
    private(set) var errorMessage: String?
    
    /// Whether this is the initial load
    private var isInitialLoad = true
    
    // MARK: - Initialization
    
    init(
        postRepository: PostRepository,
        personaRepository: PersonaRepository
    ) {
        self.postRepository = postRepository
        self.personaRepository = personaRepository
    }
    
    // MARK: - Public Methods
    
    /// Load initial data (posts and personas)
    func loadInitialData() async {
        guard isInitialLoad else { return }
        isInitialLoad = false
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Load personas first
            personas = try await personaRepository.fetchAll()
            
            // Load posts
            await loadPosts()
        } catch {
            errorMessage = "Failed to load data: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Refresh posts (pull-to-refresh)
    func refresh() async {
        errorMessage = nil
        await loadPosts()
    }
    
    /// Load more posts (pagination - for future implementation)
    func loadMoreIfNeeded() async {
        // TODO: Implement pagination in future phase
        // For MVP, we load all posts at once
    }
    
    /// Delete a post
    func deletePost(_ post: Post) async {
        do {
            try await postRepository.delete(id: post.id)
            
            // Remove from local array
            posts.removeAll { $0.id == post.id }
        } catch {
            errorMessage = "Failed to delete post: \(error.localizedDescription)"
        }
    }
    
    /// Filter posts by selected persona
    func filterByPersona(_ persona: Persona?) {
        selectedPersona = persona
        Task {
            await loadPosts()
        }
    }
    
    /// Clear error message
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Private Methods
    
    /// Load posts from repository
    private func loadPosts() async {
        do {
            if let selectedPersona {
                // Filter by persona
                posts = try await postRepository.fetchPosts(for: selectedPersona.id, limit: nil, offset: nil)
            } else {
                // Load all posts
                posts = try await postRepository.fetchAll()
            }
            
            // Sort by date (most recent first)
            posts.sort { $0.createdAt > $1.createdAt }
        } catch {
            errorMessage = "Failed to load posts: \(error.localizedDescription)"
            posts = []
        }
    }
}


