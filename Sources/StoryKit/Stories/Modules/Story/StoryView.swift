//
//  StoryView.swift
//  OlimpBetAppClip
//
//  Created by Sakhabaev Egor on 11.04.2024.
//

import SwiftUI

struct StoryView: View {

    @Environment(\.presentationMode) var presentation
    @ObservedObject var viewModel: StoryViewModel
    private var safeAreaInsets: EdgeInsets?

    init(
        viewModel: StoryViewModel,
        safeAreaInsets: EdgeInsets? = nil
    ) {
        self.viewModel = viewModel
        self.safeAreaInsets = safeAreaInsets
    }

    var body: some View {
        contentView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(
                progress()
                    .padding(.top, (safeAreaInsets?.top ?? 0) + 8),
                alignment: .top
            )
            .overlay(
                Button {
                    viewModel.didDismiss()
                    presentation.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .frame(width: 48, height: 44)
                        .padding(.top, (safeAreaInsets?.top ?? 0) + 18)
                },
                alignment: .topTrailing
            )
            .background(controls())
            .background(Color.black)
            .onAppear {
                viewModel.viewDidAppear()
            }
    }

    @ViewBuilder
    func contentView() -> some View {
        switch viewModel.pagesData[viewModel.currentPageIndex] {
        case .none, .loading:
            VStack(alignment: .center) {
                Spacer()
                LoaderView(color: .white.opacity(0.5))
                    .frame(width: 42, height: 42, alignment: .center)
                Spacer()
            }
            .frame(maxWidth: .infinity)
        case .loaded(let data):
            PageView(pageData: data, isPaused: $viewModel.isPagePaused)
                .onAppear {
                    viewModel.pageContentDidAppear()
                }
        case .failed:
            VStack {
                Spacer()
                Button {
                    viewModel.reloadPage()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 41))
                        .foregroundColor(.white)
                }
                Spacer()
            }
        }
    }

    @ViewBuilder
    func progress() -> some View {
        HStack(spacing: 4) {
            ForEach(viewModel.story.pages.indices) { index in
                ProgressView(progress: viewModel.progress(forPageIndex: index))
            }
        }
        .frame(height: 2)
        .padding(.horizontal, 8)
    }

    @ViewBuilder
    func controls() -> some View {
        HStack(spacing: 0) {
            Rectangle()
                .contentShape(Rectangle())
                .onLongPressGesture(minimumDuration: .infinity, perform: {}) { bool in
                    viewModel.didHold(ended: !bool, leftSide: true)
                }
                .highPriorityGesture(
                    TapGesture()
                        .onEnded {
                            viewModel.didSelectPreviousPage()
                        }
                )
            Rectangle()
                .contentShape(Rectangle())
                .onLongPressGesture(minimumDuration: .infinity, perform: { }) { bool in
                    viewModel.didHold(ended: !bool, leftSide: false)
                }
                .highPriorityGesture(
                    TapGesture()
                        .onEnded {
                            viewModel.didSelectNextPage()
                        }
                )
        }
        .foregroundColor(.clear)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    return StoryView(
        viewModel: .init(
            story: .init(
                id: UUID().uuidString,
                pages: [
                    .init(
                        id: UUID().uuidString,
                        duration: 15,
                        contentType: .image(url: .init(string: "https://m.media-amazon.com/images/I/71HvRxH2bgL._AC_UF1000,1000_QL80_.jpg")!)
                    )
                ]
            ),
            isActive: true,
            didEndView: { _ in },
            didRequestBack: { _ in }
        )
    )
}
