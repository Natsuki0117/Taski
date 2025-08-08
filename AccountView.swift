//
//  AccountView.swift
//  ToDoTask
//
//  Created by 金井菜津希 on 2025/08/09.
//
import SwiftUI

struct AccountView: View {
    @StateObject var viewModel = AccountViewModel()
    @State private var isEditing = false
    
    var body: some View {
        ZStack{
          
            MeshGradient(width: 3, height: 3, points: [
                            [0, 0],   [0.5, 0],   [1.0, 0],
                            [0, 0.5], [0.5, 0.5], [1.0, 0.5],
                            [0, 1.0], [0.5, 1.0], [1.0, 1.0]
                        ], colors: [
                            .color1, .color1, .color1,
                            .color1, .color1, .color2,
                            .color2, .color2, .color2
                        ])
                        .ignoresSafeArea()
            
            Color.clear
            
            NavigationStack {
                VStack(spacing: 40) {
                    Group {
                        if let image = viewModel.selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(width: 140, height: 140)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.blue, lineWidth: 3))
                    
                    Text(viewModel.displayName)
                        .font(.title)
                    
                    Spacer()
                }
                
                .padding()
                .toolbar {
                    Button("編集") {
                        isEditing = true
                    }
                }
                .sheet(isPresented: $isEditing) {
                    EditorView(viewModel: viewModel, isPresented: $isEditing)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
    }
}
