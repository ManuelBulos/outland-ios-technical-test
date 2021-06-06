//
//  ImageListCell.swift
//  outland
//
//  Created by Manuel on 04/06/21.
//

import UIKit

class ImageListCell: UITableViewCell {

    @IBOutlet weak var roundedContainerView: UIView!

    @IBOutlet weak var customImageView: UIImageView!

    @IBOutlet weak var userImageView: UIImageView!

    @IBOutlet weak var userLabel: UILabel!

    func setImageDetail(_ imageDetail: ImageDetail) {
        customImageView.loadImage(url: imageDetail.largeImageURL)
        userImageView.isHidden = imageDetail.userImageURL.isEmpty
        userImageView.loadImage(url: imageDetail.userImageURL)
        userLabel.text = imageDetail.user
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        customImageView.image = nil
        customImageView.cancelImageLoad()

        userImageView.image = nil
        userImageView.cancelImageLoad()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        roundedContainerView.layer.cornerRadius = 4
        userImageView.layer.cornerRadius = userImageView.frame.height / 2
    }
}
