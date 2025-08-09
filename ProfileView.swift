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
               MeshView()
                VStack {
                    CalendarView(selectedDate: $selectedDate, tasks: tasks) // ★ 修正：選択日バインディング渡す
                        .frame(height: 300)
                        .cardStyle()
                    
                    List(filteredTasks) { task in // ★ 修正：filteredTasks を使う
                        Button {
                            SelectedTask = task
                            ShowingAlert = true
                        } label: {
                            HStack{
                                Text(task.rank)
                                    .font(.caption)
                                    .bold()
                                    .padding(10)
                                    .background(Color.yellow)
                                    .cornerRadius(6)
                                Text(task.name)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    .cardStyle()
        
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
        @Binding var selectedDate: Date
        var tasks: [TaskItem]

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
            
            func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
                _ = parent.tasks.filter {
                            Calendar.current.isDate($0.dueDate, inSameDayAs: date)
                        }
                        return 1
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
