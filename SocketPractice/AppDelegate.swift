//
//  AppDelegate.swift
//  SocketPractice
//
//  Created by bill.w.chen on 2025/11/26.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // 監聽 App 回到前景
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillResign),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("📡 App 被關閉 → 斷線")
        SocketManager.shared.disconnect()
    }
    
    @objc func appDidBecomeActive() {
        if !SocketManager.shared.isConnected {
            print("📲 App 回到前景，自動重連中…")
            SocketManager.shared.connect()
        }
    }
    
    @objc func appWillResign() {
        print("📡 ViewController 偵測到 app 暫停 → 斷線")
        SocketManager.shared.disconnect()
    }

}

