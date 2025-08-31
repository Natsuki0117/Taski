//
//  PieChartView.swift
//  ToDoTask
//
//  Created by 金井菜津希 on 2025/08/31.
//

import SwiftUI

struct PieChartView: View {
    var data: [(rank: String, count: Int, color: Color)]
    
    var total: Int {
        data.map { $0.count }.reduce(0, +)
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<data.count, id: \.self) { index in
                    let startAngle = angle(at: index)
                    let endAngle = angle(at: index + 1)
                    
                    Path { path in
                        path.move(to: CGPoint(x: geo.size.width/2, y: geo.size.height/2))
                        path.addArc(center: CGPoint(x: geo.size.width/2, y: geo.size.height/2),
                                    radius: geo.size.width/2,
                                    startAngle: startAngle,
                                    endAngle: endAngle,
                                    clockwise: false)
                    }
                    .fill(data[index].color)
                }
            }
        }
    }
    
    private func angle(at index: Int) -> Angle {
        let value = Double(data.prefix(index).map { $0.count }.reduce(0, +)) / Double(total)
        return .degrees(360 * value - 90)
    }
}
