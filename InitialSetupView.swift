//
//  InitialSetup.swift
//  Taski
//
//  Created by 金井菜津希 on 2025/08/14.
//
import SwiftUI

struct InitialSetupView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var name: String = ""
    @State private var iconImage: UIImage?
    @State private var showPicker = false
    @State private var navigateToMain = false

    var body: some View {
        NavigationStack {
            ZStack {
                MeshView()
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Profile")
                        .font(.system(.title, design: .serif))
                        .foregroundColor(.primary)

                    padding()
                    
                    Button {
                        showPicker = true
                    } label: {
                        if let iconImage = iconImage {
                            Image(uiImage: iconImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        } else {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .shadow(radius: 7)
                                .frame(width: 120, height: 120)
                                .overlay(Text("画像選択").foregroundColor(.white))
                        }
                    }
                    .sheet(isPresented: $showPicker) {
                        ImagePicker(image: $iconImage)
                    }
                    
                    TextField("名前を入力", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .shadow(radius: 5)
                        .cornerRadius(10)
                     
                    Button {
                        authVM.updateUser(name: name, iconImage: iconImage) { success in
                            if success {
                                navigateToMain = true
                            }
                        }
                    } label: {
                        if authVM.isSaving {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            Text("保存")
//                                .frame(maxWidth: .infinity)
                                .padding()
                                .background((name.isEmpty || iconImage == nil) ? Color.gray : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                            padding()
                        }
                    }
                    .disabled(name.isEmpty || iconImage == nil)
                    .padding(.horizontal)
                    
                    NavigationLink(destination: MainView()
                                    .environmentObject(authVM), isActive: $navigateToMain) {
                        EmptyView()
                    }
                }
                .cardStyle()
                .padding()
            }
        }
    }
}

#Preview {
    InitialSetupView()
}
    
