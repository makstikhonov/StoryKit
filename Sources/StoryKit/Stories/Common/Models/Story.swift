//
//  StoryData.swift
//  OlimpBetAppClip
//
//  Created by Sakhabaev Egor on 11.04.2024.
//

import SwiftUI

public extension StoryKit {

    struct Story: Identifiable {

        public let id: String
        public let pages: [PageData]

        public init(id: String, pages: [PageData]) {
            self.id = id
            self.pages = pages
        }
    }
}

public extension StoryKit.Story {

    struct PageData: Identifiable {

        public enum ContentType {
            case image(url: URL)
            case video(url: URL)
        }

        public struct ButtonData {

            let titleColor: Color
            let backgroundColor: Color
            let title: String
            let link: URL
            let font: Font
            let height: CGFloat
            let cornerRadius: CGFloat
            let horizontalPadding: CGFloat
            let bottomPadding: CGFloat

            public init(
                titleColor: Color,
                backgroundColor: Color,
                title: String,
                link: URL,
                font: Font = .system(size: 17.0, weight: .medium),
                height: CGFloat = 54,
                cornerRadius: CGFloat = 18,
                horizontalPadding: CGFloat = 24,
                bottomPadding: CGFloat = 50
            ) {
                self.titleColor = titleColor
                self.backgroundColor = backgroundColor
                self.title = title
                self.link = link
                self.font = font
                self.height = height
                self.cornerRadius = cornerRadius
                self.horizontalPadding = horizontalPadding
                self.bottomPadding = bottomPadding
            }
        }

        public let id: String
        public let duration: Double
        public let contentType: ContentType
        public let buttonData: ButtonData?

        public init(id: String, duration: Double, contentType: ContentType, buttonData: ButtonData? = nil) {
            self.id = id
            self.duration = duration
            self.contentType = contentType
            self.buttonData = buttonData
        }
    }
}
