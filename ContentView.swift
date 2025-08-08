import SwiftUI

struct ContentView: View {
    @State var isShowLogin = false
    var authenticationManager = AuthenticationManager()
    var body: some View {
        VStack {
            if authenticationManager.isSignIn == false {
                //ログインしていないとき
                Button("ログイン") {
                    isShowLogin .toggle()
                }
                .sheet(isPresented: $isShowLogin) {
                    LoginView()
                }
            }else{
                //ログインしているとき
                MainView()
            }
        }
    }
}
