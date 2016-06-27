//
//  GridCollectionViewLayout.swift
//  Observatory
//
//  Created by Andrew Tantomo on 2016/05/17.
//  Copyright © 2016年 Andrew Tantomo. All rights reserved.
//

import UIKit

class GridCollectionViewLayout: UICollectionViewFlowLayout {

    var rects = [NSIndexPath: NSValue]()
    private let itemPerRow: CGFloat = 3.0

    override init() {

        super.init()
        registerClass(BackgroundReusableView.self, forDecorationViewOfKind: BackgroundReusableView.kind)
    }
    
    required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)
        registerClass(BackgroundReusableView.self, forDecorationViewOfKind: BackgroundReusableView.kind)
    }

    override func collectionViewContentSize() -> CGSize {

        var size = super.collectionViewContentSize()
        size.height += Constants.Size.Large

        return size
    }

    override func prepareLayout() {

        super.prepareLayout()

        setupDimension()

        let sections = collectionView!.numberOfSections()

        var dictionary = [NSIndexPath: NSValue]()

        var prevSectionHeight: CGFloat = 0
        for section in 0..<sections {

            let itemCount = collectionView!.numberOfItemsInSection(section)
            let rows = Int(ceil(CGFloat(itemCount) / itemPerRow))


            let sectionHeight = rows > 0 ? CGFloat(rows) * (itemSize.width + minimumLineSpacing) - minimumLineSpacing + Constants.Size.Small * 2 : headerReferenceSize.height
            let contentStart = headerReferenceSize.height + prevSectionHeight

            prevSectionHeight = contentStart + sectionHeight

            let indexPath = NSIndexPath(forItem: 0, inSection: section)
            dictionary[indexPath] = NSValue(CGRect: CGRectMake(0, contentStart, collectionViewContentSize().width, sectionHeight))
        }

        rects = dictionary
    }

    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {

        var attributes = super.layoutAttributesForElementsInRect(rect)!

        for (key, val) in rects {
            if val.CGRectValue().intersects(rect) {
                let attribute = UICollectionViewLayoutAttributes(forDecorationViewOfKind: BackgroundReusableView.kind, withIndexPath: key)
                attribute.frame = val.CGRectValue()
                attribute.zIndex = -1
                attributes.append(attribute)
            }
        }
        return attributes
    }

    override func layoutAttributesForDecorationViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        
        let attribute = UICollectionViewLayoutAttributes(forDecorationViewOfKind: BackgroundReusableView.kind, withIndexPath: indexPath)
        attribute.frame = rects[indexPath]!.CGRectValue()
        attribute.zIndex = -1
        return attribute
    }

    private func setupDimension() {

        scrollDirection = .Vertical
        minimumInteritemSpacing = Constants.Size.Small
        minimumLineSpacing = Constants.Size.Small

        // add spacing in between items and at both left/right ends
        let dimension = (collectionView!.frame.width - (2 * Constants.Size.Medium) - (4 * Constants.Size.Small)) / itemPerRow
        itemSize = CGSizeMake(dimension, dimension)
    }
}


