//
//  ReflectLogoAlternatives.swift
//  reflect
//
//  Created by Austin English on 1/13/26.
//

import SwiftUI

/// Alternative logo designs for Reflect app
/// These are exploration concepts not currently in use
/// Kept for reference and potential future use

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

#Preview("Alternative Logos") {
    VStack(spacing: 40) {
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
    }
    .padding()
}
