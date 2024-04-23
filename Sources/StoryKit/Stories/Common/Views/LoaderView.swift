//
//  LoaderView.swift
//  StoryKit
//
//  Created by Sakhabaev Egor on 16.04.2024.
//

import SwiftUI

struct LoaderView: View {

    @State private var isAnimating = false
    var color: Color

    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: 0.6)
                .stroke(color, lineWidth: 4)
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(.linear(duration: 1.5).repeatForever(autoreverses: false), value: isAnimating)
                .onAppear() {
                    self.isAnimating = true
                }
        }
    }
}

#Preview {
    LoaderView(color: .black)
}
