//
//  AccountViewModel.swift
//  ToDoTask
//
//  Created by 金井菜津希 on 2025/08/09.
//
import SwiftUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

final class AccountViewModel: ObservableObject {
    @Published var displayName: String = ""
    @Published var selectedImage: UIImage? = nil

    private let firestore = Firestore.firestore()
    private let storage = Storage.storage()
    
    // Firestoreのusersコレクションのパス
    private var userDocRef: DocumentReference? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        return firestore.collection("users").document(uid)
    }
    
    // Firestoreにユーザー名・アイコンURLを保存する関数
    func saveProfile(completion: @escaping (Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "NoUser", code: -1))
            return
        }
        
        if let image = selectedImage {
            // 画像アップロード→URL取得→Firestore更新
            uploadProfileImage(image, uid: uid) { [weak self] url, error in
                if let error = error {
                    completion(error)
                    return
                }
                guard let url = url else {
                    completion(NSError(domain: "NoURL", code: -1))
                    return
                }
                self?.updateFirestoreProfile(uid: uid, displayName: self?.displayName ?? "", photoURL: url, completion: completion)
            }
        } else {
            // 画像なしなら名前だけFirestore更新
            updateFirestoreProfile(uid: uid, displayName: displayName, photoURL: nil, completion: completion)
        }
    }
    
    // Storageに画像アップロード
    private func uploadProfileImage(_ image: UIImage, uid: String, completion: @escaping (URL?, Error?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil, NSError(domain: "ImageDataError", code: -1))
            return
        }
        
        let storageRef = storage.reference().child("profile_images/\(uid).jpg")
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                completion(nil, error)
                return
            }
            storageRef.downloadURL(completion: completion)
        }
    }
    
    // Firestoreにユーザープロフィール情報を保存
    private func updateFirestoreProfile(uid: String, displayName: String, photoURL: URL?, completion: @escaping (Error?) -> Void) {
        var data: [String: Any] = [
            "displayName": displayName,
            "updatedAt": FieldValue.serverTimestamp()
        ]
        if let photoURL = photoURL {
            data["photoURL"] = photoURL.absoluteString
        }
        
        userDocRef?.setData(data, merge: true) { error in
            completion(error)
        }
    }
    
    // Firestoreからユーザーデータを読み込み（オプション）
    func loadProfile() {
        userDocRef?.getDocument { [weak self] snapshot, error in
            if let error = error {
                print("Firestore読み込みエラー:", error)
                return
            }
            guard let data = snapshot?.data() else { return }
            DispatchQueue.main.async {
                self?.displayName = data["displayName"] as? String ?? ""
                if let urlString = data["photoURL"] as? String, let url = URL(string: urlString) {
                    self?.loadImageFromURL(url)
                }
            }
        }
    }
    
    private func loadImageFromURL(_ url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.selectedImage = image
                }
            }
        }.resume()
    }
}


