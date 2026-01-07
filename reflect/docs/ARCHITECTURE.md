# Reflect - Project Architecture

Technical architecture and implementation guide for the Reflect app.

---

## 🏛️ Architecture Overview

Reflect uses **MVVM (Model-View-ViewModel) + Clean Architecture** for a maintainable, testable, and scalable codebase.

### Architecture Layers

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│   (SwiftUI Views + ViewModels)          │
│   - Views are "dumb" (no logic)         │
│   - ViewModels handle UI state          │
└────────────┬────────────────────────────┘
             │
┌────────────▼────────────────────────────┐
│          Domain Layer                   │
│   (Business Logic)                      │
│   - Entities (pure Swift models)        │
│   - Use Cases (business operations)     │
│   - Repository Interfaces (protocols)   │
└────────────┬────────────────────────────┘
             │
┌────────────▼────────────────────────────┐
│           Data Layer                    │
│   (Persistence & External Data)         │
│   - Repository Implementations          │
│   - Core Data Manager (local storage)   │
│   - CloudKit Manager (Phase 12, opt-in) │
└────────────┬────────────────────────────┘
             │
┌────────────▼────────────────────────────┐
│      Services (Cross-Cutting)           │
│   - Camera Service                      │
│   - Media Processing                    │
│   - Memories Service                    │
│   - Analytics Service                   │
└─────────────────────────────────────────┘

**Storage Strategy:**
- **Phases 1-8 (Development):** Local-only (Core Data + FileManager)
- **Phase 9 (Launch Prep):** Add CloudKit sync (NSPersistentCloudKitContainer)
- **Phase 10 (Launch):** Free tier = CloudKit (1GB), Premium tier available
- **Phase 12 (Future):** Premium adds custom backend (unlimited storage)
```

---

## 📂 File Structure

### Current Structure (Phase 0)

```
reflect/
├── ContentView.swift              # Temporary component showcase
├── reflectApp.swift               # @main app entry point
├── DesignSystem.swift             # Design tokens & styles
│
└── Components/
    ├── MoodSlider.swift          # 1-10 mood selector
    ├── TagPicker.swift           # Multi-select tag picker
    ├── PostCard.swift            # Post display component
    └── MemoriesLaneView.swift    # Memories carousel
```

### Target Structure (All Phases)

```
reflect/
│
├── App/
│   ├── reflectApp.swift          # @main entry point
│   └── Configuration/
│       └── Environment.swift     # Dev/Prod configs
│
├── Design/
│   └── DesignSystem.swift        # Design tokens & styles
│
├── Domain/                        # Phase 1
│   ├── Entities/                 # Pure Swift models
│   │   ├── Post.swift
│   │   ├── User.swift
│   │   ├── Persona.swift
│   │   ├── MediaItem.swift
│   │   └── Memory.swift
│   │
│   ├── UseCases/                 # Business logic
│   │   ├── CreatePostUseCase.swift
│   │   ├── FetchMemoriesUseCase.swift
│   │   └── AnalyzePatternUseCase.swift
│   │
│   └── RepositoryInterfaces/     # Protocols
│       ├── PostRepository.swift
│       ├── UserRepository.swift
│       └── PersonaRepository.swift
│
├── Data/                          # Phase 1
│   ├── Repositories/             # Protocol implementations
│   │   ├── PostRepositoryImpl.swift
│   │   ├── UserRepositoryImpl.swift
│   │   └── PersonaRepositoryImpl.swift
│   │
│   ├── CoreData/
│   │   ├── ReflectDataModel.xcdatamodeld
│   │   ├── CoreDataManager.swift         # Actor for Core Data
│   │   └── Entities/
│   │       ├── PostEntity+CoreDataClass.swift
│   │       └── UserEntity+CoreDataClass.swift
│   │
│   └── Local/
│       ├── FileManager+Extensions.swift
│       └── KeychainManager.swift
│
├── Presentation/                  # Phases 2-8
│   ├── Screens/
│   │   ├── Onboarding/           # Phase 2
│   │   │   ├── OnboardingView.swift
│   │   │   ├── OnboardingViewModel.swift
│   │   │   └── SignUpView.swift
│   │   │
│   │   ├── Feed/                 # Phase 3
│   │   │   ├── FeedView.swift
│   │   │   └── FeedViewModel.swift
│   │   │
│   │   ├── CreatePost/           # Phase 4
│   │   │   ├── CreatePostView.swift
│   │   │   ├── CreatePostViewModel.swift
│   │   │   └── CameraView.swift
│   │   │
│   │   ├── Profile/              # Phase 5
│   │   │   ├── ProfileView.swift
│   │   │   └── ProfileViewModel.swift
│   │   │
│   │   ├── Settings/             # Phase 5
│   │   │   └── SettingsView.swift
│   │   │
│   │   ├── Memories/             # Phase 6
│   │   │   └── MemoryDetailView.swift
│   │   │
│   │   ├── Analytics/            # Phase 7
│   │   │   ├── YearInPixelsView.swift
│   │   │   ├── MoodGraphView.swift
│   │   │   └── StreakView.swift
│   │   │
│   │   └── Search/               # Phase 8
│   │       └── SearchView.swift
│   │
│   ├── Common/
│   │   ├── Components/           # Shared components
│   │   │   ├── MoodSlider.swift
│   │   │   ├── TagPicker.swift
│   │   │   ├── PostCard.swift
│   │   │   └── MemoriesLaneView.swift
│   │   │
│   │   └── Extensions/
│   │       ├── View+Extensions.swift
│   │       └── Color+Extensions.swift
│   │
│   └── Navigation/
│       ├── TabBarView.swift
│       └── AppCoordinator.swift
│
├── Services/                      # Phases 4-12
│   ├── Camera/                   # Phase 4
│   │   └── CameraService.swift
│   │
│   ├── Media/                    # Phase 4
│   │   ├── ImageProcessingService.swift
│   │   └── MediaStorageService.swift
│   │
│   ├── Memories/                 # Phase 6
│   │   └── MemoriesService.swift
│   │
│   ├── Analytics/                # Phase 7
│   │   └── AnalyticsService.swift
│   │
│   ├── Notifications/            # Phase 6
│   │   └── NotificationService.swift
│   │
│   ├── Security/                 # Phase 9
│   │   ├── EncryptionService.swift
│   │   └── BiometricAuthService.swift
│   │
│   ├── AI/                       # Phase 11
│   │   └── AIService.swift
│   │
│   └── Export/                   # Phase 12
│       └── ExportService.swift
│
├── Utilities/
│   ├── Logger.swift
│   ├── DateFormatter+Extensions.swift
│   └── ImageCache.swift
│
└── Tests/
    ├── ReflectTests/
    │   ├── RepositoryTests/
    │   ├── UseCaseTests/
    │   └── ServiceTests/
    │
    └── ReflectUITests/
        └── OnboardingFlowTests.swift
