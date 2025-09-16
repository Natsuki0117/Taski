//
//  PieChartView.swift
//  Taski
//
//  Created by 金井菜津希 on 2025/08/31.
//
import SwiftUI

struct PieChartView: View {
    // ランクごとのデータ
    var data: [(rank: String, count: Int, color: Color)]
    
    // 合計数
    var total: Int { data.map { $0.count }.reduce(0, +) }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<data.count, id: \.self) { index in
                    let startAngle = angle(at: index)
                    let endAngle = angle(at: index + 1)
                    let midAngle = Angle.degrees((startAngle.degrees + endAngle.degrees) / 2)
                    
                    // スライス
                    Path { path in
                        let center = CGPoint(x: geo.size.width/2, y: geo.size.height/2)
                        path.move(to: center)
                        path.addArc(center: center,
                                    radius: geo.size.width/2,
                                    startAngle: startAngle,
                                    endAngle: endAngle,
                                    clockwise: false)
                    }
                    .fill(data[index].color)
                    
                    // ラベル
                    if data[index].count > 0 {
                        let radius = geo.size.width / 3.2
                        let x = geo.size.width/2 + cos(midAngle.radians) * radius
                        let y = geo.size.height/2 + sin(midAngle.radians) * radius
                        
                        Text(data[index].rank)
                            .font(.title3.bold())
                            .foregroundColor(.gray)
                            .padding(6)
                            .clipShape(Capsule())
                            .position(x: x, y: y)
                    }
                }
            }
        }
    }
    
    // 指定インデックスまでの角度を計算
    private func angle(at index: Int) -> Angle {
        let value = Double(data.prefix(index).map { $0.count }.reduce(0, +)) / Double(max(total, 1))
        return .degrees(360 * value - 90)
    }
}

// MARK: - Preview
struct PieChartView_Previews: PreviewProvider {
    static var previews: some View {
        PieChartView(data: [
            ("S", 3, Color.purple.opacity(0.7)),
            ("A", 4, Color.blue.opacity(0.7)),
            ("B", 2, Color.green.opacity(0.7)),
            ("C", 1, Color.orange.opacity(0.7)),
            ("期限切れ", 1, Color.gray.opacity(0.7))
        ])
        .frame(width: 300, height: 300)
        .padding()
    }
}
