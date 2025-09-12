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


class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: UserModel?
    @Published var displayName: String = ""
    @Published var iconData: UIImage? = nil
    @Published var errorMessage: String?
    @Published var isSaving: Bool = false
    
    init() {
        if let user = Auth.auth().currentUser {
            self.isAuthenticated = true
            fetchUserData(uid: user.uid)
        }
    }
    
    func fetchUserData(uid: String) {
        Firestore.firestore().collection("users").document(uid).getDocument { snapshot, error in
            guard let data = snapshot?.data(), snapshot?.exists == true else { return }
            let name = data["name"] as? String ?? ""
            let iconURL = data["iconURL"] as? String ?? ""
            DispatchQueue.main.async {
                self.displayName = name
                self.currentUser = UserModel(id: uid, name: name, iconURL: iconURL)
                if !iconURL.isEmpty { self.loadImage(from: iconURL) }
            }
        }
    }
    
    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async { self.iconData = image }
            }
        }.resume()
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
    
    // =====================
    // updateUser（安全にアップロードする版）
    // =====================
    
    func updateUser(name: String, iconImage: UIImage?, completion: @escaping (Bool) -> Void) {
        // ログインユーザーの UID を取得
        guard let uid = Auth.auth().currentUser?.uid else {
            print("未ログインのためアップロード不可")
            completion(false)
            return
        }
        
        // 更新する Firestore データ
        var data: [String: Any] = ["name": name]
        DispatchQueue.main.async { self.isSaving = true }
        
        // 画像がある場合
        if let iconImage = iconImage, let imageData = iconImage.jpegData(compressionQuality: 0.8) {
            // バケット URL を明示して、ユーザー専用フォルダに保存
            let storageRef = Storage.storage(url: "gs://todotask-4912e.firebasestorage.app")
                .reference()
                .child("users/\(uid)/icon.jpg")
            
            storageRef.putData(imageData, metadata: nil) { _, error in
                if let error = error {
                    DispatchQueue.main.async { self.isSaving = false }
                    print("Upload failed:", error)
                    completion(false)
                    return
                }
                
                // アップロード成功後にダウンロード URL を取得
                storageRef.downloadURL { url, error in
                    DispatchQueue.main.async { self.isSaving = false }
                    
                    if let error = error {
                        print("Download URL error:", error)
                        completion(false)
                        return
                    }
                    
                    guard let urlString = url?.absoluteString else {
                        completion(false)
                        return
                    }
                    
                    // Firestore データに iconURL を追加
                    data["iconURL"] = urlString
                    
                    // Firestore 更新
                    Firestore.firestore().collection("users").document(uid).setData(data, merge: true) { error in
                        if let error = error {
                            print("Firestore Update Error:", error)
                            completion(false)
                            return
                        }
                        
                        // UI 更新
                        DispatchQueue.main.async {
                            self.currentUser?.name = name
                            self.currentUser?.iconURL = urlString
                            self.displayName = name
                            self.iconData = iconImage
                            completion(true)
                        }
                    }
                }
            }
        } else {
            // 画像がない場合は名前だけ更新
            Firestore.firestore().collection("users").document(uid).setData(data, merge: true) { error in
                DispatchQueue.main.async { self.isSaving = false }
                if let error = error {
                    print("Firestore Update Error:", error)
                    completion(false)
                    return
                }
                DispatchQueue.main.async {
                    self.currentUser?.name = name
                    self.displayName = name
                    completion(true)
                }
            }
        }
    }

    
    
    
    // =====================
    // UserModel
    // =====================
    
    struct UserModel: Identifiable {
        var id: String?
        var name: String
        var iconURL: String
    }
}