```

---

## 🎯 Layer Responsibilities

### Presentation Layer
**What it does:**
- Displays UI with SwiftUI
- Captures user interactions
- Observes state changes from ViewModels

**What it doesn't do:**
- Business logic
- Direct data access
- Data transformation

**Example:**
```swift
struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    
    var body: some View {
        ScrollView {
            ForEach(viewModel.posts) { post in
                PostCard(post: post)
            }
        }
        .task { await viewModel.loadPosts() }
    }
}
```

### Domain Layer
**What it does:**
- Defines business entities (Post, User, etc.)
- Contains business rules and use cases
- Defines repository interfaces (protocols)

**What it doesn't do:**
- UI concerns
- Framework-specific code
- Database details

**Example:**
```swift
// Domain Entity
struct Post: Identifiable {
    let id: UUID
    var caption: String
    var mood: Int
    var createdAt: Date
    var mediaItems: [MediaItem]
}

// Repository Protocol
protocol PostRepository {
    func fetchPosts() async throws -> [Post]
    func save(post: Post) async throws
    func delete(postId: UUID) async throws
}

// Use Case
struct CreatePostUseCase {
    private let repository: PostRepository
    
    func execute(post: Post) async throws {
        // Business logic here
        try await repository.save(post: post)
    }
}
```

### Data Layer
**What it does:**
- Implements repository protocols
- Manages Core Data operations
- Handles data mapping (Core Data ↔ Domain models)

**What it doesn't do:**
- Business logic
- UI updates
- Use case orchestration

**Example:**
```swift
actor CoreDataManager {
    private let container: NSPersistentContainer
    
    func save<T: NSManagedObject>(_ object: T) async throws {
        let context = container.viewContext
        try context.save()
    }
}

class PostRepositoryImpl: PostRepository {
    private let coreDataManager: CoreDataManager
    
    func fetchPosts() async throws -> [Post] {
        // Fetch from Core Data
        // Map Core Data entities to Domain models
        // Return domain models
    }
}
```

### Services Layer
**What it does:**
- Cross-cutting concerns (camera, media, notifications)
- External API integrations
- System-level operations

**What it doesn't do:**
- Business logic
- Direct UI updates
- Data persistence (delegates to repositories)

**Example:**
```swift
actor CameraService {
    func capturePhoto() async throws -> UIImage {
        // AVFoundation camera capture
    }
}

actor MemoriesService {
    private let postRepository: PostRepository
    
    func generateDailyMemories() async throws -> [Memory] {
        let posts = try await postRepository.fetchPosts()
        // Filter for "on this day" posts
        // Return memories
    }
}
```

---

## 🔄 Data Flow

### Creating a Post (Example)

```
User Action (UI)
    ↓
View captures input
    ↓
ViewModel receives action
    ↓
ViewModel calls Use Case
    ↓
Use Case validates data
    ↓
Use Case calls Repository
    ↓
Repository saves to Core Data
    ↓
Repository returns success
    ↓
Use Case completes
    ↓
ViewModel updates state
    ↓
View re-renders with new state
```

### Code Example:
```swift
// 1. View
Button("Save Post") {
    Task {
        await viewModel.createPost(caption: caption, mood: mood)
    }
}

// 2. ViewModel
@Observable
class CreatePostViewModel {
    private let createPostUseCase: CreatePostUseCase
    var isLoading = false
    
    func createPost(caption: String, mood: Int) async {
        isLoading = true
        let post = Post(caption: caption, mood: mood, ...)
        try? await createPostUseCase.execute(post: post)
        isLoading = false
    }
}

// 3. Use Case
struct CreatePostUseCase {
    private let repository: PostRepository
    
