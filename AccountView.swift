//
//  AccountView.swift
//  ToDoTask
//
//  Created by 金井菜津希 on 2025/08/10.
//

import SwiftUI

struct AccountView: View {
    @EnvironmentObject var vm: AuthViewModel
    @State private var name: String = ""
    @State private var selectedImage: UIImage?
    @State private var showPicker = false
    
    var body: some View {
        VStack(spacing: 20) {
            Button(action: { showPicker.toggle() }) {
                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                } else if let url = URL(string: vm.iconURL), !vm.iconURL.isEmpty {
                    AsyncImage(url: url) { phase in
                        if let image = phase.image {
                            image.resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        } else {
                            Circle().fill(Color.gray)
                                .frame(width: 120, height: 120)
                        }
                    }
                } else {
                    Circle().fill(Color.gray)
                        .frame(width: 120, height: 120)
                }
            }
            .sheet(isPresented: $showPicker) {
                ImagePicker(image: $selectedImage)
            }
            
            TextField("Name", text: $name)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
            
            Button("Save") {
                vm.saveUserData(name: name, image: selectedImage)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            Spacer()
        }
        .padding()
        .onAppear {
            name = vm.displayName
        }
    }
}

#Preview {
    AccountView()
}
