//
//  StoryViewModel.swift
//  OlimpBetAppClip
//
//  Created by Sakhabaev Egor on 11.04.2024.
//

import SwiftUI
import QuartzCore

class StoryViewModel: ObservableObject {

    let story: StoryKit.Story
    @Published var pagesData: [Loading<PageView.Data>] = []

    var isActive: Bool {
        didSet {
            updateTimerStatus()
        }
    }
    var didEndView: ((_ actionType: StoryKit.ActionType) -> Void)?
    var didRequestBack: ((_ actionType: StoryKit.ActionType) -> Void)?

    @Published var currentPageIndex: Int = 0 {
        didSet {
            updateTimerStatus()
        }
    }
    @Published var storyProgressSeconds: Double = 0

    private var storyShowStartDate: Date?
    private var pageShowStartDate: Date?
    private var timer: CADisplayLink?
    private var isHolded: Bool = false
    private var holdStartDate: Date?
    private var isOnTheScreen: Bool = false

    @Published var isPagePaused: Bool = false

    private var errorsCountInARow: Int = 0

    init(
        story: StoryKit.Story,
        isActive: Bool,
        didEndView: ((_ actionType: StoryKit.ActionType) -> Void)? = nil,
        didRequestBack: ((_ actionType: StoryKit.ActionType) -> Void)? = nil
    ) {
        self.story = story
        self.isActive = isActive
        self.didEndView = didEndView
        self.didRequestBack = didRequestBack
        self.pagesData = story.pages.map { _ in .none }
    }

    func prepareData() {
        // download only pages which has none state
        story.pages.enumerated()
            .filter { pagesData[$0.offset] == .none }
            .forEach { offset, page in
                preparePageData(at: offset)
            }
    }

    func reloadPage() {
        preparePageData(at: currentPageIndex)
    }

    func progress(forPageIndex pageIndex: Int) -> Double {
        let previousPagesDuration = (0..<pageIndex).reduce(0) { $0 + story.pages[$1].duration }
        let pageDuration = story.pages[pageIndex].duration
        if storyProgressSeconds - previousPagesDuration == 0 && pageDuration == 0 {
            return 1.0
        } else {
            return ((storyProgressSeconds - previousPagesDuration) / pageDuration).clamp(0, 1.0)
        }
    }

    func didSelectNextPage() {
        guard isActive else { return }
        guard let holdStartDate, Date().timeIntervalSince(holdStartDate) < 0.2 else { return }
        showNextPage()
    }

    func didSelectPreviousPage() {
        guard isActive else { return }
        guard let holdStartDate, Date().timeIntervalSince(holdStartDate) < 0.2  else { return }
        showPreviousPage()
    }

    func didHold(ended: Bool) {
        if ended {
            isHolded = false
            updateTimerStatus()
        } else if isActive {
            holdStartDate = Date()
            isHolded = true
            updateTimerStatus()
        }
    }

    func moveProgress(toPage pageIndex: Int) {
        storyProgressSeconds = story.pages[0..<pageIndex].reduce(0) { $0 + $1.duration }
    }

    func destroyTimer() {
        timer?.invalidate()
        timer = nil
    }

    func didDismiss() {
        StoryKit.configuration?.actions.storyDidClose(
            story,
            story.pages[currentPageIndex],
            .button,
            nil,
            Date().timeIntervalSince(storyShowStartDate ?? Date())
        )
        destroyTimer()
    }

    func failureView(forError error: Error) -> AnyView? {
        guard
            let failureState = StoryKit.configuration?.failureState,
            errorsCountInARow >= failureState.countToAppear
        else { return nil }
        return StoryKit.configuration?.failureState?.viewForError(error) { [weak self] in
            self?.reloadPage()
        }
    }

    // MARK: - Lifecycle -
    func viewDidAppear() {
        isOnTheScreen = true
        storyShowStartDate = Date()
        prepareData()
        updateTimerStatus()
    }

    func viewDidDisappear() {
        isOnTheScreen = false
        updateTimerStatus()
    }

    func pageContentDidAppear() {
        pageShowStartDate = Date()
        updateTimerStatus()
    }
}

// MARK: - Private methods
private extension StoryViewModel {

