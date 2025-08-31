import SwiftUI
import Combine
import Firebase

struct TimerView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var taskStore: TaskStore  // 共有データ
    @State private var counter: Int = 0
    @State private var timerCancellable: AnyCancellable?
    @State private var isFinished: Bool = false
    @State private var showCompletionCheck = false

    var task: TaskItem
    var countTo: Int { task.doTime * 60 } // 分 → 秒

    var body: some View {
        ZStack {
            MeshGradient(width: 3, height: 3, points: [
                [0, 0],   [0.5, 0],   [1.0, 0],
                [0, 0.5], [0.5, 0.5], [1.0, 0.5],
                [0, 1.0], [0.5, 1.0], [1.0, 1.0]
            ], colors: [
                .color1, .color1, .color1,
                .color1, .color1, .color2,
                .color2, .color2, .color2
            ])
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 15)
                        .frame(width: 260, height: 260)

                    Circle()
                        .trim(from: 0, to: CGFloat(counter) / CGFloat(countTo))
                        .stroke(
                            AngularGradient(gradient: Gradient(colors: [.timer2, .timer]),
                                            center: .center),
                            style: StrokeStyle(lineWidth: 15, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 260, height: 260)
                        .animation(.easeInOut(duration: 0.5), value: counter)

                    Text(timeString())
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .monospacedDigit()
                }

                if !isFinished {
                    Button("時間内に終わった！") {
                        markTaskCompleted()
                    }
                    .frame(width: 180, height: 48)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(24)
                    .shadow(radius: 5)
                }

                Button("戻る") {
                    dismiss()
                }
                .frame(width: 180, height: 48)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(24)
                .shadow(radius: 5)
                .padding(.top, 20)
            }
        }
        .onAppear { startTimer() }
        .onDisappear { timerCancellable?.cancel() }
        .alert("タスクは終わりましたか？", isPresented: $showCompletionCheck) {
            Button("はい") { markTaskCompleted() }
            Button("いいえ", role: .cancel) { dismiss() }
        }
    }

    func startTimer() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if counter < countTo {
                    counter += 1
                } else {
                    timerCancellable?.cancel()
                    isFinished = true
                    showCompletionCheck = true
                }
            }
    }

    func markTaskCompleted() {
        if let id = task.id {
            let db = Firestore.firestore()
            db.collection("tasks").document(id).updateData([
                "isCompleted": true
            ]) { error in
                if let error = error {
                    print("Error updating task: \(error.localizedDescription)")
                } else {
                    // ローカルのデータも更新
                    if let index = taskStore.tasks.firstIndex(where: { $0.id == task.id }) {
                        taskStore.tasks[index].isCompleted = true
                    }
                    dismiss()
                }
            }
        }
    }


    func timeString() -> String {
        let remaining = max(countTo - counter, 0)
        let minutes = remaining / 60
        let seconds = remaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

