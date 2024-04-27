//
//  PageView.swift
//
//  Created by Sakhabaev Egor on 11.04.2024.
//

import SwiftUI
import AVKit

struct PageView: View {

    @Environment (\.scenePhase) private var scenePhase

    let pageData: Data
    @State var avPlayer: AVPlayer = .init()
    @Binding var isPaused: Bool

    var body: some View {
        ZStack(alignment: .bottom) {
            switch pageData.contentType {
            case .image(let image):
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .embedInContainer()
                    .allowsHitTesting(false)
            case .video(let url):
                CustomVideoPlayer(player: avPlayer)
                    .onAppear {
                        avPlayer.replaceCurrentItem(with: .init(url: url))
                        if !isPaused {
                            avPlayer.play()
                        }
                    }
                    .allowsHitTesting(false)
                    .onChange(of: isPaused) { newValue in
                        newValue ? avPlayer.pause() : avPlayer.play()
                    }
                    .onChange(of: scenePhase) { phase in
                        switch phase {
                        case .active where !isPaused:
                            avPlayer.play()
                        default:
                            break
                        }
                    }
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                        if !isPaused {
                            avPlayer.play()
                        }
                    }
            }
            if let buttonData = pageData.buttonData {
                Button(action: pageData.buttonSelectionAction) {
                    Text(buttonData.title)
                        .font(.system(size: 17, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(buttonData.backgroundColor)
                        .foregroundColor(buttonData.titleColor)
                        .tintColor(buttonData.titleColor)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                }
            }
        }
        .ignoresSafeArea()
    }
}

extension PageView {

    enum ContentType {
        case image(_ image: UIImage)
        case video(url: URL)
    }

    struct Data {
        let id: String
        let duration: Double
        let contentType: ContentType
        let buttonData: StoryKit.Story.PageData.ButtonData?
        let buttonSelectionAction: () -> Void
    }
}

#Preview {
    let data = try! Data(contentsOf: .init(string: "https://m.media-amazon.com/images/I/71HvRxH2bgL._AC_UF1000,1000_QL80_.jpg")!)
    let image = UIImage(data: data)!
    return PageView(
        pageData: .init(
            id: UUID().uuidString,
            duration: 10,
            contentType: .image(image),
            buttonData: .init(
                titleColor: .black,
                backgroundColor: .yellow,
                title: "Button name",
                link: .init(string: "https://apple.com")!
            ),
            buttonSelectionAction: {}
        ),
        isPaused: .constant(false)
    )
}
