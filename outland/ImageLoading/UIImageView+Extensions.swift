//
//  UIImageView+Extensions.swift
//  outland
//
//  Created by Manuel on 05/06/21.
//

import UIKit

extension UIImageView {
    func loadImage(url: String, onFinish: (() -> Void)? = nil) {
        UIImageLoader.shared.load(url, for: self, onFinish: onFinish)
    }

    func cancelImageLoad() {
        UIImageLoader.shared.cancel(for: self)
    }
}
