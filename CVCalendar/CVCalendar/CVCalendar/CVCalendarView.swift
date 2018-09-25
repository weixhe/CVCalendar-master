//
//  CVCalendarView.swift
//  CVCalendar
//
//  Created by caven on 2018/9/12.
//  Copyright © 2018年 com.caven. All rights reserved.
//

import UIKit

private let color_month_title = UIColor.black       // 月份的标题颜色
private let color_normal = UIColor.black            // 正常时的颜色
private let color_select = UIColor.white            // 选中时的颜色
private let color_highlight = UIColor.red           // 周末，假日等等的颜色
private let color_disable = UIColor.lightGray       // 不能点击，过去，未来的颜色
private let color_lunar_initial = UIColor.init(red: 190 / 255, green: 26 / 255, blue: 47 / 255, alpha: 1)       // 农历月初 颜色
private let color_lunar_24_solar_terms = UIColor.init(red: 164 / 255, green: 15 / 255, blue: 144 / 255, alpha: 1)   // 农历二十四节气
private let color_lunar_festival = UIColor.init(red: 230 / 255, green: 20 / 255, blue: 50 / 255, alpha: 1)       // 农历 节日
private let color_solar_holidy = UIColor.init(red: 230 / 255, green: 20 / 255, blue: 50 / 255, alpha: 1)       // 阳历 节日


private let height_header: CGFloat = 60             // headerView的高度
private let kLineFormat: CGFloat = UIScreen.main.bounds.width / 375.0  // 设计图按照iphone6的尺寸进行设计



class CVCalendarView: UIView {
    /* 公有属性 */
    /// 日历的整体高度是否可变，默认：true，可改变
    var isAutoHeight: Bool = true
    /// 自定义的cell高度，如果没有自定义, 则默认：宽=高
    var customCellHeight: CGFloat?
    /// 自定义header的高度，如果没有自定义z，则默认：70.0f
    var customHeaderHeight: CGFloat?
    
    var sectionInset: UIEdgeInsets = UIEdgeInsets.zero
    
    /// 日历滑动方向
    var scrollDirection: UICollectionView.ScrollDirection = .horizontal
    /// 日历是否显示子标题，默认：true，显示
    var isShowSubTitle: Bool = true
    /// 日历的开始日期
    var startDate: Date?
    /// 日历的结束日期
    var endDate: Date?
    /// 日历需要显示的部分日期，如果为nil，则从开始到结束
    var datePart: [Date]?
    /// 日历默认选中的日期，默认：不选中
    var selectedDate: Date?
    
    /// 日历 - 代理
    var delegate: CVCalendarViewDelegate?
    
    
    
    /* 私有属性 */
    private var collectionView: UICollectionView!
    private var firstIndex: Int = 0     // 0-周日，1-周一， ...
    private var logic: CVCalendarLogic!
    private var currMonth: Date!        // 当前显示的month
    private var startContentOffset: CGPoint?
    private var willMoving: Bool = false       // 日历即将滑动
    private var didMoved: Bool = false        // 日历已经滑动
    
    private var currSection: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        
        let layout = CVCalendarLayout()
        layout.itemSize = CGSize(width: frame.width / 7, height: frame.width / 7)
        layout.headerReferenceSize = CGSize(width: frame.width, height: self.customHeaderHeight ?? height_header)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = self.sectionInset
        layout.customCellHeight = self.customHeaderHeight
        layout.isAutoHeight = self.isAutoHeight     // 日历的整体高度是否可变
        layout.scrollDirection = self.scrollDirection
        
