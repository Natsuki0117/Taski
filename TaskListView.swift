//
//  AllTaskView.swift
//  Taski
//
//  Created by 金井菜津希 on 2025/09/09.
//

import SwiftUI

struct TaskListView: View {
    @StateObject private var taskStore = TaskStore()

    var body: some View {
        NavigationStack {
            VStack {
                if taskStore.tasks.isEmpty {
                    Text("タスクがありません")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    List(taskStore.tasks) { task in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(task.title)
                                .font(.headline)
                            Text("期限: \(task.dueDate, formatter: dateFormatter)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("タスク一覧")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        taskStore.fetchTasks() // 更新ボタン
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .onAppear {
                taskStore.fetchTasks()
            }
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}
