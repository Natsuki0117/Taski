//
//  TaskDetailView.swift
//  Taski
//
//  Created by 金井菜津希 on 2025/09/18.
//

import SwiftUI

struct TaskDetailView: View {
    let task: TaskItem
    
    var body: some View {
        VStack(spacing: 20) {
            Text("タスク詳細")
                .font(.title.bold())
            
            Text("📌 タスク名: \(task.title)")
                .font(.headline)
            
            Text("予定時間: \(task.doTime)分")
            
            if let session = task.sessions.last {
                // 時間の差分
                let diffTime = (session.duration / 60) - task.doTime
                Text("実際にかかった時間: \(session.duration / 60)分 (\(diffTimeText(diffTime)))")
                
                // 難易度の差分
                let diffLevel = session.emotionLevel - task.slider
                Text("難易度: 予定 \(task.slider)、実際 \(session.emotionLevel) (\(diffLevelText(diffLevel)))")
                
                // 場所
                Text("場所: \(session.location)")
            } else {
                Text("セッション情報がありません")
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - 差分を文章にする
    private func diffTimeText(_ diff: Int) -> String {
        if diff == 0 { return "予定通り" }
        else if diff > 0 { return "予定より \(diff)分長かった" }
        else { return "予定より \(-diff)分短かった" }
    }
    
    private func diffLevelText(_ diff: Int) -> String {
        if diff == 0 { return "予定通り" }
        else if diff > 0 { return "予定より少し難しかった" }
        else { return "予定より簡単だった" }
    }
}
