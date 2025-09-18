//
//  EditorVIew.swift
//  Taski
//
//  Created by 金井菜津希 on 2025/08/09.
//
//
import SwiftUI
import Firebase
import FirebaseAuth

struct EditorView: View {
    @EnvironmentObject var vm: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var selectedImage: UIImage?
    @State private var showPicker = false
    @State private var isSaving = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 背景
                MeshView()
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Edit Profile")
                        .font(.system(.title, design: .serif))
                        .foregroundColor(.primary)
                    
                    // プロフィール画像
                    Button {
                        showPicker = true
                    } label: {
                        if let selectedImage = selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        } else if let url = URL(string: vm.currentUser?.iconURL ?? ""),
                                  !(vm.currentUser?.iconURL ?? "").isEmpty {
                            AsyncImage(url: url) { image in
                                image.resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                            } placeholder: {
                                Circle().fill(Color.gray.opacity(0.3))
                                    .frame(width: 120, height: 120)
                            }
                        } else {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 120, height: 120)
                                .overlay(Text("画像選択").foregroundColor(.white))
                        }
                    }
                  
                    .sheet(isPresented: $showPicker) {
                        ImagePicker(image: $selectedImage)
                    }
                    
                    // 名前入力
                    TextField("名前を入力", text: $name)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                        .foregroundColor(.primary)
                    
                    // 保存ボタン
                    Button {
                        Task {
                            await saveProfile()
                        }
                    } label: {
                        if isSaving {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            Text("保存")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    
                    // ログアウトボタン
                    Button("ログアウト") {
                        Task {
                            await vm.logout() // ✅ 修正
                        }
                    }
                    .padding(.bottom, 30)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.blue)
                    .cornerRadius(26)
                }
                .cardStyle()
                .padding()
            }
            .onAppear {
                name = vm.displayName
            }
        }
    }
    
    // MARK: - async/await 版保存処理
    private func saveProfile() async {
        isSaving = true
        let newName = name.isEmpty ? vm.displayName : name
        let success = await vm.updateUser(name: newName, iconImage: selectedImage)
        isSaving = false
        
        if success {
            dismiss()
        } else {
            print("更新に失敗しました")
        }
    }
}
