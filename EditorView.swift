//
//  EditorVIew.swift
//  ToDoTask
//
//  Created by 金井菜津希 on 2025/08/09.
//
//
//import SwiftUI
//
//import SwiftUI
//import PhotosUI
//
//struct EditorView: View {
//    @ObservedObject var viewModel: AccountViewModel
//    @Binding var isPresented: Bool
//    
//    @State private var tempName: String = ""
//    @State private var tempImage: UIImage? = nil
//    @State private var isShowingImagePicker = false
//    
//    var body: some View {
//        ZStack{
//            MeshGradient(width: 3, height: 3, points: [
//                            [0, 0],   [0.5, 0],   [1.0, 0],
//                            [0, 0.5], [0.5, 0.5], [1.0, 0.5],
//                            [0, 1.0], [0.5, 1.0], [1.0, 1.0]
//                        ], colors: [
//                            .test, .test, .test,
//                            .test, .test, .test1,
//                            .test1, .test1, .test1
//                        ])
//                        .ignoresSafeArea()
//            
//            
//            NavigationStack {
//                VStack(spacing: 30) {
//                    Group {
//                        if let image = tempImage {
//                            Image(uiImage: image)
//                                .resizable()
//                                .scaledToFill()
//                        } else {
//                            Image(systemName: "person.crop.circle.fill")
//                                .resizable()
//                                .scaledToFit()
//                                .foregroundColor(.gray)
//                        }
//                    }
//                    .frame(width: 140, height: 140)
//                    .clipShape(Circle())
//                    .overlay(Circle().stroke(Color.blue, lineWidth: 3))
//                    .onTapGesture {
//                        isShowingImagePicker = true
//                    }
//                    
//                    VStack(alignment: .leading) {
//                        Text("名前")
//                            .font(.headline)
//                        TextField("名前を入力してください", text: $tempName)
//                            .textFieldStyle(RoundedBorderTextFieldStyle())
//                    }
//                    .padding(.horizontal)
//                    
//                    Spacer()
//                }
//                .padding()
//                .navigationTitle("プロフィール編集")
//                .toolbar {
//                    ToolbarItem(placement: .confirmationAction) {
//                        Button("保存") {
//                            viewModel.displayName = tempName
//                            viewModel.selectedImage = tempImage
//                            isPresented = false
//                        }
//                    }
//                    ToolbarItem(placement: .cancellationAction) {
//                        Button("キャンセル") {
//                            isPresented = false
//                        }
//                    }
//                }
//            }
//     
//                .onAppear {
//                    tempName = viewModel.displayName
//                    tempImage = viewModel.selectedImage
//                }
//                .sheet(isPresented: $isShowingImagePicker) {
//                    ImagePicker(selectedImage: $tempImage)
//                }
//            }
//        }
//    }
//
