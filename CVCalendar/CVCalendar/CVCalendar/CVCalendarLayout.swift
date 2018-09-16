//
//  CVCalendarLayout.swift
//  CVCalendar
//
//  Created by caven on 2018/9/12.
//  Copyright © 2018年 com.caven. All rights reserved.
//

import UIKit

class CVCalendarLayout: UICollectionViewFlowLayout {
    lazy var item_width: CGFloat = {
        return self.collectionView == nil ? CGFloat(0) : self.collectionView!.frame.size.width / 7
    }()
    lazy var item_height: CGFloat = {
        return self.collectionView == nil ? CGFloat(0) : self.collectionView!.frame.size.width / 7
    }()

    override init() {
        super.init()
        // 水平方向
        self.scrollDirection = .horizontal
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        self.itemSize = CGSize(width: item_width, height: item_height)
    }
}
