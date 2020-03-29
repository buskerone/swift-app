//
//  SWANetworkingService.swift
//  swift app
//
//  Created by Carlos Knopel on 3/27/20.
//  Copyright © 2020 Carlos Knopel. All rights reserved.
//

import Foundation

class SWANetworkingService {
    
    private init() {}
    private var task: URLSessionTask?
    static let shared = SWANetworkingService()
    
    func request(_urlPath: String, completion: @escaping (Result<Data, Error>) -> Void) {
        
        let session = URLSession.shared
        
        guard let url = URL(string: _urlPath) else {
            completion(.failure(NSError()))
            return
        }

        task?.cancel()

        task = session.dataTask(with: url) {  data, _, error in
            DispatchQueue.main.async {
                if let err = error {
                    completion(.failure(err))
                } else if let jsonData = data {
                    completion(.success(jsonData))
                } else {
                    completion(.failure(NSError()))
                }
            }
        }

        task?.resume()
    }
    
//    func request(_ urlPath: String, completion: @escaping (Result<Data, NSError>) -> Void) {
//
//        let url = URL(string: urlPath)!
//        let session = URLSession.shared
//
//        let task = session.dataTask(with: url) { (data, _, error) in
//
//            if let unwrappedError = error {
//                completion(.failure(unwrappedError as NSError))
//            } else if let unwrappedData = data {
//                completion(.success(unwrappedData))
//            }
//        }
//
//        task.resume()
//    }
}
