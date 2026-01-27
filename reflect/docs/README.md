# Reflect

**Anti-Social Social Media for Personal Reflection**

A private journaling app with social media familiarity. Post your life, track your growth, never worry about likes or judgment.

---

## 🎯 What is Reflect?

Reflect is a personal journaling app that combines the familiar feel of social media with the privacy of a personal diary. It's designed for authentic self-expression without the anxiety of public judgment.

### Key Principles
- **Private by Default**: No followers, no likes, no social pressure
- **Familiar Interface**: Instagram-like UI for easy adoption
- **Personal Growth**: Track moods, activities, and patterns over time
- **Memory Features**: Rediscover your past with "On This Day" memories

---

## 🚀 Quick Start

### Prerequisites
- Xcode 15.0+
- iOS 16.0+ target
- Swift 5.9+

### Running the App
1. Open `reflect.xcodeproj` in Xcode
2. Select a simulator or device
3. Press `Cmd+R` to build and run
4. Explore the component showcase in `ContentView.swift`

### Project Status
- ✅ **Phase 0 Complete**: Design system and core components built
- ✅ **Phase 1 Complete**: Core Data setup and data layer (100% complete)
  - ✅ Domain entities (Post, User, Persona, MediaItem, Memory)
  - ✅ Core Data schema (ReflectDataModel.xcdatamodeld)
  - ✅ CoreDataManager actor with full CRUD operations
  - ✅ Entity mappers (bidirectional domain ↔ Core Data)
  - ✅ Repository protocols (Post, User, Persona, MediaItem, Memory)
  - ✅ Repository implementations (all 4 completed)
  - ✅ Comprehensive repository tests
- ✅ **Phase 2 Complete**: Onboarding UI (100% complete)
  - ✅ 4 onboarding screens with unified design system
  - ✅ Smooth transitions with button-only navigation
  - ✅ Input validation and error handling
  - ✅ "Anti-social social media" branding throughout
  - ✅ CompleteOnboardingUseCase integration
- 🔄 **Phase 3 In Progress**: Feed Display with Polaroid-style cards
  - ✅ Polaroid-style post cards (scrapbook aesthetic)
  - ✅ Post detail view
  - ✅ Tab bar navigation
  - 🔄 Connect to Core Data repositories
- 📋 **Phase 5 Planned**: Profile with Instagram-style grid
  - Grid layout for visual browsing (3 columns)
  - Differentiated from Feed's vertical Polaroid list
  - Same post detail view for full content
- 📋 **MVP Target**: 5 months (~20 weeks)

---

## ✨ Current Features

### Design System (`DesignSystem.swift`)
- Complete color palette (primary, mood-based, semantic)
- Typography system (5 categories, 15 styles)
- Spacing scale (9 levels, 4pt base unit)
- Reusable button styles and modifiers

### Core Components
- **MoodSlider**: Interactive 1-10 mood selector with gradient
- **TagPicker**: Multi-select tag interface with custom tag creation
- **PostCard**: Complete post display with media, tags, and metadata
- **MemoriesLaneView**: Horizontal scrolling memories carousel

### Demo
- Interactive component showcase (`ContentView.swift`)
- Real-world usage examples
- Mock data for testing

---

## 📱 Planned Features (MVP)

### Core Features
- **Post Creation**: Photo/video capture, mood tracking, activity/people tags
- **Feed Display**: Chronological feed with lazy loading
- **Memories**: "On This Day" notifications and time travel features
- **Analytics**: Year in Pixels, mood graphs, streak tracking
- **Search & Filter**: Search by keywords, dates, moods, and tags
- **Security**: App lock with Face ID/Touch ID

### Premium Features ($4.99/mo)
- Multiple personas (up to 5)
- Unlimited high-quality storage (custom backend)
- AI-powered insights and summaries
- Advanced analytics
- Export to PDF/JSON
- Priority support

---

## 🏗️ Tech Stack

### iOS Development
- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Architecture**: MVVM + Clean Architecture
- **Minimum iOS**: 16.0+

### Data & Storage
- **Local Database**: Core Data (all phases)
- **Cloud Sync**: CloudKit for all users (Phase 9, 1GB free)
- **Metadata-First Design**: Rich metadata (~3KB/post) enables analytics on years of data
  - Memories, streaks, and analytics work from lightweight metadata
  - Media files (photos/videos) stored separately and can be managed independently
  - Users can delete old media while preserving journal history for analytics
- **Premium Storage**: Custom backend (Phase 12, unlimited)
- **Media Storage**: FileManager + S3 (premium tier)
- **Security**: Keychain, AES-256 encryption

