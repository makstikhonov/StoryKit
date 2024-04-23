//
//  ProgressView.swift
//  
//
//  Created by Sakhabaev Egor on 12.04.2024.
//

import SwiftUI

struct ProgressView: View {

    var progress: Double

    var body: some View {
        GeometryReader { geo in
            Capsule()
                .foregroundColor(.white.opacity(0.3))
                .overlay(
                    Capsule()
                        .fill(.white)
                        .frame(width: geo.size.width * min(progress, 1.0)),
                    alignment: .leading
                )
        }
    }
}

#Preview {
    ZStack {
        Color.black
        ProgressView(progress: 0.5)
            .frame(height: 2)
    }
}
