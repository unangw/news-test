//
//  Endpoint.swift
//  News
//
//  Created by BTS.id on 02/03/26.
//

import Foundation
import Alamofire

protocol Endpoint {
    var authorization: Bool { get }
    var path: String { get }
    var header: [String: String] { get }
    var body: [String: Any] { get }
    var method: HTTPMethod { get }
    var queryItems: [String: Any] { get }
    var timeoutInterval: Double? { get }
}

extension Endpoint {
    // MARK: - URLConvertible
    func asURL() throws -> URL {
        guard let url = URL(string: "\(Environment.scheme)://\(Environment.host)\(path)") else {
            throw URLError(.badURL)
        }
        return url
    }
    
    // MARK: - URLRequestConvertible
    func asURLRequest(multipart: Bool = false) throws -> URLRequest {
        let url = try asURL()
        let defaultHeaders: [String: String] = [
            "Content-Type": multipart ? "multipart/form-data" : "application/json",
            "Accept": multipart ? "*/*" : "application/json",
            "Accept-Language": "id",
            "issuer": "mobile"
        ]
        
        var request = URLRequest(url: url)
        request.method = method
        request.timeoutInterval = timeoutInterval ?? 60
        
        defaultHeaders.forEach { (key, value) in
            request.headers.add(name: key, value: value)
        }
        
        header.forEach { (key, value) in
            request.headers.add(name: key, value: value)
        }
        
        switch method {
        case .get, .head, .delete:
            request = try URLEncoding(destination: .queryString).encode(request, with: queryItems as Parameters)
        case .put:
            let requestWithBody = try JSONEncoding.default.encode(request, with: body)
            
            request = try URLEncoding(destination: .queryString).encode(requestWithBody, with: queryItems as Parameters)
        default:
            if !multipart {
                request = try JSONEncoding.default.encode(request, with: body)
            }
        }
        
        return request
    }
}
