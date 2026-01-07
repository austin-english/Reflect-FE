//
//  User.swift
//  reflect
//
//  Created by Austin English on 12/4/25.
//

import Foundation

/// Domain entity representing the app user
struct User: Identifiable, Codable {
    // MARK: - Properties
    
    let id: UUID
    var name: String
    var bio: String?
    var email: String?
    var profilePhotoFilename: String?
    var createdAt: Date
    var updatedAt: Date?
    
    // MARK: - Relationships
    
    var personas: [UUID] // References to Persona IDs
    
    // MARK: - Settings
    
    var preferences: UserPreferences
    
    // MARK: - Premium Status
    
    var isPremium: Bool
    var premiumExpiresAt: Date?
    
    // MARK: - Statistics
    
    var totalPosts: Int
    var currentStreak: Int
    var longestStreak: Int
    
    // MARK: - Initialization
    
    init(
        id: UUID = UUID(),
        name: String,
        bio: String? = nil,
        email: String? = nil,
        profilePhotoFilename: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date? = nil,
        personas: [UUID] = [],
        preferences: UserPreferences = UserPreferences(),
        isPremium: Bool = false,
        premiumExpiresAt: Date? = nil,
        totalPosts: Int = 0,
        currentStreak: Int = 0,
        longestStreak: Int = 0
    ) {
        self.id = id
        self.name = name
        self.bio = bio
        self.email = email
        self.profilePhotoFilename = profilePhotoFilename
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.personas = personas
        self.preferences = preferences
        self.isPremium = isPremium
        self.premiumExpiresAt = premiumExpiresAt
        self.totalPosts = totalPosts
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
    }
}

// MARK: - User Preferences

extension User {
    struct UserPreferences: Codable {
        // MARK: - Notifications
        
        var notificationsEnabled: Bool
        var memoryNotificationTime: Date? // Time of day for daily memory notification
        var streakReminderEnabled: Bool
        
        // MARK: - Security
        
        var appLockEnabled: Bool
        var useBiometrics: Bool
        var requireAuthOnLaunch: Bool
        var lockTimeout: LockTimeout
        
        // MARK: - Privacy
        
        var allowAnalytics: Bool
        var allowCrashReporting: Bool
        var iCloudSyncEnabled: Bool
        
        // MARK: - Display
        
        var defaultFeedView: FeedViewType
        var showMemoriesLane: Bool
        var defaultPersonaId: UUID?
        
        // MARK: - Initialization
        
        init(
            notificationsEnabled: Bool = true,
            memoryNotificationTime: Date? = nil,
            streakReminderEnabled: Bool = true,
            appLockEnabled: Bool = false,
            useBiometrics: Bool = true,
            requireAuthOnLaunch: Bool = true,
            lockTimeout: LockTimeout = .immediate,
            allowAnalytics: Bool = false,
            allowCrashReporting: Bool = false,
            iCloudSyncEnabled: Bool = false,
            defaultFeedView: FeedViewType = .list,
            showMemoriesLane: Bool = true,
            defaultPersonaId: UUID? = nil
        ) {
            self.notificationsEnabled = notificationsEnabled
            self.memoryNotificationTime = memoryNotificationTime
            self.streakReminderEnabled = streakReminderEnabled
            self.appLockEnabled = appLockEnabled
            self.useBiometrics = useBiometrics
            self.requireAuthOnLaunch = requireAuthOnLaunch
            self.lockTimeout = lockTimeout
            self.allowAnalytics = allowAnalytics
            self.allowCrashReporting = allowCrashReporting
            self.iCloudSyncEnabled = iCloudSyncEnabled
            self.defaultFeedView = defaultFeedView
            self.showMemoriesLane = showMemoriesLane
            self.defaultPersonaId = defaultPersonaId
        }
    }
    
