//
//  CVCalendarModel.swift
//  CVCalendar
//
//  Created by caven on 2018/9/11.
//  Copyright © 2018年 com.caven. All rights reserved.
//

import Foundation

struct CVDayType: OptionSet {

    var rawValue: UInt
    
    public static var empty = CVDayType(rawValue: 1 << 0)           // 1-空
    
    public static var past = CVDayType(rawValue: 1 << 1)           // 2-过去的日期
    public static var future = CVDayType(rawValue: 1 << 2)         // 4-未来的日期
    
    public static var workday = CVDayType(rawValue: 1 << 3)        // 8-工作日
    public static var weekend = CVDayType(rawValue: 1 << 4)        // 16-周末
    
    public static var holiday = CVDayType(rawValue: 1 << 5)        // 32-节假日
    
    public static var lunar_festival = CVDayType(rawValue: 1 << 6) // 64-农历节假日
    public static var lunar_24_solar_terms = CVDayType(rawValue: 1 << 7) // 128-农历24节气
    public static var lunar_initial = CVDayType(rawValue: 1 << 8) // 256-农历月初，显示月份


}

struct CVCalendarModel {
    
    var dayType: CVDayType = [.empty]
    
    var date: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
//        formatter.timeZone = TimeZone(secondsFromGMT: 8)        // 东8区, 如果日历出现问题，将时区u去掉
        return formatter.date(from: "\(self.year)-\(self.month)-\(self.day)")!
    }
    /* 公历 */
    var year: Int
    var month: Int
    var day: Int
    var weekday: Int { return self.date.weekdayInMonth().weekday }
    /// 公历节日
    var holiday: String { return CVCalendarLogic.solar_holiday(date: self.date) }
    
    init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }
}

extension CVCalendarModel {
    
    /// 星座
    var constellation: String {
        return CVCalendarLogic.animal(date: self.date)
    }
    
    /* 农历 */
    var lunar: String {
        return CVCalendarLogic.lunar(date: self.date)
    }
    /// 农历 - 年份
    var lunar_year: String {
        return CVCalendarLogic.lunar_year(date: self.date)
    }
    /// 农历 - 月份
    var lunar_month: String {
        return CVCalendarLogic.lunar_month(date: self.date)
    }
    /// 农历 - 日期
    var lunar_day: String {
        return CVCalendarLogic.lunar_day(date: self.date)
    }
    /// 农历 - 节日
    var lunar_festival: String {
        
        return CVCalendarLogic.lunar_festival(date: self.date)
    }
    /// 农历 - 24节气
    var lunar_24_solar_terms: String {
        return CVCalendarLogic.twentyFourSolarTerm(date: self.date)
    }
    /// 本月是否是闰月
    var isleap: Bool {
        return CVCalendarLogic.lunar_isleep(date: self.date)
    }
}
