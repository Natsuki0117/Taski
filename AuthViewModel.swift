//
//  AuthViewModel.swift
//  Taski
//
//  Created by 金井菜津希 on 2025/08/09.
//
import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: UserModel?
    @Published var displayName: String = ""
    @Published var iconData: UIImage? = nil
    @Published var errorMessage: String?
    @Published var isSaving: Bool = false

    init() {
        Task {
            await checkCurrentUser()
        }
    }
    
    func checkCurrentUser() async {
        if let user = Auth.auth().currentUser {
            isAuthenticated = true
            await fetchUserData(uid: user.uid)
        }
    }
    
    // MARK: - Firestoreからユーザー情報取得
    func fetchUserData(uid: String) async {
        do {
            let doc = try await Firestore.firestore().collection("users").document(uid).getDocument()
            guard let data = doc.data() else { return }
            let name = data["name"] as? String ?? ""
            let iconURL = data["iconURL"] as? String ?? ""
            
            displayName = name
            currentUser = UserModel(id: uid, name: name, iconURL: iconURL)
            if !iconURL.isEmpty {
                await loadImage(from: iconURL)
            }
        } catch {
            print("fetchUserData error:", error)
        }
    }
    
    private func loadImage(from urlString: String) async {
        guard let url = URL(string: urlString) else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                iconData = image
            }
        } catch {
            print("Image load error:", error)
        }
    }
    
    // MARK: - サインイン
    func signIn(email: String, password: String) async {
        errorMessage = nil
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            isAuthenticated = true
            await fetchUserData(uid: result.user.uid)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - サインアップ
    func signUp(email: String, password: String) async throws {
        errorMessage = nil
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let uid = result.user.uid
        let userData: [String: Any] = ["name": "", "iconURL": ""]
        try await Firestore.firestore().collection("users").document(uid).setData(userData)
        isAuthenticated = true
        await fetchUserData(uid: uid)
    }
    
    // MARK: - ログアウト
    func logout() async {
        do {
            try Auth.auth().signOut()
            isAuthenticated = false
            currentUser = nil
            displayName = ""
            iconData = nil
            errorMessage = nil
        } catch {
            print("ログアウト失敗:", error)
        }
    }
    
    // MARK: - ユーザー情報更新
    func updateUser(name: String, iconImage: UIImage?) async -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else { return false }
        isSaving = true
        var data: [String: Any] = ["name": name]
        
        if let iconImage = iconImage, let imageData = iconImage.jpegData(compressionQuality: 0.8) {
            let storageRef = Storage.storage(url: "gs://todotask-4912e.firebasestorage.app")
                .reference()
                .child("users/\(uid)/icon.jpg")
            
            do {
                _ = try await storageRef.putDataAsync(imageData, metadata: nil)
                let url = try await storageRef.downloadURL()
                data["iconURL"] = url.absoluteString
                
                try await Firestore.firestore().collection("users").document(uid).setData(data, merge: true)
                
                displayName = name
                currentUser?.name = name
                currentUser?.iconURL = url.absoluteString
                self.iconData = iconImage
                isSaving = false
                return true
            } catch {
                print("updateUser error:", error)
                isSaving = false
                return false
            }
        } else {
            do {
                try await Firestore.firestore().collection("users").document(uid).setData(data, merge: true)
                displayName = name
                currentUser?.name = name
                isSaving = false
                return true
            } catch {
                print("updateUser error:", error)
                isSaving = false
                return false
            }
        }
    }
    
    // MARK: - UserModel
    struct UserModel: Identifiable {
        var id: String?
        var name: String
        var iconURL: String
    }
}
