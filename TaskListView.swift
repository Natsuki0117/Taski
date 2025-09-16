//
//  TaskListView.swift
//  Taski
//
//  Created by 金井菜津希 on 2025/09/09.
//

import SwiftUI
import FirebaseAuth

struct TaskListView: View {
    @EnvironmentObject var taskStore: TaskStore
    @State private var calendar = false
    @State private var selectedTask: TaskItem?
    @State private var showingAlert = false
    @State private var isShowingSheet = false
    @Binding var selectedIndex: Int

    var body: some View {
        let incompleteTasks = taskStore.tasks.filter { !$0.isCompleted }

        NavigationStack {
            ZStack {
                MeshView()
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    Text("All Tasks")
                        .font(.system(.title, design: .serif))
                        .foregroundColor(.primary)

                    // 半透明長方形
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .shadow(radius: 5)
                        .overlay(
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    Group {
                                        if incompleteTasks.isEmpty {
                                            Text("まずはタスクを登録しよう🎉")
                                                .foregroundColor(.secondary)
                                                .padding()
                                        } else {
                                            ForEach(sortedTasks(tasks: incompleteTasks), id: \.id) { task in
                                                TaskRowView(task: task)
                                                    .onTapGesture {
                                                        selectedTask = task
                                                        showingAlert = true
                                                    }
                                            }
                                        }
                                    }
                                }
                                .padding()
                            }
                        )
                        .padding()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { calendar = true }) {
                        Image(systemName: "calendar")
                            .font(.title2)
                    }
                    .sheet(isPresented: $calendar) {
                        CalendarView(selectedIndex: $selectedIndex)
                    }
                }
            }
            .sheet(isPresented: $isShowingSheet) {
                if let task = selectedTask {
                    TimerView(task: task)
                        .environmentObject(taskStore)
                }
            }
            .alert(selectedTask?.name ?? "",
                   isPresented: $showingAlert,
                   presenting: selectedTask) { task in
                Button("Do", role: .destructive) {
                    isShowingSheet = true
                }
            } message: { task in
                Text("\(task.doTime) 分")
            }
            .onAppear {
                Task {
                    await taskStore.fetchTasks()
                }
            }
        }
    }

    // ランク順に並び替え
    private func sortedTasks(tasks: [TaskItem]) -> [TaskItem] {
        let rankOrder = ["S", "A", "B", "C"]
        return tasks.sorted { lhs, rhs in
            let lIndex = rankOrder.firstIndex(of: lhs.rank) ?? 999
            let rIndex = rankOrder.firstIndex(of: rhs.rank) ?? 999
            return lIndex < rIndex
        }
    }
}
