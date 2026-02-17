//
//  DependencyContainer.swift
//  reflect
//
//  Created by Austin English on 1/22/26.
//

import Foundation

/// Simple dependency injection container for the app
/// Provides repository instances backed by Core Data
@MainActor
final class DependencyContainer {
    
    // MARK: - Singleton
    
    static let shared = DependencyContainer()
    
    // MARK: - Core Data
    
    private let coreDataManager = CoreDataManager.shared
    
    // MARK: - Repositories
    
    /// Post repository backed by Core Data
    lazy var postRepository: PostRepository = {
        PostRepositoryImpl(coreDataManager: coreDataManager)
    }()
    
    /// Persona repository backed by Core Data
    lazy var personaRepository: PersonaRepository = {
        PersonaRepositoryImpl(coreDataManager: coreDataManager)
    }()
    
    /// User repository backed by Core Data
    lazy var userRepository: UserRepository = {
        UserRepositoryImpl(coreDataManager: coreDataManager)
    }()
    
    /// Media item repository backed by Core Data
    lazy var mediaItemRepository: MediaItemRepository = {
        MediaItemRepositoryImpl(coreDataManager: coreDataManager)
    }()
    
    // MARK: - ViewModels
    
    /// Create a FeedViewModel with real repositories
    func makeFeedViewModel() -> FeedViewModel {
        FeedViewModel(
            postRepository: postRepository,
            personaRepository: personaRepository
        )
    }
    
    /// Create a ProfileViewModel with real repositories
    func makeProfileViewModel() -> ProfileViewModel {
        ProfileViewModel(
            postRepository: postRepository,
            userRepository: userRepository,
            personaRepository: personaRepository
        )
    }
    
    // MARK: - Initialization
    
    private init() {
        // Private to enforce singleton
    }
}