        self.collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        self.collectionView.backgroundColor = UIColor.clear
        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        self.collectionView.isPagingEnabled = true
//        if self.isAutoHeight {
//            self.collectionView.isUserInteractionEnabled = false
//            self.collectionView.isScrollEnabled = false
//        }
        self.collectionView.register(CVCalendarCell.self, forCellWithReuseIdentifier: "CVCalendarCell")
        self.collectionView.register(CVCalendarHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "CVCalendarHeader")
        self.addSubview(self.collectionView)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config() {
        
        if self.startDate == nil && self.datePart == nil {
            assertionFailure("日历控件必须有开始日期，请先赋值 startDate")
        }
        
        if self.endDate == nil  && self.datePart == nil {
            assertionFailure("日历控件必须有结束日期，请先赋值 endDate")
        }
        
        // 如果部分日期不为空，则进行一次排序，从小到大
        if self.datePart != nil {
            self.datePart!.sort(by: { (date1, date2) -> Bool in
                return date1.isEqualToDate(date2, component: .day)
            })
        }
        
        if self.startDate == nil {
            self.startDate = self.datePart!.first
        }
        
        if self.endDate == nil {
            self.endDate = self.datePart!.last
        }
        
        // 创建逻辑工程
        self.logic = CVCalendarLogic(startDate: self.startDate!, endDate: self.endDate!)
        
        self.currMonth = self.selectedDate ?? self.startDate!
        self.scrollToMonth(self.currMonth, direct: true)    // 无论如何都更新
    }
    
}

extension CVCalendarView : UICollectionViewDelegate, UICollectionViewDataSource {
    
    /// 返回section个数
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.logic.numberOfMonths()
    }
    
    /// 每个section中的item个数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let date = logic.monthForSection(section)
        return self.logic.numberOfItems(in: date)
    }
    
    /// 显示cection的header
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "CVCalendarHeader", for: indexPath) as! CVCalendarHeader
        
        let month = logic.monthForSection(indexPath.section)
        
        header.titleLabel.text = self.format(date: month, format: "yyyy-MM")
        header.firstIndex = self.firstIndex
        
        return header
    }
    
    /// 赋值显示cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CVCalendarCell", for: indexPath) as! CVCalendarCell
        var model = self.logic.calendarModel(indexPath: indexPath)
        cell.titleLabel.text = "\(model.day)"
        cell.isShowSubTitle = self.isShowSubTitle
        var subText: String = ""
        
        if !model.holiday.isEmpty {                 // 阳历节假日
            subText = model.holiday
            model.dayType = model.dayType.union(.holiday)
        } else if !model.lunar_festival.isEmpty {   // 农历节日
            subText = model.lunar_festival
            model.dayType = model.dayType.union(.lunar_festival)
        } else if !model.lunar_24_solar_terms.isEmpty {     // 农历24节气
            subText = model.lunar_24_solar_terms
            model.dayType = model.dayType.union(.lunar_24_solar_terms)
        } else if model.lunar_day == "初一" {        // 农历初一 显示 月份
            subText = model.lunar_month
            model.dayType = model.dayType.union(.lunar_initial)
        } else {                                    // 最后显示农历日期
            subText = model.lunar_day
        }
        
        cell.subTitleLabel.text = subText
        cell.dayType = model.dayType
        
        if cell.dayType.contains(.past) || cell.dayType.contains(.future) {
            cell.isUserInteractionEnabled = false
        } else {
            cell.isUserInteractionEnabled = true
        }
        
        // 设置当前时间
        if let date = self.selectedDate, date.isEqualToDate(model.date, component: .day) {
//            cell.isSelected = true

            //            self.collectionView(collectionView, didSelectItemAt: indexPath)
        }
        return cell
    }
    
    /// 点击item
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CVCalendarCell
        if cell.dayType.contains(.past) || cell.dayType.contains(.future) {
            return
        }
        let date = self.logic.calendarModel(indexPath: indexPath).date
        cell.isSelected = true
        self.delegate?.calendarView?(self, selectDate: date)
        self.selectedDate = date
    }
    
}

private extension CVCalendarView {
    /// 将date转换成字符串，年-月-日
    func format(date: Date, format: String = "yyyy-MM-dd") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
   

    /// 滚动日历到 month 位置
    @discardableResult
    func scrollToMonth(_ month: Date, direct: Bool = false) -> Bool {

        guard self.updateFrame(month: month, direct: direct) else {
            return false
        }

        let indexPath = self.logic.indexPathForMonth(month)
        
        // 滚动到目标section
        self.collectionView.scrollToItem(at: indexPath, at: [.left], animated: true)
        return true
    }
    
