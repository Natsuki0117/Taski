//
//  LogInView.swift
//  ToDoTask
//
//  Created by 金井菜津希 on 2025/08/08.
//

import SwiftUI
import FirebaseAuthUI
import FirebaseGoogleAuthUI
import FirebaseEmailAuthUI


struct LoginView: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let authUI = FUIAuth.defaultAuthUI()!
        // ログイン方法を選択
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth(authUI: authUI),
            FUIEmailAuth()
        ]
        authUI.providers = providers
        
        // FirebaseUIを表示する
        let authViewController = authUI.authViewController()
        
        return authViewController
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // 処理なし
    }
}
