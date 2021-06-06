//
//  ImageModel.swift
//  outland
//
//  Created by Manuel on 04/06/21.
//

import Foundation

class ImageList: Codable {
    var hits: [ImageDetail]?

    init() {
        hits = nil
    }
}