    enum LockTimeout: String, Codable, CaseIterable {
        case immediate = "Immediate"
        case oneMinute = "1 Minute"
        case fiveMinutes = "5 Minutes"
        case fifteenMinutes = "15 Minutes"
        case oneHour = "1 Hour"
        
        var timeInterval: TimeInterval? {
            switch self {
            case .immediate: return nil
            case .oneMinute: return 60
            case .fiveMinutes: return 300
            case .fifteenMinutes: return 900
            case .oneHour: return 3600
            }
        }
    }
    
    enum FeedViewType: String, Codable {
        case list
        case grid
        case calendar
    }
}

// MARK: - Computed Properties

extension User {
    /// Returns true if user has premium access
    var hasActivePremium: Bool {
        guard isPremium else { return false }
        
        if let expiresAt = premiumExpiresAt {
            return Date() < expiresAt
        }
        
        return true
    }
    
    /// Returns the number of days until premium expires
    var daysUntilPremiumExpires: Int? {
        guard let expiresAt = premiumExpiresAt else { return nil }
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: Date(), to: expiresAt).day
        return days
    }
    
    /// Returns member duration in days
    var memberForDays: Int {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: createdAt, to: Date()).day ?? 0
        return days
    }
    
    /// Returns formatted member duration (e.g., "2 weeks", "3 months")
    var memberDurationFormatted: String {
        let days = memberForDays
        
        if days < 7 {
            return "\(days) day\(days == 1 ? "" : "s")"
        } else if days < 30 {
            let weeks = days / 7
            return "\(weeks) week\(weeks == 1 ? "" : "s")"
        } else if days < 365 {
            let months = days / 30
            return "\(months) month\(months == 1 ? "" : "s")"
        } else {
            let years = days / 365
            return "\(years) year\(years == 1 ? "" : "s")"
        }
    }
    
    /// Returns true if user should see premium paywall
    var shouldShowPaywall: Bool {
        !hasActivePremium
    }
}

// MARK: - Storage Limits

extension User {
    /// Free tier storage limit in bytes (2 GB)
    static let freeStorageLimit: Int64 = 2_147_483_648
    
    /// Free tier post limit
    static let freePostLimit: Int = 500
    
    /// Free tier persona limit
    static let freePersonaLimit: Int = 1
    
    /// Premium persona limit
    static let premiumPersonaLimit: Int = 5
    
    /// Returns true if user has reached free tier post limit
    func hasReachedPostLimit() -> Bool {
        !hasActivePremium && totalPosts >= User.freePostLimit
    }
    
    /// Returns true if user can create more personas
    func canCreatePersona(currentCount: Int) -> Bool {
        let limit = hasActivePremium ? User.premiumPersonaLimit : User.freePersonaLimit
        return currentCount < limit
    }
}

// MARK: - Mock Data (for previews and testing)

#if DEBUG
extension User {
    static let mock = User(
        name: "Austin English",
        bio: "Living life one post at a time 🌟",
        email: "austin@example.com",
        personas: [Persona.mockPersonal.id],
        preferences: UserPreferences(
            notificationsEnabled: true,
            memoryNotificationTime: Calendar.current.date(
                bySettingHour: 9,
                minute: 0,
                second: 0,
                of: Date()
            ),
            appLockEnabled: true
        ),
        isPremium: false,
        totalPosts: 42,
        currentStreak: 7,
        longestStreak: 21
    )
    
    static let mockPremium = User(
        name: "Premium User",
        bio: "Living my best life with premium features! ✨",
        email: "premium@example.com",
        personas: [
            Persona.mockPersonal.id,
            Persona.mockWork.id,
            Persona.mockFitness.id
        ],
        isPremium: true,
        premiumExpiresAt: Calendar.current.date(byAdding: .month, value: 6, to: Date()),
        totalPosts: 523,
        currentStreak: 42,
        longestStreak: 89
    )
    
    static let mockNewUser = User(
        name: "New User",
        totalPosts: 0,
        currentStreak: 0,
        longestStreak: 0
    )
}
#endif
