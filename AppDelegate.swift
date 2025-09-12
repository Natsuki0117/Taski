//
//  AppDelegate.swift
//  Taski
//
//  Created by 金井菜津希 on 2024/08/15.
//

import SwiftUI
import FirebaseCore


import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
