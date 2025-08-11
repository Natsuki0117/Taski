//
//  TaskItem.swift
//  ToDoTask
//
//  Created by 金井菜津希 on 2024/08/21.
//

import FirebaseFirestore
import SwiftUICore

struct TaskItem: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String
    var name: String
    var slider: String
    var title: String
    var dueDate: Date
    var doTime: Int
    
    // Firestoreに保存しないランク
    var rank: String {
        let daysLeft = Calendar.current.dateComponents([.day], from: Date(), to: dueDate).day ?? 0
        
        if daysLeft < 0 {
            return "期限切れ"
        } else if daysLeft == 0 {
            return "S"
        } else if daysLeft <= 3 {
            return "A"
        } else if daysLeft <= 7 {
            return "B"
        } else {
            return "C"
        }
    }
    
    // ランクごとの色
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
    
    init(id: String? = nil, userId: String = "", name: String, slider: String, title: String, dueDate: Date, doTime: Int) {
        self.id = id
        self.userId = userId
        self.name = name
        self.slider = slider
        self.title = title
        self.dueDate = dueDate
        self.doTime = doTime
    }
}

extension Encodable {
    var encoded: [String: Any] {
        get throws {
            try Firestore.Encoder().encode(self)
        }
    }
}
