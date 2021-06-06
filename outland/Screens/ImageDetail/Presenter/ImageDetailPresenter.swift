//
//  ImageDetailPresenter.swift
//  outland
//
//  Created by Manuel on 04/06/21.
//

import UIKit

class ImageDetailPresenter {

    private(set) weak var view: ImageDetailViewController?

    var imageDetail: ImageDetail

    required init(imageDetail: ImageDetail, view: ImageDetailViewController) {
        self.imageDetail = imageDetail
        self.view = view
    }

    func onViewDidLoad() {
        view?.loadImage(imageDetail: imageDetail)
    }

    func onCloseButtonTapped(contentOffset: CGPoint, zoomScale: CGFloat) {
        imageDetail.contentOffset = contentOffset
        imageDetail.zoomScale = zoomScale
        view?.dismissController(updatedImageDetailObject: imageDetail)
    }
}
