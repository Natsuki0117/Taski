//
//  TaskRowView.swift
//  Taski
//
//  Created by 金井菜津希 on 2025/09/15.
//

import SwiftUI



struct TaskRowView: View {
    var task: TaskItem

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(task.name)
                    .font(.headline)
                    .bold()
                    .foregroundColor(.primary)
                Text("\(task.doTime)分 • \(task.dueDate.formatted(.dateTime.month().day()))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(task.rank)
                .font(.caption)
                .bold()
                .padding(.vertical, 6)
                .padding(.horizontal, 14)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: rankGradient(task.rank)),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .clipShape(Capsule())
                .shadow(color: rankShadowColor(task.rank).opacity(0.4), radius: 4, x: 0, y: 2)
        }
        .padding(8)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.15))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }

    private func rankGradient(_ rank: String) -> [Color] {
        switch rank {
        case "S": return [Color.purple.opacity(0.7), Color.pink.opacity(0.7)]
        case "A": return [Color.blue.opacity(0.7), Color.cyan.opacity(0.7)]
        case "B": return [Color.green.opacity(0.7), Color.mint.opacity(0.7)]
        case "C": return [Color.orange.opacity(0.7), Color.yellow.opacity(0.7)]
        default: return [Color.gray.opacity(0.5), Color.gray.opacity(0.3)]
        }
    }

    private func rankShadowColor(_ rank: String) -> Color {
        switch rank {
        case "S": return .pink
        case "A": return .cyan
        case "B": return .green
        case "C": return .orange
        default: return .gray
        }
    }
}
