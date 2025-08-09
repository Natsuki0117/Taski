import SwiftUI
import FirebaseAuth
import Firebase
import FirebaseStorage

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String?
    @Published var displayName: String = ""
    @Published var iconURL: String = ""
    
    private var db = Firestore.firestore()
    
    init() {
        observeAuthChanges()
    }
    
    private func observeAuthChanges() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.isAuthenticated = user != nil
                if let user = user {
                    self?.fetchUserData(uid: user.uid)
                } else {
                    self?.displayName = ""
                    self?.iconURL = ""
                }
            }
        }
    }
    
    func signIn(email: String, password: String) {
        Task {
            do {
                try await Auth.auth().signIn(withEmail: email, password: password)
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func signUp(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else if let uid = result?.user.uid {
                    self?.db.collection("users").document(uid).setData([
                        "name": "",
                        "iconURL": ""
                    ])
                    self?.isAuthenticated = true
                }
            }
        }
    }
    
    func saveUserData(name: String, image: UIImage?) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        var data: [String: Any] = ["name": name]
        
        if let image = image {
            let storageRef = Storage.storage().reference().child("icons/\(uid).jpg")
            if let jpegData = image.jpegData(compressionQuality: 0.8) {
                storageRef.putData(jpegData) { [weak self] _, error in
                    if let error = error {
                        print("Upload error: \(error)")
                        return
                    }
                    storageRef.downloadURL { url, _ in
                        if let url = url {
                            data["iconURL"] = url.absoluteString
                            self?.db.collection("users").document(uid).setData(data, merge: true)
                            DispatchQueue.main.async {
                                self?.displayName = name
                                self?.iconURL = url.absoluteString
                            }
                        }
                    }
                }
            }
        } else {
            db.collection("users").document(uid).setData(data, merge: true)
            displayName = name
        }
    }
    
    func fetchUserData(uid: String) {
        db.collection("users").document(uid).getDocument { [weak self] document, error in
            if let document = document, document.exists {
                let data = document.data()
                self?.displayName = data?["name"] as? String ?? ""
                self?.iconURL = data?["iconURL"] as? String ?? ""
            }
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            isAuthenticated = false
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
//
//class AuthViewModel: ObservableObject {
//    @Published var isAuthenticated: Bool = false
//    @Published var errorMessage: String?
//
//    init() {
//        observeAuthChanges()
//    }
//
//    private func observeAuthChanges() {
//        Auth.auth().addStateDidChangeListener { [weak self] _, user in
//            DispatchQueue.main.async {
//                self?.isAuthenticated = user != nil
//            }
//        }
//    }
//
//
//    func signIn(email: String, password: String) {
//        Task {
//            do {
//                try await Auth.auth().signIn(withEmail: email, password: password)
//            } catch {
//                print(error.localizedDescription)
//            }
//        }
//    }
//
//    func signUp(email: String, password: String) {
//        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
//            DispatchQueue.main.async {
//                if let error = error {
//                    self?.errorMessage = error.localizedDescription
//                } else {
//                    self?.isAuthenticated = true
//                }
//            }
//        }
//    }
//
//    func logout() {
//        do {
//            try Auth.auth().signOut() // Firebase Authのサインアウト
//            isAuthenticated = false // 認証状態を更新
//        } catch {
//            print("Error signing out: \(error.localizedDescription)")
//        }
//    }
//}
//
