//
//  AccountView.swift
//  Taski
//
//  Created by 金井菜津希 on 2025/08/10.
//

import SwiftUI
import FirebaseFirestore

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
                
                ScrollView {
                    VStack(spacing: 24) {
                        // ユーザー情報
                        if let user = authVM.currentUser {
                            VStack(spacing: 12) {
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
                                
                                Text(user.name)
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.primary)
                            }
                            .padding(.top, 24)
                        }
                        
                        // 完了タスクランクの円グラフカード
                        CardView {
                            VStack(spacing: 12) {
                                Text("完了タスクのランク分布")
                                    .font(.headline)
                                
                                if !taskStore.tasks.isEmpty {
                                    PieChartView(data: rankDistribution(tasks: taskStore.tasks))
                                        .frame(height: 200)
                                        .padding()
                                } else {
                                    Text("まずはタスクを登録しよう🎉")
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding()
                        }
                        
                        // 振り返り情報カード
                        CardView {
                            VStack(spacing: 16) {
                                Text("振り返り")
                                    .font(.headline)
                                
                                HStack {
                                    Text("延長率:")
                                    Spacer()
                                    Text("\(extensionRate())%")
                                        .bold()
                                }
                                
                                HStack {
                                    Text("完了タスク数:")
                                    Spacer()
                                    Text("\(completedTasksCount())")
                                        .bold()
                                }
                                
                                HStack(alignment: .top) {
                                    Text("気分の割合:")
                                    Spacer()
                                    Text(moodDistribution())
                                        .multilineTextAlignment(.trailing)
                                }
                            }
                            .padding()
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal)
                }
            }
            .task {
                await taskStore.fetchTasks()
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
                    .environmentObject(authVM)
            }
        }
    }

    // MARK: - 集計関数
    func rankDistribution(tasks: [TaskItem]) -> [(rank: String, count: Int, color: Color)] {
        let finishedTasks = tasks.filter { $0.isCompleted }
        return [
            ("S", finishedTasks.filter { $0.completedRank == "S" }.count, .purple),
            ("A", finishedTasks.filter { $0.completedRank == "A" }.count, .blue),
            ("B", finishedTasks.filter { $0.completedRank == "B" }.count, .green),
            ("C", finishedTasks.filter { $0.completedRank == "C" }.count, .orange),
            ("期限切れ", finishedTasks.filter { $0.completedRank == "期限切れ" }.count, .gray)
        ]
    }

    func extensionRate() -> Int {
        let total = taskStore.tasks.filter { $0.isCompleted || $0.completedRank != nil }.count
        guard total > 0 else { return 0 }
        let extended = taskStore.tasks.filter { $0.extendedMinutes > 0 }.count
        return Int(Double(extended) / Double(total) * 100)
    }

    func moodDistribution() -> String {
        let moods = taskStore.tasks.compactMap { $0.emotionLevel }
        guard !moods.isEmpty else { return "-" }
        let counts = Dictionary(grouping: moods, by: { $0 }).mapValues { $0.count }
        let sortedCounts = counts.sorted(by: { $0.key < $1.key })
        return sortedCounts.map { "\($0.key):\($0.value)" }.joined(separator: " ")
    }

    func completedTasksCount() -> Int {
        taskStore.tasks.filter { $0.isCompleted }.count
    }
}

// MARK: - CardView
struct CardView<Content: View>: View {
    let content: Content
    init(@ViewBuilder _ content: () -> Content) {
        self.content = content()
    }
    var body: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(Color(.systemBackground).opacity(0.9))
            .shadow(radius: 5)
            .overlay(
                content
            )
            .padding(.horizontal, 8)
    }
}