    /// 更新某一月份的frame。 directs：直接的，不管是否需要更新，都会重新计算更新
    @discardableResult
    func updateFrame(month: Date, direct: Bool = false) -> Bool {
        if self.startDate == nil || self.endDate == nil { return false }
        if month.isEarlierToDate(self.startDate!, component: .month) || month.isLaterToDate(self.endDate!, component: .month) {
            return false
        }
        
        if direct == false && month.isEqualToDate(self.currMonth, component: .day) {
            return false
        }
        
        // 重新计算view的高度
        let cellHeight = self.customCellHeight ?? (self.collectionView.frame.width - (self.sectionInset.left + self.sectionInset.right)) / 7
        let totalHeight: CGFloat = CGFloat(self.logic.numberOfRows(in: month)) * cellHeight + (self.customHeaderHeight ?? height_header)
        var frame = self.collectionView.superview?.frame
        frame?.size.height = totalHeight
        self.collectionView.superview?.frame = frame ?? CGRect.zero
        self.collectionView.frame = self.collectionView.superview?.bounds ?? CGRect.zero
        
        self.currMonth = month
        return true
    }
}

extension CVCalendarView {

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.willMoving = true    // 滑动有效
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if self.willMoving {
            
            if self.scrollDirection == .horizontal {
                
                let section = Int(scrollView.contentOffset.x / scrollView.frame.width)
                let month = self.logic.monthForSection(section)
                self.willMoving = false
                self.didMoved = true
                self.updateFrame(month: month)
            }
        }
        self.didMoved = false
    }
    

    
    /* 以下方法是通过touch处理滑动的，但是需要处理点击转换事件 */
    /*
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let t: UITouch = touch as! UITouch
            self.willMoving = true    // 滑动有效
            self.startContentOffset = t.location(in: self)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let t: UITouch = touch as! UITouch
            // 当在屏幕上连续拍动两下时，背景回复为白色
            if t.tapCount == 2 {

            } else if t.tapCount == 1 {
                if self.willMoving {
                    let movePoint = t.location(in: self)
                    guard let startPoint = self.startContentOffset else { return }

                    if self.scrollDirection == .horizontal {
                        
                        if movePoint.x - startPoint.x > 10 { // 向右滑动
                            self.willMoving = false
                            self.didMoved = true
                            self.scrollToMonth(self.currMonth.adding(months: -1))
                        } else if movePoint.x - startPoint.x < -10 {    // 向左滑动
                            self.willMoving = false
                            self.didMoved = true
                            self.scrollToMonth(self.currMonth.adding(months: 1))
                        }
                    }
                }
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.startContentOffset = nil
        self.willMoving = false
        if self.didMoved {  // 动作：已经处理了滚动，所以不需要有操作
            
        } else {        // 没有滚动操作，处理为点击操作
            for touch: AnyObject in touches {
                let t: UITouch = touch as! UITouch
                
                let endPoint = t.location(in: self)
                let point = self.collectionView.convert(endPoint, from: self)
                print(point)
            }
        }
        self.didMoved = false
    }
    */
}

// MARK: - 日历Item
class CVCalendarCell: UICollectionViewCell {
    
    /// 日历是否显示子标题，默认：true，显示
    var isShowSubTitle: Bool = true
    /// 日期类型, 修改文字的颜色
    var dayType: CVDayType = [.none] { didSet { self.updateColor() } }
    ///
    
