//
//  EmailSignInVIew.swift
//  ToDoTask
//
//  Created by 金井菜津希 on 2025/08/10.
//

import Foundation

struct EmailSignInApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var vm = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            if vm.isAuthenticated {
                MainView()
                    .environmentObject(vm)
            } else {
                SigninView()
                    .environmentObject(vm)
            }
        }
    }
}
