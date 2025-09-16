//
//  AddToDoView.swift
//  Taski
//
//  Created by 金井菜津希 on 2024/08/21.
//

import SwiftUI
import FirebaseAuth

struct AddToDoView: View {
    @State var title = ""
    @State var dueDate = Date()
    @State var moodLevel: Int = 5
    @State private var doTime: String = ""
    @Binding var selectedIndex: Int
    @EnvironmentObject var taskStore: TaskStore
    @Environment(\.dismiss) private var dismiss
    var onSave: (() -> Void)?

    var body: some View {
        ZStack {
            MeshView()
                .scrollContentBackground(.hidden)

            ScrollView {
                VStack(spacing: 24) {
                    Text("AddTask")
                        .font(.system(.title, design: .serif))
                        .foregroundColor(.primary)

//                    こっからタスク追加
                    VStack(alignment: .leading, spacing: 8) {
                        Text("✒️ タイトル").font(.headline).foregroundColor(.gray)
                        TextField("例:数学の課題", text: $title)
                            .font(.title3)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .foregroundColor(.primary)
                    }
                    .cardStyle()

                    // 期限
                    VStack(alignment: .leading) {
                        Text("📅 期限を選ぼう").foregroundColor(.gray).font(.headline)
                        DatePicker("", selection: $dueDate, displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                    }
                    .cardStyle()

                    // 難易度
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
                        Text("⏰ かかる時間（分）").font(.headline).foregroundColor(.gray)
                        TextField("30", text: $doTime)
                            .font(.title3)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .foregroundColor(.primary)
                    }
                    .cardStyle()

                    // 保存ボタン
                    Button(action: saveTask) {
                        Text("保存する")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(20)
                            .shadow(radius: 5)
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
        }
    }

//  保存ボタン押した時の処理
    func saveTask() {
        Task {
            let newTask = TaskItem(
                userId: Auth.auth().currentUser?.uid ?? "",
                name: title,
                slider: String(moodLevel),
                title: title,
                dueDate: dueDate,
                doTime: Int(doTime) ?? 30
            )
            do {
                try await taskStore.addTask(newTask)
                // 保存後のUI更新
                await MainActor.run {
                    // フィールドを初期化
                    title = ""
                    doTime = ""
                    moodLevel = 5
                    dueDate = Date()
                    
                    selectedIndex = 0
                    dismiss()
                }
            } catch {
                print("タスク保存に失敗: \(error)")
            }
        }
    }

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
