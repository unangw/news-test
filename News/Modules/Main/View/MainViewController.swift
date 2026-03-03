//
//  MainView.swift
//  News
//
//  Created by BTS.id on 02/03/26.
//

import UIKit

class MainViewController: BaseViewController {
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Variables
    var didSendEventClosure: ((MainViewController.Event) -> Void)?
    var viewModel: MainViewModelProtocol?
    let gridFlowLayout = GridFlowLayout()
    
    // MARK: - Life Cycle
    init(viewModel: MainViewModelProtocol?) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    isolated deinit {
        print("MainViewController deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - Setup UI
        setupUI()
        
    }
    
    private func setupUI() {
        // MARK: - Setup Collection View
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        // MARK: - Setup CollectionView
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // MARK: - Register Cell
        let nib = UINib(nibName: CategoryItemCell.identifier, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: CategoryItemCell.identifier)
        
        // MARK: - Configure CollectionView
        gridFlowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        gridFlowLayout.minimumLineSpacing = 16
        gridFlowLayout.minimumInteritemSpacing = 8
        gridFlowLayout.sectionInset.left = 20
        gridFlowLayout.sectionInset.right = 20
        gridFlowLayout.sectionInset.bottom = 20
        collectionView.collectionViewLayout = gridFlowLayout
        collectionView.contentInsetAdjustmentBehavior = .always
    }
    
    private func onTapCategoryItem(category: String) {
        didSendEventClosure?(.source(category: category))
    }
}

extension MainViewController {
    enum Event {
        case main
        case source(category: String)
    }
}

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    // Part of UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Category.list.count
    }
    
    // Part of UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryItemCell", for: indexPath) as? CategoryItemCell else {
            fatalError("Unable to dequeue CategoryItemCell")
        }
        
        // Configure cell
        cell.configure(category: Category.list[indexPath.item], icon: Category.images[indexPath.item], description: Category.descriptions[indexPath.item])
        
        return cell
    }
    
    // Part of UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let lay = collectionViewLayout as! UICollectionViewFlowLayout
        let collectionWidth = collectionView.safeAreaLayoutGuide.layoutFrame.width - lay.sectionInset.left - lay.sectionInset.right
        
        var itemWidth = collectionWidth
        
        itemWidth = (collectionWidth / 2) - lay.minimumInteritemSpacing
        
        return CGSize(width: itemWidth, height: 0)
    }
    
    // Part of UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onTapCategoryItem(category: Category.list[indexPath.item])
    }
}
