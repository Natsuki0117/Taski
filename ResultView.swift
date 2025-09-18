//
//  UserAnalysisView.swift
//  Taski
//
//  Created by 金井菜津希 on 2025/09/18.
//

import SwiftUI

// MARK: - ユーザー分析ビュー
struct UserAnalysisView: View {
    @Environment(\.dismiss) var dismiss
    var analysis: UserAnalysis

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text("あなたのタスク傾向")
                        .font(.largeTitle.bold())
                        .padding(.top)

                    CardView(title: "集中できる場所", content: analysis.locationFocus)

                    CardView(title: "時間差の傾向") {
                        ForEach(analysis.timeRank.sorted(by: { $0.value > $1.value }), id: \.key) { key, value in
                            HStack {
                                Text(key)
                                Spacer()
                                Text("\(value)回")
                            }
                        }
                    }

                    CardView(title: "難易度の傾向") {
                        ForEach(analysis.difficultyRank.sorted(by: { $0.value > $1.value }), id: \.key) { key, value in
                            HStack {
                                Text(key)
                                Spacer()
                                Text("\(value)回")
                            }
                        }
                    }
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
    }
}
