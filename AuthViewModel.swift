//
//  AuthViewModel.swift
//  ToDoTask
//
//  Created by 金井菜津希 on 2025/08/09.
//
import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: UserModel?
    @Published var displayName: String = ""
    @Published var iconData: UIImage? = nil
    @Published var errorMessage: String?

    init() {
        if let user = Auth.auth().currentUser {
            self.isAuthenticated = true
            fetchUserData(uid: user.uid)
        }
    }

    func signIn(email: String, password: String) {
        errorMessage = nil
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                DispatchQueue.main.async { self.errorMessage = error.localizedDescription }
                return
            }
            guard let uid = result?.user.uid else { return }
            DispatchQueue.main.async {
                self.isAuthenticated = true
                self.fetchUserData(uid: uid)
            }
        }
    }

    func signUp(email: String, password: String) {
        errorMessage = nil
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                DispatchQueue.main.async { self.errorMessage = error.localizedDescription }
                return
            }
            guard let uid = result?.user.uid else { return }
            let userData: [String: Any] = ["name": "", "iconURL": ""]
            Firestore.firestore().collection("users").document(uid).setData(userData)
            DispatchQueue.main.async {
                self.isAuthenticated = true
                self.fetchUserData(uid: uid)
            }
        }
    }

    func logout() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.isAuthenticated = false
                self.currentUser = nil
                self.displayName = ""
                self.iconData = nil
                self.errorMessage = nil
            }
        } catch {
            print("ログアウト失敗: \(error)")
        }
    }

    func fetchUserData(uid: String) {
        Firestore.firestore().collection("users").document(uid).getDocument { snapshot, error in
            if let snapshot = snapshot, snapshot.exists {
                let data = snapshot.data() ?? [:]
                let name = data["name"] as? String ?? ""
                let iconURL = data["iconURL"] as? String ?? ""
                DispatchQueue.main.async {
                    self.displayName = name
                    self.currentUser = UserModel(id: uid, name: name, iconURL: iconURL)
                    if !iconURL.isEmpty {
                        self.loadImage(from: iconURL)
                    }
                }
            }
        }
    }

    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let uiImage = UIImage(data: data) {
                DispatchQueue.main.async { self.iconData = uiImage }
            }
        }.resume()
    }

    func updateUser(name: String, iconImage: UIImage?) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        var data: [String: Any] = ["name": name]

        if let iconImage = iconImage, let imageData = iconImage.pngData() {
            let storageRef = Storage.storage().reference().child("userIcons/\(uid).png")
            storageRef.putData(imageData, metadata: nil) { _, error in
                if let error = error { print("Storage Upload Error: \(error)"); return }
                storageRef.downloadURL { url, _ in
                    if let urlString = url?.absoluteString {
                        data["iconURL"] = urlString
                        Firestore.firestore().collection("users").document(uid).setData(data, merge: true) { _ in
                            DispatchQueue.main.async {
                                self.currentUser?.name = name
                                self.currentUser?.iconURL = urlString
                                self.displayName = name
                                self.iconData = iconImage
                            }
                        }
                    }
                }
            }
        } else {
            Firestore.firestore().collection("users").document(uid).setData(data, merge: true) { _ in
                DispatchQueue.main.async {
                    self.currentUser?.name = name
                    self.displayName = name
                }
            }
        }
    }
}

struct UserModel: Identifiable {
    var id: String?
    var name: String
    var iconURL: String
}
