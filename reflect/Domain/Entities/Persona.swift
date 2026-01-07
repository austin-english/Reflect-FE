//
//  Persona.swift
//  reflect
//
//  Created by Austin English on 12/4/25.
//

import Foundation
import SwiftUI

/// Domain entity representing a user's persona (different aspects of their life)
struct Persona: Identifiable, Codable {
    // MARK: - Properties
    
    let id: UUID
    var name: String
    var color: PersonaColor
    var icon: PersonaIcon
    var description: String?
    var createdAt: Date
    var isDefault: Bool
    
    // MARK: - Relationships
    
    var userId: UUID // Reference to User
    
    // MARK: - Initialization
    
    init(
        id: UUID = UUID(),
        name: String,
        color: PersonaColor = .blue,
        icon: PersonaIcon = .person,
        description: String? = nil,
        createdAt: Date = Date(),
        isDefault: Bool = false,
        userId: UUID
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.icon = icon
        self.description = description
        self.createdAt = createdAt
        self.isDefault = isDefault
        self.userId = userId
    }
}

// MARK: - Persona Color

extension Persona {
    enum PersonaColor: String, Codable, CaseIterable {
        case blue
        case purple
        case pink
        case red
        case orange
        case yellow
        case green
        case teal
        case indigo
        case gray
        
        var displayName: String {
            rawValue.capitalized
        }
        
        var color: Color {
            switch self {
            case .blue: return .blue
            case .purple: return .purple
            case .pink: return .pink
            case .red: return .red
            case .orange: return .orange
            case .yellow: return .yellow
            case .green: return .green
            case .teal: return .teal
            case .indigo: return .indigo
            case .gray: return .gray
            }
        }
        
        var hexValue: String {
            switch self {
            case .blue: return "007AFF"
            case .purple: return "5856D6"
            case .pink: return "FF2D55"
            case .red: return "FF3B30"
            case .orange: return "FF9500"
            case .yellow: return "FFCC00"
            case .green: return "34C759"
            case .teal: return "5AC8FA"
            case .indigo: return "5856D6"
            case .gray: return "8E8E93"
            }
        }
    }
}

// MARK: - Persona Icon

extension Persona {
    enum PersonaIcon: String, Codable, CaseIterable {
        // People & Life
        case person = "person.fill"
        case personCircle = "person.circle.fill"
        case personBubble = "person.bubble.fill"
        
        // Work & Career
        case briefcase = "briefcase.fill"
        case laptopcomputer = "laptopcomputer"
        case desktopcomputer = "desktopcomputer"
        
        // Health & Fitness
        case heart = "heart.fill"
        case figureWalk = "figure.walk"
        case figureRun = "figure.run"
        case dumbbell = "dumbbell.fill"
        
        // Creative & Hobbies
        case paintpalette = "paintpalette.fill"
        case music = "music.note"
        case book = "book.fill"
        case camera = "camera.fill"
        
        // Home & Family
        case house = "house.fill"
        case heart2persons = "heart.text.square.fill"
        
        // Nature & Travel
        case leaf = "leaf.fill"
        case globe = "globe.americas.fill"
        case airplane = "airplane"
        case mountain = "mountain.2.fill"
        
        // Food
        case fork = "fork.knife"
        case cup = "cup.and.saucer.fill"
        
        // Mental & Spiritual
        case brain = "brain.head.profile"
        case sparkles = "sparkles"
        case moon = "moon.stars.fill"
        
        // Fun & Social
        case gamecontroller = "gamecontroller.fill"
        case party = "party.popper.fill"
        case star = "star.fill"
        
        var displayName: String {
            // Convert symbol name to readable name
            rawValue
                .replacingOccurrences(of: ".", with: " ")
                .replacingOccurrences(of: "fill", with: "")
                .trimmingCharacters(in: .whitespaces)
                .capitalized
        }
    }
}

// MARK: - Persona Presets

