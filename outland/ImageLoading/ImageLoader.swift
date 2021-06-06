//
//  ImageLoader.swift
//  outland
//
//  Created by Manuel on 04/06/21.
//

import UIKit

/// Helper to load and cache images, and cancel URLSession data tasks
class ImageLoader {

    let cache = NSCache<NSURL, UIImage>()

    private(set) var runningRequests = [NSURL: URLSessionDataTask]()

    func loadImage(_ urlString: String, _ completion: @escaping (Result<UIImage, NetworkError>) -> Void) -> NSURL? {

        guard let key = NSURL(string: urlString), let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return nil
        }

        if let image = self.cache.object(forKey: key) {
            completion(.success(image))
            return nil
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in

            defer {
                if let key = NSURL(string: url.absoluteString), self.runningRequests.keys.first(where: { $0 == key } ) != nil {
                    // If request is in the array: remove it when task is completed
                    self.runningRequests.removeValue(forKey: key)
                }
            }

            guard let data = data else {
                completion(.failure(NetworkError.emptyData))
                return
            }

            guard let image = UIImage(data: data) else {
                completion(.failure(NetworkError.failedToCreateImageFromData))
                return
            }

            // Add image to our cache, with the url as the key
            self.cache.setObject(image, forKey: key)

            completion(.success(image))
        }

        task.resume()

        // Add running request to the array
        self.runningRequests[key] = task
        
        return key
    }

    func cancelLoad(_ url: NSURL) {
        if runningRequests.keys.first(where: { $0 == url }) != nil {
            runningRequests[url]?.cancel()
            runningRequests.removeValue(forKey: url)
        }
    }
}
