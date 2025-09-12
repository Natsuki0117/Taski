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

    var body: some View {
        NavigationStack {
            ZStack {
                MeshView()
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    // カレンダー
                    CalendarWrapper(selectedDate: $selectedDate, tasks: taskStore.tasks)
                        .frame(height: 300)
                        .cardStyle()

                    ScrollView {
                        VStack(spacing: 12) {
                            if filteredTasks.isEmpty {
                                Text("タスクがありません")
                                    .foregroundColor(.secondary)
                                    .padding()
                            } else {
                                ForEach(filteredTasks) { task in
                                    TaskRow(task: task)
                                        .onTapGesture {
                                            selectedTask = task
                                            showingAlert = true
                                        }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { addToDo = true }) {
                        Image(systemName: "pencil.and.scribble")
                    }
                }
            }
            .sheet(isPresented: $addToDo) {
                AddToDoView()
            }
            .sheet(isPresented: $isShowingSheet) {
                if let task = selectedTask {
                    TimerView(task: task)
                }
            }
            .alert(selectedTask?.name ?? "",
                   isPresented: $showingAlert,
                   presenting: selectedTask) { task in
                Button("Do", role: .destructive) { isShowingSheet = true }
            } message: { task in
                Text("\(task.doTime) 分")
            }
            .onAppear {
                taskStore.fetchTasks()
            }
        }
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
    }

    var filteredTasks: [TaskItem] {
        taskStore.tasks.filter { !$0.isCompleted &&
            Calendar.current.isDate($0.dueDate, inSameDayAs: selectedDate)
        }
    }
}

struct TaskRow: View {
    var task: TaskItem

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(task.name)
                    .font(.headline)
                    .bold()
                    .foregroundColor(.primary)
                Text("\(task.doTime)分 • \(task.dueDate.formatted(.dateTime.month().day()))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(task.rank)
                .font(.caption)
                .bold()
                .padding(.vertical, 6)
                .padding(.horizontal, 14)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: rankGradient(task.rank)),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .clipShape(Capsule())
                .shadow(color: rankShadowColor(task.rank).opacity(0.4), radius: 4, x: 0, y: 2)
        }
        .padding(8)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.15))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }

 private func rankGradient(_ rank: String) -> [Color] {
        switch rank {
        case "S": return [Color.purple.opacity(0.7), Color.pink.opacity(0.7)]
        case "A": return [Color.blue.opacity(0.7), Color.cyan.opacity(0.7)]
        case "B": return [Color.green.opacity(0.7), Color.mint.opacity(0.7)]
        case "C": return [Color.orange.opacity(0.7), Color.yellow.opacity(0.7)]
        default: return [Color.gray.opacity(0.5), Color.gray.opacity(0.3)]
        }
    }

    private func rankShadowColor(_ rank: String) -> Color {
        switch rank {
        case "S": return .pink
        case "A": return .cyan
        case "B": return .green
        case "C": return .orange
        default: return .gray
        }
    }
}


struct CalendarWrapper: UIViewRepresentable {
    @Binding var selectedDate: Date
    var tasks: [TaskItem]

    func makeUIView(context: Context) -> FSCalendar {
        let calendar = FSCalendar()
        calendar.locale = Locale(identifier: "ja_JP")
        calendar.firstWeekday = 2

        calendar.delegate = context.coordinator
        calendar.dataSource = context.coordinator

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

        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            parent.selectedDate = date
        }

        func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
            parent.tasks.filter { Calendar.current.isDate($0.dueDate, inSameDayAs: date) }.count
        }

        func calendar(_ calendar: FSCalendar,
                      appearance: FSCalendarAppearance,
                      eventDefaultColorsFor date: Date) -> [UIColor]? {
            let dayTasks = parent.tasks.filter { Calendar.current.isDate($0.dueDate, inSameDayAs: date) }
            guard !dayTasks.isEmpty else { return nil }

            let rankOrder = ["S","A","B","C"]
            let sorted = dayTasks.sorted {
                (rankOrder.firstIndex(of: $0.rank) ?? 999) < (rankOrder.firstIndex(of: $1.rank) ?? 999)
            }
            let topRank = sorted.first?.rank ?? "C"

            let color: UIColor
            switch topRank {
            case "S": color = .purple
            case "A": color = .systemBlue
            case "B": color = .systemGreen
            case "C": color = .systemOrange
            default:  color = .systemGray
            }
            return Array(repeating: color, count: dayTasks.count)
        }
    }
}

