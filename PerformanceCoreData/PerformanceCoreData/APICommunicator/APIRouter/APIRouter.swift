//
//  APIRouter.swift
//  PerformanceCoreData
//
//  Created by Gagan Vishal on 2019/12/31.
//  Copyright © 2019 Gagan Vishal. All rights reserved.
//

import Foundation

protocol WebURL {
    var urlString: String {get}
    func asRequest() -> URLRequest
}

enum APIRouter: WebURL {
    case base_url
    
    var urlString: String {
        switch self {
        case .base_url:
            return Constants.Web_API.base_url
        }
    }
    
    func asRequest() -> URLRequest {
        guard let url = URL(string: self.urlString) else {
            fatalError("Unable to create a URL")
        }
        return URLRequest(url: url)
    }
}
