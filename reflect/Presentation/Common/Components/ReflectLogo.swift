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

// MARK: - Preview

#Preview("Ripple Logo") {
    VStack(spacing: 40) {
        Text("Main Logo")
            .font(.caption)
            .foregroundStyle(.secondary)
        ReflectLogo(size: 100)
        
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
