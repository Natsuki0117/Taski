//
//  TaskItem.swift
//  Taski
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
    var completedRank: String? 
    
    // 現在の日付で計算するランク
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
        case "S": return .s
        case "A": return .a
        case "B": return .b
        case "C": return .c
        case "期限切れ": return .gray.opacity(0.5)
        default: return .black
        }
    }
    
    // 完了済みランクの色
    var completedRankColor: Color {
        switch completedRank ?? rank {
        case "S": return .s
        case "A": return .a
        case "B": return .b
        case "C": return .c
        case "期限切れ": return .gray.opacity(0.5)
        default: return .black.opacity(0.5)
        }
    }
}
