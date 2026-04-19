//
//  NewsTests.swift
//  NewsTests
//
//  Created by BTS.id on 02/03/26.
//

import Foundation
import Testing
import Alamofire
@testable import News

struct NewsTests {

    @Test func sourceRequestModel_equatableSameValues_isEqual() {
        let lhs = SourceRequestModel(category: "business", language: "en", country: "us")
        let rhs = SourceRequestModel(category: "business", language: "en", country: "us")

        #expect(lhs == rhs)
    }

    @Test func sourceRequestModel_codable_roundTripPreservesValues() throws {
        let request = SourceRequestModel(category: "science", language: "en", country: "gb")
        let encoded = try JSONEncoder().encode(request)
        let decoded = try JSONDecoder().decode(SourceRequestModel.self, from: encoded)

        #expect(decoded == request)
    }

    @Test func articleRequestModel_equatableDifferentPage_isNotEqual() {
        let lhs = ArticleRequestModel(q: "apple", sources: ["cnn"], pageSize: 20, page: 1)
        let rhs = ArticleRequestModel(q: "apple", sources: ["cnn"], pageSize: 20, page: 2)

        #expect(lhs != rhs)
    }

    @Test func articleRequestModel_codable_roundTripPreservesValues() throws {
        let request = ArticleRequestModel(q: "tesla", sources: ["bbc-news", "cnn"], pageSize: 10, page: 3)
        let encoded = try JSONEncoder().encode(request)
        let decoded = try JSONDecoder().decode(ArticleRequestModel.self, from: encoded)

        #expect(decoded == request)
    }

    @Test func responseError_invalidURL_localizedDescriptionMatchesExpected() {
        let error = ResponseError.invalidURL

        #expect(error.localizedDescription == "An invalid URL.")
    }

    @Test func responseError_server_localizedDescriptionUsesServerMessage() {
        let message = "Service unavailable"
        let error = ResponseError.server(message: message)

        #expect(error.localizedDescription == message)
    }

    @Test func responseError_customMessage_localizedDescriptionUsesCustomMessage() {
        let message = "Custom validation error"
        let error = ResponseError.customMessage(message: message)

        #expect(error.localizedDescription == message)
    }

    @Test func sourceEndpoint_getSource_hasExpectedDefaults() {
        let request = SourceRequestModel(category: nil, language: nil, country: nil)
        let endpoint = SourceEndpoint.getSource(request: request)

        #expect(endpoint.path == "/v2/top-headlines/sources")
        #expect(endpoint.method == .get)
        #expect(endpoint.authorization == false)
        #expect(endpoint.timeoutInterval == nil)
        #expect(endpoint.header.isEmpty)
        #expect(endpoint.body.isEmpty)
    }

    @Test func articleEndpoint_getArticles_hasExpectedDefaults() {
        let request = ArticleRequestModel(q: nil, sources: nil, pageSize: nil, page: nil)
        let endpoint = ArticleEndpoint.getArticles(request: request)

        #expect(endpoint.path == "/v2/everything")
        #expect(endpoint.method == .get)
        #expect(endpoint.authorization == false)
        #expect(endpoint.timeoutInterval == nil)
        #expect(endpoint.header.isEmpty)
        #expect(endpoint.body.isEmpty)
    }

    @Test func toDisplayedDate_validISODate_formatsToReadableDate() {
        let isoDate = "2026-03-02T08:30:00Z"

        #expect(isoDate.toDisplayedDate() == "2 March 2026")
    }

}
