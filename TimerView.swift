//
//  TimerView.swift
//  Taski
//
//  Created by 金井菜津希 on 2025/08/14.
//

import SwiftUI
import Combine

struct TimerView: View {
    @EnvironmentObject var taskStore: TaskStore
    @Environment(\.dismiss) var dismiss

    @State private var counter: Int = 0
    @State private var timerCancellable: AnyCancellable?
    @State private var showEmotionInput = false
    @State private var emotionLevel: Int = 5
    @State private var paused = false
    @State private var showPauseOptions = false

    var task: TaskItem
    var location: String = "自宅"

    var totalSeconds: Int { max(task.doTime * 60, 1) }

    var body: some View {
        ZStack {
            // 背景
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.4), Color.purple.opacity(0.6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 50) {
                Text("集中して頑張りましょう📣")
                    .font(.title2.bold())
                    .foregroundColor(.white)

                // タイマーの円
                ZStack {
                    Circle()
                        .stroke(lineWidth: 16)
                        .opacity(0.3)
                        .foregroundColor(.white)

                    Circle()
                        .trim(from: 0, to: CGFloat(min(Double(counter)/Double(totalSeconds), 1.0)))
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [Color.cyan, Color.purple]),
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 16, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.2), value: counter)

                    Text(String(format: "%02d:%02d", counter/60, counter%60))
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .frame(width: 250, height: 250) // 円を大きく

                // 操作ボタン
                HStack(spacing: 30) {
                    Button(paused ? "再開" : "一時停止") {
                        paused.toggle()
                        if paused {
                            timerCancellable?.cancel()
                            showPauseOptions = true
                        } else {
                            startTimer()
                        }
                    }
                    .padding()
                    .frame(width: 140)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(15)

                    Button("終了") {
                        timerCancellable?.cancel()
                        showEmotionInput = true
                    }
                    .padding()
                    .frame(width: 140)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.pink.opacity(0.8), Color.purple.opacity(0.8)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(15)
                }
            }
            .padding()
        }
        .onAppear { startTimer() }
        .onDisappear { timerCancellable?.cancel() }

        // 一時停止時の選択肢
        .alert("一時停止", isPresented: $showPauseOptions) {
            Button("休憩する") { showPauseOptions = false }
            Button("タスク終了") {
                showPauseOptions = false
                showEmotionInput = true
            }
            Button("再開", role: .cancel) {
                showPauseOptions = false
                startTimer()
            }
        }

        // タスク終了後に難易度入力
        .sheet(isPresented: $showEmotionInput) {
            VStack(spacing: 20) {
                Text("タスクの難易度を振りかえろう")
                    .font(.title2.bold())

                Slider(
                    value: Binding(
                        get: { Double(emotionLevel) },
                        set: { emotionLevel = Int($0) }
                    ),
                    in: 0...5,
                    step: 1
                )
                .tint(.orange)

                Text("レベル: \(emotionLevel)")

                Button("保存") {
                    saveSession(finalEmotion: emotionLevel)
                    showEmotionInput = false
                    dismiss() // TimerViewを閉じる
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(15)
                .padding(.horizontal)
            }
            .padding()
        }
    }

    // MARK: - タイマー開始
    func startTimer() {
        timerCancellable?.cancel()
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if counter < totalSeconds {
                    counter += 1
                } else {
                    timerCancellable?.cancel()
                    showEmotionInput = true
                }
            }
    }

    func saveSession(finalEmotion: Int? = nil) {
        guard let index = taskStore.tasks.firstIndex(where: { $0.id == task.id }) else { return }

        let session = TaskItem.TaskSession(
            startedAt: Date().addingTimeInterval(-Double(counter)),
            endedAt: Date(),
            duration: counter,
            emotionLevel: finalEmotion ?? 5,
            location: location,
            difficulty: task.slider
        )

        // ローカル更新
        taskStore.tasks[index].sessions.append(session)
        taskStore.tasks[index].isCompleted = true
        counter = 0

        // Firestoreに保存
        Task {
            do {
                try await taskStore.updateTask(taskStore.tasks[index])
            } catch {
                print("Firestore更新失敗: \(error)")
            }
        }
    }


}
