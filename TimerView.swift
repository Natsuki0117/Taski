//
//  TimerView.swift
//  Taski
//
//  Created by 金井菜津希 on 2025/08/14.
//

import SwiftUI
import Combine
import FirebaseFirestore
import Charts

struct TimerView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var taskStore: TaskStore

    @State private var counter: Int = 0
    @State private var timerCancellable: AnyCancellable?
    @State private var showEmotionInput = false
    @State private var emotionLevel: Int = 5
    @State private var showResultView = false

    var task: TaskItem
    var totalSeconds: Int { task.doTime * 60 }

    init(task: TaskItem) {
        self.task = task
    }

    var body: some View {
        ZStack {
            MeshView()
                .ignoresSafeArea()

            VStack(spacing: 40) {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 15)
                        .frame(width: 260, height: 260)

                    Circle()
                        .trim(from: 0, to: min(CGFloat(counter) / CGFloat(totalSeconds), 1.0))
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [Color.purple.opacity(0.7), Color.blue.opacity(0.7)]),
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 15, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 260, height: 260)
                        .animation(.easeInOut(duration: 0.5), value: counter)

                    Text(stopwatchString())
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundColor(.white)
                }

                Button {
                    showEmotionInput = true
                } label: {
                    Text("✨ 終わった！ ✨")
                        .bold()
                        .frame(width: 200, height: 48)
                        .background(
                            LinearGradient(
                                colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(24)
                        .shadow(radius: 5)
                }
            }
            .padding()
        }
        .onAppear { startTimer() }
        .onDisappear { timerCancellable?.cancel() }

        // 気分入力
        .sheet(isPresented: $showEmotionInput) {
            ZStack {
                MeshView()
                VStack(spacing: 20) {
                    Text("今の気分を教えてください")
                        .font(.title2)
                        .bold()

                    Slider(value: Binding(
                        get: { Double(emotionLevel) },
                        set: { emotionLevel = Int($0) }
                    ), in: 0...10, step: 1)
                        .tint(.orange)

                    Text("レベル: \(emotionLevel) \(emotionEmoji(for: emotionLevel))")

                    Button("保存") {
                        timerCancellable?.cancel() // タイマー停止
                        markTaskCompleted(emotion: emotionLevel)
                        showEmotionInput = false
                        showResultView = true
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(colors: [Color.purple.opacity(0.7), Color.blue.opacity(0.7)],
                                       startPoint: .topLeading,
                                       endPoint: .bottomTrailing)
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(24)
                .padding()
            }
        }

        // 結果ビュー
        .fullScreenCover(isPresented: $showResultView) {
            ResultView(
                task: task,
                actualSeconds: counter,
                finalEmotion: emotionLevel,
                dismissParent: dismiss
            )
        }
    }

    // MARK: - タイマー開始
    func startTimer() {
        timerCancellable?.cancel()
        counter = 0
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                counter += 1
            }
    }

    // MARK: - タスク完了処理
    func markTaskCompleted(emotion: Int) {
        guard let id = task.id else { return }
        let db = Firestore.firestore()
        db.collection("tasks").document(id).updateData([
            "isCompleted": true,
            "emotionLevel": emotion,
            "actualSeconds": counter
        ]) { error in
            if let error = error {
                print("Error updating task: \(error.localizedDescription)")
            } else {
                if let index = taskStore.tasks.firstIndex(where: { $0.id == task.id }) {
                    taskStore.tasks[index].isCompleted = true
                    taskStore.tasks[index].emotionLevel = emotion
                }
            }
        }
    }

    // MARK: - 経過時間表示
    func stopwatchString() -> String {
        let minutes = counter / 60
        let seconds = counter % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // MARK: - 絵文字変換
    func emotionEmoji(for level: Int) -> String {
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

// MARK: - 結果ビュー
struct ResultView: View {
    var task: TaskItem
    var actualSeconds: Int
    var finalEmotion: Int
    var dismissParent: DismissAction

    var body: some View {
        ZStack {
            MeshView()
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 30) {
                    Text("🌸 タスク結果 🌸")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)

                    // 時間比較（縦棒グラフ）
                    VStack(spacing: 16) {
                        Text("⏰ 予定時間と実績時間")
                            .font(.headline)
                            .foregroundColor(.blue)

                        Chart {
                            BarMark(
                                x: .value("種類", "予定"),
                                y: .value("時間（秒）", task.doTime * 60)
                            )
                            .foregroundStyle(
                                LinearGradient(colors: [Color.purple.opacity(0.7), Color.blue.opacity(0.7)],
                                               startPoint: .top,
                                               endPoint: .bottom)
                            )

                            BarMark(
                                x: .value("種類", "実際"),
                                y: .value("時間（秒）", actualSeconds)
                            )
                            .foregroundStyle(
                                LinearGradient(colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.7)],
                                               startPoint: .top,
                                               endPoint: .bottom)
                            )
                        }
                        .frame(height: 200)

                        VStack(spacing: 6) {
                            Text("予定: \(task.doTime)分")
                            Text("実際: \(actualSeconds / 60)分 \(actualSeconds % 60)秒")
                            let diff = actualSeconds - task.doTime * 60
                            Text("差分: \(diff >= 0 ? "+" : "")\(diff)秒")
                                .foregroundColor(.gray)
                        }
                        .foregroundColor(.gray)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(24)

                    // 感情比較（縦棒グラフ）
                    VStack(spacing: 16) {
                        Text("💭 気分の変化")
                            .font(.headline)
                            .foregroundColor(.blue)

                        Chart {
                            BarMark(
                                x: .value("種類", "開始時"),
                                y: .value("レベル", Int(task.slider) ?? 0)
                            )
                            .foregroundStyle(
                                LinearGradient(colors: [Color.purple.opacity(0.7), Color.blue.opacity(0.7)],
                                               startPoint: .top,
                                               endPoint: .bottom)
                            )

                            BarMark(
                                x: .value("種類", "終了時"),
                                y: .value("レベル", finalEmotion)
                            )
                            .foregroundStyle(
                                LinearGradient(colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.7)],
                                               startPoint: .top,
                                               endPoint: .bottom)
                            )
                           
                        }
                        .frame(height: 200)

                        VStack(spacing: 6) {
                            Text("開始時: \(task.slider)/10 \(emotionEmoji(for: Int(task.slider) ?? 0))")
                            Text("終了時: \(finalEmotion)/10 \(emotionEmoji(for: finalEmotion))")
                        }
                        .foregroundColor(.gray)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(24)

                    Button("閉じる") {
                        dismissParent()
                    }
                    .frame(width: 200, height: 48)
                    .background(Color.blue.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(24)
                }
                .padding()
            }
        }
    }

    // 絵文字変換（ResultView側でも使えるように）
    func emotionEmoji(for level: Int) -> String {
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

