//
//  DesignSystem.swift
//  reflect
//
//  Created by Austin English on 12/16/25.
//

import SwiftUI

// MARK: - Colors

extension Color {
    
    // MARK: - Brand Colors
    
    /// Primary brand color - used for main actions and emphasis
    static let reflectPrimary = Color.blue
    
    /// Secondary brand color - used for accents
    static let reflectSecondary = Color.purple
    
    /// Success/positive color
    static let reflectSuccess = Color.green
    
    /// Warning color
    static let reflectWarning = Color.orange
    
    /// Error/destructive color
    static let reflectError = Color.red
    
    // MARK: - Background Colors
    
    /// Main background color for views
    static let reflectBackground = Color(uiColor: .systemGroupedBackground)
    
    /// Aged paper base color - warm beige/cream for scrapbook background
    static let agedPaper = Color(hex: "E8E4D9")
    
    /// Card/surface background color - Slightly aged Polaroid white
    static let reflectSurface = Color(hex: "FFFEF9")
    
    /// Polaroid card background - Warm off-white (same as surface, explicit for clarity)
    static let polaroidWhite = Color(hex: "FFFEF9")
    
    /// Elevated surface (for cards on cards)
    static let reflectSurfaceElevated = Color(uiColor: .tertiarySystemGroupedBackground)
    
    // MARK: - Text Colors
    
    /// Primary text color
    static let reflectTextPrimary = Color.primary
    
    /// Secondary text color (subtitles, captions)
    static let reflectTextSecondary = Color.secondary
    
    /// Tertiary text color (hints, placeholders)
    static let reflectTextTertiary = Color(uiColor: .tertiaryLabel)
    
    // MARK: - Mood Colors (1-10 scale)
    
    /// Get color for mood value (1-10)
    static func moodColor(for value: Int) -> Color {
        switch value {
        case 1...2: return Color.red
        case 3...4: return Color.orange
        case 5...6: return Color.yellow
        case 7...8: return Color.green
        case 9...10: return Color.blue
        default: return Color.gray
        }
    }
    
    /// Gradient for mood slider (red → orange → yellow → green → blue)
    static let moodGradient = LinearGradient(
        colors: [.red, .orange, .yellow, .green, .blue],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    // MARK: - Persona Colors
    
    /// Convert PersonaColor enum to SwiftUI Color
    static func personaColor(_ color: Persona.PersonaColor) -> Color {
        switch color {
        case .blue: return .blue
        case .green: return .green
        case .purple: return .purple
        case .orange: return .orange
        case .red: return .red
        case .pink: return .pink
        case .yellow: return .yellow
        case .teal: return .teal
        case .indigo: return .indigo
        case .gray: return .gray
        }
    }
    
    // MARK: - Helper: Initialize from hex
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Spacing

/// Consistent spacing scale throughout the app
/// Based on 4pt grid system
enum Spacing: CGFloat {
    case none = 0
    case tight = 2       // 2pt - Very tight spacing
    case xsmall = 4      // 4pt - Extra small spacing
    case small = 8       // 8pt - Small spacing
    case medium = 16     // 16pt - Standard spacing
    case large = 24      // 24pt - Large spacing
    case extraLarge = 32 // 32pt - Extra large spacing
    case huge = 48       // 48pt - Huge spacing
    case massive = 64    // 64pt - Massive spacing
}

// MARK: - Corner Radius

/// Consistent corner radius values
enum CornerRadius: CGFloat {
    case small = 8
    case medium = 12
    case large = 16
    case extraLarge = 20
    case circle = 9999  // Used for fully rounded corners
}

// MARK: - Typography

extension Font {
    
    // MARK: - Display (Large titles)
    
    static let displayLarge = Font.system(size: 34, weight: .bold, design: .rounded)
    static let displayMedium = Font.system(size: 28, weight: .bold, design: .rounded)
    static let displaySmall = Font.system(size: 22, weight: .bold, design: .rounded)
    
    // MARK: - Headline
    
    static let headlineLarge = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let headlineMedium = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let headlineSmall = Font.system(size: 15, weight: .semibold, design: .rounded)
    
    // MARK: - Body
    
    static let bodyLarge = Font.system(size: 17, weight: .regular, design: .rounded)
    static let bodyMedium = Font.system(size: 15, weight: .regular, design: .rounded)
    static let bodySmall = Font.system(size: 13, weight: .regular, design: .rounded)
    
    // MARK: - Label
    
    static let labelLarge = Font.system(size: 14, weight: .medium, design: .rounded)
    static let labelMedium = Font.system(size: 12, weight: .medium, design: .rounded)
    static let labelSmall = Font.system(size: 11, weight: .medium, design: .rounded)
    
    // MARK: - Caption
    
    static let captionLarge = Font.system(size: 12, weight: .regular, design: .rounded)
    static let captionMedium = Font.system(size: 11, weight: .regular, design: .rounded)
    static let captionSmall = Font.system(size: 10, weight: .regular, design: .rounded)
}

// MARK: - Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    var isEnabled: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headlineMedium)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(isEnabled ? Color.reflectPrimary : Color.gray)
            .cornerRadius(CornerRadius.medium.rawValue)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headlineMedium)
            .foregroundStyle(Color.reflectPrimary)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.reflectPrimary.opacity(0.1))
            .cornerRadius(CornerRadius.medium.rawValue)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct TextButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headlineMedium)
            .foregroundStyle(Color.reflectPrimary)
            .opacity(configuration.isPressed ? 0.6 : 1.0)
    }
}

// MARK: - View Modifiers

extension View {
    
    /// Apply card styling (background + shadow)
    func cardStyle() -> some View {
        self
            .background(Color.reflectSurface)
            .cornerRadius(CornerRadius.medium.rawValue)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    /// Apply primary button styling
    func primaryButton(isEnabled: Bool = true) -> some View {
        self.buttonStyle(PrimaryButtonStyle(isEnabled: isEnabled))
    }
    
    /// Apply secondary button styling
    func secondaryButton() -> some View {
        self.buttonStyle(SecondaryButtonStyle())
    }
    
    /// Apply text button styling
    func textButton() -> some View {
        self.buttonStyle(TextButtonStyle())
    }
}

// MARK: - Shadow Styles

enum ShadowStyle {
    case small
    case medium
    case large
    case polaroid  // Soft, elevated shadow for Polaroid cards
    
    var radius: CGFloat {
        switch self {
        case .small: return 2
        case .medium: return 4
        case .large: return 8
        case .polaroid: return 15
        }
    }
    
    var y: CGFloat {
        switch self {
        case .small: return 1
        case .medium: return 2
        case .large: return 4
        case .polaroid: return 6
        }
    }
    
    var opacity: Double {
        switch self {
        case .small: return 0.1
        case .medium: return 0.1
        case .large: return 0.1
        case .polaroid: return 0.1  // Gentle shadow for Polaroid cards
        }
    }
}

extension View {
    func shadow(_ style: ShadowStyle) -> some View {
        self.shadow(
            color: Color.black.opacity(style.opacity),
            radius: style.radius,
            x: 0,
            y: style.y
        )
    }
}
