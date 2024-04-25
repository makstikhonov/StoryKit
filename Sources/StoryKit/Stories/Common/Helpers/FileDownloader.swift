//
//  FileDownloader.swift
//  OlimpBetAppClip
//
//  Created by Sakhabaev Egor on 11.04.2024.
//

import Foundation

class FilesDownloader {


    // Custom URL cache with 200 mb disk storage
    lazy var cache: URLCache = {
        let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let diskCacheURL = cachesURL.appendingPathComponent("StoriesDownloadCache")
        let cache = URLCache(memoryCapacity: 100_000_000, diskCapacity: 200_000_000, directory: diskCacheURL)
        return cache
    }()

    lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.urlCache = cache
        return URLSession(configuration: config)
    }()

    func download(from url: URL, completion: @escaping (_ localURL: URL?, _ suggestedFileName: String?, _ error: Error?) -> Void) {
        let request = URLRequest(url: url)
        if let response = cache.cachedResponse(for: request) {
            let path = NSTemporaryDirectory() + (response.response.suggestedFilename ?? "")
            if FileManager.default.fileExists(atPath: path) {
                let cachedURL = URL(fileURLWithPath: path)
                completion(cachedURL, response.response.suggestedFilename, nil)
                return
            }
        }
        let task = session.downloadTask(with: request) { tempURL, response, error in
            // Store data in cache
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 200
            guard error == nil && statusCode >= 200 && statusCode < 400 else {
                // Error state
                completion(nil, response?.suggestedFilename, error ?? NSError())
                return
            }
            if
                let tempURL,
                let response = response,
                self.cache.cachedResponse(for: request) == nil,
                let data = try? Data(contentsOf: tempURL, options: [.mappedIfSafe])
            {
                self.cache.storeCachedResponse(CachedURLResponse(response: response, data: data), for: request)
            }
            // Move file to local url
            if let tempURL {
                let localURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(response?.suggestedFilename ?? "")
                try? FileManager.default.moveItem(at: tempURL, to: localURL)
                completion(localURL, response?.suggestedFilename, error)
            } else {
                completion(tempURL, response?.suggestedFilename, error)
            }
        }
        task.resume()
    }
}
