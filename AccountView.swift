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

    var body: some View {
        NavigationStack {
            ZStack {
                Color.clear
                    .appBackground()
                    .ignoresSafeArea()

                VStack {
                    Text("Account")
                        .font(.system(.title, design: .serif))
                        .foregroundColor(.primary)
                    // 上部にアイコンと名前
                    if let user = authVM.currentUser {
                        Spacer().frame(height: 40)

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

                        Spacer()

                        // 円グラフまたは「タスクがありません」
                        if !taskStore.tasks.isEmpty {
                            PieChartView(data: rankDistribution(tasks: taskStore.tasks))
                                .frame(height: 200)
                        } else {
                            Text("まずはタスクを登録しよう🎉")
                                .foregroundColor(.secondary)
                                .font(.headline)
                        }

                        Spacer() // 円グラフとログアウトの間にスペース

                        // ログアウトボタンを画面下部に固定
                        Button("ログアウト") {
                            authVM.logout()
                        }
                        .padding(.bottom, 30)
                    }
                }
                .padding(.horizontal)
                .onAppear {
                    taskStore.fetchTasks()
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
        }
    }

    func rankDistribution(tasks: [TaskItem]) -> [(rank: String, count: Int, color: Color)] {
        let finishedTasks = tasks.filter { $0.isCompleted }
        return [
            ("S", finishedTasks.filter { $0.rank == "S" }.count, .s),
            ("A", finishedTasks.filter { $0.rank == "A" }.count, .a),
            ("B", finishedTasks.filter { $0.rank == "B" }.count, .b),
            ("C", finishedTasks.filter { $0.rank == "C" }.count, .c),
            ("期限切れ", finishedTasks.filter { $0.rank == "期限切れ" }.count, .gray)
        ]
    }
}
