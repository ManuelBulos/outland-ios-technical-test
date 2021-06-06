//
//  NetworkError.swift
//  outland
//
//  Created by Manuel on 04/06/21.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidHttpURLResponse
    case httpURLResponseTypeError(HTTPStatusCode.ResponseType)
    case clientError
    case emptyData
    case failedToDecodeObject
    case failedToCreateImageFromData
    case other(Error)
}

extension NetworkError: Equatable {
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        return lhs.localizedDescription == rhs.localizedDescription
    }
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL is invalid"
        case .invalidHttpURLResponse:
            return "failed to read HTTP URL Response."
        case .httpURLResponseTypeError(let responseType):
            return responseType.localizedDescription
        case .clientError:
            return "Client seems to have erred"
        case .emptyData:
            return "Did not encounter any error, but the data is empty."
        case .failedToDecodeObject:
            return "Failed to decode object from response"
        case .failedToCreateImageFromData:
            return "Failed to create image from the downloaded data"
        case .other(let error):
            return error.localizedDescription
        }
    }
}