### Services
- **Authentication**: Sign in with Apple (Phase 9, all users)
- **Subscriptions**: StoreKit 2 (Phase 10)
- **AI**: OpenAI API (Phase 11, premium tier)
- **Analytics**: TelemetryDeck (privacy-focused)
- **Backend**: Custom API for premium unlimited storage (Phase 12)
- **AI**: OpenAI API (premium tier)
- **Analytics**: TelemetryDeck (privacy-focused)

---

## 📂 Project Structure

```
reflect/
├── App/
│   ├── ContentView.swift              # Component showcase (temp)
│   └── reflectApp.swift               # App entry point
│
├── Design/
│   └── DesignSystem.swift             # Design tokens & styles
│
├── Components/                         # Reusable UI components
│   ├── MoodSlider.swift
│   ├── TagPicker.swift
│   ├── PostCard.swift
│   ├── MemoriesLaneView.swift
│   └── ReflectLogo.swift
│
├── Domain/                             # Business logic (to create)
│   ├── Entities/
│   ├── UseCases/
│   └── RepositoryInterfaces/
│
├── Data/                               # Data layer (to create)
│   ├── Repositories/
│   ├── CoreData/
│   └── Local/
│
├── Presentation/                       # UI layer (to create)
│   ├── Screens/
│   ├── Common/
│   └── Navigation/
│
├── Services/                           # App services (to create)
│   ├── Camera/
│   ├── Media/
│   ├── Memories/
│   └── Analytics/
│
└── docs/                               # Documentation
    ├── README.md                       # This file
    ├── ARCHITECTURE.md                 # Technical architecture
    └── FEATURES.md                     # Feature checklist
```

---

## 🎨 Design System Usage

### Colors
```swift
// Use semantic colors from DesignSystem
.foregroundStyle(.reflectPrimary)
.background(Color.reflectSurface)
.foregroundStyle(Color.moodColor(for: 7)) // Mood-based colors
```

### Typography
```swift
Text("Title").font(.headlineLarge)
Text("Body").font(.bodyMedium)
```

### Spacing
```swift
VStack(spacing: Spacing.medium) { }
.padding(Spacing.large)
```

### Buttons
```swift
Button("Action") { }
    .reflectButtonStyle(variant: .primary, isFullWidth: true)
```

---

## 🧩 Component Examples

### Creating a Post Form
```swift
VStack(spacing: Spacing.medium) {
    TextField("What's on your mind?", text: $caption)
    MoodSlider(mood: $mood)
    TagPicker(selectedTags: $activities, availableTags: tags, title: "Activities")
    Button("Post") { savePost() }
        .reflectButtonStyle(variant: .primary, isFullWidth: true)
}
```

### Displaying Posts
```swift
ScrollView {
    MemoriesLaneView(memories: memories)
    ForEach(posts) { post in
        PostCard(post: post) { navigateToDetail(post) }
    }
}
```

---

## 📚 Documentation

### Core Documents
- **README.md** (this file): Project overview and quick reference
- **ARCHITECTURE.md**: Technical architecture and project structure
- **FEATURES.md**: Feature checklist and implementation roadmap

### Additional Resources
- Component showcase: Run the app and explore `ContentView.swift`
- Design tokens: Reference `DesignSystem.swift`
- Code comments: Detailed inline documentation

---

## 🎯 Development Workflow

1. **Plan**: Check `FEATURES.md` for next phase
2. **Build**: Follow architecture patterns in `ARCHITECTURE.md`
3. **Style**: Use design tokens from `DesignSystem.swift`
4. **Test**: Write unit tests for business logic
5. **Document**: Update this README as you progress

---

## 🧪 Testing

### Running Tests
```bash
# Run all tests (uses Simulator)
Cmd+U in Xcode

# Run specific test file
Right-click test file → Run
```

### Test Structure
```
ReflectTests/
├── CoreDataManagerTests.swift    # Core Data operations
├── RepositoryTests.swift          # Repository implementations
├── MappersTests.swift             # Entity mapping
├── SimpleDiagnosticTest.swift    # Test diagnostics
└── XCTestDiagnostic.swift         # XCTest diagnostics
```

### Testing Strategy

**Current: In-Memory Unit Tests (Fast & Isolated)**
- ✅ Tests run on Simulator (instant execution)
- ✅ Use in-memory Core Data stores (100x faster)
- ✅ Cover business logic, data mapping, relationships
- ✅ Each test gets clean database automatically
- ✅ Appropriate for rapid development iteration

**⚠️ TODO: Persistent Store Integration Tests**

See `TODO_PERSISTENT_TESTS.md` for details.

Before Phase 9 (CloudKit), add tests for:
- Data persistence across app restarts
- SQLite-specific batch operations
- Concurrent save scenarios
- Migration testing

