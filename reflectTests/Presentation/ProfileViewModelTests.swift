//
//  ProfileViewModelTests.swift
//  reflectTests
//
//  Created by Austin English on 2/17/26.
//

import Testing
import Foundation
@testable import reflect

/// Comprehensive tests for ProfileViewModel
///
/// Covers:
/// - Initial data loading (success + error paths)
/// - Persona filtering
/// - Pull-to-refresh
/// - Computed properties (displayName, bio, postCount, etc.)
/// - Error handling and clearError
/// - Edge cases (empty state, single persona, many posts)
@Suite("Profile ViewModel Tests")
@MainActor
struct ProfileViewModelTests {

    // MARK: - Helpers

    /// Builds a fresh ViewModel with controllable mock dependencies
    func makeViewModel(
        postRepo: ProfileMockPostRepository,
        userRepo: ProfileMockUserRepository,
        personaRepo: ProfileMockPersonaRepository
    ) -> ProfileViewModel {
        ProfileViewModel(
            postRepository: postRepo,
            userRepository: userRepo,
            personaRepository: personaRepo
        )
    }

    /// Convenience overload — all empty/default mocks
    func makeViewModel() -> ProfileViewModel {
        ProfileViewModel(
            postRepository: ProfileMockPostRepository(),
            userRepository: ProfileMockUserRepository(),
            personaRepository: ProfileMockPersonaRepository()
        )
    }

    /// A stable user ID shared across helpers
    let userId = UUID()

    func makeUser(name: String = "Test User", bio: String? = "Hello world") -> User {
        User(id: userId, name: name, bio: bio, email: nil)
    }

    func makePersona(name: String = "Personal", isDefault: Bool = true) -> Persona {
        Persona(name: name, color: .blue, icon: .personCircle, isDefault: isDefault, userId: userId)
    }

    func makePost(mood: Int = 7, personaId: UUID? = nil, caption: String = "Test post") -> Post {
        Post(
            caption: caption,
            mood: mood,
            personaId: personaId ?? UUID()
        )
    }

    // MARK: - Initial State

    @Test("Initial state has empty collections and is not loading")
    func testInitialState() {
        let vm = makeViewModel()

        #expect(vm.user == nil)
        #expect(vm.personas.isEmpty)
        #expect(vm.posts.isEmpty)
        #expect(vm.filteredPosts.isEmpty)
        #expect(vm.selectedPersonaId == nil)
        #expect(vm.isLoading == false)
        #expect(vm.errorMessage == nil)
    }

    // MARK: - loadInitialData — Success

    @Test("loadInitialData populates user, personas, and posts")
    func testLoadInitialDataSuccess() async {
        let persona = makePersona()
        let post = makePost(personaId: persona.id)

        let postRepo = ProfileMockPostRepository(posts: [post])
        let userRepo = ProfileMockUserRepository(stubbedUser: makeUser())
        let personaRepo = ProfileMockPersonaRepository(personas: [persona])

        let vm = makeViewModel(postRepo: postRepo, userRepo: userRepo, personaRepo: personaRepo)
        await vm.loadInitialData()

        #expect(vm.user?.name == "Test User")
        #expect(vm.personas.count == 1)
        #expect(vm.posts.count == 1)
        #expect(vm.filteredPosts.count == 1)
        #expect(vm.isLoading == false)
        #expect(vm.errorMessage == nil)
    }

    @Test("loadInitialData sets filteredPosts equal to all posts when no persona selected")
    func testLoadInitialDataFilteredPostsMatchesAllPosts() async {
        let persona = makePersona()
        let posts = [makePost(personaId: persona.id), makePost(personaId: persona.id)]

        let postRepo = ProfileMockPostRepository(posts: posts)
        let userRepo = ProfileMockUserRepository(stubbedUser: makeUser())
        let personaRepo = ProfileMockPersonaRepository(personas: [persona])

        let vm = makeViewModel(postRepo: postRepo, userRepo: userRepo, personaRepo: personaRepo)
        await vm.loadInitialData()

        #expect(vm.filteredPosts.count == vm.posts.count)
    }

