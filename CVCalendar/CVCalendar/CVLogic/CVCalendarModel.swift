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
    
    public static var past = CVDayType(rawValue: 1 << 0)           // 过去的日期
    public static var future = CVDayType(rawValue: 1 << 1)         // 未来的日期
    
    public static var workday = CVDayType(rawValue: 2 << 0)        // 工作日
    public static var weekend = CVDayType(rawValue: 2 << 1)        // 周末
    
    public static var holiday = CVDayType(rawValue: 3 << 0)        // 节假日
}

struct CVCalendarModel {
    
    var dayType: CVDayType
    
    /* 公历 */
    var year: Int
    var month: Int
    var day: Int
    var week: Int
    var date: Date
    var holiday: String     // 公历节日
    var constellation: String   // 星座
    
    /* 农历 */
    var lunar: String
    var lunar_year: String
    var lunar_month: String
    var lunar_day: String
    var lunar_festival: String          // 农历节日
    var lunar_24_solar_terms: String    // 24节气
    var isleap: Bool    // 本月是否是闰月
    
    
//    init(year: Int, month: Int, day: Int) {
//        self.year = year
//        self.month = month
//        self.day = day
//    }
}
