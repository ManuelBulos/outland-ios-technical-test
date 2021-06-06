//
//  ImageDetail.swift
//  outland
//
//  Created by Manuel on 04/06/21.
//

import UIKit

struct ImageDetail: Codable {
    let id: Int
    let largeImageURL: String
    let user: String
    let userImageURL: String
    var zoomScale: CGFloat?
    var contentOffset: CGPoint?
}