    func execute(post: Post) async throws {
        // Validate mood is 1-10
        guard (1...10).contains(post.mood) else {
            throw ValidationError.invalidMood
        }
        try await repository.save(post: post)
    }
}

// 4. Repository
class PostRepositoryImpl: PostRepository {
    func save(post: Post) async throws {
        let entity = PostEntity(context: context)
        entity.id = post.id
        entity.caption = post.caption
        entity.mood = Int16(post.mood)
        try await coreDataManager.save(entity)
    }
}
```

---

## 💾 Core Data Architecture

**Design Philosophy**: Store rich metadata with every post to enable on-demand analytics without pre-computation. This "metadata-first" approach allows unlimited journal history with minimal storage impact.

### Schema Design

**Core Data Model**: `ReflectDataModel.xcdatamodeld` ✅

#### UserEntity
```
Attributes:
├── id: UUID (unique constraint)
├── name: String
├── bio: String?
├── email: String?
├── profilePhotoFilename: String?
├── createdAt: Date
├── updatedAt: Date?
├── isPremium: Bool (default: false)
├── premiumExpiresAt: Date?
├── totalPosts: Int32 (default: 0)
├── currentStreak: Int32 (default: 0)
├── longestStreak: Int32 (default: 0)
└── preferencesData: Binary (JSON-encoded UserPreferences)

Relationships:
└── personas: [PersonaEntity] (one-to-many, cascade delete)
```

#### PersonaEntity
```
Attributes:
├── id: UUID (unique constraint)
├── name: String
├── color: String (PersonaColor enum rawValue)
├── icon: String (PersonaIcon enum rawValue)
├── descriptionText: String?
├── createdAt: Date
└── isDefault: Bool (default: false)

Relationships:
├── user: UserEntity (many-to-one)
└── posts: [PostEntity] (one-to-many, cascade delete)

Indexes:
└── byUserIndex (for efficient user queries)
```

#### PostEntity (Metadata-Rich Design)
```
Attributes:
├── id: UUID (unique constraint)
├── caption: String
├── mood: Int16                     // Core analytics field (indexed)
├── experienceRating: Int16?        // Optional analytics field
├── createdAt: Date                 // Core analytics field (indexed, descending)
├── updatedAt: Date?
├── location: String?
├── postType: String (PostType enum rawValue, indexed)
├── activityTags: [String]          // Transformable, tag analytics
├── peopleTags: [String]            // Transformable, people analytics
├── isGratitude: Bool               // Special post type filtering
├── isRant: Bool
├── isDream: Bool
├── isFutureYou: Bool
├── scheduledFor: Date?
├── autoDeleteDate: Date?
├── voiceMemoFilename: String?
├── voiceMemoDuration: Double?
├── voiceMemoTranscription: String?
└── memoryNotes: String?            // Added when viewed as memory

Relationships:
├── persona: PersonaEntity (many-to-one, indexed)
└── mediaItems: [MediaItemEntity] (one-to-many, ordered, cascade delete)

Indexes (for analytics performance):
├── byCreatedAtIndex (descending)   // Feed queries, memories
├── byMoodIndex (ascending)         // Mood analytics
├── byPersonaIndex                  // Filter by persona
└── byPostTypeIndex                 // Filter by type
```

#### MediaItemEntity (Separate from core post metadata)
```
Attributes:
├── id: UUID (unique constraint)
├── type: String (MediaType enum rawValue, indexed)
├── filename: String                // Reference to file storage
├── thumbnailFilename: String?
├── createdAt: Date
├── fileSize: Int64
├── width: Int32?
├── height: Int32?
└── duration: Double?               // For videos

Relationships:
└── post: PostEntity (many-to-one, indexed)

Indexes:
├── byPostIndex (for loading post media)
└── byTypeIndex (filter photos/videos)
```

#### ⚠️ No Memory Entity in Core Data
```
❌ No MemoryEntity in persistent storage
❌ No separate analytics tables
❌ No pre-computed statistics
❌ No cached memory records

✅ Memories computed on-demand by filtering posts
✅ Analytics calculated from indexed queries
✅ Zero storage overhead for analytics/memories
```

**Why This Schema Design?**

1. **Rich metadata in Post entity (~3 KB per post)**
   - Mood, tags, dates enable all analytics
   - 1,000 posts = only 3 MB (negligible storage)
   - Supports years of history within CloudKit 1GB limit

2. **Media stored separately (500 KB - 5 MB each)**
   - MediaItem references files by name
   - Files can be deleted independently to free space
   - Post metadata preserved even without media
   - Analytics still work after media deletion

3. **No analytics tables (zero storage overhead)**
   - Core Data queries fast enough (<200ms for 10,000 posts)
   - Always up-to-date (no cache invalidation)
   - Simpler schema, easier maintenance

4. **No Memory entity in persistent storage**
   - Memories computed daily by filtering posts
   - "On This Day" = posts where month/day match, year differs
   - No data duplication, no extra storage

**Performance Strategy:**
- **Indexes**: `createdAt`, `mood`, `personaId` (fast filtering)
- **Batch fetching**: Load relationships efficiently
- **Lazy loading**: Media items only when needed
- **Background processing**: Heavy analytics on background thread
- **Query optimization**: Fetch only required fields

**Storage Impact Example:**
```
Daily posts for 3 years (1,095 posts):

