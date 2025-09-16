//
//  SignupVIew.swift
//  Taski
//
//  Created by 金井菜津希 on 2025/08/09.
//
import SwiftUI

struct SigninView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showSignup = false
    @State private var showPassword = false
    @State private var main = false

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Text("Sign In")
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
                
                // ログインボタン
                Button("ログイン") {
                    Task {
                        await authVM.signIn(email: email, password: password)
                    }
                }
                .sheet(isPresented: $main){
                    MainView()
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(26)
                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)

                // 新規登録ボタン
                Button("新規登録") {
                    showSignup.toggle()
                }
                .sheet(isPresented: $showSignup) {
                    SignupView().environmentObject(authVM)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(26)
                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                
            }
            .padding()
            .cardStyle()
        }
    }
}
