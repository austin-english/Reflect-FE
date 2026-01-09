//
//  ReflectLogo.swift
//  reflect
//
//  Created by Austin English on 1/9/26.
//

import SwiftUI

/// Custom logo for Reflect app
/// Single person silhouette in a spotlight/circle
/// Represents "you're the only follower" - solo, personal, introspective
struct ReflectLogo: View {
    var size: CGFloat = 80
    var animated: Bool = false
    
    var body: some View {
        ZStack {
            // Outer glow/spotlight effect
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.reflectPrimary.opacity(0.15),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: size * 0.3,
                        endRadius: size * 0.7
                    )
                )
                .frame(width: size * 1.4, height: size * 1.4)
            
            // Main circle (your space, your bubble)
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.reflectPrimary.opacity(0.12),
                            Color.reflectPrimary.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
            
            // Subtle circle outline (boundary of your personal space)
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.reflectPrimary.opacity(0.4),
                            Color.reflectPrimary.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
                .frame(width: size, height: size)
            
            // Single person silhouette (you - the only follower)
            VStack(spacing: size * 0.08) {
                // Head
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.reflectPrimary.opacity(0.9),
                                Color.reflectPrimary
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size * 0.24, height: size * 0.24)
                
                // Body/torso
                RoundedRectangle(cornerRadius: size * 0.08)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.reflectPrimary.opacity(0.9),
                                Color.reflectPrimary
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: size * 0.32, height: size * 0.38)
            }
            .offset(y: -size * 0.02)
            
            // Subtle dot below (grounding, present moment)
            Circle()
                .fill(Color.reflectPrimary.opacity(0.3))
                .frame(width: size * 0.08, height: size * 0.08)
                .offset(y: size * 0.42)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Wave Shape

/// Custom shape for flowing wave curves
struct WaveShape: Shape {
    var amplitude: CGFloat
    var frequency: CGFloat
    var phase: CGFloat
    
    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let midHeight = height / 2
        
        path.move(to: CGPoint(x: 0, y: midHeight))
        
        for x in stride(from: 0, through: width, by: 1) {
            let relativeX = x / width
            let sine = sin((relativeX * frequency * 2 * .pi) + (phase * .pi / 180))
            let y = midHeight + (sine * amplitude)
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        // Close the path for filling
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Alternative Logo: Minimal Person Icon

/// Minimalist logo showing a single person (you're the only follower)
struct ReflectLogoMinimal: View {
    var size: CGFloat = 80
    var color: Color = .reflectPrimary
    
    var body: some View {
        ZStack {
            // Outer circle (your space)
            Circle()
                .stroke(color.opacity(0.2), lineWidth: 3)
                .frame(width: size * 1.2, height: size * 1.2)
            
            // Main circle background
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            color.opacity(0.15),
                            color.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
            
            // Person silhouette
            VStack(spacing: 2) {
                // Head
                Circle()
                    .fill(color)
                    .frame(width: size * 0.25, height: size * 0.25)
                
                // Body (shoulders)
                Capsule()
                    .fill(color)
                    .frame(width: size * 0.35, height: size * 0.3)
            }
            .offset(y: -size * 0.05)
        }
    }
}

// MARK: - Alternative Logo: Mirror Effect

/// Logo showing reflection/mirror effect (self-reflection concept)
struct ReflectLogoMirror: View {
    var size: CGFloat = 80
    
    var body: some View {
        ZStack {
            // Background glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.reflectPrimary.opacity(0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.6
                    )
                )
                .frame(width: size * 1.4, height: size * 1.4)
            
            // Top half (you)
            Circle()
                .trim(from: 0, to: 0.5)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.reflectPrimary,
                            Color.reflectPrimary.opacity(0.6)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(180))
            
            // Bottom half (your reflection)
            Circle()
                .trim(from: 0, to: 0.5)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.reflectPrimary.opacity(0.3),
                            Color.reflectPrimary.opacity(0.1)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: size, height: size)
            
            // Center dot (the present moment)
            Circle()
                .fill(Color.reflectPrimary)
                .frame(width: 8, height: 8)
        }
    }
}

// MARK: - Preview

#Preview("All Logos") {
    VStack(spacing: 40) {
        Text("Ripple Logo (Animated)")
            .font(.caption)
        ReflectLogo(size: 100, animated: true)
        
        Divider()
        
        Text("Minimal Person Logo")
            .font(.caption)
        ReflectLogoMinimal(size: 100)
        
        Divider()
        
        Text("Mirror/Reflection Logo")
            .font(.caption)
        ReflectLogoMirror(size: 100)
        
        Divider()
        
        Text("Different Sizes")
            .font(.caption)
        HStack(spacing: 20) {
            ReflectLogo(size: 40)
            ReflectLogo(size: 60)
            ReflectLogo(size: 80)
            ReflectLogo(size: 100)
        }
    }
    .padding()
}
