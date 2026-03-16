//
//  SourceItemCell.swift
//  News
//
//  Created by BTS.id on 02/03/26.
//

import UIKit

class SourceItemCell: UICollectionViewCell {
    // MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var chipStackView: UIStackView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var sourceUrlLabel: UILabel!
    
    // MARK: - Variables
    static let identifier = "SourceItemCell"
    var sourceUrl: String?
    
    func configure(source: SourceItemModel?) {
        guard let source = source else { return }
        
        // Clear all subview on stack view
        chipStackView.removeAllArrangedSubviews()
        
        nameLabel.text = source.name ?? "-"
        descriptionLabel.text = source.description ?? "-"
        
        // MARK: - Configure Chip Stack View Content
        if let category = source.category {
            let categoryChip = GeneralChipView()
            categoryChip.label = category.capitalized
            
            chipStackView.addArrangedSubview(categoryChip)
        }
        
        if let country = source.country {
            let countryChip = GeneralChipView()
            countryChip.label = country.uppercased()
            
            chipStackView.addArrangedSubview(countryChip)
        }
        
        if let language = source.language {
            let languageChip = GeneralChipView()
            languageChip.label = language.uppercased()
            
            chipStackView.addArrangedSubview(languageChip)
        }
        
        // Add Spacer into Chip Stack View
        chipStackView.addArrangedSubview(UIStackView())
        
        // MARK: - Configure Source Url
        if let url = source.url {
            sourceUrl = url
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapUrl))
            sourceUrlLabel.addGestureRecognizer(tapGesture)
            sourceUrlLabel.text = url
        }
    }
    
    @objc private func didTapUrl() {
        if let sourceUrl = sourceUrl {
            if let url = URL(string: sourceUrl) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    /// Don't remove this function if use CustomFlowLayout
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)
        layoutAttributes.frame.size = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        return layoutAttributes
    }
}
