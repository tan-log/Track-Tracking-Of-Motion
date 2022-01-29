//
//  SceneDelegate.swift
//  MyMapkit
//
//  Created by tan on 2021/11/26.
//

import UIKit
import SwiftUI
import CoreLocation

class SceneDelegate: UIResponder, UIWindowSceneDelegate{

    var window: UIWindow?
    let locationManager = CLLocationManager()
    var coordinatePath = CoordinatePath()


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        locationManager.delegate = self
        checkLocationServiceEnabledAndInit()
        let contentView = ContentView()
            .environmentObject(coordinatePath)

        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
/**
     1. 点击应用程序图标
     2. 程序入口：进入Main函数
     3. 通过UIApplicationMain函数
     4. 初始化UIApplication对象并且设置代理对象AppDelegate
     5. 程序完成加载：[AppDelegate application:didFinishLaunchingWithOptions:]
     6. 进入场景对象调用：[SceneDelegate scene:willConnectToSession:options:]方法
     7. 程序将要进入场景：[SceneDelegate sceneWillEnterForeground:]
     8. 场景已经激活：[SceneDelegate sceneDidBecomeActive:]
     9. 点击Home键：
       （1）取消场景激活状态：[SceneDelegate sceneWillResignActive:]
       （2）程序进入后台：[SceneDelegate sceneDidEnterBackground:]
     10. 点击图标
       （1）程序将要进入前台：[SceneDelegate sceneWillEnterForeground:]
       （2）程序已经被激活：[SceneDelegate sceneDidBecomeActive:]
     11. 进入程序选择界面：[SceneDelegate sceneWillResignActive:]
     11. 程序被杀死：[SceneDelegate sceneDidDisconnect:]
     */
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    /**
       kCLLocationAccuracyBestForNavigation // 最适合导航
       kCLLocationAccuracyBest; // 最好的
       kCLLocationAccuracyNearestTenMeters; // 10m
       kCLLocationAccuracyHundredMeters; // 100m
       kCLLocationAccuracyKilometer; // 1000m
       kCLLocationAccuracyThreeKilometers; // 3000m
     */
    func sceneDidBecomeActive(_ scene: UIScene) {
        
        locationManager.distanceFilter = kCLDistanceFilterNone
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
       
    }

    func sceneWillResignActive(_ scene: UIScene) {
        locationManager.stopUpdatingLocation()
        locationManager.distanceFilter = 10 //10m update once
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
       
       
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        print("scene front")
       
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    func sceneDidEnterBackground(_ scene: UIScene) {
        print("scene back")
        
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    


}

extension SceneDelegate {
    func checkLocationServiceEnabledAndInit() {
        // If previously denied, do nothing.
        
        let status = locationManager.authorizationStatus;
        // restricted or denied
        if status == .denied || status == .restricted || !CLLocationManager.locationServicesEnabled() {
            print("You hava denied this app location permission. Go into settings to change it.")
            return
        }

        // haven't show location permission before, show it.
        
        if(status == .notDetermined){
            locationManager.requestAlwaysAuthorization()
            print("requestAlwaysAuthorization")
            return
        }
        //background update
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
    }
}
extension SceneDelegate: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != .authorizedAlways {
            checkLocationServiceEnabledAndInit()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        ///如果获得到的精度大于15则停止获取位置信息，否则很费电，
        if let location = locations.last, location.horizontalAccuracy < 15 {
            coordinatePath.coordinates.append(location.coordinate)
            // 1. 获取方向偏向
            var angleStr:String?
            
              switch (location.course / 90) {
              case 0..<1:
                      angleStr = "北偏东"
                      break
              case 1..<2:
                      angleStr = "东偏南"
                      break
              case 2..<3:
                      angleStr = "南偏西"
                      break
              case 3..<4:
                      angleStr = "西偏北"
                      break;
                      
                  default:
                      angleStr = "跑沟里去了!!"
                      break;
              }
            print(angleStr!)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error)")
    }
}
