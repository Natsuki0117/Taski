//
//  AccountView.swift
//  Taski
//
//  Created by 金井菜津希 on 2025/08/10.
//

import SwiftUI

struct AccountView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var taskStore: TaskStore
    @State private var edit = false
    @State private var selectedTask: TaskItem? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
               MeshView()
                .ignoresSafeArea()
                
                VStack {
                    Text("Account")
                        .font(.system(.title, design: .serif))
                        .foregroundColor(.primary)
                        .padding(.top, 20)
                    
                    if let user = authVM.currentUser {
                        Spacer().frame(height: 20)

                        // アイコン
                        if let url = URL(string: user.iconURL), !user.iconURL.isEmpty {
                            AsyncImage(url: url) { image in
                                image.resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                            } placeholder: {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 120, height: 120)
                            }
                        } else {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 120, height: 120)
                        }

                        // 名前
                        Text(user.name)
                            .font(.title2)
                            .bold()
                            .foregroundColor(.primary)
                            .padding(.top, 12)

                        Spacer().frame(height: 20)

                        // 完了タスクセクション
                        Text("完了したタスクを振り返ろう🎉")
                            .font(.headline)
                            .padding(.bottom, 8)
                        
                        if !taskStore.tasks.isEmpty {
                            let completedTasks = taskStore.tasks.filter { $0.isCompleted }
                            
                            if completedTasks.isEmpty {
                                Text("まだ完了したタスクがありません")
                                    .foregroundColor(.secondary)
                                    .font(.headline)
                            } else {
                                ScrollView {
                                    LazyVStack(spacing: 12) {
                                        ForEach(completedTasks) { task in
                                            Button {
                                                selectedTask = task
                                            } label: {
                                                HStack {
                                                    VStack(alignment: .leading) {
                                                        Text(task.title)
                                                            .font(.headline)
                                                        Text("予定時間: \(task.doTime)分")
                                                            .font(.subheadline)
                                                            .foregroundColor(.secondary)
                                                    }
                                                    Spacer()
                                                    Text(task.completedRank ?? "―")
                                                        .bold()
                                                        .foregroundColor(.blue)
                                                }
                                                .padding()
                                                .background(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .fill(Color.white.opacity(0.3)) // 半透明
                                                        .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 4)
                                                )
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        } else {
                            Text("まずはタスクを登録しよう🎉")
                                .foregroundColor(.secondary)
                                .font(.headline)
                        }

                        Spacer()
                    }
                }
                .padding(.horizontal)
                .onAppear {
                    Task {
                        await taskStore.fetchTasks()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { edit = true }) {
                        Text("編集")
                    }
                    .accentColor(.gray)
                }
            }
            .sheet(isPresented: $edit) {
                EditorView()
            }
            // タスク結果画面
            .sheet(item: $selectedTask) { task in
                ResultView(task: task)
            }
        }
    }
}
