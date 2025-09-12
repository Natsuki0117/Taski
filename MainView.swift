

import SwiftUI
import FirebaseAuth


struct MainView: View {
    @EnvironmentObject var vm: AuthViewModel
    @StateObject var taskStore = TaskStore()
    @State private var selectedIndex = 0
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().standardAppearance = appearance
    }
    
    var body: some View {
        ZStack {
            // TabView本体
            TabView(selection: $selectedIndex) {
                TaskListView()
                    .environmentObject(taskStore)
                    .tabItem {
                        Label("Main", systemImage: "party.popper.fill")
                    }
                    .tag(0)
                
                AddToDoView()
                    .environmentObject(taskStore)
                    .tabItem {
                        Label("Add", systemImage: "plus.circle.fill")
                    }
                    .tag(1)
                
                AccountView()
                    .tabItem {
                        Label("Profile", systemImage: "person.crop.circle")
                    }
                    .tag(2)
            }
            .tint(.blue) // 選択中タブの色
            
            // 中央カスタムボタン
            VStack {
                Spacer()
                Button(action: {
                    selectedIndex = 1
                }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("test1"), Color("test2")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 65, height: 65)
                            .shadow(color: .purple.opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        Image(systemName: "plus")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .offset(y: -20) // タブバーから飛び出す量
            }
        }
    }
}

#Preview {
    MainView()
        .environmentObject(AuthViewModel())
}
