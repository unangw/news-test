//
//  ArticleViewModel.swift
//  News
//
//  Created by BTS.id on 02/03/26.
//

import RxSwift
import RxRelay

protocol ArticleViewModelProtocol {
    // MARK: - States
    var getArticlesState: Observable<RequestState> { get }
    
    // MARK: - Variables
    var articles: [ArticleItemModel] { get set }
    var articlePageSize: Int { get set }
    var isMaxPage: Bool { get set }
    
    // MARK: - Functions
    func getArticles(request: ArticleRequestModel)
}

class ArticleViewModel: ArticleViewModelProtocol {
    let service: ArticleServiceProtocol
    
    private let getArticlesStateRelay = PublishRelay<RequestState>()
    
    var getArticlesState: Observable<RequestState> {
        return getArticlesStateRelay.asObservable()
    }
    
    var articles: [ArticleItemModel] = []
    var articlePageSize: Int = 10
    var isMaxPage: Bool = false
    
    init(service: ArticleServiceProtocol) {
        self.service = service
    }
    
    func getArticles(request: ArticleRequestModel) {
        getArticlesStateRelay.accept(.loading)
        
        Task {
            let result = try await self.service.getArticles(request: request)
            
            switch result {
            case .success(let response):
                if request.page == 1 {
                    isMaxPage = false
                    
                    articles.removeAll()
                }
                
                articles.append(contentsOf: response.articles ?? [])
                
                if (response.totalResults ?? 0 < 10 || response.articles?.isEmpty ?? true) {
                    isMaxPage = true
                }
                
                self.getArticlesStateRelay.accept(.loaded)
            case .failure(let failure):
                self.getArticlesStateRelay.accept(.error(failure))
            }
        }
    }
}
