//
//  Network.swift
//  outland
//
//  Created by Manuel on 04/06/21.
//

import Foundation

struct Network {
    func execute<T: Decodable>(_ endpoint: Endpoint,
                               completion: @escaping (Result<T, NetworkError>) -> Void) {

        guard let url = endpoint.url else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.invalidURL))
            }
            return
        }

        URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(NetworkError.other(error)))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse,
                      let responseType = httpResponse.status?.responseType else {
                    completion(.failure(NetworkError.invalidHttpURLResponse))
                    return
                }

                if responseType == .clientError {
                    completion(.failure(NetworkError.clientError))
                    return
                }

                guard responseType == .success else {
                    completion(.failure(NetworkError.httpURLResponseTypeError(responseType)))
                    return
                }

                guard let data = data else {
                    completion(.failure(NetworkError.emptyData))
                    return
                }

                do {
                    let decodedObject = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decodedObject))
                } catch {
                    completion(.failure(NetworkError.failedToDecodeObject))
                }
            }
        }.resume()
    }
}
