//
//  InitialSetup.swift
//  ToDoTask
//
//  Created by 金井菜津希 on 2025/08/14.
//
import SwiftUI

struct InitialSetupView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var name: String = ""
    @State private var iconImage: UIImage?
    @State private var showPicker = false

    var body: some View {
        VStack(spacing: 20) {
            Text("初期設定").font(.title)

            Button {
                showPicker = true
            } label: {
                if let iconImage = iconImage {
                    Image(uiImage: iconImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 120, height: 120)
                        .overlay(Text("画像選択").foregroundColor(.white))
                }
            }
            .sheet(isPresented: $showPicker) {
                ImagePicker(image: $iconImage)
            }

            TextField("名前を入力", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(.primary)

            Button("保存") {
                authVM.updateUser(name: name, iconImage: iconImage)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
        }
        .padding()
        .onAppear { name = authVM.displayName }
    }
}
