//
//  CategoryItemCell.swift
//  News
//
//  Created by BTS.id on 02/03/26.
//

import UIKit

class CategoryItemCell: UICollectionViewCell {
    // MARK: - Outlets
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var categoryImage: UIImageView!
    
    // MARK: - Variables
    static let identifier = "CategoryItemCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.borderColor = UIColor.black
    }
    
    func configure(category: String, icon: UIImage, description: String) {
        categoryLabel.text = category.capitalized
        descriptionLabel.text = description
        
        categoryImage.image = icon
    }
    
    /// Don't remove this function if use CustomFlowLayout
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)
        layoutAttributes.frame.size = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        return layoutAttributes
    }
}
