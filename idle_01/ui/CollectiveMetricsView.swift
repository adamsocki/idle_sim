//
//  CollectiveMetricsView.swift
//  idle_01
//
//  Created by Adam Socki on 10/10/25.
//

import SwiftUI

struct CollectiveMetricsView: View {
    let totalCities: Int
    let awakeCities: Int
    let averageProgress: Double
    
    var body: some View {
        HStack(spacing: 12) {
            MetricPillView(
                value: "\(totalCities)",
                label: "cities",
                color: .purple
            )
            
            MetricPillView(
                value: "\(awakeCities)",
                label: "awake",
                color: .cyan
            )
            
            if averageProgress > 0 {
                MetricPillView(
                    value: "\(Int(averageProgress * 100))%",
                    label: "awareness",
                    color: .blue
                )
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        CollectiveMetricsView(
            totalCities: 5,
            awakeCities: 3,
            averageProgress: 0.75
        )
    }
}
