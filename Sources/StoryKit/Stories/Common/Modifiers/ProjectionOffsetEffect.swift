//
//  ProjectionOffsetEffect.swift
//  StoryKit
//
//  Created by Sakhabaev Egor on 27.10.2024.
//

import SwiftUI

/// Working replacement for .offset in scoped animation
/// https://forums.developer.apple.com/forums/thread/748852
struct ProjectionOffsetEffect: GeometryEffect {

    var translation: CGPoint
    var animatableData: CGPoint.AnimatableData {
        get { translation.animatableData }
        set { translation = .init(x: newValue.first, y: newValue.second) }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        .init(CGAffineTransform(translationX: translation.x, y: translation.y))
    }
}

extension View {

    /// Working replacement for .offset in scoped animation
    /// https://forums.developer.apple.com/forums/thread/748852
    func projectionOffset(_ translation: CGPoint) -> some View {
        modifier(ProjectionOffsetEffect(translation: translation))
    }

    /// Working replacement for .offset in scoped animation
    /// https://forums.developer.apple.com/forums/thread/748852
    func projectionOffset(x: CGFloat = 0, y: CGFloat = 0) -> some View {
        self.projectionOffset(.init(x: x, y: y))
    }

    /// Working replacement for .offset in scoped animation
    /// https://forums.developer.apple.com/forums/thread/748852
    func projectionOffset(_ offset: CGSize) -> some View {
        self.projectionOffset(.init(x: offset.width, y: offset.height))
    }
}
