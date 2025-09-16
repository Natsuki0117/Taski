//
//  TaskItem.swift
//  Taski
//
//  Created by 金井菜津希 on 2024/08/21.
//
import SwiftUI
import FirebaseFirestore

// Firebaseに送るタスクモデル
struct TaskItem: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String
    var name: String
    var slider: Int        // 感情負荷 1~10（高いほど負荷が高い）
    var title: String
    var dueDate: Date
    var doTime: Int        // 所要時間（分）
    var isCompleted: Bool = false
    var completedRank: String?
    var extendedMinutes: Int = 0
    var emotionLevel: Int = 0

    // 現在の日付で計算するランク（締切 + 負荷 + 所要時間）
    var rank: String {
        let daysLeft = Calendar.current.dateComponents([.day], from: Date(), to: dueDate).day ?? 0
        let emotionWeight = Double(slider) / 10.0          // 負荷が高いほど加点
        let timeWeight = Double(doTime) / 60.0             // 所要時間を60分単位で加点

        // 締切が過ぎていれば期限切れ
        if daysLeft < 0 { return "期限切れ" }

        // 締切の近さを加味（7日以内は加点、7日以上は0）
        let daysWeight = max(0, 7 - Double(daysLeft))

        // 総合スコア（スコアが高いほど優先度高）
        let score = daysWeight + emotionWeight + timeWeight

        switch score {
        case 5...:
            return "S"
        case 3..<5:
            return "A"
        case 1.5..<3:
            return "B"
        default:
            return "C"
        }
    }

    // ランクごとの色
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

    // 完了済みランクの色
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
}