    @Test("loadInitialData with no user still loads posts")
    func testLoadInitialDataWithNoUser() async {
        let persona = makePersona()
        let postRepo = ProfileMockPostRepository(posts: [makePost(personaId: persona.id)])
        let userRepo = ProfileMockUserRepository(stubbedUser: nil)
        let personaRepo = ProfileMockPersonaRepository(personas: [persona])

        let vm = makeViewModel(postRepo: postRepo, userRepo: userRepo, personaRepo: personaRepo)
        await vm.loadInitialData()

        #expect(vm.user == nil)
        #expect(vm.posts.count == 1)
    }

    @Test("loadInitialData does not run twice when called again")
    func testLoadInitialDataGuardAgainstDoubleLoad() async {
        let userRepo = ProfileMockUserRepository(stubbedUser: makeUser())
        let postRepo = ProfileMockPostRepository()
        let personaRepo = ProfileMockPersonaRepository()

        let vm = makeViewModel(postRepo: postRepo, userRepo: userRepo, personaRepo: personaRepo)
        await vm.loadInitialData()
        await vm.loadInitialData() // Second call should no-op

        #expect(userRepo.fetchCurrentUserCallCount == 1)
    }

    // MARK: - loadInitialData — Error Handling

    @Test("loadInitialData sets errorMessage when user fetch throws")
    func testLoadInitialDataUserFetchError() async {
        let userRepo = ProfileMockUserRepository(shouldThrow: true)
        let vm = makeViewModel(
            postRepo: ProfileMockPostRepository(),
            userRepo: userRepo,
            personaRepo: ProfileMockPersonaRepository()
        )

        await vm.loadInitialData()

        #expect(vm.errorMessage != nil)
        #expect(vm.isLoading == false)
    }

    @Test("loadInitialData sets errorMessage when post fetch throws")
    func testLoadInitialDataPostFetchError() async {
        let userRepo = ProfileMockUserRepository(stubbedUser: makeUser())
        let personaRepo = ProfileMockPersonaRepository(personas: [makePersona()])
        let postRepo = ProfileMockPostRepository(shouldThrow: true)

        let vm = makeViewModel(postRepo: postRepo, userRepo: userRepo, personaRepo: personaRepo)
        await vm.loadInitialData()

        #expect(vm.errorMessage != nil)
        #expect(vm.isLoading == false)
    }

    @Test("loadInitialData always resets isLoading to false after error")
    func testLoadInitialDataIsLoadingFalseAfterError() async {
        let userRepo = ProfileMockUserRepository(shouldThrow: true)
        let vm = makeViewModel(
            postRepo: ProfileMockPostRepository(),
            userRepo: userRepo,
            personaRepo: ProfileMockPersonaRepository()
        )

        await vm.loadInitialData()

        #expect(vm.isLoading == false)
    }

    // MARK: - refresh

    @Test("refresh reloads posts and updates filteredPosts")
    func testRefreshReloadsPosts() async {
        let persona = makePersona()
        let postRepo = ProfileMockPostRepository(posts: [makePost(personaId: persona.id)])
        let userRepo = ProfileMockUserRepository(stubbedUser: makeUser())
        let personaRepo = ProfileMockPersonaRepository(personas: [persona])

        let vm = makeViewModel(postRepo: postRepo, userRepo: userRepo, personaRepo: personaRepo)
        await vm.loadInitialData()

        // Add a second post then refresh
        postRepo.posts.append(makePost(personaId: persona.id, caption: "New post"))
        await vm.refresh()

        #expect(vm.posts.count == 2)
        #expect(vm.filteredPosts.count == 2)
    }

    @Test("refresh clears a previous error message on success")
    func testRefreshClearsPreviousError() async {
        let userRepo = ProfileMockUserRepository(shouldThrow: true)
        let vm = makeViewModel(
            postRepo: ProfileMockPostRepository(),
            userRepo: userRepo,
            personaRepo: ProfileMockPersonaRepository()
        )

        await vm.loadInitialData()
        #expect(vm.errorMessage != nil)

        // Fix the repo then refresh
        userRepo.shouldThrow = false
        userRepo.stubbedUser = makeUser()
        await vm.refresh()

        #expect(vm.errorMessage == nil)
    }

