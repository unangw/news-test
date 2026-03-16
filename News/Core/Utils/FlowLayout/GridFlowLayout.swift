//
//  GridFlowLayout.swift
//  News
//
//  Created by BTS.id on 02/03/26.
//

import UIKit

class GridFlowLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        // Get default layout attributes from the superclass
        guard let originalAttributes = super.layoutAttributesForElements(in: rect) else { return nil }
        
        // Make a deep copy of the attributes to avoid modifying internal cached layout
        // swiftlint:disable:next force_cast
        let attributes = originalAttributes.map { $0.copy() as! UICollectionViewLayoutAttributes }
        
        // Group attributes by row (items on the same y-position)
        var rowAttributes: [[UICollectionViewLayoutAttributes]] = []
        var currentRow: [UICollectionViewLayoutAttributes] = []
        var currentY: CGFloat?
        
        for attr in attributes {
            // Check if current attribute is in the same row based on Y coordinate
            if currentY == nil || abs(attr.frame.origin.y - currentY!) < 1 {
                currentRow.append(attr)
                currentY = attr.frame.origin.y
            } else {
                // Save completed row and start a new one
                rowAttributes.append(currentRow)
                currentRow = [attr]
                currentY = attr.frame.origin.y
            }
        }
        
        // Append the last row if any
        if !currentRow.isEmpty {
            rowAttributes.append(currentRow)
        }
        
        // If a row has only one item, align it to the left
        for row in rowAttributes {
            if row.count == 1 {
                row[0].frame.origin.x = sectionInset.left
            }
        }
        
        return attributes
    }
}
