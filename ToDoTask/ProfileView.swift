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

  
    var body: some View {
        
        ZStack{
            
            LinearGradient(gradient: Gradient(colors: [.white, .pink]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            NavigationView{
            
                VStack{
                    
                    CalendarView()
                        .frame(height: 300) // カレンダーの高さを設定
                        .padding()
                    
                    
                    
                    List(tasks) { task in
                        Button {
                            SelectedTask = task
                            ShowingAlert = true
                        } label: {
                            Text(task.name)
                        }
                        .frame(maxHeight: .infinity)
                        
                    }
                    
                    .scrollContentBackground(.hidden)
                    .background(Color.blue.opacity(0.1))
                }
                
                .toolbar {
                    
                    Button(action: {
                        AddToDo = true
                    }) {
                        Image(systemName: "pencil.and.scribble")
                    }
                    
                }
                .sheet(isPresented: $AddToDo) {
                    AddToDoView()
                }
            }
            .scrollContentBackground(.hidden)
            
               
        }
            .sheet(isPresented: $isShowingSheet) {
                if let task = SelectedTask {
                    TimerView(counter: 0, countTo: task.doTime)
                } else {
                    Text("No task selected.")
                }
            }
      
        .alert(SelectedTask?.name ?? "", isPresented: $ShowingAlert, presenting: SelectedTask) { task in
            Button("Do", role: .destructive) {
                isShowingSheet = true // シートを表示
            }
        } message: { task in
            Text("\(SelectedTask?.doTime ?? 0) 分")
        }

        .task {
            tasks = await FirestoreClient.fetchUserWishes()
        }
    }
       
}
    

struct CalendarView: UIViewRepresentable {
    func makeUIView(context: Context) -> FSCalendar {
        return FSCalendar()
    }
    
    func updateUIView(_ uiView: FSCalendar, context: Context) {
        // 必要な設定があればここで行う
    }
}
#Preview {
    ProfileView()
}
