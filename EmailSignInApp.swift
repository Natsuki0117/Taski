//
//  EmailSignInVIew.swift
//  ToDoTask
//
//  Created by 金井菜津希 on 2025/08/10.
//
import SwiftUI
import FirebaseStorage

@main
struct EmailSignInApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var vm = AuthViewModel()
    @StateObject var taskStore = TaskStore()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if vm.isAuthenticated {
                    if vm.displayName.isEmpty && vm.iconData == nil {
                        InitialSetupView()
                            .environmentObject(vm)
                            .environmentObject(taskStore)
                    } else {
                        MainView()
                            .environmentObject(taskStore)
                    }
                } else {
                    SigninView()
                        .environmentObject(vm)
                        .environmentObject(taskStore)
                }
            }
            .environmentObject(vm)
        }
    }
}
