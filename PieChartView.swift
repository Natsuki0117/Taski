//
//  PieChartView.swift
//  Taski
//
//  Created by 金井菜津希 on 2025/08/31.
//
import SwiftUI

struct PieChartView: View {
    var data: [(rank: String, count: Int, color: Color)]
    
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
                        path.move(to: CGPoint(x: geo.size.width/2, y: geo.size.height/2))
                        path.addArc(center: CGPoint(x: geo.size.width/2, y: geo.size.height/2),
                                    radius: geo.size.width/2,
                                    startAngle: startAngle,
                                    endAngle: endAngle,
                                    clockwise: false)
                    }
                    .fill(data[index].color)
                    
                    // ラベル
                    if data[index].count > 0 {
                        Text(data[index].rank)
                            .font(.title2)
                            .foregroundColor(.white)
                            .position(x: geo.size.width/2 + cos(midAngle.radians) * geo.size.width/4,
                                      y: geo.size.height/2 + sin(midAngle.radians) * geo.size.height/4)
                    }
                }
            }
        }
    }
    
    private func angle(at index: Int) -> Angle {
        let value = Double(data.prefix(index).map { $0.count }.reduce(0, +)) / Double(max(total,1))
        return .degrees(360 * value - 90)
    }
}
