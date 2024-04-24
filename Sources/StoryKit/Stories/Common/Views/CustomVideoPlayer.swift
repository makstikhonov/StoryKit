//
//  CustomVideoPlayer.swift
//  StoryKit
//
//  Created by Sakhabaev Egor on 24.04.2024.
//

import UIKit
import SwiftUI
import AVKit

struct CustomVideoPlayer : UIViewControllerRepresentable {
    var player : AVPlayer

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {

    }
}
