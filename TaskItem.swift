//
//  TaskItem.swift
//  ToDoTask
//
//  Created by 金井菜津希 on 2024/08/21.
//
import SwiftUI
import FirebaseFirestore

struct TaskItem: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String
    var name: String
    var slider: String
    var title: String
    var dueDate: Date
    var doTime: Int
    var isCompleted: Bool = false
    
    var rank: String {
        let daysLeft = Calendar.current.dateComponents([.day], from: Date(), to: dueDate).day ?? 0
        if daysLeft < 0 { return "期限切れ" }
        else if daysLeft == 0 { return "S" }
        else if daysLeft <= 3 { return "A" }
        else if daysLeft <= 7 { return "B" }
        else { return "C" }
    }
    
    var rankColor: Color {
        switch rank {
        case "S": return .red
        case "A": return .yellow
        case "B": return .blue
        case "C": return .green
        case "期限切れ": return .gray
        default: return .black
        }
    }
}
