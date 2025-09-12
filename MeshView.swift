//
//  MeshView.swift
//  Taski
//
//  Created by 金井菜津希 on 2025/08/09.
//

import SwiftUI

struct MeshView: View {
    var body: some View {
        
        MeshGradient(width: 3, height: 3, points: [
                        [0, 0],   [0.5, 0],   [1.0, 0],
                        [0, 0.5], [0.5, 0.5], [1.0, 0.5],
                        [0, 1.0], [0.5, 1.0], [1.0, 1.0]
                    ], colors: [
                        .color1, .color1, .color1,
                        .color1, .color1, .color2,
                        .color2, .color2, .color2
                    ])
                    .ignoresSafeArea()
        
        
    }
}

extension View {
    func appBackground() -> some View {
        self.background(
            MeshView()
                .ignoresSafeArea()
        )
    }
}


extension View {
    func cardStyle() -> some View {
        self
            .foregroundColor(Color.white.opacity(0.2))
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
            .padding(.horizontal)
    }
}


