//
//  ArticleEndpoint.swift
//  News
//
//  Created by BTS.id on 02/03/26.
//

import Foundation
import Alamofire

enum ArticleEndpoint {
    case getArticles(request: ArticleRequestModel)
}

extension ArticleEndpoint: Endpoint {
    var path: String {
        switch self {
        case .getArticles:
            return "/v2/everything"
        }
    }
    
    var header: [String: String] {
        return [:]
    }
    
    var body: [String: Any] {
        return [:]
    }
    
    var method: Alamofire.HTTPMethod {
        return .get
    }
    
    var queryItems: [String: Any] {
        switch self {
        case .getArticles(let request):
            let httpBody: [String: Any?] = [
                "apiKey": Environment.apiKey,
                "q": request.query,
                "sources": request.sources?.joined(separator: ","),
                "page": request.page,
                "pageSize": request.pageSize
            ]
            return httpBody.compactMapValues { $0 }
        }
    }
    
    var authorization: Bool {
        return false
    }
    
    var timeoutInterval: Double? {
        return nil
    }
}
