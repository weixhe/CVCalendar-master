//
//  CVCalendarViewProtocol.swift
//  CVCalendar
//
//  Created by caven on 2018/9/24.
//  Copyright © 2018年 com.caven. All rights reserved.
//

import Foundation

/// 日历控件的代理
@objc protocol CVCalendarViewDelegate {
    
    /// 日历 - 选中某一个日期
    @objc optional func calendarView(_ calendarView: CVCalendarView, selectDate: Date)
}
