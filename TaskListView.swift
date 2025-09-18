//
//  TaskListView.swift
//  Taski
//
//  Created by 金井菜津希 on 2025/09/09.
//

import SwiftUI

struct TaskListView: View {
    @EnvironmentObject var taskStore: TaskStore
    @State private var calendar = false
    @State private var selectedTask: TaskItem?
    @State private var showLocationPicker = false
    @State private var selectedLocation = "家"
    @State private var isShowingTimer = false
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

                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .shadow(radius: 5)
                        .overlay(
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    if incompleteTasks.isEmpty {
                                        Text("まずはタスクを登録しよう🎉")
                                            .foregroundColor(.secondary)
                                            .padding()
                                    } else {
                                        ForEach(sortedTasks(tasks: incompleteTasks), id: \.id) { task in
                                            TaskRowView(task: task)
                                                .onTapGesture {
                                                    selectedTask = task
                                                    showLocationPicker = true
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

            // 場所選択 confirmationDialog
            .confirmationDialog("どこでやる？", isPresented: $showLocationPicker, titleVisibility: .visible) {
                Button("家") { startTimer(location: "家") }
                Button("学校") { startTimer(location: "学校") }
                Button("図書館") { startTimer(location: "図書館") }
                Button("カフェ") { startTimer(location: "カフェ") }
                Button("キャンセル", role: .cancel) { }
            }

            // タイマー画面
            .fullScreenCover(isPresented: $isShowingTimer) {
                if let task = selectedTask {
                    TimerView(task: task, location: selectedLocation)
                        .environmentObject(taskStore)
                }
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

    // 選択した場所でタイマーを開始
    private func startTimer(location: String) {
        selectedLocation = location
        isShowingTimer = true
    }
}
