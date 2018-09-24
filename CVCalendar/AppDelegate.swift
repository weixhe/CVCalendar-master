//
//  AppDelegate.swift
//  CVCalendar
//
//  Created by caven on 2018/9/11.
//  Copyright © 2018年 com.caven. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        //创建两个日期
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        let startDate = f.date(from: "2018-09-01")!;
        let endDate = f.date(from: "2019-01-02")!;
        
        //利用NSCalendar比较日期的差异
        /**
         * 要比较的时间单位,常用如下,可以同时传：
         *    NSCalendarUnitDay : 天
         *    NSCalendarUnitYear : 年
         *    NSCalendarUnitMonth : 月
         *    NSCalendarUnitHour : 时
         *    NSCalendarUnitMinute : 分
         *    NSCalendarUnitSecond : 秒
         */
//        NSCalendarUnit unit = NSCalendarUnitDay;//只比较天数差异
        //比较的结果是NSDateComponents类对象
        let delta = Calendar.current.dateComponents([.month], from: startDate, to: endDate)
        //打印
        print(delta);
        //获取其中的"天"
        print( delta.month);
    


        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

