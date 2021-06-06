//
//  UIImageLoader.swift
//  outland
//
//  Created by Manuel on 05/06/21.
//

import UIKit

/// Singleton helper for UIImageView to load images async and cancel load requests
class UIImageLoader {

    static let shared = UIImageLoader()

    let imageLoader = ImageLoader()

    // A map to be able to cancel ongoing requests for each image view if needed
    private(set) var imageViewMap = [UIImageView: NSURL]()

    private init() {}

    func load(_ url: String, for imageView: UIImageView, onFinish: (() -> Void)?) {
        let token = imageLoader.loadImage(url) { result in

            // Remove object from map when the task is completed
            defer {
                if self.imageViewMap.keys.first(where: {$0 == imageView}) != nil {
                    self.imageViewMap.removeValue(forKey: imageView)
                }
            }

            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    imageView.image = image
                    onFinish?()
                }
            case .failure:
                DispatchQueue.main.async {
                    imageView.image = nil
                    onFinish?()
                }
            }
        }

        if let token = token {
            imageViewMap[imageView] = token
        }
    }

    func cancel(for imageView: UIImageView) {
        if self.imageViewMap.keys.first(where: {$0 == imageView}) != nil {
            if let url = imageViewMap[imageView] {
                self.imageLoader.cancelLoad(url)
            }
            self.imageViewMap.removeValue(forKey: imageView)
        }
    }
}