Metadata:
- 1,095 posts × 3 KB = 3.3 MB
- All analytics work with this data

Media (varies):
- Text-only posts: 0 KB
- Photo posts: 1,095 × 500 KB = 547 MB
- Video posts: Higher storage needs

Total: ~550 MB (55% of 1GB CloudKit limit)
Analytics: Works with just 3.3 MB metadata ✅
```

### Core Data Manager Pattern

**Implementation**: `CoreDataManager.swift` ✅

```swift
actor CoreDataManager {
    static let shared = CoreDataManager()
    
    private let container: NSPersistentContainer
    
    /// Main thread view context (nonisolated for UI access)
    nonisolated var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    private init() {
        container = NSPersistentContainer(name: "ReflectDataModel")
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error)")
            }
        }
        
        // Configure view context
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // MARK: - Context Management
    
    /// Creates background context for heavy operations
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
    
    // MARK: - Save Operations
    
    /// Save main view context
    func save() async throws {
        let context = viewContext
        guard context.hasChanges else { return }
        
        try await context.perform {
            try context.save()
        }
    }
    
    /// Save specific context
    func save(context: NSManagedObjectContext) async throws {
        guard context.hasChanges else { return }
        
        try await context.perform {
            try context.save()
        }
    }
    
    // MARK: - Fetch Operations
    
    /// Generic fetch with request
    func fetch<T: NSManagedObject>(
        _ request: NSFetchRequest<T>,
        context: NSManagedObjectContext? = nil
    ) async throws -> [T]
    
    /// Fetch by ID
    func fetchByID<T: NSManagedObject>(
        _ type: T.Type,
        id: UUID,
        context: NSManagedObjectContext? = nil
    ) async throws -> T?
    
    /// Fetch all entities
    func fetchAll<T: NSManagedObject>(
        _ type: T.Type,
        sortDescriptors: [NSSortDescriptor]? = nil,
        context: NSManagedObjectContext? = nil
    ) async throws -> [T]
    
    /// Count entities
    func count<T: NSManagedObject>(
        _ request: NSFetchRequest<T>,
        context: NSManagedObjectContext? = nil
    ) async throws -> Int
    
    // MARK: - Delete Operations
    
    /// Delete single entity
    func delete(_ object: NSManagedObject) async throws
    
    /// Delete multiple entities
    func delete(_ objects: [NSManagedObject]) async throws
    
    /// Batch delete with predicate
    func batchDelete<T: NSManagedObject>(
        _ type: T.Type,
        predicate: NSPredicate? = nil,
        context: NSManagedObjectContext? = nil
    ) async throws
    
    // MARK: - Batch Operations
    
    /// Perform batch operation in background
    func performBatchOperation(
        _ operation: @escaping (NSManagedObjectContext) async throws -> Void
    ) async throws
    
    // MARK: - Reset
    
    /// Delete all data (testing/debugging only)
    func resetStore() async throws
}
```

**Key Features:**

1. **Actor Isolation**
   - Thread-safe Core Data access
   - All operations are `async`
   - `nonisolated` view context for UI binding

2. **Context Management**
   - Main view context for UI updates
   - Background contexts for heavy operations
   - Automatic merge from parent context
   - Property object trump merge policy

3. **Generic Operations**
   - Type-safe fetch operations
   - Support for custom fetch requests
   - Optional context parameter (defaults to viewContext)

4. **Error Handling**
   - Custom `CoreDataError` enum
   - Localized error descriptions
   - Debug logging in development

5. **Performance**
   - Batch delete for large operations
   - Background context for imports
   - Only saves when context has changes

**Usage Examples:**

```swift
// Save a new post
let manager = CoreDataManager.shared
let entity = PostEntity(context: manager.viewContext)
entity.id = UUID()
entity.caption = "Hello"
entity.mood = 8
try await manager.save()

// Fetch all posts
let posts = try await manager.fetchAll(
    PostEntity.self,
    sortDescriptors: [NSSortDescriptor(key: "createdAt", ascending: false)]
)

// Fetch by ID
if let post = try await manager.fetchByID(PostEntity.self, id: postId) {
    // Found post
}

// Delete old posts (batch)
let sixMonthsAgo = Calendar.current.date(byAdding: .month, value: -6, to: Date())!
let predicate = NSPredicate(format: "createdAt < %@", sixMonthsAgo as NSDate)
try await manager.batchDelete(PostEntity.self, predicate: predicate)

// Background import
try await manager.performBatchOperation { context in
    for jsonPost in importedPosts {
        let entity = PostEntity(context: context)
        // ... populate entity
    }
    // Save happens automatically after operation
}
```
    
    func fetch<T: NSManagedObject>(
        _ type: T.Type,
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil
    ) async throws -> [T] {
        let request = NSFetchRequest<T>(entityName: String(describing: type))
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        return try viewContext.fetch(request)
    }
}
```

### Entity Mapping Pattern

**Implementation**: `CoreDataMappers.swift` ✅

Mappers convert between domain models and Core Data entities:

```swift
// MARK: - Domain → Core Data

extension PostEntity {
    /// Creates new entity from domain model
    static func create(from post: Post, context: NSManagedObjectContext) throws -> PostEntity
    
    /// Updates existing entity from domain model
    func update(from post: Post, context: NSManagedObjectContext) throws
}

// MARK: - Core Data → Domain

extension PostEntity {
    /// Converts entity to domain model
    func toDomain() throws -> Post
}

// Batch mapping
extension Array where Element == PostEntity {
    func toDomain() throws -> [Post]
}
```

