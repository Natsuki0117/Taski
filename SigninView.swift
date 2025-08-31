//
//  SignupVIew.swift
//  ToDoTask
//
//  Created by 金井菜津希 on 2025/08/09.
//

import SwiftUI

struct SigninView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showSignup = false
    @State private var showPassword = false
    
    var body: some View {
        ZStack{
            MeshView()
            
            VStack(spacing: 20) {
                Text("LogIn")
                    .font(.system(.title, design: .serif))
                    .font(.largeTitle)
                    .foregroundColor(.primary)
                
                HStack {
                    Image(systemName: "person")
                        .foregroundColor(.secondary)
                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                .foregroundColor(.primary)
                .cardStyle()
                
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
                
                
                if let error = authVM.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                }
                
                Button("ログイン") {
                    authVM.signIn(email: email, password: password)
                }
                .buttonStyle(.borderedProminent)
                .foregroundColor(.white)
                
                Button("新規登録") {
                    authVM.errorMessage = nil // 遷移前にエラーをクリア
                    showSignup.toggle()
                }
                .sheet(isPresented: $showSignup) {
                    SignupView()
                        .environmentObject(authVM)
                }
                .buttonStyle(.borderedProminent)
                .foregroundColor(.white)
            }
            .cardStyle()
        }
    }
}
