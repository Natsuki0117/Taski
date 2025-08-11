import SwiftUI
import FirebaseAuth // 必要なインポート


struct MainView: View {
    @EnvironmentObject var vm: AuthViewModel // EnvironmentObjectを使用する
    
    var body: some View {
        ZStack{
            
            TabView {
                CalendarView()
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
