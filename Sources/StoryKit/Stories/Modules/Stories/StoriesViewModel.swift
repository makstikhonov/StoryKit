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
    var storiesViewModels: [StoryViewModel]
    var isDragging: Bool = false
    @Published var isDismissing: Bool = false
    private var storyShowStartDate: Date?

    init(stories: [StoryKit.Story], initialIndex: Int) {
        self.stories = stories
        self.initialIndex = initialIndex
        self.currentStoryIndex = initialIndex

        self.storiesViewModels = stories.enumerated().map {
            StoryViewModel.init(story: $1, isActive: $0 == initialIndex)
        }
        self.storiesViewModels.forEach {
            $0.didEndView = { [weak self] actionType in
                self?.didEndViewStory(actionType)
            }
            $0.didRequestBack = { [weak self] actionType in
                self?.didRequestBack(actionType)
            }
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

    func didChangeDragLocation() {
        guard !isDragging else { return }
        isDragging = true
        storiesViewModels.forEach { $0.isActive = false }
    }

    func didCancelDismiss() {
        isDragging = false
        storiesViewModels.enumerated().forEach { $0.element.isActive = $0.offset == currentStoryIndex }
    }

    func didDismiss(byAction actionType: StoryKit.ActionType, direction: StoryKit.Direction?) {
        isDismissing = true
        StoryKit.configuration?.actions.storyDidClose(
            stories[currentStoryIndex],
            storiesViewModels[currentStoryIndex].story.pages[storiesViewModels[currentStoryIndex].currentPageIndex],
            actionType,
            direction,
            Date().timeIntervalSince(storyShowStartDate ?? Date())
        )
        storiesViewModels.forEach { $0.destroyTimer() }
    }

    // MARK: - Lifecycle -
    func viewDidAppear() {
        storyShowStartDate = Date()
    }
}

// MARK: - Private methods
extension StoriesViewModel {

    func showStory(at index: Int, byAction actionType: StoryKit.ActionType) {
        defer {
            storyShowStartDate = Date()
        }
        let isNext = currentStoryIndex < index
        switch isNext {
        case true:
            if stories.count - 1 >= index {
                // Page in new story
                let page = storiesViewModels[index].story.pages[storiesViewModels[index].currentPageIndex]
                StoryKit.configuration?.actions.storyDidMoveFromPageToStoryWithAction(
                    stories[currentStoryIndex],
                    page,
                    stories[index],
                    .forward,
                    .slide,
                    Date().timeIntervalSince(storyShowStartDate ?? Date())
                )
                currentStoryIndex = index
            } else {
                didDismiss(byAction: actionType, direction: .forward)
            }
        case false:
            if index >= 0 {
                // Page in new story
                let page = storiesViewModels[index].story.pages[storiesViewModels[index].currentPageIndex]
                StoryKit.configuration?.actions.storyDidMoveFromPageToStoryWithAction(
                    stories[currentStoryIndex],
                    page,
                    stories[index],
                    .back,
                    .slide,
                    Date().timeIntervalSince(storyShowStartDate ?? Date())
                )
                currentStoryIndex = index
            } else {
                didDismiss(byAction: actionType, direction: .back)
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
