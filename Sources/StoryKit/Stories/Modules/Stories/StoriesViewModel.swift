//
//  StoriesViewModel.swift
//  StoryKit
//
//  Created by Sakhabaev Egor on 15.04.2024.
//

import SwiftUI

class StoriesViewModel: ObservableObject {

    let stories: [StoryKit.Story]
    let initialIndex: Int

    @Published var currentStoryIndex: Int {
        didSet {
            updateStories()
        }
    }
    let storiesViewModels: [StoryViewModel]
    @Published var isDismissing: Bool = false

    init(stories: [StoryKit.Story], initialIndex: Int) {
        self.stories = stories
        self.initialIndex = initialIndex
        self.currentStoryIndex = initialIndex

        self.storiesViewModels = stories.enumerated().map {
            StoryViewModel.init(story: $1, isActive: $0 == initialIndex)
        }
        self.storiesViewModels.forEach {
            $0.didEndView = didEndViewStory(_:)
            $0.didRequestBack = didRequestBack
        }
        // Prepare data for first and next stories
        self.storiesViewModels[currentStoryIndex].prepareData()
        updateStories()
    }

    func didEndViewStory(_ actionType: StoryKit.ActionType) -> Void {
        showStory(at: currentStoryIndex + 1, byAction: actionType)
    }

    func didRequestBack(_ actionType: StoryKit.ActionType) -> Void {
        showStory(at: currentStoryIndex - 1, byAction: actionType)
    }

    func didStartSlideStories() {
        storiesViewModels.forEach { $0.isActive = false }
    }

    func didEndSlideStories(toIndex index: Int) {
        showStory(at: index, byAction: .slide)
    }

    func didDismiss(byAction actionType: StoryKit.ActionType) {
        isDismissing = true
        StoryKit.configuration?.actions.storyDidClose(stories[currentStoryIndex], actionType)
    }
}

// MARK: - Private methods
extension StoriesViewModel {

    func showStory(at index: Int, byAction actionType: StoryKit.ActionType) {
        let isNext = currentStoryIndex < index
        switch isNext {
        case true:
            if stories.count - 1 >= index {
                StoryKit.configuration?.actions.storyDidMoveToStoryWithAction(
                    stories[currentStoryIndex],
                    stories[index],
                    .slide
                )
                currentStoryIndex = index
            } else {
                didDismiss(byAction: actionType)
            }
        case false:
            if index >= 0 {
                StoryKit.configuration?.actions.storyDidMoveToStoryWithAction(
                    stories[currentStoryIndex],
                    stories[index],
                    .slide
                )
                currentStoryIndex = index
            } else {
                didDismiss(byAction: actionType)
            }
        }
    }

    func updateStories() {
        storiesViewModels.enumerated().forEach { index, element in
            element.isActive = index == currentStoryIndex
            if index != currentStoryIndex {
                // Reset story progress to current page start for other stories
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    element.moveProgress(toPage: element.currentPageIndex)
                }
            }
        }
        if currentStoryIndex + 1 < storiesViewModels.count {
            storiesViewModels[currentStoryIndex + 1].prepareData()
        }
    }
}
