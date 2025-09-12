//
//  AddToDoView.swift
//  Taski
//
//  Created by 金井菜津希 on 2024/08/21.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct AddToDoView: View {
    
    @State var title = ""
    @State var dueDate = Date()
    @State var moodLevel: Int = 5
    @State private var doTime: String = ""
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
     
        ZStack {
          MeshView()
                .scrollContentBackground(.hidden)
            ScrollView {
                VStack(spacing: 24) {
                    Text("AddTask")
                        .font(.system(.title, design: .serif))
                        .foregroundColor(.primary)
                    Group {
                        // タイトル入力
                        VStack(alignment: .leading, spacing: 8) {
                            Text("✒️ タイトル")
                                .font(.headline)
                                .foregroundColor(.gray)
                            TextField("例:数学の課題", text: $title)
                                .font(.title3)
                                .foregroundColor(.gray)
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        .cardStyle()                        // 期限入力
                        VStack(alignment: .leading) {
                            Text("📅 期限を選ぼう")
                                .foregroundColor(.gray)
                                .font(.headline)
                            DatePicker("", selection: $dueDate, displayedComponents: .date)
                                .datePickerStyle(GraphicalDatePickerStyle())
                        }
                        .cardStyle()
                    }
                                        
                    // タスクの重さ
                    VStack(spacing: 8) {
                       
                            Text("⚖️ タスクの難易度")
                                .foregroundColor(.gray)
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Slider(value: Binding(
                            get: { Double(moodLevel) },
                            set: { moodLevel = Int($0.rounded()) }
                        ), in: 0...10, step: 1)
                        
                        Text(moodEmoji(for: moodLevel))
                            .font(.system(size: 40))
                        Text("レベル: \(moodLevel)")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                    }
                    .cardStyle()

                    // かかる時間
                    VStack(alignment: .leading, spacing: 8) {
                        Text("⏰ かかる時間（分）")
                            .font(.headline)
                            .foregroundColor(.gray)
                        TextField("30",text: $doTime)
                            .font(.title3)
                            .foregroundColor(.gray)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .cardStyle()
                    Button(action: {
                        let client = FirestoreClient()
                        
                        // Firestore に保存するタスク
                        let newTask = TaskItem(
                            userId: Auth.auth().currentUser?.uid ?? "",
                            name: title,
                            slider: String(moodLevel),
                            title: title,
                            dueDate: dueDate,
                            doTime: Int(doTime) ?? 30
                        )
                        
                        client.addTask(task: newTask) { error in
                            if let error = error {
                                print("Error adding task: \(error)")
                            } else {
                                dismiss()
                            }
                        }
                    }) {
                        Text("保存する")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(20)
                            .shadow(radius: 5)
                    }.padding(.horizontal)
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
    
    // スコア化＋ランク計算
    func calculateRank(slider: Int, dueDate: Date) -> String {
        let daysRemaining = Calendar.current.dateComponents([.day], from: Date(), to: dueDate).day ?? 0
        let deadlineScore = max(0, 7 - daysRemaining) // 期限が近いほど点数アップ
        let score = slider * 2 + deadlineScore         // sliderを2倍重み付け
        
        switch score {
        case 15...:
            return "S"
        case 8..<15:
            return "A"
        default:
            return "B"
        }
    }
}

// テキストフィールド用の小コンポーネント
//struct TextFieldCard: View {
//    var title: String
//    @Binding var text: String
//    var placeholder: String
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text("🖋️ \(title)")
//                .font(.headline)
//            TextField(placeholder, text: $text)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//        }
//        .cardStyle()
//    }
//}
//
