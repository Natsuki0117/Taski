//
//  ProfileView.swift
//  ToDoTask
//
//  Created by 金井菜津希 on 2024/08/21.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FSCalendar
import UIKit

struct CalendarView: View {
    @State private var isShowingSheet = false
    @State var showingAlert = false
    @State var selectedTask: TaskItem?
    @State var tasks: [TaskItem] = []
    @State private var addToDo = false
    @State private var selectedDate: Date = Date()
    @State private var currentDate = Date()

    var body: some View {
        NavigationStack {
            ZStack {
                MeshView()
                VStack {
                    CalendarWrapper(selectedDate: $selectedDate, tasks: tasks)
                        .frame(height: 300)
                        .cardStyle1()
                    
                    
                    List {
                        ForEach(filteredTasks) { task in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(task.name)
                                        .font(.headline)
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
                            .frame(maxWidth: .infinity)
                            .listRowBackground(Color.clear)
                            .glassCardStyle()
                            .onTapGesture {
                                selectedTask = task
                                showingAlert = true
                            }
                        }
                        .onAppear {
                            UITableView.appearance().backgroundColor = .clear
                            UITableViewCell.appearance().backgroundColor = .clear
                        }
                    }
                    
//                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)

                    
                }
                .toolbar {
                    Button(action: { addToDo = true }) {
                        Image(systemName: "pencil.and.scribble")
                    }
                    .accentColor(Color.gray)
                }
                .sheet(isPresented: $addToDo) {
                    AddToDoView()
                }
            }
            .scrollContentBackground(.hidden)
            .sheet(isPresented: $isShowingSheet) {
                if let task = selectedTask {
                    CountdownView(task: task)
                }
            }
            .alert(selectedTask?.name ?? "", isPresented: $showingAlert, presenting: selectedTask) { task in
                Button("Do", role: .destructive) {
                    isShowingSheet = true
                }
            } message: { task in
                Text("\(task.doTime) 分")
            }
            .task {
                tasks = await FirestoreClient.fetchUserWishes()
            }
            // 毎分更新してランクを再計算
            .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) { _ in
                currentDate = Date()
            }
        }
    }


    var filteredTasks: [TaskItem] {
        let rankOrder: [String: Int] = ["S": 0, "A": 1, "B": 2, "C": 3]
        return tasks
            .filter {
                Calendar.current.isDate($0.dueDate, inSameDayAs: selectedDate)
            }
            .sorted {
                let r1 = rankOrder[$0.rank] ?? 99
                let r2 = rankOrder[$1.rank] ?? 99
                if r1 != r2 {
                    return r1 < r2
                } else {
                    return $0.dueDate < $1.dueDate
                }
            }
    }

    func rankGradient(_ rank: String) -> [Color] {
        switch rank {
        case "S": return [Color.purple, Color.pink]
        case "A": return [Color.blue, Color.cyan]
        case "B": return [Color.green, Color.mint]
        case "C": return [Color.orange, Color.yellow]
        default: return [Color.gray, Color.gray.opacity(0.7)]
        }
    }

    func rankShadowColor(_ rank: String) -> Color {
        switch rank {
        case "S": return .pink
        case "A": return .cyan
        case "B": return .green
        case "C": return .orange
        default: return .gray
        }
    }

//    // ランクカラー
//    func rankColor(_ rank: String) -> Color {
//        switch rank {
//        case "S": return .red
//        case "A": return .orange
//        case "B": return .yellow
//        case "C": return .green
//        default: return .gray
//        }
//    }
}

struct CalendarWrapper: UIViewRepresentable {
    @Binding var selectedDate: Date
    var tasks: [TaskItem]

    func makeUIView(context: Context) -> FSCalendar {
        let calendar = FSCalendar()
        calendar.delegate = context.coordinator
        return calendar
    }

    func updateUIView(_ uiView: FSCalendar, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, FSCalendarDelegate {
        var parent: CalendarWrapper
        init(_ parent: CalendarWrapper) { self.parent = parent }

        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            parent.selectedDate = date
        }
    }
}

extension View {
    func cardStyle1() -> some View {
        self
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
            .padding(.horizontal)
    }
}

extension View {
    func glassCardStyle() -> some View {
        self
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
            .padding(.horizontal)
    }
}