**Key Features:**

1. **Bidirectional Mapping**
   - Domain → Core Data (create/update)
   - Core Data → Domain (toDomain)
   - Preserves all data integrity

2. **Error Handling**
   - `MappingError.missingRequiredField`
   - `MappingError.invalidData`
   - Throws instead of force-unwrapping

3. **Relationship Handling**
   - Post ↔ Persona
   - Post ↔ MediaItems (ordered)
   - User ↔ Personas
   - Maintains referential integrity

4. **JSON Encoding**
   - UserPreferences stored as Binary
   - Tags stored as Transformable arrays
   - Efficient storage, type-safe access

5. **Batch Operations**
   - Array extensions for bulk mapping
   - `[PostEntity].toDomain() -> [Post]`
   - Optimized for feed queries

**Usage Example:**

```swift
// Domain → Core Data (Create)
let post = Post(caption: "Hello", mood: 8, ...)
let entity = try PostEntity.create(from: post, context: context)
try await manager.save()

// Domain → Core Data (Update)
let existingEntity = try await manager.fetchByID(PostEntity.self, id: post.id)
try existingEntity?.update(from: post, context: context)
try await manager.save()

// Core Data → Domain (Single)
let entity = try await manager.fetchByID(PostEntity.self, id: postId)
let domainPost = try entity?.toDomain()

// Core Data → Domain (Batch)
let entities = try await manager.fetchAll(PostEntity.self)
let domainPosts = try entities.toDomain()
```

---

## 🎨 Design System Architecture

### Design Tokens Structure

```swift
// Colors
extension Color {
    // Brand
    static let reflectPrimary = Color(hex: "007AFF")
    static let reflectSecondary = Color(hex: "5856D6")
    
    // Mood Scale
    static func moodColor(for value: Int) -> Color {
        // Red → Orange → Green gradient
    }
    
    // Semantic
    static let reflectBackground = Color(hex: "F2F2F7")
    static let reflectSurface = Color.white
}

// Typography
extension Font {
    static let displayLarge = Font.system(size: 57, weight: .bold, design: .rounded)
    static let headlineLarge = Font.system(size: 32, weight: .bold, design: .rounded)
    static let bodyLarge = Font.system(size: 17, weight: .regular, design: .rounded)
}

// Spacing
enum Spacing: CGFloat {
    case tight = 2
    case extraSmall = 4
    case small = 8
    case medium = 16
    case large = 24
    case extraLarge = 32
}
```

### Component Architecture

```swift
// All components are:
// 1. Reusable
// 2. Self-contained
// 3. Customizable via parameters
// 4. Use design system tokens

struct MoodSlider: View {
    @Binding var mood: Int
    let showEmojis: Bool
    
    var body: some View {
        // Implementation uses DesignSystem tokens
    }
}
```

---

## 🧪 Testing Architecture

### Test Structure

```swift
// Unit Tests (Business Logic)
@Test("Creating a post with valid mood")
func createPostWithValidMood() async throws {
    let repository = MockPostRepository()
    let useCase = CreatePostUseCase(repository: repository)
    let post = Post(mood: 7, caption: "Test")
    
    try await useCase.execute(post: post)
    
    #expect(repository.savedPosts.count == 1)
}

// UI Tests (User Flows)
@Test("Complete onboarding flow")
func completeOnboardingFlow() async throws {
    let app = XCUIApplication()
    app.launch()
    
    app.buttons["Get Started"].tap()
    // ... test flow
}
```

### Mock Implementations

```swift
class MockPostRepository: PostRepository {
    var savedPosts: [Post] = []
    
    func save(post: Post) async throws {
        savedPosts.append(post)
    }
    
    func fetchPosts() async throws -> [Post] {
        return savedPosts
    }
}
```

---

## 📦 Storage & Sync Strategy

### Storage Architecture by Phase

#### **Phases 1-8 (Development): Local-Only Storage**
```
Developer's Mac/iPhone
└── App Sandbox
    ├── Core Data (SQLite) - Posts, users, personas, memories
    ├── FileManager - Photos & videos
    └── UserDefaults - Settings & preferences

✅ Benefits:
- Fast development (no network calls)
- Works in Simulator
- Easy debugging
- No CloudKit complexity yet
- All features testable offline

⏳ Development focus:
- Build all core features
- Perfect the user experience
- Test with local data
```

#### **Phase 9: CloudKit Integration (All Users - Free Tier)**
```
User's iPhone/iPad/Mac + iCloud
├── Local storage (primary, always works offline)
│   ├── Core Data (SQLite)
│   ├── FileManager (media)
│   └── UserDefaults
│
└── iCloud (automatic backup & sync)
    └── CloudKit Private Database
        ├── 1GB per user (free from Apple)
        ├── Compressed photos (~500KB each)
        ├── Videos up to 1 minute
        └── ~400-500 posts with media

Implementation:
- NSPersistentCloudKitContainer (Apple's automatic sync!)
- Sign in with Apple (required)
- Local-first (always works offline)
- Background sync when online

✅ Benefits for users:
- Multi-device sync (iPhone, iPad, Mac)
- Automatic backup
- Data survives app deletion
- No manual export needed

✅ Benefits for you:
- Zero infrastructure costs
- Apple handles all scaling
- Privacy-preserving (user's iCloud)
- Competitive with Day One, Bear, etc.
```

