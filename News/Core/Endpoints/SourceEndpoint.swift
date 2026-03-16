//
//  SourceEndpoint.swift
//  News
//
//  Created by BTS.id on 02/03/26.
//

import Foundation
import Alamofire

enum SourceEndpoint {
    case getSource(request: SourceRequestModel)
}

extension SourceEndpoint: Endpoint {
    var path: String {
        switch self {
        case .getSource:
            return "/v2/top-headlines/sources"
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
        case .getSource(let request):
            let httpBody: [String: Any?] = [
                "apiKey": Environment.apiKey,
                "category": request.category,
                "country": request.country,
                "language": request.language
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