    @Test("refresh sets errorMessage when fetch throws")
    func testRefreshSetsErrorMessage() async {
        let userRepo = ProfileMockUserRepository(stubbedUser: makeUser())
        let postRepo = ProfileMockPostRepository()
        let personaRepo = ProfileMockPersonaRepository()

        let vm = makeViewModel(postRepo: postRepo, userRepo: userRepo, personaRepo: personaRepo)
        await vm.loadInitialData()

        postRepo.shouldThrow = true
        await vm.refresh()

        #expect(vm.errorMessage != nil)
    }

    // MARK: - Persona Filtering

    @Test("selectPersona filters posts to matching persona only")
    func testSelectPersonaFiltersCorrectly() async {
        let persona1 = makePersona(name: "Personal")
        let persona2 = makePersona(name: "Work")

        let post1 = makePost(personaId: persona1.id, caption: "Personal post")
        let post2 = makePost(personaId: persona2.id, caption: "Work post")

        let postRepo = ProfileMockPostRepository(posts: [post1, post2])
        let userRepo = ProfileMockUserRepository(stubbedUser: makeUser())
        let personaRepo = ProfileMockPersonaRepository(personas: [persona1, persona2])

        let vm = makeViewModel(postRepo: postRepo, userRepo: userRepo, personaRepo: personaRepo)
        await vm.loadInitialData()

        vm.selectPersona(persona1.id)

        #expect(vm.filteredPosts.count == 1)
        #expect(vm.filteredPosts.first?.caption == "Personal post")
    }

    @Test("selectPersona with nil shows all posts")
    func testSelectPersonaNilShowsAllPosts() async {
        let persona1 = makePersona(name: "Personal")
        let persona2 = makePersona(name: "Work")

        let postRepo = ProfileMockPostRepository(posts: [
            makePost(personaId: persona1.id),
            makePost(personaId: persona2.id)
        ])
        let userRepo = ProfileMockUserRepository(stubbedUser: makeUser())
        let personaRepo = ProfileMockPersonaRepository(personas: [persona1, persona2])

        let vm = makeViewModel(postRepo: postRepo, userRepo: userRepo, personaRepo: personaRepo)
        await vm.loadInitialData()

        vm.selectPersona(persona1.id)
        #expect(vm.filteredPosts.count == 1)

        vm.selectPersona(nil)
        #expect(vm.filteredPosts.count == 2)
    }

    @Test("selectPersona with ID that has no posts returns empty filteredPosts")
    func testSelectPersonaNoMatchingPosts() async {
        let persona1 = makePersona(name: "Personal")
        let persona2 = makePersona(name: "Work") // No posts for this one

        let postRepo = ProfileMockPostRepository(posts: [makePost(personaId: persona1.id)])
        let userRepo = ProfileMockUserRepository(stubbedUser: makeUser())
        let personaRepo = ProfileMockPersonaRepository(personas: [persona1, persona2])

        let vm = makeViewModel(postRepo: postRepo, userRepo: userRepo, personaRepo: personaRepo)
        await vm.loadInitialData()

        vm.selectPersona(persona2.id)

        #expect(vm.filteredPosts.isEmpty)
    }

    @Test("selectedPersonaId updates when selectPersona is called")
    func testSelectedPersonaIdUpdates() async {
        let persona = makePersona()
        let postRepo = ProfileMockPostRepository()
        let userRepo = ProfileMockUserRepository(stubbedUser: makeUser())
        let personaRepo = ProfileMockPersonaRepository(personas: [persona])

        let vm = makeViewModel(postRepo: postRepo, userRepo: userRepo, personaRepo: personaRepo)
        await vm.loadInitialData()

        vm.selectPersona(persona.id)
        #expect(vm.selectedPersonaId == persona.id)

        vm.selectPersona(nil)
        #expect(vm.selectedPersonaId == nil)
    }

