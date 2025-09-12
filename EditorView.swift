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
import FirebaseStorage

struct EditorView: View {
    @EnvironmentObject var vm: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var selectedImage: UIImage?
    @State private var showPicker = false

    var body: some View {
        NavigationStack {
            ZStack {
                // 背景を一番下に
                MeshView()
                    .ignoresSafeArea()
                
                // その上にフォームを置く
                VStack(spacing: 20) {
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

                    TextField("名前を入力", text: $name)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                        .foregroundColor(.primary)

                    Button("保存") {
                        let newName = name.isEmpty ? vm.displayName : name
                        vm.updateUser(name: newName, iconImage: selectedImage) { success in
                            if success {
                                dismiss()
                            } else {
                                print("更新に失敗しました")
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("プロフィール編集")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                name = vm.displayName
            }
        }
    }
}
