//
//  ResultView.swift
//  Taski
//
//  Created by 金井菜津希 on 2025/09/18.
//

import SwiftUI

struct ResultView: View {
    let task: TaskItem
    @Environment(\.dismiss) private var dismiss

    private var lastSession: TaskItem.TaskSession? {
        task.sessions.last
    }

    private var actualMinutes: Int? {
        if let s = lastSession { return s.duration / 60 }
        if let sec = task.actualSeconds { return sec / 60 }
        if task.extendedMinutes > 0 { return task.doTime + task.extendedMinutes }
        return nil
    }

    private var actualEmotion: Int? {
        if let s = lastSession { return s.emotionLevel }
        if let fe = task.finalEmotion { return fe }
        if task.emotionLevel != 0 { return task.emotionLevel }
        return nil
    }

    private var locationText: String {
        lastSession?.location ?? "記録なし"
    }

    private var timeDiff: Int? {
        guard let actual = actualMinutes else { return nil }
        return actual - task.doTime
    }

    private var difficultyDiff: Int? {
        guard let actual = actualEmotion else { return nil }
        return actual - task.slider
    }

    private var feedbackText: String {
        var lines: [String] = []

        if let diff = timeDiff {
            if diff <= -5 {
                lines.append("⚡ すごい！予定より \(abs(diff))分早く終わってるよ。集中して取り組めたんだね。")
            } else if diff < 0 {
                lines.append("👍 予定より少し早く終わっています（\(abs(diff))分）。良いペース！")
            } else if diff == 0 {
                lines.append("👌 予定通りに完了できてるね。見積もりが安定してるよ。")
            } else if diff <= 5 {
                lines.append("⏳ 予定より \(diff)分遅れてるね。ちょっと長引いたかも。")
            } else {
                lines.append("⚠️ 予定より \(diff)分長くかかってるよ。このタスクは時間かかりがちかも、、？")
            }
        } else {
            lines.append("ℹ️ 実際の時間の記録がありません。次回はセッションを保存してみてね。")
        }

        if let diff = difficultyDiff {
            if diff <= -2 {
                lines.append("🌟 実際はかなり楽に感じてるみたい！予定の難易度を下げても良さそう。")
            } else if diff < 0 {
                lines.append("😊 予定より楽にできたみたい。次回は少しタスクを増やしてもいいかも。")
            } else if diff == 0 {
                lines.append("😌 想定どおりの難しさだったね。見積もりバッチリ！")
            } else if diff <= 2 {
                lines.append("😅 予定より少し大変だったね。次は少し余裕を見よう。")
            } else {
                lines.append("💪 予想よりだいぶ大変だったね。タスクを分割すると良いかも、、、？")
            }
        } else {
            lines.append("📝 難易度のフィードバックがありません。終了時に入力してみてね。")
        }

        return lines.joined(separator: "\n\n")
    }

    var body: some View {
        ZStack {
            // 背景をグラデーションに
            LinearGradient(
                colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            MeshView() // メッシュ効果を残す場合
                .opacity(0.3)
            
            NavigationStack {
                ScrollView {
                    VStack(spacing: 20) {
                        // ヘッダー
                        VStack(spacing: 8) {
                            Text(task.title)
                                .font(.title2)
                                .bold()
                                .multilineTextAlignment(.center)
                                .foregroundColor(.primary)

                            if locationText != "記録なし" {
                                Text("📍 \(locationText)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 6)
                                    .background(
                                        LinearGradient(
                                            colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.8)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .clipShape(Capsule())
                                    .shadow(color: .purple.opacity(0.6), radius: 6, x: 0, y: 3)
                            } else {
                                HStack(spacing: 6) {
                                    Image(systemName: "mappin.and.ellipse")
                                        .foregroundColor(.secondary)
                                    Text(locationText)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.top, 12)

                        // メインカード（半透明）
                        VStack(spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("予定時間")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("\(task.doTime) 分")
                                        .font(.headline)
                                }
                                Spacer()
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("実際の時間")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    if let actual = actualMinutes {
                                        Text("\(actual) 分")
                                            .font(.headline)
                                    } else {
                                        Text("記録なし")
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }

                            Divider()

                            HStack {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("予定の難易度")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("\(task.slider)/10")
                                        .font(.headline)
                                }
                                Spacer()
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("実際の難易度")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    if let em = actualEmotion {
                                        HStack(spacing: 6) {
                                            Text("\(em)/10")
                                                .font(.headline)
                                            Text(emotionEmoji(for: em))
                                        }
                                    } else {
                                        Text("未入力")
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.white.opacity(0.6))
                                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                        )
                        .padding(.horizontal)

                        // フィードバック
                        VStack(spacing: 12) {
                            Text("あなたへのフィードバック")
                                .font(.headline)
                                .foregroundColor(.secondary)

                            Text(feedbackText)
                                .font(.body)
                                .multilineTextAlignment(.leading)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.2)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                )
                        }
                        .padding(.horizontal)

                        // ランク
                        if let rank = task.completedRank {
                            VStack(spacing: 6) {
                                Text("結果ランク")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(rank)
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color.purple, Color.blue],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            }
                            .padding(.top, 6)
                        }

                        Spacer(minLength: 30)

                        // 閉じるボタン
                        Button(action: { dismiss() }) {
                            Text("閉じる")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [Color.purple, Color.blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(14)
                                .padding(.horizontal)
                        }
                        .padding(.bottom, 20)
                    }
                }
                .background(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                )
                .navigationTitle("結果")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }

    private func emotionEmoji(for level: Int) -> String {
        switch level {
        case 0...2: return "😍"
        case 3...4: return "😊"
        case 5...6: return "😐"
        case 7...8: return "😣"
        case 9...10: return "😤"
        default: return "❓"
        }
    }
}
