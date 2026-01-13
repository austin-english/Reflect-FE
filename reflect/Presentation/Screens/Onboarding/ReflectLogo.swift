//
//  ReflectLogo.swift
//  reflect
//
//  Created by Austin English on 1/9/26.
//

import SwiftUI

/// Custom logo for Reflect app
/// Water ripple design - like dropping a stone into a still pond
/// Represents "you're the only follower" - solo, personal, introspective
/// The ripple symbolizes the impact of self-reflection spreading outward
struct ReflectLogo: View {
    var size: CGFloat = 80
    var animated: Bool = false
    
    var body: some View {
        ZStack {
            // Subtle background glow (water surface ambiance)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.reflectPrimary.opacity(0.06),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.6
                    )
                )
                .frame(width: size * 1.2, height: size * 1.2)
            
            // Fourth ripple (outermost, faintest)
            Circle()
                .stroke(
                    Color.reflectPrimary.opacity(0.12),
                    lineWidth: 1.5
                )
                .frame(width: size, height: size)
            
            // Third ripple
            Circle()
                .stroke(
                    Color.reflectPrimary.opacity(0.2),
                    lineWidth: 2
                )
                .frame(width: size * 0.75, height: size * 0.75)
            
            // Second ripple
            Circle()
                .stroke(
                    Color.reflectPrimary.opacity(0.35),
                    lineWidth: 2.5
                )
                .frame(width: size * 0.5, height: size * 0.5)
            
            // First ripple (closest to center)
            Circle()
                .stroke(
                    Color.reflectPrimary.opacity(0.5),
                    lineWidth: 2.5
                )
                .frame(width: size * 0.3, height: size * 0.3)
            
            // Center impact point (where the stone hit)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.reflectPrimary.opacity(0.8),
                            Color.reflectPrimary.opacity(0.6)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.08
                    )
                )
                .frame(width: size * 0.16, height: size * 0.16)
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

// MARK: - Alternative Logo: Minimal Ripple

/// Minimalist ripple logo - simplified concentric circles
/// Represents introspection and personal reflection
struct ReflectLogoMinimal: View {
    var size: CGFloat = 80
    var color: Color = .reflectPrimary
    
    var body: some View {
        ZStack {
            // Background glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            color.opacity(0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.5
                    )
                )
                .frame(width: size, height: size)
            
            // Outer ring
            Circle()
                .stroke(color.opacity(0.25), lineWidth: 2)
                .frame(width: size * 0.85, height: size * 0.85)
            
            // Middle ring
            Circle()
                .stroke(color.opacity(0.45), lineWidth: 2.5)
                .frame(width: size * 0.55, height: size * 0.55)
            
            // Inner ring
            Circle()
                .stroke(color.opacity(0.65), lineWidth: 3)
                .frame(width: size * 0.3, height: size * 0.3)
            
            // Center dot
            Circle()
                .fill(color)
                .frame(width: size * 0.15, height: size * 0.15)
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

// MARK: - Alternative Logo: Inner Light

/// Abstract logo showing inner light/focus radiating outward
/// Represents personal growth and self-awareness
struct ReflectLogoInnerLight: View {
    var size: CGFloat = 80
    
    var body: some View {
        ZStack {
            // Outer subtle glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.reflectPrimary.opacity(0.05),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: size * 0.2,
                        endRadius: size * 0.6
                    )
                )
                .frame(width: size * 1.2, height: size * 1.2)
            
            // Radiating arcs (like light beams)
            ForEach(0..<6) { index in
                Circle()
                    .trim(from: CGFloat(index) / 12.0, to: CGFloat(index) / 12.0 + 0.04)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.reflectPrimary.opacity(0.6),
                                Color.reflectSecondary.opacity(0.3)
                            ],
                            startPoint: .center,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: size * 0.75, height: size * 0.75)
                    .rotationEffect(.degrees(Double(index) * 60))
            }
            
            // Middle circle (boundary)
            Circle()
                .stroke(
                    Color.reflectPrimary.opacity(0.2),
                    lineWidth: 1.5
                )
                .frame(width: size * 0.5, height: size * 0.5)
            
            // Core center (the self)
            ZStack {
                // Bright center
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white,
                                Color.reflectPrimary,
                                Color.reflectSecondary
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: size * 0.12
                        )
                    )
                    .frame(width: size * 0.24, height: size * 0.24)
                
                // Inner glow
                Circle()
                    .fill(Color.reflectPrimary)
                    .frame(width: size * 0.18, height: size * 0.18)
                    .blur(radius: 4)
            }
        }
    }
}

// MARK: - Preview

#Preview("All Logos") {
    VStack(spacing: 40) {
        Text("Ripple Logo (Main)")
            .font(.caption)
            .foregroundStyle(.secondary)
        ReflectLogo(size: 100)
        
        Divider()
        
        Text("Minimal Ripple Logo")
            .font(.caption)
            .foregroundStyle(.secondary)
        ReflectLogoMinimal(size: 100)
        
        Divider()
        
        Text("Mirror/Reflection Logo")
            .font(.caption)
            .foregroundStyle(.secondary)
        ReflectLogoMirror(size: 100)
        
        Divider()
        
        Text("Inner Light Logo")
            .font(.caption)
            .foregroundStyle(.secondary)
        ReflectLogoInnerLight(size: 100)
        
        Divider()
        
        Text("Different Sizes")
            .font(.caption)
            .foregroundStyle(.secondary)
        HStack(spacing: 20) {
            ReflectLogo(size: 40)
            ReflectLogo(size: 60)
            ReflectLogo(size: 80)
            ReflectLogo(size: 100)
        }
    }
    .padding()
}
