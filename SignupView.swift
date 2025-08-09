//
//  SignupView.swift
//  ToDoTask
//
//  Created by 金井菜津希 on 2025/08/10.
//

import SwiftUI

struct SignupView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPresented: Bool = false
    @State private var showPassword = false
    @EnvironmentObject var vm: AuthViewModel
    
    var body: some View {
        NavigationStack {
            ZStack{
                MeshView()
                VStack{
                    Spacer().frame(height: 60)
                    Text("SignUp")
                        .accentColor(Color.test)
                        .font(.system(.title, design: .serif))
                    HStack {
                        Image(systemName: "person")
                            .foregroundColor(.secondary)
                        TextField("Username",text: $email)
                    } .cardStyle()
                        .background(Capsule().fill(Color.white));
                       
                    HStack {
                        Image(systemName: "lock")
                            .foregroundColor(.secondary)
                        if showPassword {
                            TextField("Password",
                                      text: $password)}
                        else {
                            SecureField("Password",text: $password)
                        }
                        Button(action: { self.showPassword.toggle()}) {
                            Image(systemName: "eye")
                                .foregroundColor(.secondary)
                        }
                    }
                    .cardStyle()
                    .background(Capsule().fill(Color.white))
                    
                    .padding(.bottom, 50)
                    Button("新規登録"){
                        vm.signUp(email: email, password: password)
                    }
                    .accentColor(Color.white)
                    .padding()
                    .background(Color.test)
                    .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                    .cornerRadius(26)
                    
                    .padding(.bottom, 40)
                 
                    if let errorMessage = vm.errorMessage {
                        Text("登録できませんでした")
                    }
                 
                }
                .cardStyle()
               
            }
           
            
            
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $vm.isAuthenticated) {
                MainView()
            }
            
        }
    }
    
    func cardStyle() -> some View {
        self
            .foregroundColor(Color.white.opacity(0.2))
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
            .padding(.horizontal)
    }
}
#Preview {
    SignupView()
}

