//
//  StoryKitConfiguration.swift
//  StoryKit
//
//  Created by Sakhabaev Egor on 21.04.2024.
//

import Foundation

public extension StoryKit {

    enum ActionType {
        case slide
        case click
        case button
        case auto
    }

    enum Direction {
        case forward
        case back
        case down
    }
}


public extension StoryKit {

    struct Configuration {

        public let actions: Actions

        public init(actions: Actions) {
            self.actions = actions
        }
    }
}

public extension StoryKit.Configuration {

    struct Actions {

        public var storyDidShow: (_ story: StoryKit.Story, _ page: StoryKit.Story.PageData) -> Void
        public var storyDidMoveToPageWithAction: (
            _ story: StoryKit.Story,
            _ newPage: StoryKit.Story.PageData,
            _ direction: StoryKit.Direction,
            _ actionType: StoryKit.ActionType,
            _ showDuration: TimeInterval
        ) -> Void
        public var storyDidMoveFromPageToStoryWithAction: (
            _ story: StoryKit.Story,
            _ page: StoryKit.Story.PageData,
            _ newStory: StoryKit.Story,
            _ direction: StoryKit.Direction,
            _ actionType: StoryKit.ActionType,
            _ showDuration: TimeInterval
        ) -> Void
        public var storyDidClose: (
            _ story: StoryKit.Story,
            _ page: StoryKit.Story.PageData,
            _ actionType: StoryKit.ActionType,
            _ direction: StoryKit.Direction?,
            _ showDuration: TimeInterval
        ) -> Void
        public var storyPageDidSelectActionButton: (
            _ story: StoryKit.Story,
            _ page: StoryKit.Story.PageData
        ) -> Void

        public init(
            storyDidShow: @escaping(_ story: StoryKit.Story, _ page: StoryKit.Story.PageData) -> Void,
            storyDidMoveToPageWithAction: @escaping (
                _ story: StoryKit.Story,
                _ newPage: StoryKit.Story.PageData,
                _ direction: StoryKit.Direction,
                _ actionType: StoryKit.ActionType,
                _ showDuration: TimeInterval
            ) -> Void,
            storyDidMoveFromPageToStoryWithAction: @escaping (
                _ story: StoryKit.Story,
                _ page: StoryKit.Story.PageData,
                _ newStory: StoryKit.Story,
                _ direction: StoryKit.Direction,
                _ actionType: StoryKit.ActionType,
                _ showDuration: TimeInterval
            ) -> Void,
            storyDidClose: @escaping (
                _ story: StoryKit.Story,
                _ page: StoryKit.Story.PageData,
                _ actionType: StoryKit.ActionType,
                _ direction: StoryKit.Direction?,
                _ showDuration: TimeInterval
            ) -> Void,
            storyPageDidSelectActionButton: @escaping (
                _ story: StoryKit.Story,
                _ page: StoryKit.Story.PageData
            ) -> Void
        ) {
            self.storyDidShow = storyDidShow
            self.storyDidMoveToPageWithAction = storyDidMoveToPageWithAction
            self.storyDidMoveFromPageToStoryWithAction = storyDidMoveFromPageToStoryWithAction
            self.storyDidClose = storyDidClose
            self.storyPageDidSelectActionButton = storyPageDidSelectActionButton
        }
    }
}
