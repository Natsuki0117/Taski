//
//  SignupVIew.swift
//  ToDoTask
//
//  Created by 金井菜津希 on 2025/08/09.
//

import SwiftUI

struct SigninView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPresented: Bool = false
    
    
    @StateObject var vm = AuthViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack{
                MeshView()
                VStack{
                    Text("メールアドレス")
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    Text("パスワード")
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
           
                    Button("ログイン") {
                        vm.signUp(email: email, password: password)
                    }
                    
                    Button(action: {
                                isPresented = true //trueにしないと画面遷移されない
                            }) {
                                Text("NextViewへ")
                            }
                            .fullScreenCover(isPresented: $isPresented) { //フルスクリーンの画面遷移
                                SignupView()
                            }
                    
                    if let errorMessage = vm.errorMessage {
                        Text("登録できませんでした")
                    }
                }
            }
            .navigationBarHidden(true)
                        .fullScreenCover(isPresented: $vm.isAuthenticated) {
                            MainView()
                        }
        }
    }
}

#Preview {
    SignupView()
}

