//
//  EmailSignInVIew.swift
//  Taski
//
//  Created by 金井菜津希 on 2025/08/10.
//
import SwiftUI
import FirebaseStorage

@main
struct Taski: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authVM = AuthViewModel()
    @StateObject var taskStore = TaskStore()

    var body: some Scene {
        WindowGroup {

                ZStack {
                    MeshView()
                        .ignoresSafeArea()
                    
                    if authVM.isAuthenticated {
                        if authVM.currentUser?.name.isEmpty ?? true || authVM.currentUser?.iconURL.isEmpty ?? true {
                            SigninView()
                                .environmentObject(authVM)
                                .environmentObject(taskStore)
                        } else {
                            MainView()
                                .environmentObject(authVM)
                                .environmentObject(taskStore)
                        }
                    } else {
                        SignupView()
                            .environmentObject(authVM)
                            .environmentObject(taskStore)
                    }
                }
            
        }
    }
}
