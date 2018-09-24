//
//  CVCalendarLayout.swift
//  CVCalendar
//
//  Created by caven on 2018/9/12.
//  Copyright © 2018年 com.caven. All rights reserved.
//

import UIKit

class CVCalendarLayout: UICollectionViewFlowLayout {
    
    /* 公开方法 */
    /// 自定义的cell高度，如果没有自定义, 则默认：宽=高
    public var customCellHeight: CGFloat?
    /// 日历的整体高度是否可变，默认：true，可改变
    var isAutoHeight = true
    
    /// 所有cell的布局属性
    private var attrisArr = [UICollectionViewLayoutAttributes]()
    
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        self.attrisArr.removeAll()
        
        if let collectionView = self.collectionView {
            
            // 总共有多少个sections
            let sectionCount = collectionView.numberOfSections
            
            for i in 0..<sectionCount {
                
                // 过滤header
                if let attri = self.layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionHeader, at: IndexPath(item: 0, section: i)) {
                    self.attrisArr.append(attri)
                }
                
                // 过滤cell
                // 每个section有多少个rows
                let rowCount = collectionView.numberOfItems(inSection: i)
                for j in 0..<rowCount {
                    if let attri = self.layoutAttributesForItem(at: IndexPath(row: j, section: i)) {
                        self.attrisArr.append(attri)
                    }
                }
                
                // 过滤footer
                if let attri = self.layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionFooter, at: IndexPath(item: 0, section: i)) {
                    self.attrisArr.append(attri)
                }
            }
        }
    }

    override var collectionViewContentSize: CGSize {
        if self.scrollDirection == .horizontal {
            if let collectionView = self.collectionView {
                let sectionCount = CGFloat(collectionView.numberOfSections)
                return CGSize(width: collectionView.frame.width * sectionCount, height: collectionView.frame.height)
            }
        }
        return CGSize.zero
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.attrisArr
    }
    
    /// 重写父类方法 - 布局header
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        let oneAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)
        guard let collectionView = self.collectionView else { return oneAttributes }

        // 初始化每个item的frame， x， y
        var frame = CGRect.zero
        var x: CGFloat = 0
        let y: CGFloat = 0
        let width: CGFloat = collectionView.frame.width
        var height: CGFloat = 0
        
        if elementKind == UICollectionElementKindSectionHeader {
            x = self.sectionInset.left + collectionView.frame.width * CGFloat(indexPath.section)
            height = self.headerReferenceSize.height
            frame = CGRect(x: x, y: y, width: width, height: height)
            oneAttributes.frame = frame
        }

        return oneAttributes
    }
    
    /// 重写父类方法 - 布局每一个cell
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let oneAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        
        guard let collectionView = self.collectionView else { return oneAttributes }
 
        
        // 初始化每个item的frame， x， y
        var frame = CGRect.zero
        var x: CGFloat = 0
        var y: CGFloat = 0
        var width: CGFloat = 0
        var height: CGFloat = 0
        
        // 横向滑动
        if self.scrollDirection == .horizontal {
            
            // 计算每一个cell的宽度
            width = (collectionView.frame.width - (self.sectionInset.left + self.sectionInset.right)) / 7
            height = self.customCellHeight ?? width
            // 计算每一个cell的原点
            x = self.sectionInset.left + CGFloat(indexPath.item % 7) * (width + self.minimumInteritemSpacing) + CGFloat(indexPath.section) * collectionView.frame.width
            y = self.sectionInset.top + CGFloat(indexPath.item / 7) * (height + self.minimumLineSpacing) + self.headerReferenceSize.height
            
            // 计算出最新的frame
            frame = CGRect(x: x, y: y, width: width, height: height)
        } else {
            // 竖直滑动
        }
        
        oneAttributes.frame = frame
        return oneAttributes
        
    }
}
