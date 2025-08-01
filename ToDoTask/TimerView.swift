import SwiftUI
import FirebaseFirestore

let timer = Timer
    .publish(every: 1, on: .main, in: .common)
    .autoconnect()

// タイマーのビュー
struct TimerView: View {
    var counter: Int
    var countTo: Int

    var body: some View {
        VStack {
            Text(counterToMinutes())
                .font(.custom("Avenir Next", size: 60))
                .fontWeight(.black)
        }
    }

    func counterToMinutes() -> String {
        let currentTime = countTo - counter
        let seconds = currentTime % 60
        let minutes = Int(currentTime / 60)
        return "\(minutes):\(seconds < 10 ? "0" : "")\(seconds)"
    }
}

// 進行状況を示すトラック（背景）
struct ProgressTrack: View {
    var body: some View {
        Circle()
            .fill(Color.clear)
            .frame(width: 250, height: 250)
            .overlay(
                Circle().stroke(Color.black, lineWidth: 15)
            )
    }
}

// 進行状況を示すバー（動く部分）
struct ProgressBar: View {
    var counter: Int
    var countTo: Int

    var body: some View {
        Circle()
            .fill(Color.clear)
            .frame(width: 250, height: 250)
            .overlay(
                Circle().trim(from: 0, to: progress())
                    .stroke(
                        style: StrokeStyle(
                            lineWidth: 15,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                    .foregroundColor(completed() ? Color.purple : Color.pink)
                    .animation(.easeInOut(duration: 0.2), value: progress())
            )
    }


    func completed() -> Bool {
        return progress() == 1
    }

    func progress() -> CGFloat {
        return CGFloat(counter) / CGFloat(countTo)
    }
}

// カウントダウン全体のビュー
struct CountdownView: View {
    @State var counter: Int = 0
    @State var showConfetti: Bool = false
    var task: TaskItem // デコードされたタスク
    var countTo: Int { task.doTime } // タスクの doTime を使用

    var body: some View {
        VStack {
            ZStack {
                ProgressTrack()
                ProgressBar(counter: counter, countTo: countTo)
                TimerView(counter: counter, countTo: countTo)
            }
        }
        }
    }

//preview
struct CountdownView_Previews: PreviewProvider {
    @State var counter: Int = 0
    static var previews: some View {
        VStack{
            CountdownView(task: TaskItem(name: "Sample Task", slider: "50", title: "Example", dueDate: Date(), doTime: 10))
            
            Button(action: {
                
                print("ボタン押せてるよーーー")
            },label:{
                Text("aaa")
                    .frame(width: UIScreen.main.bounds.size.width / 8 * 4,
                                   height: UIScreen.main.bounds.size.width / 14 * 1)            })
    //            button size
            .padding()
            .accentColor(Color.white)
            .background(Color.blue)
            .cornerRadius(50)
            .shadow(color: Color.purple, radius: 15, x: 0, y: 5)
            
//この辺でボタンの装飾の処理できる、適当につけてる
        }
    }

}

// タスクを表すデータモデル
struct TodoTaskItem: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String
    var name: String
    var slider: String
    var title: String
    var dueDate: Date
    var doTime: Int

    init(id: String? = nil, userId: String = "", name: String, slider: String, title: String, dueDate: Date, doTime: Int) {
        self.id = id
        self.userId = userId
        self.name = name
        self.slider = slider
        self.title = title
        self.dueDate = dueDate
        self.doTime = doTime
    }
}

// Firestore から TaskItem をデコードする関数
func decodeTaskItem(from data: [String: Any]) throws -> TodoTaskItem {
    let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .secondsSince1970 // Firestore のデフォルト形式
    return try decoder.decode(TodoTaskItem.self, from: jsonData)
}

