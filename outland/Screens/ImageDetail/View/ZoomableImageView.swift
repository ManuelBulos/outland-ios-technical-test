//
//  ZoomableImageView.swift
//  outland
//
//  Created by Manuel on 05/06/21.
//

import UIKit

class ZoomableImageView : UIScrollView {

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.allowsEdgeAntialiasing = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private(set) var imageDetail: ImageDetail?

    private var oldSize: CGSize?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        delegate = self
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        contentInsetAdjustmentBehavior = .never
        addSubview(imageView)

        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTapGesture)
    }

    func loadImage(imageDetail: ImageDetail) {
        self.imageDetail = imageDetail

        imageView.loadImage(url: imageDetail.largeImageURL) { [weak self] in
            guard let self = self else { return }
            self.oldSize = nil

            self.updateImageView()
            self.scrollToCenter()

            if let zoomScale = imageDetail.zoomScale, let contentOffset = imageDetail.contentOffset {
                DispatchQueue.main.async {
                    self.zoomScale = zoomScale
                    self.contentOffset = contentOffset
                }
            }
        }
    }

    func scrollToCenter() {
        let centerOffset = CGPoint(
            x: contentSize.width > bounds.width ? (contentSize.width / 2) - (bounds.width / 2) : 0,
            y: contentSize.height > bounds.height ? (contentSize.height / 2) - (bounds.height / 2) : 0
        )
        contentOffset = centerOffset
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if imageView.image != nil && oldSize != bounds.size {
            updateImageView()
            oldSize = bounds.size
        }

        if imageView.frame.width <= bounds.width {
            imageView.center.x = bounds.width * 0.5
        }

        if imageView.frame.height <= bounds.height {
            imageView.center.y = bounds.height * 0.5
        }
    }

    override func updateConstraints() {
        super.updateConstraints()
        updateImageView()
    }

    private func updateImageView() {
        guard let image = imageView.image else { return }

        let aspectRatio = image.size
        var boundingSize = bounds.size
        let widthRatio = (boundingSize.width / aspectRatio.width)
        let heightRatio = (boundingSize.height / aspectRatio.height)

        if widthRatio < heightRatio {
            boundingSize.height = boundingSize.width / aspectRatio.width * aspectRatio.height
        }
        else if (heightRatio < widthRatio) {
            boundingSize.width = boundingSize.height / aspectRatio.height * aspectRatio.width
        }

        let size = CGSize(width: round(ceil(boundingSize.width)),
                          height: round(ceil(boundingSize.height)))

        zoomScale = 1

        maximumZoomScale = image.size.width / size.width

        imageView.bounds.size = size

        contentSize = size

        imageView.center = contentCenter(forBoundingSize: bounds.size, contentSize: contentSize)
    }

    @objc private func handleDoubleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        if self.zoomScale == 1 {
            // Zoom in to the location where the gesture recognizer caught the double tap
            zoom(
                to: zoomRectFor(
                    scale: max(1, maximumZoomScale),
                    with: gestureRecognizer.location(in: gestureRecognizer.view)),
                animated: true
            )
        } else {
            setZoomScale(1, animated: true)
        }
    }

    private func zoomRectFor(scale: CGFloat, with center: CGPoint) -> CGRect {
        let center = imageView.convert(center, from: self)
        var zoomRect = CGRect()
        zoomRect.size.height = bounds.height / scale
        zoomRect.size.width = bounds.width / scale
        zoomRect.origin.x = center.x - zoomRect.width / 2.0
        zoomRect.origin.y = center.y - zoomRect.height / 2.0
        return zoomRect
    }

    /*
     When the zoom scale changes (image is zoomed in or out), the hypothetical center of the content view changes too.
     If the image ratio is not matching the screen ratio, there will be some empty space horizontaly or verticaly.
     This needs to be calculated so that we can get the correct new center value.
     When these are added, edges of contentView are aligned in realtime and always aligned with corners of scrollview.
     */
    private func contentCenter(forBoundingSize boundingSize: CGSize, contentSize: CGSize) -> CGPoint {
        let horizontalOffset = (boundingSize.width > contentSize.width) ? ((boundingSize.width - contentSize.width) * 0.5): 0.0
        let verticalOffset = (boundingSize.height > contentSize.height) ? ((boundingSize.height - contentSize.height) * 0.5): 0.0
        return CGPoint(x: contentSize.width * 0.5 + horizontalOffset,  y: contentSize.height * 0.5 + verticalOffset)
    }
}

// MARK: - UIScrollViewDelegate

extension ZoomableImageView: UIScrollViewDelegate {
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        imageView.center = contentCenter(forBoundingSize: bounds.size, contentSize: contentSize)
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
