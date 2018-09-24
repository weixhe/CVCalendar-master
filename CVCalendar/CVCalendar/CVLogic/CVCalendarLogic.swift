//
//  CVCalendarLogic.swift
//  CVCalendar
//
//  Created by caven on 2018/9/11.
//  Copyright © 2018年 com.caven. All rights reserved.
//

import Foundation

/// 获取当前日历
fileprivate let CurrentCalendar = Calendar(identifier: Calendar.Identifier.gregorian) // 公历日历

struct CVCalendarLogic {
    
    /// 日历的开始日期
    var startDate: Date
    /// 日历的结束日期
    var endDate: Date
    
    init(startDate: Date, endDate: Date) {
        self.startDate = startDate
        self.endDate = endDate
    }

    /// 返回总共有多少个月份，即：多少个section
    func numberOfMonths() -> Int {
        // 判断两个日期之间跨越几个月份，需要从开始日期的1号，到结束日期的1号，否则会计算错误，跨越并不是相差月份
        return Date.monthsBetween(from: self.startDate.startOfMonth(), to: self.endDate.startOfMonth())
    }
    
    /// 返回某个月份有多少个日期（包含上月余，本月，下月初）
    func numberOfItems(in month: Date) -> Int {
        return self.numberOfRows(in: month) * 7 // 总item个数
    }
    
    /// 返回某个月份需要显示多少行
    func numberOfRows(in month: Date) -> Int {
        let headPlace = self.headPlaceForMonth(month)  // 1号之前有多少天
        let daysOfMonth = month.daysInThisMonth()   // 这个月有多少天
        let headDayCount = daysOfMonth + headPlace
        let rowCount = headDayCount / 7 + (headDayCount % 7 > 0 ? 1 : 0)  // 总行数
        return rowCount
    }    
    
    /// 获取每个月1号之前需要显示上个月的日期的天数
    func headPlaceForMonth(_ month: Date) -> Int {
        let weekDay = month.weekForFirstDayInMonth() // 这个月的第一天是周几
        let headPlaceholders = (weekDay.weekday - CurrentCalendar.firstWeekday + 7) % 7
        return headPlaceholders
    }
}

