//
//  CVCalendar+Day.swift
//  CVCalendar
//
//  Created by caven on 2018/9/11.
//  Copyright © 2018年 com.caven. All rights reserved.
//

import Foundation

// MARK: - 日期基础
extension Date {
    /// 返回当前日期 年份
    var year: Int {
        let components = Date.currentCalendar.dateComponents(flags, from: self)
        return components.year!
    }
    /// 返回当前日期 月份
    var month: Int {
        let components = Date.currentCalendar.dateComponents(flags, from: self)
        return components.month!
    }
    /// 返回当前日期 天
    var day: Int {
        let components = Date.currentCalendar.dateComponents(flags, from: self)
        return components.day!
    }
    /// 返回当前日期 小时
    var hour: Int {
        let components = Date.currentCalendar.dateComponents(flags, from: self)
        return components.hour!
    }
    /// 返回当前日期 分钟
    var minute: Int {
        let components = Date.currentCalendar.dateComponents(flags, from: self)
        return components.minute!
    }
    /// 返回当前日期 秒数
    var second: Int {
        let components = Date.currentCalendar.dateComponents(flags, from: self)
        return components.second!
    }
    
    /// 返回当前日期 星期几
    var weekday: Int {
        let interval = Int(self.timeIntervalSince1970)
        let days = Int(interval / CV_DAY) // 24*60*60
        let weekday = ((days + 4) % 7 + 7 ) % 7
        return weekday == 0 ? 7 : weekday
    }
}

// MARK: - 日历操作
extension Date {
    /// 某个月有多少天
    func daysInMonth(date: Date) -> Int {
        let totaldaysInMonth: Range = Date.currentCalendar.range(of: .day, in: .month, for: date)!
        return totaldaysInMonth.count
    }
    
    /// 某个月有多少周
    func weeksInMonth(date: Date) -> Int {
        let weekday = date.startOfMonth(date: Date()).weekInMonth(date: Date()).weekday
        var days = date.daysInMonth(date: Date())
        var weeks = 0
        
        if (weekday > 1) {
            weeks += 1
            days -= (7 - weekday + 1)
        }
        weeks += days / 7;
        weeks += (days % 7 > 0) ? 1 : 0
        return weeks
    }
    
    
    /// 某日期是周几（1-周日 2-周一 ...）
    func weekInMonth(date: Date) -> (weekday: Int, weekString: String) {
        let weekday: Int = Date.currentCalendar.ordinality(of: .day, in: .weekOfMonth, for: date)!
        return (weekday, self.getWeekStringFromInt(weekday))
    }
    
    /// 某月的第一天是周几（1-周日， 2-周一 ...）
    func firstWeekdayInMonth(date: Date) -> (weekday: Int, weekString: String) {
        let weekday: Int = Date.currentCalendar.ordinality(of: .day, in: .month, for: date)!
        return (weekday, self.getWeekStringFromInt(weekday))
        
        //        let firstDayInMonth: Date = "\(self.year)-\(self.month)-01".formatToDate("yyyy-MM-dd")!
        //        return firstDayInMonth.weekInThisMonth()
    }
    
    /// 判断每周的第一天是从周几开始的（1-周日， 2-周一 ...）, 用户可以自定义从周日开始或者周一开始
    func firstWeekday() -> Int {
        return Date.currentCalendar.firstWeekday
    }
    func setFirstWeekday(_ weekday: Int) {
        Date.currentCalendar.firstWeekday = weekday
    }
    
    /// 某月的开始日期（2018-09-01）
    func startOfMonth(date: Date) -> Date {
        let components = Date.currentCalendar.dateComponents(Set<Calendar.Component>([.year, .month]), from: date)
        let startOfMonth = Date.currentCalendar.date(from: components)!
        return startOfMonth
    }
    /// 某年开始日期2018-01-01）
    func startOfYear(date: Date) -> Date {
        let components = Date.currentCalendar.dateComponents(Set<Calendar.Component>([.year]), from: date)
        let startOfYear = Date.currentCalendar.date(from: components)!
        return startOfYear
    }
    
    /// 某月结束日期（2018-09-30 or 2018-09-30 23:59:59）
    func endOfMonth(date: Date, returnEndTime: Bool = false) -> Date {
        var components = DateComponents()
        components.month = 1
        if returnEndTime {
            components.second = -1
        } else {
            components.day = -1
        }
        
        let endOfMonth = Date.currentCalendar.date(byAdding: components, to: startOfMonth(date: date))!
        return endOfMonth
    }
    
    /// 某年结束日期（2018-12-31 or 2018-12-31 23:59:59）
    func endOfYear(date: Date, returnEndTime: Bool = false) -> Date {
        var components = DateComponents()
        components.year = 1
        if returnEndTime {
            components.second = -1
        } else {
            components.day = -1
        }
        
        let endOfYear = Date.currentCalendar.date(byAdding: components, to: startOfYear(date: date))!
        return endOfYear
    }
    
    /// 本日期之前的几个月的日期
    func dayInThePreviousMonth(_ month: Int) -> Date {
        var component = DateComponents()
        component.month = -month
        return Date.currentCalendar.date(byAdding: component, to: self)!
    }
    
    /// 本日期之后几个月的日期
    func dayInTheFollowingMonth(_ month: Int) -> Date {
        var component = DateComponents()
        component.month = month
        return Date.currentCalendar.date(byAdding: component, to: self)!
    }
    
    /// 两个日期之间有多少个月
    static func monthsBetween(from: Date, to: Date) -> Int {
        return abs(Date.currentCalendar.dateComponents([.month], from: from, to: to).month! + 1)
    }
    
