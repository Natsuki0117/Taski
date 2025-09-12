//
//  TaskListView.swift
//  Taski
//
//  Created by 金井菜津希 on 2025/09/09.
//

import SwiftUI

struct TaskListView: View {
    @EnvironmentObject var taskStore: TaskStore
    @Environment(\.scenePhase) var scenePhase
    @State private var addToDo = false
    @State private var calendar = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                MeshView()
                    .ignoresSafeArea()
                
                VStack {
                    
                    Text("AllTask")
                        .font(.system(.title, design: .serif))
                        .foregroundColor(.primary)
                    
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground).opacity(0.9))
                        .shadow(radius: 5)
                        .overlay(
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    if taskStore.tasks.isEmpty {
                                        Text("まずはタスクを登録しよう🎉")
                                            .foregroundColor(.secondary)
                                            .padding()
                                    } else {
                                        ForEach(taskStore.tasks) { task in
                                            VStack(alignment: .leading, spacing: 6) {
                                                Text(task.title)
                                                    .font(.headline)
                                                    .foregroundColor(.primary)
                                                
                                                Text("期限: \(task.dueDate, formatter: dateFormatter)")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }
                                            .padding()
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(Color.white)
                                                    .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
                                            )
                                            .padding(.horizontal)
                                        }
                                    }
                                }
                                .padding()
                            }
                        )
                        .padding()
                }
             
                .toolbar {
                    
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { calendar = true }) {
                            Image(systemName: "calendar")
                                .font(.title2)
                        }
                        .sheet(isPresented: $calendar) {
                            CalendarView()
                        }
                    }
                }
                .onAppear {
                    taskStore.fetchTasks()
                }
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .active {
                        taskStore.fetchTasks()
                    }
                }
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


