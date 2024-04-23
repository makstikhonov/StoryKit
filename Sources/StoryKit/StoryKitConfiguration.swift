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
        case press
        case auto
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

        public var storyDidShow: (_ story: StoryKit.Story) -> Void
        public var storyDidMoveToPageWithAction: (
            _ story: StoryKit.Story,
            _ page: StoryKit.Story.PageData,
            _ actionType: StoryKit.ActionType
        ) -> Void
        public var storyDidMoveToStoryWithAction: (
            _ story: StoryKit.Story,
            _ newStory: StoryKit.Story,
            _ actionType: StoryKit.ActionType
        ) -> Void
        public var storyDidClose: (
            _ story: StoryKit.Story,
            _ actionType: StoryKit.ActionType
        ) -> Void

        public init(
            storyDidShow: @escaping(_ story: StoryKit.Story) -> Void,
            storyDidMoveToPageWithAction: @escaping (
                _ story: StoryKit.Story,
                _ page: StoryKit.Story.PageData,
                _ actionType: StoryKit.ActionType
            ) -> Void,
            storyDidMoveToStoryWithAction: @escaping (
                _ story: StoryKit.Story,
                _ newStory: StoryKit.Story,
                _ actionType: StoryKit.ActionType
            ) -> Void,
            storyDidClose: @escaping (
                _ story: StoryKit.Story,
                _ actionType: StoryKit.ActionType
            ) -> Void
        ) {
            self.storyDidShow = storyDidShow
            self.storyDidMoveToPageWithAction = storyDidMoveToPageWithAction
            self.storyDidMoveToStoryWithAction = storyDidMoveToStoryWithAction
            self.storyDidClose = storyDidClose
        }
    }
}