extension CVCalendarLogic {
    // MARK: - 根据公历的年月日 -> 转换成农历
    static func lunar(year: Int, month: Int, day: Int) -> String {
        
        let solar = CVSolar(year: year, month: month, day: day)
        let lunar = CVLunarSolarConverter.solarToLunar(solar: solar)
        // 农历年份名
        let chinese_years = ["甲子年", "乙丑年", "丙寅年", "丁卯年", "戊辰年", "己巳年", "庚午年", "辛未年", "壬申年", "癸酉年",
                             "甲戌年", "乙亥年", "丙子年", "丁丑年", "戊寅年", "己卯年", "庚辰年", "辛己年", "壬午年", "癸未年",
                             "甲申年", "乙酉年", "丙戌年", "丁亥年", "戊子年", "己丑年", "庚寅年", "辛卯年", "壬辰年", "癸巳年",
                             "甲午年", "乙未年", "丙申年", "丁酉年", "戊戌年", "己亥年", "庚子年", "辛丑年", "壬寅年", "癸丑年",
                             "甲辰年", "乙巳年", "丙午年", "丁未年", "戊申年", "己酉年", "庚戌年", "辛亥年", "壬子年", "癸丑年",
                             "甲寅年", "乙卯年", "丙辰年", "丁巳年", "戊午年", "己未年", "庚申年", "辛酉年", "壬戌年", "癸亥年"]
        
        // 农历日期名
        let chinese_days = ["*", "初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", " 初九", "初十",
                            "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十",
                            "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十"]
        
        // 农历月份名
        let chinese_months = ["*", "正月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "冬月", "腊月"]
        if lunar.isleap {
            return chinese_years[lunar.year] + "-" + "润" + chinese_months[lunar.month] + "-" + chinese_days[lunar.day]
        } else {
            return chinese_years[lunar.year] + "-" + chinese_months[lunar.month] + "-" + chinese_days[lunar.day]
        }
    }
    
    // MARK: - 以下是系统方法获取农历，据说有问题，但是没发现过
    /// 返回 农历(2017丁酉年闰六月初二星期一)
    static func lunar(date: Date) -> String {
        // 设置农历日历
        let chinese = Calendar(identifier: .chinese)
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.calendar = chinese
        // 日期样式
        formatter.dateStyle = .full
        // 公历转为农历
        let lunar = formatter.string(from: date)
        return lunar
    }
    
    /// 返回 农历是否是闰月
    static func lunar_isleep(date: Date) -> Bool {
        // 设置农历日历
        let chinese = Calendar(identifier: .chinese)
        let componment = chinese.dateComponents([.year, .month], from: date)
        if let isLeap = componment.isLeapMonth, isLeap == true {
            return true
        }
        return false
    }
    
    /// 返回农历的年(丁酉年)
    static func lunar_year(date: Date) -> String {
        let chineseYear = ["甲子年", "乙丑年", "丙寅年", "丁卯年", "戊辰年", "己巳年", "庚午年", "辛未年", "壬申年", "癸酉年",
                           "甲戌年", "乙亥年", "丙子年", "丁丑年", "戊寅年", "己卯年", "庚辰年", "辛己年", "壬午年", "癸未年",
                           "甲申年", "乙酉年", "丙戌年", "丁亥年", "戊子年", "己丑年", "庚寅年", "辛卯年", "壬辰年", "癸巳年",
                           "甲午年", "乙未年", "丙申年", "丁酉年", "戊戌年", "己亥年", "庚子年", "辛丑年", "壬寅年", "癸丑年",
                           "甲辰年", "乙巳年", "丙午年", "丁未年", "戊申年", "己酉年", "庚戌年", "辛亥年", "壬子年", "癸丑年",
                           "甲寅年", "乙卯年", "丙辰年", "丁巳年", "戊午年", "己未年", "庚申年", "辛酉年", "壬戌年", "癸亥年"]
        // 设置农历日历
        let chinese = Calendar(identifier: .chinese)
        let componment = chinese.dateComponents([.year], from: date)
        return chineseYear[componment.year! - 1]
    }
    
    /// 返回农历的月(闰六月)
    static func lunar_month(date: Date) -> String {
        let chineseMonth = ["正月", "二月", "三月", "四月", "五月", "六月", "七月", "八月",
                            "九月", "十月", "十一月", "腊月"]
        // 设置农历日历
        let chinese = Calendar(identifier: .chinese)
        let componment = chinese.dateComponents([.year, .month], from: date)
        if let isLeap = componment.isLeapMonth, isLeap == true {
            return "润" + chineseMonth[componment.month! - 1]
        }
        return chineseMonth[componment.month! - 1]
    }
    
    /// 返回农历的日(初二)
    static func lunar_day(date: Date) -> String {
        let chineseDay = ["初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十",
                          "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十",
                          "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十"]
        // 设置农历日历
        let chinese = Calendar(identifier: .chinese)
        let componment = chinese.dateComponents([.year, .month, .day], from: date)
        return chineseDay[componment.day! - 1]
    }
    
    // MARK: - 计算节日、节气
    static func lunar_festival(date: Date) -> String {
        let lunar_month = self.lunar_month(date: date)
        let lunar_day = self.lunar_day(date: date)
        var result = ""
        
        // 除夕单独计算，春节的前一天
        if self.lunar_month(date: date.adding(days: -1)) == "正月" && self.lunar_day(date: date.adding(days: -1)) == "初一" {
            result = "除夕"
        } else if lunar_month == "正月" && lunar_day == "初一" {
            result = "春节"
        } else if lunar_month == "正月" && lunar_day == "十五" {
            result = "元宵节"
        } else if lunar_month == "二月" && lunar_day == "初二" {
            result = "龙抬头"
        } else if lunar_month == "五月" && lunar_day == "初五" {
            result = "端午节"
        } else if lunar_month == "七月" && lunar_day == "初七" {
            result = "七夕节"
        } else if lunar_month == "八月" && lunar_day == "十五" {
            result = "中秋节"
        } else if lunar_month == "九月" && lunar_day == "初九" {
            result = "重阳节"
        } else if lunar_month == "腊月" && lunar_day == "初八" {
            result = "腊八节"
        } else if lunar_month == "腊月" && lunar_day == "廿三" {
            result = "北方小年"
        } else if lunar_month == "腊月" && lunar_day == "廿四" {
            result = "南方小年"
        }
        return result
    }
    
    /// 公历节日
    static func solar_holiday(date: Date) -> String {
        var result = ""
        if date.month == 1 && date.day == 1 {
            result = "元旦"
        } else if date.month == 2 && date.day == 14 {
            result = "情人节"
        } else if date.month == 3 && date.day == 8 {
            result = "妇女节"
        } else if date.month == 3 && date.day == 12 {
            result = "植树节"
        } else if date.month == 5 && date.day == 1 {
            result = "劳动节"
        } else if date.month == 6 && date.day == 1 {
            result = "儿童节"
        } else if date.month == 8 && date.day == 1 {
            result = "建军节"
        } else if date.month == 9 && date.day == 10 {
            result = "教师节"
        } else if date.month == 10 && date.day == 1 {
            result = "国庆节"
        } else if date.month == 11 && date.day == 11 {
            result = "光棍节"
        } else if date.month == 12 && date.day == 25 {
            result = "圣诞节"
        }
        return result
    }
    
    /// 二十四节气
    static func twentyFourSolarTerm(date: Date) -> String {
        // 24节气只有(1901 - 2050)之间为准确的节气
        /* 定气法计算二十四节气,二十四节气是按地球公转来计算的，并非是阴历计算的 */
        let solarTerm = ["小寒", "大寒", "立春", "雨水", "惊蛰", "春分", "清明", "谷雨", "立夏", "小满", "芒种", "夏至", "小暑", "大暑", "立秋", "处暑", "白露", "秋分", "寒露", "霜降", "立冬", "小雪", "大雪", "冬至"]
        let solarTermInfo = [0, 21208, 42467, 63836, 85337, 107014, 128867, 150921, 173149, 195551, 218072, 240693, 263343, 285989, 308563, 331033, 353350, 375494, 397447, 419210, 440795, 462224, 483532, 504758]
        
        let formater = DateFormatter()
        formater.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let baseDateAndTime = formater.date(from: "1900-01-06 02:05:00")
        guard baseDateAndTime != nil else { return "" }
        var newDate: Date!
        var num = 0.0
        var result = ""
        let year = date.year        // ??? 确定这里不需要换算成农历后在进行计算比较？？
        for i in 1...24 {
            num = 525948.76 * Double(year - 1900) + Double(solarTermInfo[i - 1])
            newDate = baseDateAndTime!.addingTimeInterval(num * 60) // 按分钟计算
            if newDate.month == date.month && newDate.day == date.day {
                result = solarTerm[i - 1];
                break;
            }
        }
        
        return result
    }
    
    // MARK: - 星座 & 属相
    /// 星座
    static func constellationName(date: Date) -> String {
        let constellations = ["白羊座", "金牛座", "双子座", "巨蟹座", "狮子座", "处女座", "天秤座", "天蝎座", "射手座", "摩羯座", "水瓶座", "双鱼座"]
        var index = 0;
        let year = date.month * 100 + date.day;
        
        if (((year >= 321) && (year <= 419))) { index = 0 }
        else if ((year >= 420) && (year <= 520)) { index = 1 }
        else if ((year >= 521) && (year <= 620)) { index = 2 }
        else if ((year >= 621) && (year <= 722)) { index = 3 }
        else if ((year >= 723) && (year <= 822)) { index = 4 }
        else if ((year >= 823) && (year <= 922)) { index = 5 }
        else if ((year >= 923) && (year <= 1022)) { index = 6 }
        else if ((year >= 1023) && (year <= 1121)) { index = 7 }
        else if ((year >= 1122) && (year <= 1221)) { index = 8 }
        else if ((year >= 1222) || (year <= 119)) { index = 9 }
        else if ((year >= 120) && (year <= 218)) { index = 10 }
        else if ((year >= 219) && (year <= 320)) { index = 11 }
        else { index = 0 }
        
        return constellations[index];
    }
    
    /// 生肖属相
    static func animal(date: Date) -> String {
        let animals = ["鼠", "牛", "虎", "兔", "龙", "蛇", "马", "羊", "猴", "鸡", "狗", "猪"]
        let animalStartYear = 1900 // 1900年为鼠年
        let offset = date.year - animalStartYear
        return animals[abs(offset) % 12]
    }
    
    // MARK: - 天干地支
    /// 取农历天干地支表示年月日（甲子年乙丑月丙庚日）
    static func gan_zhi(date: Date) -> String {
        return self.gan_zhi_year(date: date) + self.gan_zhi_month(date: date) + self.gan_zhi_day(date: date)
    }
    
    /// 取农历年的干支表示法（乙丑年）
    static func gan_zhi_year(date: Date) -> String {
        let ganZhiStartYear = 1864 // 干支计算起始年
        // 换算农历日历
        let solar = CVSolar(year: date.year, month: date.month, day: date.day)
        let lunar = CVLunarSolarConverter.solarToLunar(solar: solar)
        let i: Int = (lunar.year - ganZhiStartYear) % 60 //计算干支
        let gan = ["甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸"][abs(i) % 10]
        let zhi = ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"][abs(i) % 12]
        return gan + zhi + "年"
    }
    
    /// 取干支的月表示字符串（乙丑月），注意农历的闰月不记干支
    static func gan_zhi_month(date: Date) -> String {
        var zhiIndex: Int!
        // 换算农历日历
        let solar = CVSolar(year: date.year, month: date.month, day: date.day)
        let lunar = CVLunarSolarConverter.solarToLunar(solar: solar)
        if (lunar.month > 10) {  // 每个月的地支总是固定的, 而且总是从寅月开始
            zhiIndex = lunar.month - 10
        } else {
            zhiIndex = lunar.month + 2
        }
        let zhi = ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"][zhiIndex - 1]
        
        // 根据当年的干支年的干来计算月干的第一个
        var ganIndex = 1;
        let ganZhiStartYear = 1864 // 干支计算起始年
        let i = (lunar.year - ganZhiStartYear) % 60; // 计算干支
        switch (i % 10) {
        case 0: // 甲
            ganIndex = 3
        case 1: // 乙
            ganIndex = 5
        case 2: // 丙
            ganIndex = 7
        case 3: // 丁
            ganIndex = 9
        case 4: // 戊
            ganIndex = 1
        case 5: // 己
            ganIndex = 3
        case 6: // 庚
            ganIndex = 5
        case 7: // 辛
            ganIndex = 7
        case 8: // 壬
            ganIndex = 9
        case 9: // 癸
            ganIndex = 1
        default:
            ganIndex = 1
        }
        let gan = ["甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸"][(ganIndex + lunar.month - 2) % 10]
        
        return gan + zhi + "月";
    }
    
    /// 取干支日表示法（丙庚日）
    static func gan_zhi_day(date: Date) -> String {
        // 换算农历日历
        let solar: CVSolar = CVSolar(year: date.year, month: date.month, day: date.day)
        let lunar: CVLunar = CVLunarSolarConverter.solarToLunar(solar: solar)
        let dateString: String = String.init(format: "%d-%d-%d %d:%d:%d", lunar.year, lunar.month, lunar.day, date.hour, date.minute, date.second)
        
        let formater = DateFormatter()
        formater.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let lunarDate: Date = formater.date(from: dateString)!
        
        let i: Int = Date.daysBetween(from: formater.date(from: "1899-12-22 00:00:00")!, to: lunarDate) % 60
        let gan = ["甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸"][abs(i) % 10]
        let zhi = ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"][abs(i) % 12]
        return gan + zhi + "日"
    }
}