    func preparePageData(at index: Int) {
        let page = story.pages[index]
        pagesData[index] = .loading
        StoryKit.pageData(page) { [weak self] localURL, error in
            guard let localURL else {
                self?.errorsCountInARow += 1
                self?.pagesData[index] = .failed(error ?? NSError(domain: "com.storykit", code: 404, userInfo: nil))
                return
            }
            let buttonSelectionAction = { [weak self] in
                guard let self, let link = page.buttonData?.link else { return }
                StoryKit.configuration?.actions.storyPageDidSelectActionButton(story, page)
                UIApplication.shared.open(link)
            }
            switch page.contentType {
            case .image(let url):
                if let data = try? Data(contentsOf: localURL), let image = UIImage(data: data) {
                    self?.pagesData[index] = .loaded(.init(
                        id: page.id,
                        duration: page.duration,
                        contentType: .image(image),
                        buttonData: page.buttonData,
                        buttonSelectionAction: buttonSelectionAction
                    ))
                } else {
                    self?.errorsCountInARow += 1
                    self?.pagesData[index] = .failed(error ?? NSError(domain: "com.storykit", code: 404, userInfo: nil))
                }
            case .video(let url):
                self?.pagesData[index] = .loaded(.init(
                    id: page.id,
                    duration: page.duration,
                    contentType: .video(url: localURL),
                    buttonData: page.buttonData,
                    buttonSelectionAction: buttonSelectionAction
                ))
            }
        }
    }

    func showNextPage() {
        if story.pages.count - 1 > currentPageIndex {
            StoryKit.configuration?.actions.storyDidMoveToPageWithAction(
                story,
                story.pages[currentPageIndex + 1],
                .forward,
                .click,
                Date().timeIntervalSince(pageShowStartDate ?? Date())
            )
            moveProgress(toPage: currentPageIndex + 1)
            currentPageIndex += 1
            pageShowStartDate = Date()
        } else {
            didEndView?(.click)
        }
    }

    func showPreviousPage() {
        if currentPageIndex > 0 {
            StoryKit.configuration?.actions.storyDidMoveToPageWithAction(
                story,
                story.pages[currentPageIndex - 1],
                .back,
                .click,
                Date().timeIntervalSince(pageShowStartDate ?? Date())
            )
            moveProgress(toPage: currentPageIndex - 1)
            currentPageIndex -= 1
            pageShowStartDate = Date()
        } else {
            didRequestBack?(.click)
        }
    }

    // MARK: - Timer
    func updateTimerStatus() {
        if 
            let pagesData = pagesData[currentPageIndex].value,
            pagesData.duration != 0 &&
            isActive &&
            !isHolded &&
            isOnTheScreen
        {
            resumeTimer()
        } else {
            pauseTimer()
        }
    }
    func resumeTimer() {
        if timer == nil {
            timer = CADisplayLink(target: self, selector: #selector(timerDidRefresh(_:)))
            timer?.add(to: .current, forMode: .common)
        }
        timer?.isPaused = false
        isPagePaused = false
    }

    func pauseTimer() {
        timer?.isPaused = true
        isPagePaused = true
    }

    @objc func timerDidRefresh(_ displayLink: CADisplayLink) {
        guard isActive else { return }
        storyProgressSeconds += displayLink.duration
        updatePageIndex()
    }

    func updatePageIndex() {
        var newPageIndex: Int?
        var totalDuration: Double = 0
        for index in 0..<story.pages.count {
            totalDuration += story.pages[index].duration
            if storyProgressSeconds < totalDuration {
                newPageIndex = index
                break
            }
        }
        guard var newPageIndex else {
            didEndView?(.auto)
            return
        }
        guard Int(newPageIndex) != currentPageIndex else { return }
        // if next page has duration 0
        if newPageIndex == currentPageIndex + 2 && story.pages[newPageIndex - 1].duration == 0 {
            newPageIndex -= 1
        }
        StoryKit.configuration?.actions.storyDidMoveToPageWithAction(
            story,
            story.pages[newPageIndex],
            .forward,
            .auto,
            Date().timeIntervalSince(pageShowStartDate ?? Date())
        )
        // this and .main.async needs to stop playing video on current(previous currenly) page
        timer?.isPaused = true
        isPagePaused = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.moveProgress(toPage: newPageIndex)
            self.currentPageIndex = Int(newPageIndex)
            self.pageShowStartDate = Date()
        }
    }
}

