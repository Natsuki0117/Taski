//
//  File.swift
//  Taski
//
//  Created by 金井菜津希 on 2025/09/18.
//

import Foundation
import SwiftUI


// MARK: - タスク分析
struct UserAnalysis {
    let locationFocus: String
    let timeRank: [String: Int]
    let difficultyRank: [String: Int]
}

func analyzeUserTasks(tasks: [TaskItem]) -> UserAnalysis {
    var locationScores: [String: Int] = [:]
    var timeRanks: [String: Int] = [:]
    var difficultyRanks: [String: Int] = [:]

    for task in tasks {
        for session in task.sessions {
            let diffTime = session.duration - task.doTime * 60
            let timeCategory: String
            switch diffTime {
            case ..<(-60): timeCategory = "かなり短い"
            case -60..<0: timeCategory = "短い"
            case 0..<60: timeCategory = "ほぼ予定通り"
            case 60..<180: timeCategory = "長い"
            default: timeCategory = "かなり長い"
            }
            timeRanks[timeCategory, default: 0] += 1

            let diffDifficulty = session.difficulty - task.slider
            let diffCategory: String
            switch diffDifficulty {
            case ..<(-2): diffCategory = "楽すぎ"
            case -2..<0: diffCategory = "少し楽"
            case 0..<2: diffCategory = "想定通り"
            case 2...: diffCategory = "難しい"
            default: diffCategory = "不明"
            }
            difficultyRanks[diffCategory, default: 0] += 1

            if session.duration < task.doTime * 60 {
                locationScores[session.location, default: 0] += 1
            }
        }
    }

    let bestLocation = locationScores.max(by: { $0.value < $1.value })?.key ?? "まだ不明"
    return UserAnalysis(locationFocus: bestLocation, timeRank: timeRanks, difficultyRank: difficultyRanks)
}
