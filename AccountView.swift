//
//  AccountView.swift
//  ToDoTask
//
//  Created by 金井菜津希 on 2025/08/10.
//
import SwiftUI

struct AccountView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var taskStore: TaskStore
    @State private var showEditor = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let user = authVM.currentUser {
                    // アイコン
                    if let url = URL(string: user.iconURL), !user.iconURL.isEmpty {
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
                    }
                    
                    // 名前
                    Text(user.name)
                        .font(.title2)
                        .padding(.top, 8)
                    
                    // 編集ボタン
                    Button("プロフィール編集") {
                        showEditor.toggle()
                    }
                    .sheet(isPresented: $showEditor) {
                        EditorView()
                            .environmentObject(authVM)
                    }
                    
                    Divider()
                    
                    // 終了タスクのランク別円グラフ
                    if !taskStore.tasks.isEmpty {
                        PieChartView(data: rankDistribution(tasks: taskStore.tasks))
                            .frame(height: 200)
                            .padding()
                    }
                    
                    Spacer()
                    
                    Button("ログアウト") {
                        authVM.logout()
                    }
                    .padding(.bottom, 30)
                } else {
                    Text("ログインしていません")
                }
            }
            .padding()
            .onAppear {
                taskStore.fetchTasks()
            }
        }
    }
    
    func rankDistribution(tasks: [TaskItem]) -> [(rank: String, count: Int, color: Color)] {
        let finishedTasks = tasks.filter { $0.isCompleted }
        return [
            ("S", finishedTasks.filter { $0.rank == "S" }.count, .red),
            ("A", finishedTasks.filter { $0.rank == "A" }.count, .yellow),
            ("B", finishedTasks.filter { $0.rank == "B" }.count, .blue),
            ("C", finishedTasks.filter { $0.rank == "C" }.count, .green),
            ("期限切れ", finishedTasks.filter { $0.rank == "期限切れ" }.count, .gray)
        ]
    }
}
