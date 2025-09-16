//
//  TimerView.swift
//  Taski
//
//  Created by 金井菜津希 on 2025/08/14.
//
import SwiftUI
import Combine
import FirebaseFirestore

struct TimerView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var taskStore: TaskStore

    @State private var counter: Int = 0
    @State private var timerCancellable: AnyCancellable?
    @State private var isFinished: Bool = false

    @State private var showCompletionCheck = false
    @State private var showExtensionChoice = false
    @State private var extensionMinutes = ""

    @State private var showEmotionInput = false
    @State private var emotionLevel: Int = 5

    @State private var totalSeconds: Int

    var task: TaskItem

    init(task: TaskItem) {
        self.task = task
        _totalSeconds = State(initialValue: (task.doTime + task.extendedMinutes) * 60)
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
                        .trim(from: 0, to: CGFloat(counter) / CGFloat(totalSeconds))
                        .stroke(
                            AngularGradient(gradient: Gradient(colors: [Color.purple.opacity(0.7), Color.blue.opacity(0.7)]),
                                            center: .center),
                            style: StrokeStyle(lineWidth: 15, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 260, height: 260)
                        .animation(.easeInOut(duration: 0.5), value: counter)

                    Text(timeString())
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundColor(.white)
                }

                // 時間内に終わったボタン
                if !isFinished {
                    Button {
                        showEmotionInput = true
                    } label: {
                        Text("時間内に終わった！")
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

                Button {
                    dismiss()
                } label: {
                    Text("戻る")
                        .bold()
                        .frame(width: 200, height: 48)
                        .background(Color.blue.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(24)
                        .shadow(radius: 5)
                }
            }
            .padding()
        }
        .onAppear { startTimer() }
        .onDisappear { timerCancellable?.cancel() }

        .alert("タスクは終わりましたか？", isPresented: $showCompletionCheck) {
            Button("終わった！") { showEmotionInput = true }
            Button("終わってない") { showExtensionChoice = true }
        }

        .sheet(isPresented: $showExtensionChoice) {
            ZStack {
                MeshView()
                VStack(spacing: 20) {
                    Text("タスクを延長しますか？")
                        .font(.title2)
                        .bold()

                    TextField("延長する分数", text: $extensionMinutes)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    HStack(spacing: 40) {
                        Button("延長する") {
                            if let min = Int(extensionMinutes), min > 0 {
                                extendTask(minutes: min)
                                showExtensionChoice = false
                            }
                        }
                        .frame(width: 120, height: 44)
                        .background(
                            LinearGradient(colors: [Color.purple.opacity(0.7), Color.blue.opacity(0.7)],
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing)
                        )
                        .foregroundColor(.white)
                        .cornerRadius(20)

                        Button("あとでやる") {
                            showExtensionChoice = false
                            dismiss()
                        }
                        .frame(width: 120, height: 44)
                        .background(Color.gray.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(20)
                    }
                    Spacer()
                }
                .padding()
            }
        }
//タスク終わってからの
        .sheet(isPresented: $showEmotionInput) {
            ZStack {
                MeshView()
                VStack(spacing: 20) {
                    Text("どれくらいの難易度でしたか？")
                        .font(.title2)
                        .bold()

                    Slider(value: Binding(
                        get: { Double(emotionLevel) },
                        set: { emotionLevel = Int($0) }
                    ), in: 0...10, step: 1)

                    Text("レベル: \(emotionLevel)")

                    Button("保存") {
                        markTaskCompleted(emotion: emotionLevel)
                        showEmotionInput = false
                        dismiss()
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
    }

    // MARK: - タイマー開始
    func startTimer() {
        timerCancellable?.cancel()
        isFinished = false // 延長後もボタンを表示
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if counter < totalSeconds {
                    counter += 1
                } else {
                    timerCancellable?.cancel()
                    isFinished = true
                    showCompletionCheck = true
                }
            }
    }

    // MARK: - 延長処理（タイマー再開＆ボタン表示）
    func extendTask(minutes: Int) {
        taskStore.extendTask(task, minutes: minutes)  // Firestore 更新
        totalSeconds += minutes * 60                  // 残り時間に追加
        startTimer()                                  // タイマー再開
    }

    // MARK: - タスク完了処理
    func markTaskCompleted(emotion: Int) {
        guard let id = task.id else { return }
        let db = Firestore.firestore()
        db.collection("tasks").document(id).updateData([
            "isCompleted": true,
            "emotionLevel": emotion,
            "extendedMinutes": task.extendedMinutes
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

    // MARK: - タイマー表示
    func timeString() -> String {
        let remaining = max(totalSeconds - counter, 0)
        let minutes = remaining / 60
        let seconds = remaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

