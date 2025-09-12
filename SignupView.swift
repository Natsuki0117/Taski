//
//  SignupView.swift
//  Taski
//
//  Created by 金井菜津希 on 2025/08/10.
//
import SwiftUI
import Firebase
import FirebaseAuth


struct SignupView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword = false
    @EnvironmentObject var vm: AuthViewModel
    @State private var showSetup = false
    @State private var showSignin = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                MeshView() // 背景
                
                VStack {
                    Spacer().frame(height: 60)
                    
                    Text("Sign Up")
                        .font(.system(.title, design: .serif))
                        .foregroundColor(.primary)
                    padding()
                    // Email入力
                    HStack {
                        Image(systemName: "person")
                            .foregroundColor(.secondary)
                        TextField("Email", text: $email)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    .foregroundColor(.primary)
                    .cardStyle()
                    
                    // パスワード入力
                    HStack {
                        Image(systemName: "lock")
                            .foregroundColor(.secondary)
                        if showPassword {
                            TextField("Password", text: $password)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        } else {
                            SecureField("Password", text: $password)
                        }
                        Button(action: { self.showPassword.toggle() }) {
                            Image(systemName: "eye")
                                .foregroundColor(.secondary)
                        }
                    }
                    .foregroundColor(.primary)
                    .cardStyle()
                    .padding(.bottom, 30)
                    
                    // サインアップボタン
                    Button(action: signUp) {
                        Text("新規登録")
                            .foregroundColor(.white)
//                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(26)
                            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(.bottom, 20)
                     
                    // エラーメッセージ
                    if let errorMessage = vm.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                }
                .cardStyle()
                .navigationBarHidden(true)
                
      
                .sheet(isPresented: $showSetup) {
                    InitialSetupView()
                        .environmentObject(vm)
                }
            }
        }
    }
        
        func signUp() {
            guard !email.isEmpty, !password.isEmpty else {
                vm.errorMessage = "Email と Password を入力してください"
                return
            }
            
            vm.errorMessage = nil
            
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    vm.errorMessage = error.localizedDescription
                    return
                }
                guard let uid = result?.user.uid else { return }
                
                // Firestoreにユーザー情報を保存
                let userData: [String: Any] = [
                    "name": "",   // 初期は空
                    "iconURL": "" // 初期は空
                ]
                Firestore.firestore().collection("users").document(uid).setData(userData) { err in
                    if let err = err {
                        vm.errorMessage = err.localizedDescription
                    } else {
                        vm.fetchUserData(uid: uid)
                        // 初期設定画面を表示
                        showSetup = true
                    }
                }
            }
        }
    
}