#### **Phase 10: Launch with Free & Premium Tiers**
```
Free Tier (95% of users):
├── CloudKit: 1GB storage
├── Sync across devices
├── Compressed photos (500KB)
├── Videos up to 1 minute
├── 1 persona
├── Basic features
└── Cost to you: $0

Premium Tier ($4.99/mo):
├── CloudKit: 1GB (metadata)
├── Custom Backend: Unlimited
├── High-quality photos (2-5MB)
├── Videos up to 10 minutes
├── 5 personas
├── AI features
└── Cost to you: ~$1-2/user/mo
```

#### **Phase 12: Premium Backend (Unlimited Storage)**
```
Premium User Storage:
├── CloudKit (1GB)
│   ├── All metadata (posts, personas, users)
│   ├── Thumbnails
│   └── Small media files
│
└── Your Custom Backend (Unlimited)
    ├── AWS S3 (full-resolution media)
    │   ├── Original photos (2-5MB each)
    │   ├── Long videos (up to 10 min)
    │   └── No compression
    │
    └── Your API Server
        ├── Upload/download endpoints
        ├── Storage tracking
        ├── User authentication
        └── Cost optimization

Implementation:
- StorageCoordinator decides where to store
- Small files → CloudKit
- Large files → S3 (premium only)
- Transparent to user
- Fallback strategies

Cost Example (1,000 premium users):
├── Server: $50/mo (Railway/Render)
├── Database: $25/mo (Supabase)
├── Storage: $345/mo (15GB avg × 1000 users × $0.023/GB)
└── Total: $420/mo
    Revenue: $4,990/mo
    Profit: $4,570/mo (91% margin ✅)
```

### Repository Implementation Strategy

```swift
// Phases 1-8: Single implementation (local only for development)
class PostRepositoryImpl: PostRepository {
    private let coreDataManager: CoreDataManager
    
    func create(_ post: Post) async throws {
        try await coreDataManager.save(post)
    }
}

// Phase 9: Add NSPersistentCloudKitContainer (automatic sync!)
class PostRepositoryImpl: PostRepository {
    // Core Data with CloudKit automatically enabled
    private let persistentContainer: NSPersistentCloudKitContainer
    
    func create(_ post: Post) async throws {
        let context = persistentContainer.viewContext
        let entity = PostEntity(from: post, context: context)
        try context.save()
        
        // CloudKit sync happens automatically! 🎉
        // No manual CloudKit code needed
    }
}

// Phase 12: Add custom backend for premium unlimited storage
class PostRepositoryImpl: PostRepository {
    private let persistentContainer: NSPersistentCloudKitContainer
    private let backendAPI: BackendAPIClient?  // Premium only
    private let storageCoordinator: StorageCoordinator
    
    func create(_ post: Post) async throws {
        // 1. Always save to Core Data (syncs to CloudKit automatically)
        let context = persistentContainer.viewContext
        let entity = PostEntity(from: post, context: context)
        try context.save()
        
        // 2. Premium: Upload high-res media to custom backend
        if let backend = backendAPI {
            for media in post.mediaItems where media.shouldUseBackend {
                let url = try await backend.uploadMedia(media)
                entity.updateMediaURL(url)
            }
            try context.save()
        }
    }
}
```

### Storage Capacity Planning

#### **Free Tier (CloudKit - All Users)**
```
CloudKit Storage: 1GB per user (from Apple)

Compression strategy:
- Photos: 500KB average (JPEG, quality 0.7)
- Videos: 5MB for 30 seconds max
- Thumbnails: 50KB each

Capacity:
- ~2,000 photos, OR
- ~200 videos, OR
- ~500 posts with mixed media (2-3 photos each)

User experience:
- "You're using 650 MB of 1 GB"
- Warning at 900 MB: "Upgrade for unlimited storage"
- At limit: Can't add media until upgraded or deleted
```

#### **Metadata Strategy for Analytics & Memories**

**Key Insight**: Metadata is extremely lightweight, enabling unlimited history without storage concerns.

```
Post Metadata Size Analysis:
- Post record (without media): ~1-5 KB
  - UUID (16 bytes)
  - Caption (1-2 KB typical)
  - Mood, ratings, dates (~50 bytes)
  - Tags array (~500 bytes typical)
  - Persona ID (16 bytes)
  - Boolean flags (~10 bytes)
  - Location string (~100 bytes)
  
- Media references: ~100 bytes per item
  - Filename (UUID + extension)
  - Type, dimensions, duration
  
Total per post: ~1-5 KB for metadata
Media files: 500 KB - 5 MB each

Example: 1,000 posts over 3 years
- Metadata: 1,000 × 3 KB = 3 MB
- Media: 1,000 × 500 KB = 500 MB
- Total: 503 MB (50% of 1GB limit)

Analytics Impact:
✅ Years of posts = minimal metadata storage
✅ Mood tracking, tags, dates all queryable forever
✅ Memories work by filtering posts, not duplicating
✅ Statistics computed on-demand from Core Data queries
✅ Media files are the storage concern, not post history
```

**Why This Matters for Features:**

