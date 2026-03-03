//
//  ArticleItemCell.swift
//  News
//
//  Created by BTS.id on 02/03/26.
//

import UIKit

class ArticleItemCell: UICollectionViewCell {
    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var publishedAtLabel: UILabel!
    
    // MARK: - Variables
    static let identifier = "ArticleItemCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configure(article: ArticleItemModel?) {
        guard let article = article else { return }
        
        imageView.setImage(with: article.urlToImage)
        
        titleLabel.text = article.title ?? "-"
        
        publishedAtLabel.text = article.publishedAt?.toDisplayedDate() ?? "-"
    }
    
    /// Don't remove this function if use CustomFlowLayout
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)
        layoutAttributes.frame.size = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        return layoutAttributes
    }
}
