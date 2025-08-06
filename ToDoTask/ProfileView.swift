//
//  AddToDoView.swift
//  ToDoTask
//
//  Created by 金井菜津希 on 2024/08/21.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FSCalendar


struct ProfileView: View {
    @State private var isShowingSheet = false
    @State var ShowingAlert = false
    @State var SelectedTask: TaskItem?
    @State var tasks: [TaskItem] = []
    @State private var AddToDo = false
    @State private var selectedDate: Date = Date() // ★ 追加：カレンダーで選択された日付

    var body: some View {
        
        NavigationStack {
            ZStack{
                MeshGradient(width: 3, height: 3, points: [
                    [0, 0],   [0.5, 0],   [1.0, 0],
                    [0, 0.5], [0.5, 0.5], [1.0, 0.5],
                    [0, 1.0], [0.5, 1.0], [1.0, 1.0]
                ], colors: [
                    .test, .test, .test,
                    .test, .test1, .test1,
                    .test1, .test1, .test1
                ])
                .ignoresSafeArea()
                
                VStack {
                    CalendarView(selectedDate: $selectedDate) // ★ 修正：選択日バインディング渡す
                        .frame(height: 300)
                        .cardStyle()
                    
                    List(filteredTasks) { task in // ★ 修正：filteredTasks を使う
                        Button {
                            SelectedTask = task
                            ShowingAlert = true
                        } label: {
                            Text(task.name)
                        }
                    }
                    .cardStyle()
                    //                    .scrollContentBackground(.hidden)
                    //                                        .background(Color.blue.opacity(0.1))
                    //                    ↑list
                    
                }
                
                .toolbar {
                    Button(action: {
                        AddToDo = true
                    }) {
                        Image(systemName: "pencil.and.scribble")
                    }
                    .accentColor(Color.gray)
                }
                .sheet(isPresented: $AddToDo) {
                    AddToDoView()
                }
            }
            
            .scrollContentBackground(.hidden)
            
            
            
            
            .sheet(isPresented: $isShowingSheet) {
                if let task = SelectedTask {
                    CountdownView(task: task)
                } else {
                    Text("No task selected.")
                }
            }
            
            .alert(SelectedTask?.name ?? "", isPresented: $ShowingAlert, presenting: SelectedTask) { task in
                Button("Do", role: .destructive) {
                    isShowingSheet = true
                }
            } message: { task in
                Text("\(task.doTime) 分")
            }
            
            .task {
                tasks = await FirestoreClient.fetchUserWishes()
            }
        }
    }

    // ★ 追加：選択された日付に一致するタスクだけを返す
    var filteredTasks: [TaskItem] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return tasks.filter {
            formatter.string(from: $0.dueDate) == formatter.string(from: selectedDate)
        }
    }
    
    struct CalendarView: UIViewRepresentable {
        @Binding var selectedDate: Date // ★ 追加：バインディング

        func makeUIView(context: Context) -> FSCalendar {
            let calendar = FSCalendar()
            calendar.delegate = context.coordinator
            return calendar
        }

        func updateUIView(_ uiView: FSCalendar, context: Context) {
            // 特に必要な設定がなければ空でもOK
        }

        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }

        class Coordinator: NSObject, FSCalendarDelegate {
            var parent: CalendarView

            init(_ parent: CalendarView) {
                self.parent = parent
            }

            func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
                parent.selectedDate = date // ★ カレンダーで選択された日付を親に反映
            }
        }
    }
}

extension View {
    func cardStyle1() -> some View {
        self
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
            .padding(.horizontal)
    }
}
