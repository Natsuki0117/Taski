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
                    
                    
                    
                    List(filteredTasks) { task in
                        Button {
                            selectedTask = task
                            showingAlert = true
                        } label: {
                            HStack {
                                Text(task.rank) // ← ここは計算プロパティ
                                    .font(.caption)
                                    .bold()
//                                    .background(Color.)
//                                    .padding()
//                                    .glassCardWithBorder(color: task.rankColor)
                                    .cornerRadius(20)
                                    
                                Text(task.name)
                                    .foregroundColor(.primary)
                            }
                            .listRowInsets(EdgeInsets())
                        }
                       
                    }
                    .glassCardStyle()
                    .listStyle(.plain)
//                    .cardStyle1()
                  
//                    .background(.ultraThinMaterial)
                    
                    
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
    
    // 選択日のタスクだけを返す
    var filteredTasks: [TaskItem] {
        tasks.filter {
            Calendar.current.isDate($0.dueDate, inSameDayAs: selectedDate)
        }
    }
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
            .background(.ultraThinMaterial) // ガラスっぽいBlur背景
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
            .padding(.horizontal)
    }
}


extension View {
    func glassCardWithBorder(color: Color) -> some View {
        self
            .padding()
            .background(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(color, lineWidth: 3) // 枠色を渡す
            )
            .cornerRadius(20)
            .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
            .padding(.horizontal)
    }
}

