//
//  ImageDetailViewController.swift
//  outland
//
//  Created by Manuel on 04/06/21.
//

import UIKit

class ImageDetailViewController: UIViewController {

    static func make(imageDetail: ImageDetail, onDismiss: ((ImageDetail) -> Void)?) -> ImageDetailViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        let controller = storyboard.instantiateViewController(withIdentifier: ImageDetailViewController.objectName) as! ImageDetailViewController

        let presenter = ImageDetailPresenter(imageDetail: imageDetail, view: controller)

        controller.presenter = presenter

        controller.onDismiss = onDismiss

        return controller
    }

    @IBOutlet weak var zoomableImageView: ZoomableImageView!

    var presenter: ImageDetailPresenter!

    var onDismiss: ((ImageDetail) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.onViewDidLoad()
    }

    @IBAction func closeButtonTapped(_ sender: UIButton) {
        presenter.onCloseButtonTapped(contentOffset: zoomableImageView.contentOffset,
                                      zoomScale: zoomableImageView.zoomScale)
    }
}

extension ImageDetailViewController {
    func loadImage(imageDetail: ImageDetail) {
        zoomableImageView.loadImage(imageDetail: imageDetail)
    }

    func dismissController(updatedImageDetailObject: ImageDetail) {
        onDismiss?(updatedImageDetailObject)
        dismiss(animated: true, completion: nil)
    }
}
