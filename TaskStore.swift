//
//  TaskStore.swift
//  ToDoTask
//
//  Created by 金井菜津希 on 2025/08/14.
//
import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth

@MainActor
class TaskStore: ObservableObject {
    @Published var tasks: [TaskItem] = []
    
    func fetchTasks() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("tasks")
            .whereField("userId", isEqualTo: uid)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching tasks: \(error)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                let fetchedTasks = documents.compactMap { doc -> TaskItem? in
                    try? doc.data(as: TaskItem.self)
                }
                DispatchQueue.main.async {
                    self.tasks = fetchedTasks
                }
            }
    }
}
