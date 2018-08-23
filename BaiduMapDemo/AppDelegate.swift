//
//  AppDelegate.swift
//  BaiduMapDemo
//
//  Created by ning on 2018/8/23.
//  Copyright © 2018年 ning. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, BMKGeneralDelegate{

    var window: UIWindow?
    var mapManager = BMKMapManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        setupMapLocation()
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

extension AppDelegate {
    func setupMapLocation()  {
        if BMKMapManager.setCoordinateTypeUsedInBaiduMapSDK(BMK_COORDTYPE_BD09LL) {
            print("经纬度类型设置成功")
        }else {
            print("经纬度类型设置失败")
        }
        
        let ret = mapManager.start("PBfAZ7MZZDpnSUekkQFv2fRC25aRVf2d", generalDelegate: self)
        if  ret == false {
            print("manager start failed")
        }
    }
    
    
}
//MARK: -- BMKGeneralDelegate
extension AppDelegate {
    func onGetNetworkState(_ iError: Int32) {
        if 0 == iError {
            print("联网成功")
        }else {
            print("联网失败。错误码：Error\(iError)")
        }
    }
    
    func onGetPermissionState(_ iError: Int32) {
        if 0 == iError {
            print("授权成功")
        }else {
            print("授权失败。错误码：Error\(iError)")
        }
    }
}
