//
//  AppDelegate.swift
//  ToDoTask
//
//  Created by 金井菜津希 on 2024/08/15.
//
import SwiftUI
import FirebaseCore
import FirebaseAuthUI


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        return true
    }
    // MARK: URL Schemes
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        // other URL handling goes here.
        return false
    }
}
@main
struct sampleFirebaseUIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


//import SwiftUI
//import FirebaseCore
//import FirebaseAuth
//
//class AppDelegate: NSObject, UIApplicationDelegate {
//    func application(_ application: UIApplication,
//                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//        FirebaseApp.configure()
//        FirebaseAuthManager.anonymousSignIn()
//        // ここで匿名サインインを行う場合は、ViewModelを作成してから呼び出す必要があります。
//        return true
//    }
//}
//
//@main
//struct EmailSignInExampleApp: App {
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
//    @StateObject var vm = AuthViewModel() // @StateObjectをここで定義
//
//    var body: some Scene {
//        WindowGroup {
//            MainView() // AuthViewModelを直接渡さず、EnvironmentObjectで設定します。
//                .environmentObject(vm) // ここでEnvironmentObjectとして渡します
//        }
//    }
//}