**Important:** Current tests don't verify disk persistence. Manual testing on device is critical until persistent integration tests are added.

**Device vs Simulator:**
- ✅ **Use Simulator** for unit tests (fast, reliable)
- ✅ **Use physical device** for manual testing (real performance)

---

## 📈 Success Metrics

### Engagement Goals
- 20% Day 30 retention
- 3 posts per user per week
- 60% daily Memories Lane engagement

### Revenue Goals
- 50,000 downloads Year 1
- 5% free-to-premium conversion
- $10K MRR by end of Year 1

---

## 🗺️ Roadmap

| Milestone | Timeline | Status |
|-----------|----------|--------|
| Foundation | Week 0 | ✅ Complete |
| Core Data Setup | Weeks 1-2 | ⏳ In Progress |
| Core Features | Weeks 3-8 | 📋 Planned |
| Memory & Analytics | Weeks 9-11 | 📋 Planned |
| Premium Features | Weeks 12-16 | 📋 Planned |
| Testing & Polish | Weeks 17-18 | 📋 Planned |
| Beta & Launch | Weeks 19-20 | 📋 Planned |

---

## 🤝 Contributing

This is currently a solo project. For questions or suggestions:
1. Review existing documentation
2. Check `FEATURES.md` for planned work
3. Follow architecture patterns in `ARCHITECTURE.md`

---

## 📄 License

Private project - All rights reserved

---

## 🆘 Getting Help

### Common Issues

**Q: Components not displaying correctly?**  
A: Ensure `DesignSystem.swift` is imported and colors are defined.

**Q: Preview crashes?**  
A: Provide all required bindings with `.constant()` values in previews.

**Q: Core Data errors?**  
A: Delete app from simulator and reinstall to reset database.

### Resources
- [Apple SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Swift Evolution](https://github.com/apple/swift-evolution)
- [Core Data Programming Guide](https://developer.apple.com/documentation/coredata)

---

## 🎉 Recent Updates

### January 9, 2026
- ✅ **Phase 2 Complete (100%)**
  - **Onboarding Flow**: 4 polished screens with smooth transitions
    - WelcomeView: "Anti-social social media" positioning with 4 feature highlights
    - PrivacyView: "100% Private, 0% Social" messaging
    - SignUpView: Name, bio, and email input with validation
    - PersonaSetupView: First persona creation with color picker
  - **Design System Integration**: All onboarding screens use unified design tokens
    - Consistent spacing, typography, colors, and button styles
    - Fixed text truncation issues across all screens
    - Removed swipe navigation for intentional button-only flow
  - **UX Polish**: 
    - Removed auto-focus from text fields for better UX
    - Progress bar shows completion percentage
    - Smooth asymmetric transitions between screens
    - Input validation with error messages
  - **Branding Updates**:
    - Tagline: "Social media where you're the only follower"
    - Generic messaging (no specific app names)
    - Memories feature teaser added to welcome screen
  - **Integration**: CompleteOnboardingUseCase creates User + Persona in Core Data

### December 16, 2025
- ✅ **Phase 1 Complete (100%)**
  - Created Core Data schema (`ReflectDataModel.xcdatamodeld`)
  - 4 entities: UserEntity, PersonaEntity, PostEntity, MediaItemEntity
  - Comprehensive relationships and indexes
  - Built `CoreDataManager` actor with full CRUD operations
  - Implemented `CoreDataMappers` for bidirectional mapping
  - Completed all repository implementations:
    - `UserRepositoryImpl` with full user management
    - `PersonaRepositoryImpl` with persona operations
    - `PostRepositoryImpl` with advanced search and queries
    - `MediaItemRepositoryImpl` with storage management
  - Comprehensive repository tests with RepositoryTests.swift
  - Updated ARCHITECTURE.md with schema details
  
### December 4, 2025
- ✅ Documentation consolidated into 3 core files
- ✅ Design system finalized
- ✅ Core components completed
- ✅ Domain entities completed (5 models)

---

## 🎉 Next Steps

1. Review `FEATURES.md` for Phase 3 tasks (Feed Display)
2. ✅ Polaroid-style feed cards implemented
3. 🔄 Connect feed to Core Data repositories
4. Begin Phase 4 (Post Creation)
5. Plan Phase 5 (Profile with Instagram-style grid)

**Design Philosophy**: Feed = Polaroid scrapbook (reading), Profile = Instagram grid (browsing)

**Let's build something amazing! 🚀**

---

**Project Status**: Phase 3 In Progress 🔄  
**Next Milestone**: Complete Feed Data Connection, then Post Creation (Phase 4)  
**Last Updated**: January 27, 2026
