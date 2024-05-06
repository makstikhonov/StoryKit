//
//  viPagingModifier.swift
//  StoryKit
//
//  Created by Sakhabaev Egor on 06.05.2024.
//

import Foundation
import SwiftUI

/// Wrapper for .tint iOS 16+.
struct viPagingModifier: ViewModifier {

    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content.scrollTargetBehavior(.paging)
        } else {
            content
        }
    }
}

extension View {

    /// Wrapper for .tint iOS 16+.
    func pagingEnable() -> some View {
        modifier(viPagingModifier())
    }
}
