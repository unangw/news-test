//
//  NewsRequestModel.swift
//  News
//
//  Created by BTS.id on 02/03/26.
//

struct ArticleRequestModel: Equatable, Codable {
    let query: String?
    var sources: [String]?
    let pageSize: Int?
    let page: Int?

        enum CodingKeys: String, CodingKey {
            case query = "q"
            case sources
            case pageSize
            case page
        }
}
