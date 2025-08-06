import SwiftUI
import Combine

struct CountdownView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var counter: Int = 0
    @State private var timerCancellable: AnyCancellable?
    @State private var isFinished: Bool = false

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
                .color1, .color2, .color2,
              .color2, .color2, .color2
            ])
            .ignoresSafeArea()

            VStack(spacing: 40) {
                ZStack {
                    // トラック
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 15)
                        .frame(width: 260, height: 260)

                    // プログレスバー
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

                    // 時間表示
                    Text(timeString())
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .monospacedDigit()
                }

                if isFinished {
                    Text("おつかれさま！")
                        .font(.title2)
                        .foregroundColor(.purple)
                }

                Button(action: {
                    dismiss()
                }) {
                    Text("戻る")
                        .frame(width: 180, height: 48)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(24)
                        .shadow(radius: 5)
                }
                .padding(.top, 20)
            }
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timerCancellable?.cancel()
        }
    }

    // タイマー開始処理
    func startTimer() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if counter < countTo {
                    counter += 1
                } else {
                    timerCancellable?.cancel()
                    isFinished = true
                }
            }
    }

    // 残り時間を「mm:ss」形式に変換
    func timeString() -> String {
        let remaining = max(countTo - counter, 0)
        let minutes = remaining / 60
        let seconds = remaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

