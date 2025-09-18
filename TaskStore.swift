//
//  TaskStore.swift
//  Taski
//
//  Created by 金井菜津希 on 2025/08/14.
//
import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth
import SwiftUI


@MainActor
class TaskStore: ObservableObject {
    @Published var tasks: [TaskItem] = []

    func fetchTasks() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            let snapshot = try await Firestore.firestore()
                .collection("tasks")
                .whereField("userId", isEqualTo: uid)
                .getDocuments()
            let fetchedTasks = snapshot.documents.compactMap { doc -> TaskItem? in
                try? doc.data(as: TaskItem.self)
            }
            self.tasks = fetchedTasks
        } catch {
            print("Error fetching tasks: \(error)")
        }
    }

    func addTask(_ task: TaskItem) async throws {
        let docRef = Firestore.firestore().collection("tasks").document()
        try docRef.setData(from: task)
        tasks.append(task)
    }

    func updateTask(_ task: TaskItem) async throws {
        guard let id = task.id else { return }
        let docRef = Firestore.firestore().collection("tasks").document(id)
        try docRef.setData(from: task, merge: true)
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        }
    }

    func deleteTask(_ task: TaskItem) async throws {
        guard let id = task.id else { return }
        let docRef = Firestore.firestore().collection("tasks").document(id)
        try await docRef.delete()
        tasks.removeAll { $0.id == task.id }
    }

    func extendTask(_ task: TaskItem, minutes: Int) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index].extendedMinutes += minutes
        if let id = task.id {
            let docRef = Firestore.firestore().collection("tasks").document(id)
            docRef.updateData(["extendedMinutes": tasks[index].extendedMinutes]) { error in
                if let error = error {
                    print("Error updating extendedMinutes: \(error.localizedDescription)")
                }
            }
        }
    }
}