1. **Memories ("On This Day")**
   - Query posts by date components (month/day from past years)
   - No need to store separate Memory records in CloudKit
   - Works with 10 years of posts using ~30 MB metadata
   - Media loads on-demand from CloudKit

2. **Analytics (Year in Pixels, Mood Graphs, Streaks)**
   - All computed from post metadata queries
   - `fetchMoodDistribution()` scans all posts' mood values
   - `fetchPostingDates()` returns dates for streak calculation  
   - No separate analytics storage needed
   - Core Data indexes make queries fast even with 10,000+ posts

3. **Search & Filtering**
   - Tags, moods, dates all in lightweight metadata
   - Full-text search on captions (1-2 KB each)
   - Media filtering by presence, not content

**Storage Optimization Strategy:**
```swift
// Metadata stays forever (negligible storage)
struct Post {
    let id: UUID                    // 16 bytes
    var caption: String             // ~1 KB
    var mood: Int                   // 8 bytes
    var createdAt: Date             // 8 bytes
    var activityTags: [String]      // ~500 bytes
    var peopleTags: [String]        // ~200 bytes
    var personaId: UUID             // 16 bytes
    // ... other metadata
    
    // Media stored separately, can be deleted/compressed
    var mediaItems: [MediaItem]     // References only (~100 bytes each)
}

// Media files can be managed independently
struct MediaItem {
    let id: UUID                    // 16 bytes
    var filename: String            // ~50 bytes (UUID + extension)
    var type: MediaType             // 1 byte
    // ... file stored at path, not in metadata
}

// Optional: Allow users to delete media but keep posts
func deleteMediaButKeepPost(postId: UUID) async throws {
    let post = try await fetchPost(postId)
    
    // Delete large media files from disk/CloudKit
    for media in post.mediaItems {
        try await mediaStorage.delete(media.filename)
    }
    
    // Update post to mark media as deleted
    post.mediaItems = []
    post.caption += " [Media deleted to free storage]"
    try await update(post)
    
    // Metadata preserved: mood, tags, date still available for analytics!
}
```

**Practical Example: 5 Years of Daily Posts**
```
Scenario: User posts daily for 5 years (1,825 posts)

Metadata Storage:
- 1,825 posts × 3 KB = 5.5 MB

Media Storage (varies by user):
- Conservative: 1,825 × 200 KB (compressed, some text-only) = 365 MB
- Average: 1,825 × 500 KB = 912 MB (approaching limit)
- Heavy: 1,825 × 1 MB = 1.8 GB (needs premium)

Analytics Still Work Even If Media Deleted:
- Mood graph: Pull mood values from all 1,825 posts (5.5 MB)
- Year in Pixels: Pull dates and moods (5.5 MB)
- Tag analysis: Pull tags from all posts (5.5 MB)
- Memories: Pull caption + metadata, note media unavailable

Key Insight: Analytics and memories work with metadata alone.
Users can delete old media files to free space while preserving their journal history.
```

#### **Premium Tier (CloudKit + Custom Backend)**
```
CloudKit: 1GB (metadata + thumbnails)
Backend: Unlimited (your S3 storage)

Compression strategy:
- CloudKit thumbnails: 50KB (for fast loading)
- S3 full resolution: 2-5MB photos, 10MB+ videos
- Original formats preserved

Capacity: Unlimited
- Store full-resolution originals
- Keep all versions
- No compression artifacts
- Videos up to 10 minutes

Cost per user:
- Average 15GB per active premium user
- 15GB × $0.023/GB = $0.35/month storage cost
- User pays $4.99/month
- Your profit: $4.64/user/month
```

### User Authentication Strategy

#### **Phases 1-8 (Development): No Authentication**
```swift
// Single-user app during development
func loadUser() async throws -> User? {
    return try await userRepository.fetchCurrentUser()
}

// Onboarding creates initial user
func completeOnboarding(name: String) async throws {
    let user = try await userRepository.createInitialUser(
        name: name,
        bio: nil,
        email: nil
    )
    // User is now set up, no login required
}
```

#### **Phase 9: Sign in with Apple (Required for All Users)**
```swift
// Required on first launch for CloudKit
func signInWithApple() async throws -> User {
    let appleIDProvider = ASAuthorizationAppleIDProvider()
    let request = appleIDProvider.createRequest()
    request.requestedScopes = [.fullName]  // Email optional
    
    // Apple handles authentication
    let authorization = try await performSignIn(request)
    
    // Get stable user identifier (for CloudKit)
    let userID = authorization.user
    
    // Check if returning user (CloudKit has data)
    if let existingUser = try await fetchFromCloudKit(userID) {
        // Sync down existing data
        return existingUser
    } else {
        // New user - create account
        let newUser = User(
            id: UUID(),
            name: authorization.fullName?.formatted() ?? "User"
        )
        try await saveToCloudKit(newUser, userID: userID)
        return newUser
    }
}
```

#### **Benefits of Sign in with Apple**
```
✅ Privacy-preserving (user controls email sharing)
✅ One-tap authentication (Face ID/Touch ID)
✅ Stable user ID across devices
✅ Required by Apple for CloudKit usage
✅ Built-in trust (users familiar with it)
✅ No password management needed
```

### Data Migration Path

