//
//  ScrollDetector.swift

import UIKit
import SwiftUI

struct ScrollDetector: UIViewRepresentable {

    var onScrollViewInit: ((_ scrollView: UIScrollView) -> Void)?
    var onScroll: ((_ scrollView: UIScrollView, _ offset: CGPoint) -> Void)?

    var onDraggingBegin: ((_ offset: CGPoint) -> Void)?
    var onDraggingEnd: ((_ offset: CGPoint, _ velocity: CGFloat) -> Void)?
    var onEndDecelerating: ((_ offset: CGPoint) -> Void)?

    init(
        onScrollViewInit: ((_ scrollView: UIScrollView) -> Void)? = nil,
        onScroll: ((_ scrollView: UIScrollView, _ offset: CGPoint) -> Void)? = nil,
        onDraggingBegin: ((_ offset: CGPoint) -> Void)? = nil,
        onDraggingEnd: ((_ offset: CGPoint, _ velocity: CGFloat) -> Void)? = nil,
        onEndDecelerating: ((_ offset: CGPoint) -> Void)? = nil
    ) {
        self.onScrollViewInit = onScrollViewInit
        self.onScroll = onScroll
        self.onDraggingBegin = onDraggingBegin
        self.onDraggingEnd = onDraggingEnd
        self.onEndDecelerating = onEndDecelerating
    }

    class Coordinator: NSObject, UIScrollViewDelegate {

        var parent: ScrollDetector

        var isDelegateAdded: Bool = false

        public init(parent: ScrollDetector) {
            self.parent = parent
        }

        public func scrollViewDidScroll(_ scrollView: UIScrollView) {
            parent.onScroll?(scrollView, scrollView.contentOffset)
        }

        public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            parent.onDraggingBegin?(scrollView.contentOffset)
        }

        public func scrollViewWillEndDragging(
            _ scrollView: UIScrollView,
            withVelocity velocity: CGPoint,
            targetContentOffset: UnsafeMutablePointer<CGPoint>
        ) {
            parent.onDraggingEnd?(targetContentOffset.pointee, velocity.y)
        }

        public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            parent.onEndDecelerating?(scrollView.contentOffset)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UIView {
        let uiView = UIView()
        DispatchQueue.main.async {
            if let scrollView = recursiveFindScrollView(view: uiView), !context.coordinator.isDelegateAdded {
                onScrollViewInit?(scrollView)
                scrollView.delegate = context.coordinator
                context.coordinator.isDelegateAdded = true
            }
        }
        return uiView
    }

    func recursiveFindScrollView(view: UIView) -> UIScrollView? {
        if let scrollView = view as? UIScrollView {
            return scrollView
        } else {
            if let superview = view.superview {
                return recursiveFindScrollView(view: superview)
            } else {
                return nil
            }
        }
    }

    func updateUIView(_ uiView: UIView, context: Context) { }
}
