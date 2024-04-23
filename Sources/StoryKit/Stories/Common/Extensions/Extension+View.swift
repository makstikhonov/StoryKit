//
//  Extension+View.swift
//  uUI
//
//  Created by Sakhabaev Egor on 23.03.2024.
//

import SwiftUI

extension View {

    /// Can be used for Image to fit screen width/height
    func embedInContainer() -> some View {
        Color.clear
            .background(self)
    }
}
