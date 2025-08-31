//
//  FirestoreClient.swift
//  ToDoTask
//
//  Created by 金井菜津希 on 2024/08/28.
//
import SwiftUI
import FirebaseFirestore

struct User: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var iconData: String
}

class FirestoreClient: ObservableObject {
    private let db = Firestore.firestore()
    
    @Published var tasks: [TaskItem] = []
    
    // タスク追加
    func addTask(task: TaskItem, completion: @escaping (Error?) -> Void) {
        do {
            _ = try db.collection("tasks").addDocument(from: task, completion: completion)
        } catch {
            completion(error)
        }
    }
    
    // タスク更新
    func updateTask(task: TaskItem, completion: @escaping (Error?) -> Void) {
        guard let id = task.id else { return }
        do {
            try db.collection("tasks").document(id).setData(from: task, merge: true, completion: completion)
        } catch {
            completion(error)
        }
    }
    
    // リアルタイムでユーザーのタスクを監視
    func listenTasks(userId: String) {
        db.collection("tasks")
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                let tasks = documents.compactMap { try? $0.data(as: TaskItem.self) }
                DispatchQueue.main.async {
                    self.tasks = tasks
                }
            }
    }
}