    @Test("selectedPersona computed property returns the matching loaded persona")
    func testSelectedPersonaComputedProperty() async {
        let persona = makePersona(name: "Travel")
        let postRepo = ProfileMockPostRepository()
        let userRepo = ProfileMockUserRepository(stubbedUser: makeUser())
        let personaRepo = ProfileMockPersonaRepository(personas: [persona])

        let vm = makeViewModel(postRepo: postRepo, userRepo: userRepo, personaRepo: personaRepo)
        await vm.loadInitialData()

        vm.selectPersona(persona.id)

        #expect(vm.selectedPersona?.name == "Travel")
    }

    @Test("selectedPersona is nil when no persona is selected")
    func testSelectedPersonaIsNilByDefault() {
        let vm = makeViewModel()
        #expect(vm.selectedPersona == nil)
    }

    // MARK: - Computed Properties

    @Test("displayName returns the loaded user's name")
    func testDisplayNameReturnsUserName() async {
        let userRepo = ProfileMockUserRepository(stubbedUser: makeUser(name: "Austin English"))
        let vm = makeViewModel(
            postRepo: ProfileMockPostRepository(),
            userRepo: userRepo,
            personaRepo: ProfileMockPersonaRepository()
        )
        await vm.loadInitialData()

        #expect(vm.displayName == "Austin English")
    }

    @Test("displayName returns fallback string when user is nil")
    func testDisplayNameFallback() {
        let vm = makeViewModel()
        #expect(vm.displayName == "User")
    }

    @Test("bio returns the user's bio when set")
    func testBioReturnsUserBio() async {
        let userRepo = ProfileMockUserRepository(stubbedUser: makeUser(bio: "Living in the moment 🌅"))
        let vm = makeViewModel(
            postRepo: ProfileMockPostRepository(),
            userRepo: userRepo,
            personaRepo: ProfileMockPersonaRepository()
        )
        await vm.loadInitialData()

        #expect(vm.bio == "Living in the moment 🌅")
    }

    @Test("bio returns default string when user bio is nil")
    func testBioFallback() async {
        let userRepo = ProfileMockUserRepository(stubbedUser: makeUser(bio: nil))
        let vm = makeViewModel(
            postRepo: ProfileMockPostRepository(),
            userRepo: userRepo,
            personaRepo: ProfileMockPersonaRepository()
        )
        await vm.loadInitialData()

        #expect(vm.bio == "Capturing life, one moment at a time ✨")
    }

    @Test("postCount matches the number of loaded posts")
    func testPostCountMatchesLoadedPosts() async {
        let persona = makePersona()
        let postRepo = ProfileMockPostRepository(posts: [
            makePost(personaId: persona.id),
            makePost(personaId: persona.id)
        ])
        // totalPosts on User is the source of truth for postCount —
        // set it to match the posts we loaded
        let userRepo = ProfileMockUserRepository(stubbedUser: User(
            id: userId, name: "Test User", bio: nil, email: nil, totalPosts: 2
        ))
        let personaRepo = ProfileMockPersonaRepository(personas: [persona])

        let vm = makeViewModel(postRepo: postRepo, userRepo: userRepo, personaRepo: personaRepo)
        await vm.loadInitialData()

        #expect(vm.postCount == 2)
    }

    @Test("postCount falls back to posts array count when user has no posts recorded")
    func testPostCountFallsBackToPostsArray() async {
        let persona = makePersona()
        let postRepo = ProfileMockPostRepository(posts: [
            makePost(personaId: persona.id),
            makePost(personaId: persona.id)
        ])
        // User with totalPosts = 0 — postCount uses posts.count fallback
        let userRepo = ProfileMockUserRepository(stubbedUser: makeUser())
        let personaRepo = ProfileMockPersonaRepository(personas: [persona])

        let vm = makeViewModel(postRepo: postRepo, userRepo: userRepo, personaRepo: personaRepo)
        await vm.loadInitialData()

        // totalPosts is 0 so falls back to live posts.count (2)
        #expect(vm.postCount == vm.posts.count)
    }

    @Test("currentStreak returns 0 when user is nil")
    func testCurrentStreakDefaultsToZero() {
        let vm = makeViewModel()
        #expect(vm.currentStreak == 0)
    }

