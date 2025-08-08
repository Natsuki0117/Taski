import SwiftUI
import FirebaseAuth // 必要なインポート

struct MainView: View {
    @EnvironmentObject var vm: AuthViewModel // EnvironmentObjectを使用する
    
    var body: some View {
        ZStack{
            //
            
            TabView {
                ProfileView()
                    .tabItem {
                        Label("Main", systemImage: "party.popper.fill")
                    }
                AddToDoView()
                    .tabItem {
                        Label("Profile", systemImage: "person.crop.circle")
                    }
                AccountView()
                    .tabItem {
                        
                        Label("Profile", systemImage: "person.crop.circle")
                    }
            }
            
            //                tabview
        }
        .background(Gradient(colors: [Color("Blue"),Color("Pink")])).opacity(0.6)
        
    }
    
}
