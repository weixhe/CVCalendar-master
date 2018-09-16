//
//  CVCalendarView.swift
//  CVCalendar
//
//  Created by caven on 2018/9/12.
//  Copyright © 2018年 com.caven. All rights reserved.
//

import UIKit

fileprivate let color_normal = UIColor.black            // 正常时的颜色
fileprivate let color_select = UIColor.white            // 选中时的颜色
fileprivate let color_highlight = UIColor.red           // 周末，假日等等的颜色
fileprivate let color_disable = UIColor.lightGray       // 不能点击，过去，未来的颜色

class CVCalendarView: UIView {
    
    var collectionView: UICollectionView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let layout = CVCalendarLayout()
        layout.itemSize = CGSize(width: frame.width / 7, height: frame.width / 7)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        
        self.collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        self.collectionView.backgroundColor = UIColor.clear
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(CVCalendarCell.self, forCellWithReuseIdentifier: "CVCalendarCell")
        self.addSubview(self.collectionView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension CVCalendarView : UICollectionViewDelegate, UICollectionViewDataSource {
    
    /// 返回section个数
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 6;
    }
    
    /// 每个section中的item个数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 30
    }
    
    /// 赋值显示cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CVCalendarCell", for: indexPath) as! CVCalendarCell
        cell.backgroundColor = UIColor.red
        cell.titleLabel.text = "\(indexPath.item + 1)"
        cell.subTitleLabel.text = "初\(indexPath.item)"
        return cell
    }
    
    /// 点击item
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CVCalendarCell
        cell.isSelected = true
    }
}


// MARK: - 日历Item
class CVCalendarCell: UICollectionViewCell {
    
    private let scale: CGFloat = UIScreen.main.bounds.width / 375.0  // 设计图按照iphone6的尺寸进行设计
    private let height_title: CGFloat = 17
    private let height_subTitle: CGFloat = 13
    
    lazy var titleLabel: UILabel = {
        let y: CGFloat = (self.contentView.bounds.size.height - self.height_title - self.height_subTitle) / 2
        let label = UILabel(frame: CGRect(x: 0, y: y, width: self.contentView.frame.width, height: self.height_title))
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12 * scale)
        label.textColor = color_normal
        self.contentView.addSubview(label)
        return label
    }()
    
    lazy var subTitleLabel: UILabel = {
        let y: CGFloat = self.titleLabel.frame.maxY
        let label = UILabel(frame: CGRect(x: 0, y: y, width: self.contentView.frame.width, height: self.height_subTitle))
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 9 * scale)
        label.textColor = color_normal
        self.contentView.addSubview(label)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        self.backgroundView = UIView(frame: self.bounds)
        
        self.selectedBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width * 0.7, height: self.frame.height * 0.7))
        self.selectedBackgroundView!.backgroundColor = UIColor.white
        self.selectedBackgroundView!.layer.cornerRadius = 8
        self.selectedBackgroundView!.layer.masksToBounds = true
        self.selectedBackgroundView!.layer.borderWidth = 2 * scale
        self.selectedBackgroundView!.layer.borderColor = UIColor.red.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