    @Test("personaCount reflects the number of loaded personas")
    func testPersonaCount() async {
        let userRepo = ProfileMockUserRepository(stubbedUser: makeUser())
        let personaRepo = ProfileMockPersonaRepository(personas: [
            makePersona(name: "A"),
            makePersona(name: "B"),
            makePersona(name: "C")
        ])

        let vm = makeViewModel(
            postRepo: ProfileMockPostRepository(),
            userRepo: userRepo,
            personaRepo: personaRepo
        )
        await vm.loadInitialData()

        #expect(vm.personaCount == 3)
    }

    // MARK: - clearError

    @Test("clearError resets errorMessage to nil")
    func testClearError() async {
        let userRepo = ProfileMockUserRepository(shouldThrow: true)
        let vm = makeViewModel(
            postRepo: ProfileMockPostRepository(),
            userRepo: userRepo,
            personaRepo: ProfileMockPersonaRepository()
        )

        await vm.loadInitialData()
        #expect(vm.errorMessage != nil)

        vm.clearError()
        #expect(vm.errorMessage == nil)
    }

    @Test("clearError is a no-op when there is no existing error")
    func testClearErrorWhenNoError() {
        let vm = makeViewModel()
        vm.clearError()
        #expect(vm.errorMessage == nil)
    }

    // MARK: - Edge Cases

    @Test("Empty post list results in empty filteredPosts")
    func testEmptyPostsShowsEmptyFilteredPosts() async {
        let userRepo = ProfileMockUserRepository(stubbedUser: makeUser())
        let personaRepo = ProfileMockPersonaRepository(personas: [makePersona()])
        let postRepo = ProfileMockPostRepository()

        let vm = makeViewModel(postRepo: postRepo, userRepo: userRepo, personaRepo: personaRepo)
        await vm.loadInitialData()

        #expect(vm.filteredPosts.isEmpty)
    }

    @Test("Posts across many personas all appear when no filter is active")
    func testManyPersonasAllPostsVisible() async {
        let personas = (0..<5).map { i in
            Persona(name: "Persona \(i)", color: .blue, icon: .personCircle, userId: userId)
        }
        let posts = personas.map { makePost(personaId: $0.id) }

        let postRepo = ProfileMockPostRepository(posts: posts)
        let userRepo = ProfileMockUserRepository(stubbedUser: makeUser())
        let personaRepo = ProfileMockPersonaRepository(personas: personas)

        let vm = makeViewModel(postRepo: postRepo, userRepo: userRepo, personaRepo: personaRepo)
        await vm.loadInitialData()

        #expect(vm.selectedPersonaId == nil)
        #expect(vm.filteredPosts.count == 5)
    }

    @Test("Switching persona filter multiple times always reflects the current selection")
    func testMultiplePersonaSwitches() async {
        let persona1 = makePersona(name: "A")
        let persona2 = makePersona(name: "B")

        let postRepo = ProfileMockPostRepository(posts: [
            makePost(personaId: persona1.id, caption: "A post"),
            makePost(personaId: persona2.id, caption: "B post")
        ])
        let userRepo = ProfileMockUserRepository(stubbedUser: makeUser())
        let personaRepo = ProfileMockPersonaRepository(personas: [persona1, persona2])

        let vm = makeViewModel(postRepo: postRepo, userRepo: userRepo, personaRepo: personaRepo)
        await vm.loadInitialData()

        vm.selectPersona(persona1.id)
        #expect(vm.filteredPosts.first?.caption == "A post")

        vm.selectPersona(persona2.id)
        #expect(vm.filteredPosts.first?.caption == "B post")

        vm.selectPersona(nil)
        #expect(vm.filteredPosts.count == 2)
    }
}

// MARK: - ProfileMockPostRepository

/// Mock PostRepository scoped to ProfileViewModel tests.
/// Prefixed "Profile" to avoid collision with any other mock in the test bundle.
@MainActor
final class ProfileMockPostRepository: PostRepository {

    var posts: [Post]
    var shouldThrow: Bool

