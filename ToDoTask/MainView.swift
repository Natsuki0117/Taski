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
                HomeView()
                    .tabItem {
                        Label("Profile", systemImage: "person.crop.circle")
                    }
                HomeView()
                    .tabItem {
                        AddToDoView()
                        Label("Profile", systemImage: "person.crop.circle")
                    }
            }
            
            //                tabview
        }
        .background(Gradient(colors: [Color("Blue"),Color("Pink")])).opacity(0.6)
        
    }
    //LinearGradient(colors: [Color("test"),Color("Color")], startPoint: .top, endPoint: .bottom)
    //            .ignoresSafeArea()
    
    
}

#Preview {
    MainView()
        .environmentObject(AuthViewModel()) // プレビュー用の環境オブジェクト
}

