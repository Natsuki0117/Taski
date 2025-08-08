//
//  FirestoreClient.swift
//  ToDoTask
//
//  Created by 金井菜津希 on 2024/08/28.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class FirestoreClient {
    
    static var tasks: CollectionReference = Firestore.firestore().collection("tasks")
    
    // データをFirestoreに追加する関数
    static func add(taskItem: TaskItem) {
        Task {
            guard let userId = Auth.auth().currentUser?.uid else {
                print("ユーザーがログインしていません")
                return
            }
            
            // 日本標準時 (JST) に変換
            //            let jstTimeZone = TimeZone(identifier: "Asia/Tokyo")!
            //            var calendar = Calendar.current
            //            calendar.timeZone = jstTimeZone
            //
            //            let jstDueDate = calendar.date(bySettingHour: Calendar.current.component(.hour, from: dueDate),
            //                                           minute: Calendar.current.component(.minute, from: dueDate),
            //                                           second: Calendar.current.component(.second, from: dueDate),
            //                                           of: dueDate,
            //                                           matchingPolicy: .nextTime,
            //                                           repeatedTimePolicy: .first,
            //                                           direction: .forward)!
            //
            //            let formatter = DateFormatter()
            //            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            //            formatter.timeZone = jstTimeZone
            //            let jstDueDateString = formatter.string(from: jstDueDate)
            
            //            let taskData = TaskItem(userId: userId, name: taskName, slider: sliderValue, title: taskTitle, dueDate: dueDate)
            //            [String: Any] = [
            //                "userId": userId,
            //                "name": taskName,
            //                "slider": sliderValue,
            //                "title": taskTitle,
            //                "dueDate": jstDueDateString,  // JST形式で保存
            //                "doTime": doTime
            //            ]
            
            do {
                try await tasks.addDocument(data: taskItem.encoded)
                print("タスクが正常に保存されました")
            } catch {
                print("タスクの保存中にエラーが発生しました: \(error.localizedDescription)")
            }
        }
    }
    
    
    static func fetchUserWishes() async -> [TaskItem] {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("ユーザーがログインしていません")
            return []
        }
        do{
            return try await tasks.getDocuments().documents.compactMap { try? $0.data(as: TaskItem.self) }
//            return try await tasks.whereField("userId", isEqualTo: userId).getDocuments().documents.compactMap { try? $0.data(as: TaskItem.self) }
        }catch{
            print(error.localizedDescription)
            return []
        }
    }
}
//test

//aaa