    init(posts: [Post] = [], shouldThrow: Bool = false) {
        self.posts = posts
        self.shouldThrow = shouldThrow
    }

    func fetchAll() async throws -> [Post] {
        if shouldThrow { throw ProfileMockError.forcedFailure }
        return posts
    }

    func fetchPosts(for personaId: UUID, limit: Int?, offset: Int?) async throws -> [Post] {
        if shouldThrow { throw ProfileMockError.forcedFailure }
        return posts.filter { $0.personaId == personaId }
    }

    // MARK: - Protocol stubs (not exercised by ProfileViewModel)

    func create(_ post: Post) async throws {}
    func fetch(id: UUID) async throws -> Post? { nil }
    func update(_ post: Post) async throws {}
    func delete(id: UUID) async throws {}
    func fetchPosts(from startDate: Date, to endDate: Date) async throws -> [Post] { [] }
    func fetchPosts(with mood: Int) async throws -> [Post] { [] }
    func fetchPosts(withMoodBetween minMood: Int, and maxMood: Int) async throws -> [Post] { [] }
    func fetchPosts(containing tags: [String]) async throws -> [Post] { [] }
    func fetchPosts(containingAll tags: [String]) async throws -> [Post] { [] }
    func fetchPosts(mentioning people: [String]) async throws -> [Post] { [] }
    func fetchPostsWithMedia() async throws -> [Post] { [] }
    func fetchPostsWithoutMedia() async throws -> [Post] { [] }
    func fetchSpecialPosts() async throws -> [Post] { [] }
    func searchPosts(query: String) async throws -> [Post] { [] }
    func searchPosts(query: String?, personaIds: [UUID]?, moodRange: (min: Int, max: Int)?, dateRange: (start: Date, end: Date)?, tags: [String]?, hasMedia: Bool?) async throws -> [Post] { [] }
    func fetchPostsOnThisDay(date: Date) async throws -> [Post] { [] }
    func fetchPostsFromThisWeekLastYear(date: Date) async throws -> [Post] { [] }
    func fetchRandomOldPosts(olderThan date: Date, count: Int) async throws -> [Post] { [] }
    func fetchPostCount() async throws -> Int { posts.count }
    func fetchPostCount(for personaId: UUID) async throws -> Int { 0 }
    func fetchPostCount(from startDate: Date, to endDate: Date) async throws -> Int { 0 }
    func fetchAverageMood() async throws -> Double? { nil }
    func fetchAverageMood(from startDate: Date, to endDate: Date) async throws -> Double? { nil }
    func fetchMoodDistribution() async throws -> [Int: Int] { [:] }
    func fetchMostUsedTags(limit: Int) async throws -> [(tag: String, count: Int)] { [] }
    func fetchMostMentionedPeople(limit: Int) async throws -> [(person: String, count: Int)] { [] }
    func fetchPostingDates() async throws -> [Date] { [] }
    func fetchFirstPostDate() async throws -> Date? { nil }
    func fetchMostRecentPostDate() async throws -> Date? { nil }
    func deletePosts(ids: [UUID]) async throws {}
    func deleteAllPosts(for personaId: UUID) async throws {}
    func deleteAllPosts(olderThan date: Date) async throws -> Int { 0 }
}

// MARK: - ProfileMockUserRepository

/// Mock UserRepository scoped to ProfileViewModel tests.
/// Has full stubbing support unlike the lightweight onboarding mock.
@MainActor
final class ProfileMockUserRepository: UserRepository {

    var stubbedUser: User?
    var shouldThrow: Bool
    private(set) var fetchCurrentUserCallCount = 0

    init(stubbedUser: User? = nil, shouldThrow: Bool = false) {
        self.stubbedUser = stubbedUser
        self.shouldThrow = shouldThrow
    }

    func fetchCurrentUser() async throws -> User? {
        fetchCurrentUserCallCount += 1
        if shouldThrow { throw ProfileMockError.forcedFailure }
        return stubbedUser
    }

    // MARK: - Protocol stubs