extension Persona {
    /// Predefined persona templates for easy setup
    enum Preset {
        case personal
        case work
        case fitness
        case creative
        case family
        case travel
        
        var name: String {
            switch self {
            case .personal: return "Personal"
            case .work: return "Work"
            case .fitness: return "Fitness"
            case .creative: return "Creative"
            case .family: return "Family"
            case .travel: return "Travel"
            }
        }
        
        var color: PersonaColor {
            switch self {
            case .personal: return .blue
            case .work: return .gray
            case .fitness: return .green
            case .creative: return .purple
            case .family: return .pink
            case .travel: return .teal
            }
        }
        
        var icon: PersonaIcon {
            switch self {
            case .personal: return .personCircle
            case .work: return .briefcase
            case .fitness: return .dumbbell
            case .creative: return .paintpalette
            case .family: return .heart2persons
            case .travel: return .airplane
            }
        }
        
        var description: String {
            switch self {
            case .personal: return "Your everyday life and thoughts"
            case .work: return "Career, projects, and professional growth"
            case .fitness: return "Workouts, health, and wellness journey"
            case .creative: return "Art, music, writing, and creative projects"
            case .family: return "Family moments and relationships"
            case .travel: return "Adventures, trips, and exploration"
            }
        }
        
        func create(userId: UUID, isDefault: Bool = false) -> Persona {
            Persona(
                name: name,
                color: color,
                icon: icon,
                description: description,
                isDefault: isDefault,
                userId: userId
            )
        }
    }
    
    /// Create persona from preset
    static func from(preset: Preset, userId: UUID, isDefault: Bool = false) -> Persona {
        preset.create(userId: userId, isDefault: isDefault)
    }
}

// MARK: - Computed Properties

extension Persona {
    /// Returns SwiftUI Color for this persona
    var swiftUIColor: Color {
        color.color
    }
    
    /// Returns SF Symbol name for this persona's icon
    var symbolName: String {
        icon.rawValue
    }
}

// MARK: - Validation

extension Persona {
    /// Validates persona name is not empty
    var hasValidName: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// Maximum name length
    static let maxNameLength = 30
    
    /// Validates persona name length
    var hasValidNameLength: Bool {
        name.count <= Persona.maxNameLength
    }
    
    /// Returns validation errors if any
    var validationErrors: [String] {
        var errors: [String] = []
        
        if !hasValidName {
            errors.append("Persona name cannot be empty")
        }
        
        if !hasValidNameLength {
            errors.append("Persona name must be \(Persona.maxNameLength) characters or less")
        }
        
        return errors
    }
    
    /// Returns true if persona is valid
    var isValid: Bool {
        validationErrors.isEmpty
    }
}

// MARK: - Mock Data (for previews and testing)

#if DEBUG
extension Persona {
    static let mockPersonal = Persona(
        name: "Personal",
        color: .blue,
        icon: .personCircle,
        description: "My everyday life and thoughts",
        isDefault: true,
        userId: UUID()
    )
    
    static let mockWork = Persona(
        name: "Work",
        color: .gray,
        icon: .briefcase,
        description: "Career and professional growth",
        userId: UUID()
    )
    
    static let mockFitness = Persona(
        name: "Fitness",
        color: .green,
        icon: .dumbbell,
        description: "Health and wellness journey",
        userId: UUID()
    )
    
    static let mockCreative = Persona(
        name: "Creative",
        color: .purple,
        icon: .paintpalette,
        description: "Art and creative projects",
        userId: UUID()
    )
    
    static let mockFamily = Persona(
        name: "Family",
        color: .pink,
        icon: .heart2persons,
        description: "Family moments",
        userId: UUID()
    )
    
    static let mockTravel = Persona(
        name: "Travel",
        color: .teal,
        icon: .airplane,
        description: "Adventures and exploration",
        userId: UUID()
    )
    
    static let allMocks = [
        mockPersonal,
        mockWork,
        mockFitness,
        mockCreative,
        mockFamily,
        mockTravel
    ]
}
#endif
