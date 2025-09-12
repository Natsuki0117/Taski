//
//  TestView.swift
//  Taski
//
//  Created by 金井菜津希 on 2025/09/07.
//


import SwiftUI
import FirebaseStorage

struct TestView: View {
    var body: some View {
        Button("画像アップロードテスト") {
            guard let image = UIImage(systemName: "person.circle"),
                  let data = image.jpegData(compressionQuality: 0.8) else { return }

            let uid = "テストUID" // 実際にはログイン中の uid に置き換える
            let storageRef = Storage.storage().reference().child("images/\(uid).jpg")

            storageRef.putData(data, metadata: nil) { metadata, error in
                if let error = error {
                    print("Upload failed:", error)
                    return
                }
                print("Upload succeeded")

                storageRef.downloadURL { url, error in
                    if let url = url {
                        print("Download URL:", url)
                    } else if let error = error {
                        print("Download URL Error:", error)
                    }
                }
            }
        }
    }
}