    /// 两个日期之间有多少周
    static func weeksBetween(from: Date, to: Date) -> Int {
        return abs(Date.currentCalendar.dateComponents([.weekOfYear], from: from, to: to).weekOfYear! + 1)
    }
    
    /// 两个日期之间有多少天
    static func daysBetween(from: Date, to: Date) -> Int {
        return abs(Date.currentCalendar.dateComponents(flags, from: from, to: to).day! + 1)
    }
    
    /// 通过数字返回周几, 周日是“1”，周一是“2”...
    func getWeekStringFromInt(_ week: Int) -> String {
        var str_week = ""
        switch (week) {
        case 1:
            str_week = "周日"
        case 2:
            str_week = "周一"
        case 3:
            str_week = "周二"
        case 4:
            str_week = "周三"
        case 5:
            str_week = "周四"
        case 6:
            str_week = "周五"
        case 7:
            str_week = "周六"
        default:
            str_week = ""
        }
        return str_week
    }
}

// MARK: - 日期加减
extension Date {
    /// 获取当前日历
    static var currentCalendar = Calendar(identifier: Calendar.Identifier.gregorian) // 公历日历
    
    /// 根据date获取其他的日期
    func adding(years: Int) -> Date {
        var component = DateComponents()
        component.year = years
        return Date.currentCalendar.date(byAdding: component, to: self)!
    }
    
    func adding(months: Int) -> Date {
        var component = DateComponents()
        component.month = months
        return Date.currentCalendar.date(byAdding: component, to: self)!
    }
    
    func adding(days: Int) -> Date {
        var component = DateComponents()
        component.day = days
        return Date.currentCalendar.date(byAdding: component, to: self)!
    }
    
    func adding(hours: Int) -> Date {
        var component = DateComponents()
        component.hour = hours
        return Date.currentCalendar.date(byAdding: component, to: self)!
    }
    
    func adding(minutes: Int) -> Date {
        var component = DateComponents()
        component.minute = minutes
        return Date.currentCalendar.date(byAdding: component, to: self)!
    }
    
    func adding(seconds: Int) -> Date {
        var component = DateComponents()
        component.second = seconds
        return Date.currentCalendar.date(byAdding: component, to: self)!
    }
}

// MARK: - 日期对比
extension Date {
    /// 是否是周末
    func isWeekend() -> Bool {
        let component: DateComponents = Date.currentCalendar.dateComponents([.weekday], from: self)
        if component.weekday == 1 || component.weekday == 7 {
            return true
        }
        return false
    }
    
    /// 是否是工作日
    func isWorkDay() -> Bool {
        return !self.isWeekend()
    }
    
    func isToday() -> Bool {
        return isEqualToDate(Date())
    }
    
    /// 是否是明天
    func isTomorrow() -> Bool {
        return isEqualToDate(Date().adding(days: 1))
    }
    
    /// 是否是昨天
    func isYesterday() -> Bool {
        return isEqualToDate(Date().adding(days: -1))
    }
    
    /// 是不是同一周
    func isTheSameWeek(_ date: Date) -> Bool {
        let component1 = Date.currentCalendar.dateComponents(flags, from: self)
        let component2 = Date.currentCalendar.dateComponents(flags, from: date)
        if component1.weekOfYear != component2.weekOfYear {
            return false
        }
        // 两个日期相差小于 7
        return fabs(self.timeIntervalSince(date)) < Double(CV_WEEK)
    }
    
    
    enum CVDateCompareResult {
        case equal
        case earlier
        case later
    }
    
    /// 两个日期比较，返回比较结果
    func compare(_ date: Date, ignoreTime: Bool = true) -> CVDateCompareResult {
        let component1 = Date.currentCalendar.dateComponents(flags, from: self)
        let component2 = Date.currentCalendar.dateComponents(flags, from: date)
        let data1: Array<Int> = [component1.year!, component1.month!, component1.day!, component1.hour!, component1.minute!, component1.second!]
        let data2: Array<Int> = [component2.year!, component2.month!, component2.day!, component2.hour!, component2.minute!, component2.second!]
        let count = ignoreTime ? 3 : data1.count  // 忽略时间时，比较 year， month， day
        var result: CVDateCompareResult = .equal
        for i in 0..<count {
            if data1[i] > data2[i] {
                result = .later; break
            } else if data1[i] < data2[i] {
                result = .earlier; break
            }
        }
        return result
    }
    
    
    /// 两个日期是否相等，可忽略时间
    func isEqualToDate(_ date: Date, ignoreTime: Bool = true) -> Bool {
        return self.compare(date, ignoreTime: ignoreTime) == .equal
    }
    
    /// self 比 date 更早一些
    func isEarlierToDate(_ date: Date, ignoreTime: Bool = true) -> Bool {
        return self.compare(date, ignoreTime: ignoreTime) == .earlier
    }
    
    /// self 比 date 更晚一些
    func isLaterToDate(_ date: Date, ignoreTime: Bool = true) -> Bool {
        return self.compare(date, ignoreTime: ignoreTime) == .later
    }
}

private let CV_MINUTE: Int     = 60
private let CV_HOUR: Int       = 3600
private let CV_DAY: Int        = 86400   // 24*60*60
private let CV_WEEK: Int       = 604800  // 24*60*60*7
private let CV_YEAR: Int       = 31556926

private let flags: Set = [Calendar.Component.year, Calendar.Component.month, Calendar.Component.day, Calendar.Component.hour, Calendar.Component.minute, Calendar.Component.second, Calendar.Component.weekday]
