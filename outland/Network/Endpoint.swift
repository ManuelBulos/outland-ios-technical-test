//
//  Endpoint.swift
//  outland
//
//  Created by Manuel on 04/06/21.
//

import Foundation

enum Endpoint {
    typealias SearchQuery = String
    case imageList(SearchQuery? = nil)
}

extension Endpoint {
    var url: URL? {

        var components = URLComponents()
        components.scheme = Constants.serverScheme
        components.host = Constants.serverAddress
        components.path = Constants.serverPath
        components.queryItems = [URLQueryItem(name: "key", value: Constants.apiKey)]

        switch self {
        case .imageList(let searchQuery):
            let queryItems = [URLQueryItem(name: "image_type", value: "photo"),
                              URLQueryItem(name: "page", value: "2"),
                              URLQueryItem(name: "per_page", value: "30")]

            components.queryItems?.append(contentsOf: queryItems)

            if let searchQuery = searchQuery {
                components.queryItems?.append(URLQueryItem(name: "q", value: searchQuery))
            }
        }

        return components.url

    }
}
