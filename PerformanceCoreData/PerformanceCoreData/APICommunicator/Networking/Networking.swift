//
//  Networking.swift
//  PerformanceCoreData
//
//  Created by Gagan Vishal on 2019/12/31.
//  Copyright © 2019 Gagan Vishal. All rights reserved.
//

import Foundation
struct Networking {
    //1.
    let urlSession: URLSession = URLSession(configuration: .default)
    //2.
    typealias JSONDataTaskCompletionHandler = (Decodable?, APIError?) -> Void
    //MARK:- Decode Object
    private func decode<T: Decodable>(with request: URLRequest, decodingType: T.Type, completionHaldler: @escaping JSONDataTaskCompletionHandler) -> URLSessionDataTask {
        let task = self.urlSession.dataTask(with: request) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse  else {
                completionHaldler(nil, APIError.requestFailed(description: error?.localizedDescription ?? "Something went wrong"))
                return
            }
            
            if httpResponse.statusCode == 200 {
                if let data = data {
                    do {
                        let genericModel = try JSONDecoder().decode(decodingType, from: data)
                        completionHaldler(genericModel, nil)
                    }
                    catch {
                        print(error)
                        completionHaldler(nil, .jsonConversionFailure(description: "Unable to decode data"))
                    }
                }
                else {
                    completionHaldler(nil, .invalidData)
                }
            }
            else {
                completionHaldler(nil, .responseUnsuccessful(description: error?.localizedDescription ?? "Something went wrong"))
            }
        }
        return task
    }
    
    //MARK:- Fetch object
    private func fetch<T: Decodable>(with router: APIRouter, decode: @escaping(Decodable) -> T?, completion: @escaping(Result<T, APIError>) -> Void ) {
       let taskSession =  self.decode(with: router.asRequest(), decodingType: T.self) { (decodable, error) in
            guard let json = decodable  else  {
                if let errorFound = error {
                    completion(.failuer(errorFound))
                }
                else {
                    completion(.failuer(.invalidData))
                }
                return
            }
            
            if let value = decode(json ) {
                completion(.success(value))
            }
            else {
                completion(.failuer(.jsonParsingFailure))
            }
        }
        taskSession.resume()
    }
    
    //MARK:- Get Object /*********************Get All Earthqauke data************************/
    func getEarthqaukeData<T: Decodable>(value: T.Type, completionHandler: @escaping(Result<T, APIError>) -> Void) {
        self.fetch(with: APIRouter.base_url, decode: { json -> T? in
            guard let resource = json as? T else {
                return nil
            }
            return resource
        }, completion: completionHandler)
    }
}
