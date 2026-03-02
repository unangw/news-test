//
//  ListArticleViewController.swift
//  News
//
//  Created by BTS.id on 02/03/26.
//

import UIKit
import SkeletonView
import CHTCollectionViewWaterfallLayout
import RxSwift
import RxCocoa

class ListArticleViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchTextField: CustomTextField!
    
    // MARK: - Variables
    var didSendEventClosure: ((ListArticleViewController.Event) -> Void)?
    var viewModel: ArticleViewModelProtocol?
    var source: SourceItemModel!
    var customFlowLayout = CHTCollectionViewWaterfallLayout()
    let refreshControl = UIRefreshControl()
    var page = 1
    var isLoadingNextPage: Bool = false
    var articlesIsLoading = true
    private lazy var sizingCell: ArticleItemCell = {
        guard let cell = Bundle.main.loadNibNamed(ArticleItemCell.identifier, owner: nil)?.first as? ArticleItemCell else {
            fatalError("Failed to load ArticleItemCell.xib")
        }
        return cell
    }()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Life Cycle
    init(viewModel: ArticleViewModelProtocol?) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    isolated deinit {
        print("ListArticleViewController deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - Observe Event
        observeEvent()
        
        // MARK: - Setup UI
        setupUI()
        
        // MARK: - Fetch Data
        fetchData()
    }
    
    private func setupUI() {
        // MARK: - Setup Navigation
        setupNavigation()
        
        // MARK: - Setup Collection View
        setupCollectionView()
        
        // MARK: - Setup Search Text Field
        setupSearchTextField()
    }
    
    private func setupNavigation() {
        let backGesture = UITapGestureRecognizer(target: self, action: #selector(closeArticleScreen))
        setupNavigationBar(title: "Articles", backAction: backGesture)
    }
    
    private func setupCollectionView() {
        // MARK: - Setup CollectionView
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // MARK: - Register Cell
        let nib = UINib(nibName: ArticleItemCell.identifier, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: ArticleItemCell.identifier)
        
        let shimmerNib = UINib(nibName: ArticleShimmerCell.identifier, bundle: nil)
        collectionView.register(shimmerNib, forCellWithReuseIdentifier: ArticleShimmerCell.identifier)
        
        // MARK: - Configure CollectionView
        customFlowLayout.minimumInteritemSpacing = 16
        customFlowLayout.minimumColumnSpacing = 16
        customFlowLayout.sectionInset.left = 20
        customFlowLayout.sectionInset.right = 20
        customFlowLayout.sectionInset.bottom = 20
        collectionView.collectionViewLayout = customFlowLayout
        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.alwaysBounceVertical = true
        
        // MARK: - Add refresh control
        collectionView.addSubview(refreshControl)
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
    
    private func setupSearchTextField() {
        // MARK: - Setup Search TextField
        searchTextField.placeholder = "Search article here..."
        
        searchTextField.setSuffix(.icClose, target: self, action: #selector(clearSearch))
        searchTextField.textField.rightViewMode = .never // Hide suffix icon
        
        setupSearchBinding()
    }
    
    private func setupNoData() {
        let noDataView = NoDataView()
        noDataView.descriptionMessage = "Article is empty!"
        
        collectionView.backgroundView = noDataView
        
        // Set Constraints to center backgroundView
        noDataView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noDataView.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            noDataView.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),
            noDataView.widthAnchor.constraint(equalTo: collectionView.widthAnchor),
            noDataView.heightAnchor.constraint(equalTo: collectionView.heightAnchor)
        ])
    }
    
    private func reloadCollectionView() {
        collectionView.reloadData()
        
        if !articlesIsLoading && (viewModel?.articles.isEmpty ?? true) {
            setupNoData()
        } else {
            collectionView.backgroundView = nil
        }
    }
    
    private func observeEvent() {
        // MARK: - Observe Get Articles
        getArticlesEvent()
    }
    
    @objc private func refreshData() {
        fetchData()
    }
    
    private func fetchData() {
        // MARK: - Get Articles
        getArticles()
    }
    
    private func getArticles(page: Int = 1) {
        self.page = page
        
        var request = ArticleRequestModel(
            q: searchTextField.textField.text,
            sources: nil,
            pageSize: viewModel?.articlePageSize ?? 10,
            page: page
        )
        
        if let sourceId = source.id {
            request.sources = [sourceId]
        }
        
        viewModel?.getArticles(request: request)
    }
    
    private func setupSearchBinding() {
        let searchText = searchTextField.textField.rx.controlEvent(.editingChanged)
            .withLatestFrom(searchTextField.textField.rx.text.orEmpty)
            .share(replay: 1)
        
        searchText
            .map { $0.isEmpty ? UITextField.ViewMode.never : .always }
            .bind(to: searchTextField.textField.rx.rightViewMode)
            .disposed(by: disposeBag)

        searchText
            .debounce(.milliseconds(1000), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] _ in
                self?.getArticles(page: 1)
            })
            .disposed(by: disposeBag)
    }
    
    @objc private func closeArticleScreen() {
        didSendEventClosure?(.article)
    }
    
    @objc private func clearSearch() {
        searchTextField.textField.text = nil
        
        getArticles(page: 1)
    }
    
    private func onTapNewsItem(article: ArticleItemModel?) {
        if let article = article {
            didSendEventClosure?(.articleDetail(article: article))
        }
    }
}

