//
//  CVCalendar+Logic.swift
//  CVCalendar
//
//  Created by caven on 2018/9/12.
//  Copyright © 2018年 com.caven. All rights reserved.
//

import Foundation

extension CVCalendarLogic {
    
    /// 返回 month，根据section，查找是哪个月份
    func monthForSection(_ section: Int) -> Date {
        return self.startDate.startOfMonth().dayInTheFollowingMonth(section)
    }
    
    /// 返回 rows 根据section，总共需要显示多少行日期
    func rowsForSection(_ section: Int) -> Int {
        let month = self.monthForSection(section)
        return self.numberOfRows(in: month)
    }
    
    /// 返回月份的 indexPath，根据月份，indexPath.row为0
    func indexPathForMonth(_ month: Date) -> IndexPath {
        let num = Date.monthsBetween(from: self.startDate, to: month) - 1
        return IndexPath(item: 0, section: num)
    }
    
    /// 返回日期的 indexPath, 根据日期， indexPath.row为日期的具体位置
    func indexPathForDate(_ date: Date) -> IndexPath {
        let section = Date.monthsBetween(from: self.startDate, to: date) - 1
        let headPlace: Int = self.headPlaceForMonth(date)
        let row = headPlace + date.day - 1
        return IndexPath(row: row, section: section)
    }
    
    func calendarModel(indexPath: IndexPath) -> CVCalendarModel {
        
        // 先根据section找到需要的月份
        let month = self.startDate.startOfMonth().dayInTheFollowingMonth(indexPath.section)
        
        var model: CVCalendarModel
        // 再根据row找到需要的确切的日期
        let headPlace: Int = self.headPlaceForMonth(month)  // 1号之前有上个月的天
        if indexPath.row < headPlace {  // 处理1号之前的日期
            let preMonth: Date = month.adding(months: -1)
            let day: Int = preMonth.daysInThisMonth() - headPlace + Int(indexPath.row) + 1
            model = CVCalendarModel(year: preMonth.year, month: preMonth.month, day: day)
            model.dayType = [.past]
        } else if indexPath.row < (headPlace + month.daysInThisMonth()) {    // 本月
            let day: Int = Int(indexPath.row) - headPlace + 1
            model = CVCalendarModel(year: month.year, month: month.month, day: day)
            if model.weekday == 1 || model.weekday == 7 {
                model.dayType = [.weekend]
            } else {
                model.dayType = [.workday]
            }
            
            if model.date.isEarlierToDate(self.startDate, component: .day) {
                model.dayType = model.dayType.union(.past)
            }
            if model.date.isLaterToDate(self.endDate, component: .day) {
                model.dayType = model.dayType.union(.future)
            }
            
        } else {    // 30(29,28,31)之后下个月的日期
            let nextMonth: Date = month.adding(months: 1)
            let day: Int = Int(indexPath.row) - headPlace - month.daysInThisMonth() + 1
            model = CVCalendarModel(year: nextMonth.year, month: nextMonth.month, day: day)
            model.dayType = [.future]
        }
        
        return model
    }
    
}
