import SwiftUI
import FirebaseAuth // 必要なインポート


struct MainView: View {
    @EnvironmentObject var vm: AuthViewModel
    @StateObject var taskStore = TaskStore()
    
    var body: some View {
        ZStack{
            
            TabView {
                CalendarView()
                    .environmentObject(taskStore)
                    .tabItem {
                        Label("Main", systemImage: "party.popper.fill")
                    }
                
                AccountView()
                    .tabItem {
                        
                        Label("Profile", systemImage: "person.crop.circle")
                    }
            }
        
        }
        
        
    }
    
}
