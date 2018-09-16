//
//  ViewController.swift
//  CVCalendar
//
//  Created by caven on 2018/9/11.
//  Copyright © 2018年 com.caven. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let calendar = CVCalendarView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: self.view.frame.width, height: 300)))
        calendar.backgroundColor = UIColor.brown
        self.view.addSubview(calendar)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

