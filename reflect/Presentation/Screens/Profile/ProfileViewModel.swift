//
//  ProfileViewModel.swift
//  reflect
//
//  Created by Austin English on 1/27/26.
//

import Foundation
import Observation

/// ViewModel for the Profile screen
@Observable
final class ProfileViewModel {
    
    // MARK: - Dependencies
    
    private let postRepository: PostRepository
    private let userRepository: UserRepository
    private let personaRepository: PersonaRepository
    
    // MARK: - State
    
    var user: User?
    var personas: [Persona] = []
    var posts: [Post] = []
    var filteredPosts: [Post] = []
    
    var selectedPersonaId: UUID? // nil means "All Posts"
    
    var isLoading = false
    var errorMessage: String?
    
    // MARK: - Computed Properties
    
    var selectedPersona: Persona? {
        guard let id = selectedPersonaId else { return nil }
        return personas.first { $0.id == id }
    }
    
    var displayName: String {
        user?.name ?? "User"
    }
    
    var bio: String {
        user?.bio ?? "Capturing life, one moment at a time ✨"
    }
    
    var postCount: Int {
        user?.totalPosts ?? posts.count
    }
    
    var currentStreak: Int {
        user?.currentStreak ?? 0
    }
    
    var personaCount: Int {
        personas.count
    }
    
    // MARK: - Initialization
    
    init(
        postRepository: PostRepository,
        userRepository: UserRepository,
        personaRepository: PersonaRepository
    ) {
        self.postRepository = postRepository
        self.userRepository = userRepository
        self.personaRepository = personaRepository
    }
    
    // MARK: - Actions
    
    /// Load initial profile data
    @MainActor
    func loadInitialData() async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Load user
            user = try await userRepository.fetchCurrentUser()
            
            // Load personas
            if let userId = user?.id {
                personas = try await personaRepository.fetchPersonas(for: userId)
            }
            
            // Load posts
            posts = try await postRepository.fetchAll()
            
            // Apply initial filter
            applyFilter()
            
        } catch {
            errorMessage = "Failed to load profile: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Refresh profile data
    @MainActor
    func refresh() async {
        do {
            // Reload user
            user = try await userRepository.fetchCurrentUser()
            
            // Reload personas
            if let userId = user?.id {
                personas = try await personaRepository.fetchPersonas(for: userId)
            }
            
            // Reload posts
            posts = try await postRepository.fetchAll()
            
            // Apply current filter
            applyFilter()
            
        } catch {
            errorMessage = "Failed to refresh: \(error.localizedDescription)"
        }
    }
    
    /// Select a persona to filter by (nil for all posts)
    @MainActor
    func selectPersona(_ personaId: UUID?) {
        selectedPersonaId = personaId
        applyFilter()
    }
    
    /// Apply persona filter to posts
    private func applyFilter() {
        if let personaId = selectedPersonaId {
            filteredPosts = posts.filter { $0.personaId == personaId }
        } else {
            filteredPosts = posts
        }
    }
    
    /// Clear error message
    func clearError() {
        errorMessage = nil
    }
}

// MARK: - Preview Helpers

#if DEBUG
extension ProfileViewModel {
    /// Preview instance with mock data
    static var preview: ProfileViewModel {
        let vm = ProfileViewModel(
            postRepository: PreviewContainer.shared.postRepository,
            userRepository: PreviewContainer.shared.userRepository,
            personaRepository: PreviewContainer.shared.personaRepository
        )
        
        // Set mock data
        vm.user = User.mock
        vm.personas = [Persona.mockPersonal, Persona.mockWork, Persona.mockFitness]
        vm.posts = Post.mockPosts
        vm.filteredPosts = Post.mockPosts
        
        return vm
    }
    
    /// Preview instance with empty state
    static var emptyPreview: ProfileViewModel {
        let vm = ProfileViewModel(
            postRepository: PreviewContainer.shared.postRepository,
            userRepository: PreviewContainer.shared.userRepository,
            personaRepository: PreviewContainer.shared.personaRepository
        )
        
        // Set empty mock data
        vm.user = User.mockNewUser
        vm.personas = [Persona.mockPersonal]
        vm.posts = []
        vm.filteredPosts = []
        
        return vm
    }
}
#endif