    private let height_title: CGFloat = 17
    private let height_subTitle: CGFloat = 13
    private lazy var selectedView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width * 0.8, height: self.frame.height * 0.8))
        view.backgroundColor = UIColor.white
        view.isHidden = true
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.layer.borderWidth = 2 * kLineFormat
        view.layer.borderColor = UIColor.red.cgColor
        view.center = CGPoint(x: self.frame.width * 0.5, y: self.frame.height * 0.5)
        self.addSubview(view)
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let y: CGFloat = (self.contentView.bounds.size.height - self.height_title - self.height_subTitle) / 2
        let label = UILabel(frame: CGRect(x: 0, y: y, width: self.contentView.frame.width, height: self.height_title))
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14 * kLineFormat)
        label.textColor = color_normal
        self.contentView.addSubview(label)
        return label
    }()
    
    lazy var subTitleLabel: UILabel = {
        let y: CGFloat = self.titleLabel.frame.maxY
        let label = UILabel(frame: CGRect(x: 0, y: y, width: self.contentView.frame.width, height: self.height_subTitle))
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 9 * kLineFormat)
        label.textColor = color_normal
        self.contentView.addSubview(label)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        if self.isShowSubTitle {
            let y: CGFloat = (self.contentView.bounds.size.height - self.height_title - self.height_subTitle) / 2
            self.titleLabel.frame = CGRect(x: 0, y: y, width: self.contentView.frame.width, height: self.height_title)
            self.subTitleLabel.frame = CGRect(x: 0, y: self.titleLabel.frame.maxY, width: self.contentView.frame.width, height: self.height_subTitle)
            self.subTitleLabel.isHidden = false
        } else {
            self.titleLabel.frame = self.contentView.bounds;
            self.subTitleLabel.isHidden = true
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
//                if self.dayType.contains(.past) || self.dayType.contains(.future) {
//                    self.selectedView.isHidden = true
//                } else {
                    self.selectedView.isHidden = false
                    self.sendSubview(toBack: self.selectedView)
//                }
            } else {
                self.selectedView.isHidden = true
            }
        }
    }
    
    private func updateColor() {
        // title 和 subtitle 统一颜色
        if dayType.contains(.weekend) {
            self.titleLabel.textColor = color_highlight
            self.subTitleLabel.textColor = color_highlight
        } else {
            self.titleLabel.textColor = color_normal
            self.subTitleLabel.textColor = color_normal
        }
        
        // 单独：农历的颜色（与下边的单独节日冲突的时候，看需求调整位置）
        if dayType.contains(.lunar_initial) {
            self.subTitleLabel.textColor = color_lunar_initial
        } else if dayType.contains(.lunar_festival) {
            self.subTitleLabel.textColor = color_lunar_festival
        } else if dayType.contains(.lunar_24_solar_terms) {
            self.subTitleLabel.textColor = color_lunar_24_solar_terms
        }
        
        // 单独：阳历的颜色（与上边的单独节日冲突的时候，看需求调整位置）
        if dayType.contains(.holiday) {
            self.subTitleLabel.textColor = color_solar_holidy
        }
        
        // 最后处理：过去，未来，不能点击等等问题
        if dayType.contains(.future) || dayType.contains(.past) {
            self.titleLabel.textColor = color_disable
            self.subTitleLabel.textColor = color_disable
        }
    }
}


class CVCalendarHeader: UICollectionReusableView {
    
    var firstIndex: Int = 0     // 0-周日，1-周一， ...

    
    lazy var titleLabel: UILabel = {
        let y: CGFloat = 0
        let label = UILabel(frame: CGRect(x: 0, y: y, width: self.frame.width, height: self.frame.height * 0.8))
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16 * kLineFormat)
        label.textColor = color_month_title
        self.addSubview(label)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 创建 周末 - 周六
        let weeks = ["周日", "周一", "周二", "周三", "周四", "周五", "周六"]
        for i in self.firstIndex..<(weeks.count + self.firstIndex) {
            let week_Index = self.firstIndex < weeks.count ? i : i - weeks.count
            let label = self.createWeekLabel(text: weeks[week_Index])
            let width = self.frame.width / 7
            label.frame = CGRect(x: width * CGFloat(week_Index), y: self.frame.height - 15, width: width, height: 15)
            label.textColor = week_Index == 0 || week_Index == 6 ? color_highlight : color_normal
            self.addSubview(label)
        }
    }
    
    private func createWeekLabel(text: String) -> UILabel {
        let label = UILabel(frame: CGRect.zero)
        label.textAlignment = .center
        label.text = text
        label.font = UIFont.systemFont(ofSize: 12 * kLineFormat)
        return label
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
