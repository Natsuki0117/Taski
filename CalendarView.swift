//
//  ProfileView.swift
//  Taski
//
//  Created by 金井菜津希 on 2024/08/21.
//

import SwiftUI
import FirebaseAuth
import FSCalendar
import UIKit

struct CalendarView: View {
    @EnvironmentObject var taskStore: TaskStore
    @State private var selectedDate: Date = Date()
    @State private var addToDo = false
    @State private var showingAlert = false
    @State private var selectedTask: TaskItem?
    @State private var isShowingSheet = false
    @Binding var selectedIndex: Int
    

    var body: some View {
        NavigationStack {
            ZStack {
                // 背景
                MeshView()
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    // カレンダー
                    CalendarWrapper(selectedDate: $selectedDate, tasks: taskStore.tasks)
                        .frame(height: 300)
                        .cardStyle()

                    // 選択日のタスクリスト
                    ScrollView {
                        VStack(spacing: 12) {
                            taskListView() // タスクリスト表示を別関数に切り出し
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
            }
            .navigationBarTitleDisplayMode(.inline)
            
            // AddToDoViewに画面遷移
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { addToDo = true }) {
                        Image(systemName: "pencil.and.scribble")
                    }
                }
            }
            // AddToDoViewをシートで表示
            .sheet(isPresented: $addToDo) {
                AddToDoView(selectedIndex: $selectedIndex)
            }
            // タスクタイマー表示
            .sheet(isPresented: $isShowingSheet) {
                if let task = selectedTask {
                    TimerView(task: task)
                }
            }
            // タスクをタップしたときのアラート
            .alert(selectedTask?.name ?? "",
                   isPresented: $showingAlert,
                   presenting: selectedTask) { task in
                Button("Do", role: .destructive) { isShowingSheet = true }
            } message: { task in
                Text("\(task.doTime) 分")
            }
            .onAppear {
                Task {
                    await taskStore.fetchTasks()
                }
            }
        }
        // ナビゲーションバーの背景
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
    }

    // MARK: - タスクリスト部分を別関数に切り出す
    @ViewBuilder
    private func taskListView() -> some View {
        let tasksForSelectedDate = filteredTasksForSelectedDate()
        if tasksForSelectedDate.isEmpty {
            // タスクなし
            Text("タスクがありません")
                .foregroundColor(.secondary)
                .padding()
        } else {
            // タスクあり
            ForEach(tasksForSelectedDate, id: \.id) { task in
                TaskRowView(task: task)
                    .onTapGesture {
                        selectedTask = task
                        showingAlert = true
                    }
            }
        }
    }

    // MARK: - 選択日で未完了タスクを取得
    private func filteredTasksForSelectedDate() -> [TaskItem] {
        taskStore.tasks.filter { !$0.isCompleted && Calendar.current.isDate($0.dueDate, inSameDayAs: selectedDate) }
    }
}

// MARK: - FSCalendarラッパー
struct CalendarWrapper: UIViewRepresentable {
    @Binding var selectedDate: Date
    var tasks: [TaskItem]

    func makeUIView(context: Context) -> FSCalendar {
        let calendar = FSCalendar()
        calendar.locale = Locale(identifier: "ja_JP")
        calendar.firstWeekday = 2
        calendar.delegate = context.coordinator
        calendar.dataSource = context.coordinator

        // カレンダー見た目
        calendar.appearance.headerDateFormat = "yyyy年 M月"
        calendar.appearance.headerTitleAlignment = .center
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        calendar.appearance.todayColor = .clear
        calendar.appearance.titleTodayColor = .systemRed

        return calendar
    }

    func updateUIView(_ uiView: FSCalendar, context: Context) {
        uiView.reloadData()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
        var parent: CalendarWrapper
        init(_ parent: CalendarWrapper) { self.parent = parent }

        // 日付選択
        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            parent.selectedDate = date
        }

        // タスクの丸ポチ数
        func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
            let tasksForDate = parent.tasks.filter { !$0.isCompleted && Calendar.current.isDate($0.dueDate, inSameDayAs: date) }
            return tasksForDate.count
        }

        // 丸ポチの色
        func calendar(_ calendar: FSCalendar,
                      appearance: FSCalendarAppearance,
                      eventDefaultColorsFor date: Date) -> [UIColor]? {
            let tasksForDate = parent.tasks.filter { !$0.isCompleted && Calendar.current.isDate($0.dueDate, inSameDayAs: date) }
            guard !tasksForDate.isEmpty else { return nil }

            let color = colorForTasks(tasksForDate)
            return Array(repeating: color, count: tasksForDate.count)
        }

        // タスクランクに応じて色を返す
        private func colorForTasks(_ tasks: [TaskItem]) -> UIColor {
            let rankOrder = ["S","A","B","C"]
            let sorted = tasks.sorted { (rankOrder.firstIndex(of: $0.rank) ?? 999) < (rankOrder.firstIndex(of: $1.rank) ?? 999) }
            let topRank = sorted.first?.rank ?? "C"

            switch topRank {
            case "S": return .purple
            case "A": return .systemBlue
            case "B": return .systemGreen
            case "C": return .systemOrange
            default:  return .systemGray
            }
        }
    }
}
