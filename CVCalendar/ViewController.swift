//
//  ViewController.swift
//  CVCalendar
//
//  Created by caven on 2018/9/11.
//  Copyright © 2018年 com.caven. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CVCalendarViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        
        let calendar = CVCalendarView(frame: CGRect(origin: CGPoint(x: 0, y: 100), size: CGSize(width: self.view.frame.width, height: 400)))
        
        let date = Date()
        calendar.startDate = date
        calendar.endDate = date.adding(days: 1001)
        calendar.delegate = self
        calendar.isShowSubTitle = true
        calendar.selectedDate = date
        calendar.isAutoHeight = false
        
        
        let date1 = Date.init(year: 2018, month: 9, day: 25)
        let date2 = Date.init(year: 2018, month: 9, day: 28)
        let date3 = Date.init(year: 2018, month: 9, day: 29)
        var arr = [date1, date2, date3]
        for i in 1..<32 {
            switch i {
            case 2,4,5,7,8,14,18,27,30:
                print("none")
            default:
                let date = Date.init(year: 2018, month: 10, day: i)
                arr.append(date)
            }
        }
        
        for i in 1..<31 {
            switch i {
            case 4,7,12,24,16,28:
                print("none")
            default:
                let date = Date.init(year: 2018, month: 11, day: i)
                arr.append(date)
            }
        }
        
        calendar.datePart = arr
        self.view.addSubview(calendar)
        
        calendar.config()
        
        let btn1 = UIButton(type: .custom)
        btn1.setTitle("日历-横向", for: .normal)
        btn1.setTitleColor(UIColor.red, for: UIControlState.normal)
        btn1.layer.cornerRadius = 3
        btn1.layer.masksToBounds = true
        btn1.layer.borderWidth = 1
        btn1.layer.borderColor = UIColor.red.cgColor
        btn1.addTarget(self, action: #selector(onClickBtn1Action), for: UIControlEvents.touchUpInside)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func onClickBtn1Action() {
        
    }
    
    // MARK: - CVCalendarDelegate
    func calendarView(_ calendarView: CVCalendarView, selectDate: Date) {
        print("click the date: \(selectDate)")
    }
}

