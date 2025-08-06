//
//  AddToDoView.swift
//  ToDoTask
//
//  Created by 金井菜津希 on 2024/08/21.
//
import SwiftUI

struct AddToDoView: View {
    
    @State var title = ""
    @State var dueDate = Date()
    @State var moodLevel: Int = 5
    @State private var doTime: String = "30"
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // 背景グラデーション
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
            
            ScrollView {
                VStack(spacing: 24) {
           
                    Group {
                        // タイトル入力
                        TextFieldCard(title: "タイトル", text: $title, placeholder: "例: 数学の宿題")

                        // 期限入力
                        VStack(alignment: .leading) {
                            Text("📅 期限を選ぼう")
                                .font(.headline)
                            DatePicker("", selection: $dueDate, displayedComponents: .date)
                                .datePickerStyle(GraphicalDatePickerStyle())
                        }
                        .cardStyle()
                    }
                    
                    // タスクの重さ
                    VStack(spacing: 8) {
                        Text("⚖️ タスクの重さ")
                            .font(.headline)
                        Slider(value: Binding(
                            get: { Double(moodLevel) },
                            set: { moodLevel = Int($0.rounded()) }
                        ), in: 0...10, step: 1)
                        
                        Text(moodEmoji(for: moodLevel))
                            .font(.system(size: 40))
                        Text("レベル: \(moodLevel)")
                            .font(.subheadline)
                    }
                    .cardStyle()

                    // かかる時間
                    VStack(alignment: .leading, spacing: 8) {
                        Text("⏰ かかる時間（分）")
                            .font(.headline)
                        TextField("30", text: $doTime)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .cardStyle()

                    // 保存ボタン
                    Button(action: {
                        FirestoreClient.add(taskItem: TaskItem(
                            name: title,
                            slider: String(moodLevel),
                            title: "Task",
                            dueDate: dueDate,
                            doTime: Int(doTime) ?? 30
                        ))
                        dismiss()
                    }) {
                        Text("保存する")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.test1)
                            .cornerRadius(20)
                            .shadow(radius: 5)
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
        }
    }
    
    // 絵文字で気分を表現
    func moodEmoji(for level: Int) -> String {
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

// 共通のカードスタイル修飾子
extension View {
    func cardStyle() -> some View {
        self
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
            .padding(.horizontal)
    }
}

// テキストフィールド用の小コンポーネント
struct TextFieldCard: View {
    var title: String
    @Binding var text: String
    var placeholder: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("🖋️ \(title)")
                .font(.headline)
            TextField(placeholder, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .cardStyle()
    }
}