```
Phase 1-8 (Development):
└── Local Core Data only
    ✅ Fast development
    ✅ No network complexity
    ✅ Perfect for building features

Phase 9 (Pre-Launch):
├── Local Core Data (primary)
└── NSPersistentCloudKitContainer
    ✅ Automatic CloudKit sync
    ✅ Sign in with Apple required
    ✅ All users get sync & backup
    ✅ Migration: Just enable container, Apple handles sync

Phase 10 (Launch):
├── Free Tier: CloudKit (1GB)
└── Premium Tier: CloudKit + Backend (unlimited)
    ✅ No breaking changes
    ✅ Premium just adds more storage

Phase 12 (Premium Backend):
├── Free: CloudKit only (1GB)
└── Premium: CloudKit + S3 (unlimited)
    ✅ StorageCoordinator decides storage location
    ✅ Small files → CloudKit
    ✅ Large files → S3 (premium)
    ✅ Transparent to user
```

**Key Insight:** NSPersistentCloudKitContainer = Zero manual CloudKit code! 🎉
Apple handles all the sync automatically. You just enable it.

---

## 🔐 Security Architecture

### Data Protection

1. **App Lock**: Face ID/Touch ID + PIN fallback
2. **Keychain**: Store sensitive data (auth tokens, encryption keys)
3. **Encryption**: AES-256 for sensitive post content
4. **Privacy**: No analytics without user consent

### Implementation

```swift
actor BiometricAuthService {
    func authenticate() async throws -> Bool {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: &error
        ) else {
            // Fall back to PIN
            return try await authenticateWithPIN()
        }
        
        return try await context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: "Unlock Reflect"
        )
    }
}
```

---

## 🚀 Performance Considerations

### Metadata-First Analytics Performance

**Key Insight**: Analytics queries on metadata are fast enough that pre-computation isn't needed.

```
Typical Analytics Queries (10,000 posts):

Year in Pixels (365 days):
- Fetch posts for year: 50ms
- Extract moods: 10ms
- Render visualization: 100ms
- Total: ~160ms ✅

Mood Distribution (all posts):
- Fetch all posts: 100ms
- Aggregate mood values: 20ms  
- Total: ~120ms ✅

Streak Calculation (3 years):
- Fetch posting dates: 80ms
- Calculate streak: 30ms
- Total: ~110ms ✅

Tag Frequency (all posts):
- Fetch all tags: 150ms
- Count and sort: 50ms
- Total: ~200ms ✅
```

**Why This Works:**
- SQLite (Core Data backend) is optimized for these queries
- Metadata fields are indexed (createdAt, mood, personaId)
- Metadata is small (3 KB/post vs 500 KB+ with media)
- Queries stay local (no network latency)
- Can run on background thread for heavy operations

**Benefits vs Pre-Computed Approach:**
- ✅ Always up-to-date (no stale cache)
- ✅ Zero storage overhead (no analytics tables)
- ✅ Simpler codebase (no cache invalidation logic)
- ✅ Flexible queries (not locked into pre-computed views)

### Core Data Optimization
- Use batch fetching for large datasets
- Implement NSFetchedResultsController for tables
- Use faulting to lazy-load relationships
- Add indexes for frequently queried properties (createdAt, mood, personaId)

### Image Optimization
- Store multiple sizes (thumbnail, preview, full)
- Compress images before saving
- Use lazy loading for image grids
- Implement image cache

### Memory Management
- Use actors for thread-safe data access
- Implement pagination for feeds
- Clean up unused image cache
- Profile with Instruments regularly

---

## 📦 Dependency Management

### Current Dependencies
- **None** (Phase 0)

### Planned Dependencies
- **Minimal approach**: Prefer native frameworks
- **Considered**: RevenueCat (subscriptions), Kingfisher (image caching)

### Dependency Injection

```swift
// Protocol-based injection
protocol PostRepository { }

class FeedViewModel {
    private let repository: PostRepository
    
    init(repository: PostRepository = PostRepositoryImpl()) {
        self.repository = repository
    }
}
```

---

## 🔄 State Management

### SwiftUI Observable Pattern

```swift
@Observable
class FeedViewModel {
    var posts: [Post] = []
    var isLoading = false
    var error: Error?
    
    private let repository: PostRepository
    
    func loadPosts() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            posts = try await repository.fetchPosts()
        } catch {
            self.error = error
        }
    }
}
```

---

## 📝 Coding Standards

### File Organization
1. Mark sections with `// MARK: -`
2. Order: Properties → Initialization → Public Methods → Private Methods
3. Group related functionality

### Naming Conventions
- **Views**: `FeedView`, `CreatePostView`
- **ViewModels**: `FeedViewModel`, `CreatePostViewModel`
- **Entities**: `Post`, `User`, `Persona`
- **Services**: `CameraService`, `MemoriesService`
- **Repositories**: `PostRepository`, `PostRepositoryImpl`

### Swift Concurrency
- Prefer `async/await` over completion handlers
- Use actors for shared mutable state
- Mark long-running operations with `@MainActor` when needed

---

## 🎯 Next Steps

1. **Phase 1**: Create domain entities and Core Data schema
2. **Phase 2**: Implement repositories with tests
3. **Phase 3**: Build onboarding flow
4. **Phase 4+**: Continue per FEATURES.md roadmap

---

**Last Updated**: December 4, 2025  
**Version**: 1.0  
**Status**: Phase 0 Complete ✅
