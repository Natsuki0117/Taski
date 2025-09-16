//
//  SignupView.swift
//  Taski
//
//  Created by 金井菜津希 on 2025/08/10.
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignupView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword = false
    @EnvironmentObject var vm: AuthViewModel
    @State private var showSetup = false

    var body: some View {
        NavigationStack {
            ZStack {
                MeshView() // 背景
                
                VStack {
                    Spacer().frame(height: 60)
                    Text("Sign Up")
                        .font(.system(.title, design: .serif))
                        .foregroundColor(.primary)
                    
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
                    Button(action: {
                        Task {
                            do {
                                try await vm.signUp(email: email, password: password)
                                showSetup = true
                            } catch {
                                vm.errorMessage = error.localizedDescription
                            }
                        }
                    }) {
                        Text("新規登録")
                            .foregroundColor(.white)
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
}
