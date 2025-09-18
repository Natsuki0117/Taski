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
    var slider: Int        // 感情負荷 1~10
    var title: String
    var dueDate: Date
    var doTime: Int        // 所要時間（分）
    var isCompleted: Bool = false
    var completedRank: String?
    var extendedMinutes: Int = 0
    var emotionLevel: Int = 0
    var finalEmotion: Int?
    var actualSeconds: Int?
    var sessions: [TaskSession] = []
    var location: String?

    var rank: String {
        let daysLeft = Calendar.current.dateComponents([.day], from: Date(), to: dueDate).day ?? 0
        let emotionWeight = Double(slider) / 10.0
        let timeWeight = Double(doTime) / 60.0

        // 期限切れ
        if daysLeft < 0 { return "期限切れ" }

        // 日数の重み：残り日数が少ないほどスコア高め
        let daysWeight = daysLeft > 0 ? 1.0 / Double(daysLeft) * 5.0 : 5.0

        // 難易度3以上なら加点
        let difficultyBonus = slider >= 3 ? 1.0 : 0.0

        // 締め切り7日以内なら加点
        let urgentBonus = daysLeft <= 7 ? 1.0 : 0.0

        let score = daysWeight + emotionWeight + timeWeight + difficultyBonus + urgentBonus

        switch score {
        case 5...: return "S"
        case 3..<5: return "A"
        case 1.5..<3: return "B"
        default: return "C"
        }
    }


    var rankColor: Color {
        switch rank {
        case "S": return .purple
        case "A": return .blue
        case "B": return .green
        case "C": return .orange
        case "期限切れ": return .gray.opacity(0.5)
        default: return .black
        }
    }

    var completedRankColor: Color {
        switch completedRank ?? rank {
        case "S": return .purple
        case "A": return .blue
        case "B": return .green
        case "C": return .orange
        case "期限切れ": return .gray.opacity(0.5)
        default: return .black.opacity(0.5)
        }
    }

    struct TaskSession: Codable, Identifiable {
        var id: String = UUID().uuidString
        var startedAt: Date
        var endedAt: Date
        var duration: Int
        var emotionLevel: Int
        var location: String
        var difficulty: Int
    }

}
