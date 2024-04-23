import UIKit
import SwiftUI

public struct StoryKit {

    static let fileDownloader = FilesDownloader()
    static var configuration: Configuration?

    public static func storiesView(_ stories: [Story], initialIndex: Int, withConfiguration configuration: Configuration) -> some View {
        self.configuration = configuration
        return StoriesView(stories: stories, initialIndex: initialIndex)
    }

    public static func prepareStory(_ story: Story, completion: @escaping () -> Void) {
        guard let page = story.pages.first else {
            completion()
            return
        }
        pageData(page) { _, _ in
            completion()
        }
    }
}

extension StoryKit {

    static func pageData(_ page: Story.PageData, completion: @escaping (_ localURL: URL?, _ error: Error?) -> Void) {
        switch page.contentType {
        case .image(let url), .video(let url):
            fileDownloader.download(from: url) { localURL, suggestedFileName, error in
                let closure = {
                    if let error {
                        completion(nil, error)
                    } else if let localURL {
                        completion(localURL, nil)
                    } else {
                        completion(nil, NSError(domain: "", code: 0))
                    }
                }
                if Thread.isMainThread {
                    closure()
                } else {
                    DispatchQueue.main.async {
                        closure()
                    }
                }
            }
        }
    }
}
