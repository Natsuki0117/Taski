import SwiftUI
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String?

    init() {
        observeAuthChanges()
    }

    private func observeAuthChanges() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.isAuthenticated = user != nil
            }
        }
    }


    func signIn(email: String, password: String) {
        Task {
            do {
                try await Auth.auth().signIn(withEmail: email, password: password)
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func signUp(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.isAuthenticated = true
                }
            }
        }
    }

    func logout() {
        do {
            try Auth.auth().signOut() // Firebase Authのサインアウト
            isAuthenticated = false // 認証状態を更新
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

