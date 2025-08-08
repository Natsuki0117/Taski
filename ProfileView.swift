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
                                .color1, .color1, .color1,
                                .color1, .color1, .color2,
                                .color2, .color2, .color2
                            ])
                            .ignoresSafeArea()

              
                VStack {
                    CalendarView(selectedDate: $selectedDate, tasks: tasks)
                        .frame(height: 300)
                        .cardStyle()
                   

                    List(filteredTasks) { task in
                        Button {
                            SelectedTask = task
                            ShowingAlert = true
                        } label: {
                            HStack{
                                Text(task.rank)
                                Text(task.name)
                            }
                                .frame(maxWidth: .infinity, alignment: .leading) // 横幅最大に
                               .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                        }
                        .listRowInsets(EdgeInsets()) // List セルの余白削除
                        .listRowBackground(Color.clear) // 背景透過（親の背景が見えるように）
                    }
                    .cardStyle()


                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
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
        .scrollContentBackground(.hidden)
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
            calendar.dataSource = context.coordinator
            return calendar
        }

        func updateUIView(_ uiView: FSCalendar, context: Context) {
            // 更新時に再描画
            uiView.reloadData()
        }

        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }

        class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
            var parent: CalendarView
            let formatter: DateFormatter

            init(_ parent: CalendarView) {
                self.parent = parent
                self.formatter = DateFormatter()
                self.formatter.dateFormat = "yyyyMMdd"
            }

            func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
                parent.selectedDate = date
            }

            func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
                let count = parent.tasks.filter {
                    formatter.string(from: $0.dueDate) == formatter.string(from: date)
                }.count
                return count > 0 ? 1 : 0 // ドットは1個だけ表示（色で区別）
            }

            private func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventColorFor date: Date) -> UIColor? {
                let count = parent.tasks.filter {
                    formatter.string(from: $0.dueDate) == formatter.string(from: date)
                }.count

                switch count {
                case 1:
                    return UIColor.systemPink
                case 2...4:
                    return UIColor.systemYellow
                case 5...:
                    return UIColor.systemRed
                default:
                    return nil
                }
            }
        }
    }

}

extension View {
    func cardStyle1() -> some View {
        self
            
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
            
    }
}
