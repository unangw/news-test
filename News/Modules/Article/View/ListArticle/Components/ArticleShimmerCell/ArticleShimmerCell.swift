//
//  ArticleShimmerCell.swift
//  News
//
//  Created by BTS.id on 02/03/26.
//

import UIKit

class ArticleShimmerCell: UICollectionViewCell {
    // MARK: Variables
    static let identifier = "ArticleShimmerCell"
    
    /// Don't remove this function if use CustomFlowLayout
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)
        layoutAttributes.frame.size = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        return layoutAttributes
    }
}