extension ListArticleViewController {
    enum Event {
        case article
        case articleDetail(article: ArticleItemModel)
    }
}

extension ListArticleViewController: UICollectionViewDataSource, UICollectionViewDelegate, CHTCollectionViewDelegateWaterfallLayout {
    // Part of UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return articlesIsLoading ? 10 : viewModel?.articles.count ?? 0
    }
    
    // Part of UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()
        
        if articlesIsLoading {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArticleShimmerCell.identifier, for: indexPath)
            
            DispatchQueue.main.async {
                cell.showAnimatedSkeleton()
            }
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArticleItemCell.identifier, for: indexPath)
            
            if !(viewModel?.articles.isEmpty ?? true) {
                // Configure cell
                (cell as! ArticleItemCell).configure(article: viewModel?.articles[indexPath.item])
            }
        }
        
        return cell
    }
    
    // Part of UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onTapNewsItem(article: viewModel?.articles[indexPath.item])
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let dataCount = viewModel?.articles.count ?? 0
        let countDataForDisplay = dataCount - indexPath.item
        
        if !(viewModel?.isMaxPage ?? false) && !articlesIsLoading && !isLoadingNextPage && countDataForDisplay <= 1 {
            
            getArticles(page: page+1)
        }
    }
    
    // Part of CHTCollectionViewDelegateWaterfallLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let contentWidth = (collectionView.bounds.width - (20 * 2 + 16)) / 2
        var contentHeight: CGFloat = 148
        
        if !articlesIsLoading {
            sizingCell.frame.size.width = contentWidth
            
            let item = viewModel?.articles[indexPath.item]
            sizingCell.configure(article: item)
            
            sizingCell.setNeedsLayout()
            sizingCell.layoutIfNeeded()
            
            let size = sizingCell.contentView.systemLayoutSizeFitting(
                CGSize(
                    width: contentWidth,
                    height: UIView.layoutFittingExpandedSize.height
                ),
                withHorizontalFittingPriority: UILayoutPriority.required,
                verticalFittingPriority: UILayoutPriority.fittingSizeLevel
            )
            
            contentHeight = size.height
        }
        
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    // Part of CHTCollectionViewDelegateWaterfallLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, columnCountFor section: Int) -> Int {
        return 2
    }
}

// MARK: - Request State
extension ListArticleViewController {
    private func getArticlesEvent() {
        viewModel?.getArticlesState
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] state in
                guard let self else { return }
                
                switch state {
                case .loading:
                    self.refreshControl.endRefreshing()
                    
                    if self.page == 1 {
                        self.articlesIsLoading = true
                    } else {
                        self.isLoadingNextPage = true
                    }
                    
                    self.reloadCollectionView()
                case .loaded:
                    if self.page == 1 {
                        self.articlesIsLoading = false
                    } else {
                        self.isLoadingNextPage = false
                    }
                    
                    self.reloadCollectionView()
                case .error(let failure):
                    if self.page == 1 {
                        self.articlesIsLoading = false
                    } else {
                        self.isLoadingNextPage = false
                    }
                    
                    self.reloadCollectionView()
                    
                    self.showToast(with: failure.localizedDescription)
                }
            })
            .disposed(by: disposeBag)
    }
}