    func create(_ user: User) async throws {}
    func fetch(id: UUID) async throws -> User? { stubbedUser }
    func update(_ user: User) async throws {}
    func delete(id: UUID) async throws {}
    func hasUser() async throws -> Bool { stubbedUser != nil }
    func createInitialUser(name: String, bio: String?, email: String?) async throws -> User {
        User(name: name, bio: bio, email: email)
    }
    func fetchPreferences(for userId: UUID) async throws -> User.UserPreferences { .init() }
    func updatePreferences(for userId: UUID, preferences: User.UserPreferences) async throws {}
    func hasActivePremium(for userId: UUID) async throws -> Bool { false }
    func updatePremiumStatus(for userId: UUID, isPremium: Bool, expiresAt: Date?) async throws {}
    func fetchStatistics(for userId: UUID) async throws -> (totalPosts: Int, currentStreak: Int, longestStreak: Int) { (0, 0, 0) }
    func updateStatistics(for userId: UUID, totalPosts: Int, currentStreak: Int, longestStreak: Int) async throws {}
    func incrementPostCount(for userId: UUID) async throws {}
    func decrementPostCount(for userId: UUID) async throws {}
    func updateStreaks(for userId: UUID, currentStreak: Int, longestStreak: Int) async throws {}
    func updateProfile(for userId: UUID, name: String, bio: String?) async throws {}
    func updateProfilePhoto(for userId: UUID, filename: String?) async throws {}
    func addPersona(to userId: UUID, personaId: UUID) async throws {}
    func removePersona(from userId: UUID, personaId: UUID) async throws {}
    func fetchPersonaIds(for userId: UUID) async throws -> [UUID] { [] }
    func deleteUserData(for userId: UUID) async throws {}
    func exportUserData(for userId: UUID) async throws -> User {
        guard let user = stubbedUser else { throw ProfileMockError.forcedFailure }
        return user
    }
}

// MARK: - ProfileMockPersonaRepository

/// Mock PersonaRepository scoped to ProfileViewModel tests.
@MainActor
final class ProfileMockPersonaRepository: PersonaRepository {

    var personas: [Persona]
    var shouldThrow: Bool

    init(personas: [Persona] = [], shouldThrow: Bool = false) {
        self.personas = personas
        self.shouldThrow = shouldThrow
    }

    func fetchPersonas(for userId: UUID) async throws -> [Persona] {
        if shouldThrow { throw ProfileMockError.forcedFailure }
        return personas
    }

    func fetchAll() async throws -> [Persona] {
        if shouldThrow { throw ProfileMockError.forcedFailure }
        return personas
    }

    // MARK: - Protocol stubs

    func create(_ persona: Persona) async throws {}
    func fetch(id: UUID) async throws -> Persona? { personas.first { $0.id == id } }
    func update(_ persona: Persona) async throws {}
    func delete(id: UUID) async throws {}
    func fetchDefaultPersona(for userId: UUID) async throws -> Persona? { personas.first { $0.isDefault } }
    func fetchPersonaCount(for userId: UUID) async throws -> Int { personas.count }
    func setDefaultPersona(personaId: UUID, for userId: UUID) async throws {}
    func clearDefaultPersona(for userId: UUID) async throws {}
    func isPersonaNameUnique(name: String, for userId: UUID, excludingId: UUID?) async throws -> Bool { true }
    func canCreatePersona(for userId: UUID, isPremium: Bool) async throws -> Bool { true }
    func createFromPreset(_ preset: Persona.Preset, for userId: UUID, isDefault: Bool) async throws -> Persona {
        preset.create(userId: userId, isDefault: isDefault)
    }
    func deleteAllPersonas(for userId: UUID) async throws {}
    func fetchPersonas(withColor color: Persona.PersonaColor, for userId: UUID) async throws -> [Persona] { [] }
    func fetchMostUsedPersona(for userId: UUID) async throws -> (persona: Persona, postCount: Int)? { nil }
    func fetchPostCountsByPersona(for userId: UUID) async throws -> [UUID: Int] { [:] }
}

// MARK: - ProfileMockError

enum ProfileMockError: Error {
    case forcedFailure
}

