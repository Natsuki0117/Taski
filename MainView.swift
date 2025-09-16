//
//  MainView.swift
//  Taski
//
//  Created by 金井菜津希 on 2025/08/14.
//
import SwiftUI
import FirebaseAuth

struct MainView: View {
    @EnvironmentObject var taskStore: TaskStore
    @State private var selectedIndex = 0
    
//tabbar関連
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedIndex) {
                TaskListView(selectedIndex: $selectedIndex)
                    .environmentObject(taskStore)
                    .tabItem {
                        Label("Main", systemImage: "party.popper.fill")
                    }
                    .tag(0)

                // AddToDoView に selectedIndex を渡す
                AddToDoView(selectedIndex: $selectedIndex)
                    .environmentObject(taskStore)
                    .tag(1)

                AccountView()
                    .environmentObject(taskStore)
                    .tabItem {
                        Label("Profile", systemImage: "person.crop.circle")
                    }
                    .tag(2)
            }
            .tint(.blue)
        }
        // 真ん中のAddToDoの処理
        .overlay(
            VStack {
                Spacer()
                if selectedIndex != 1 { 
                    Button(action: { selectedIndex = 1 }) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [Color("test1"), Color("test2")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 65, height: 65)
                                .shadow(color: .purple.opacity(0.3), radius: 8)

                            Image(systemName: "plus")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.bottom, 10)
                    .zIndex(1)
                }
            }
        )
    }
}

#Preview {
    MainView()
        .environmentObject(TaskStore())
}
