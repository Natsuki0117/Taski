//
//  EmailSignInVIew.swift
//  Taski
//
//  Created by 金井菜津希 on 2025/08/10.
//
import SwiftUI
import FirebaseStorage

@main
//↑これ消したら詰み
struct Taski: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authVM = AuthViewModel()
    @StateObject var taskStore = TaskStore()

//    特大メイン
    var body: some Scene {
        WindowGroup {

                ZStack {
                    MeshView()
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                    
                    if authVM.isAuthenticated {
                        if authVM.currentUser?.name.isEmpty ?? true || authVM.currentUser?.iconURL.isEmpty ?? true {
                            SignupView()
                                .environmentObject(authVM)
                                .environmentObject(taskStore)
                        } else {
                            MainView()
                                .environmentObject(authVM)
                                .environmentObject(taskStore)
                        }
                    } else {
                        SigninView()
                            .environmentObject(authVM)
                            .environmentObject(taskStore)
                    }
                }
            
        }
    }
}
