//
//  StoriesView.swift
//  StoryKit
//
//  Created by Sakhabaev Egor on 15.04.2024.
//

import SwiftUI

struct StoriesView: View {

    @Environment(\.presentationMode) var presentation
    @StateObject var viewModel: StoriesViewModel
    @State private var viewSize: CGSize = .zero
    @GestureState private var dragTranslation: CGSize = .zero
    @State private var opacity: Double = 0.0

    private var scale: CGFloat {
        guard viewSize.height > 0 else { return 1 }
        let scale = 1 - dragTranslation.height * 0.6 / viewSize.height
        return scale.clamp(0.4, 1)
    }

    init(stories: [StoryKit.Story], initialIndex: Int) {
        _viewModel = .init(wrappedValue: .init(stories: stories, initialIndex: initialIndex))
    }

    var body: some View {
        GeometryReader { geo in
            storyView(geo: geo)
                .background(viewModel.isDragging ? .clear : Color.init(hex: "1A1A1A"))
                .clipShape(RoundedRectangle(cornerRadius: viewModel.isDragging ? 12 : 0))
                .projectionOffset(dragTranslation)
                .scaleEffect(
                    CGSize(width: scale, height: scale),
                    anchor: .center
                )
                .ignoresSafeArea()
                .disabled(viewModel.isDragging || viewModel.isAutoScrolling)
                .onAppear {
                    viewSize = geo.size
                    viewModel.viewDidAppear()
                }
                .opacity(opacity)
        }
        .statusBarHidden(false)
        .gesture(
            DragGesture(minimumDistance: 25)
                .onChanged { value in
                    // enable only swipe to bottom when start dragging
                    guard value.translation.height >= 0 || viewModel.isDragging else { return }
                    viewModel.didChangeDragLocation()
                }
                .updating($dragTranslation) { value, state, transaction in
                    // enable only swipe to bottom when start dragging
                    guard value.translation.height >= 0 || viewModel.isDragging else { return }
                    state = value.translation
                }
                .onEnded { value in
                    if value.translation.height > 100 {
                        viewModel.didDismiss(byAction: .slide, direction: .down)
                    } else {
                        viewModel.didCancelDismiss()
                    }
                }
        )
        .animation(.linear(duration: 0.15), value: dragTranslation)
        .onChange(of: viewModel.isDismissing) { newValue in
            guard newValue else { return }
            presentation.wrappedValue.dismiss()
        }
    }

    @ViewBuilder
    func storyView(geo: GeometryProxy) -> some View {
        ScrollViewReader { scrollReader in
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(Array(viewModel.stories.enumerated()), id: \.offset) { index, story in
                        GeometryReader { proxy in
                            let minX = {
                                if !dragTranslation.height.isZero {
                                    return 0.0
                                } else {
                                    return proxy.frame(in: .global).minX
                                }
                            }()
                            let rate: CGFloat = -minX / proxy.size.width
                            let scale = (1 - rate * 0.1).clamp(0.8, 1)

                            StoryView(
                                viewModel: viewModel.storiesViewModels[index],
                                safeAreaInsets: geo.safeAreaInsets
                            )
                            .id(viewModel.storiesViewModels[index].story.id)
                            // Darken when changing stories
                            .overlay(Color.black.opacity(rate * 0.5))
                            // Corner radius when changing stories
                            .clipShape(RoundedRectangle(cornerRadius: 12 * (rate)))
                            .clipped()
                            // Transform when changing stories
                            .scaleEffect(scale, anchor: .center)
                            .transformEffect(
                                .identity
                                    .translatedBy(x: minX < 0 ? -minX : 0, y: 0)
                            )
                        }
                        .frame(
                            width: geo.size.width + geo.safeAreaInsets.leading + geo.safeAreaInsets.trailing,
                            height: geo.size.height + geo.safeAreaInsets.top + geo.safeAreaInsets.bottom
                        )
                    }
                }
                .background(scrollDetector(geo: geo))
            }
            .pagingEnable()
            .onChange(of: viewModel.currentStoryIndex) { newValue in
                withAnimation {
                    scrollReader.scrollTo(newValue)
                }
            }
            .onAppear {
                // workaround for the bug with story flickering on opening due to scrolling
                if #available(iOS 16.4, *) {
                    opacity = 1.0
                } else {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        opacity = 1.0
                    }
                }
                // Have to scroll to current page if stories were opened not from first item
                scrollReader.scrollTo(viewModel.currentStoryIndex)
            }
        }
    }

    @ViewBuilder
    func scrollDetector(geo: GeometryProxy) -> some View {
        ScrollDetector(
            onScrollViewInit: { scrollView in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    scrollView.isPagingEnabled = true
                    scrollView.showsHorizontalScrollIndicator = false
                }
            },
            onScroll: { scrollView, offset in
                guard
                    !viewModel.isDismissing,
                    offset.x <= -10 ||
                    offset.x >= scrollView.contentSize.width - scrollView.frame.width + 10
                else { return }
                viewModel.didDismiss(byAction: .slide, direction: offset.x <= -10 ? .back : .forward)
            },
            onDraggingBegin: { offset in
                viewModel.didStartSlideStories()
            },
            onEndDecelerating: { offset in
                let page = offset.x / geo.size.width
                viewModel.didEndSlideStories(toIndex: Int(page))
            }
        )
    }
}
