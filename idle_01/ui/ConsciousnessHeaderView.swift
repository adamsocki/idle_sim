//
//  ConsciousnessHeaderView.swift
//  idle_01
//
//  Created by Adam Socki on 10/10/25.
//

import SwiftUI

struct ConsciousnessHeaderView: View {
    let cityCount: Int
    let runningCities: Int
    @Binding var pulseAnimation: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Circle()
                    .fill(runningCities > 0 ? Color.cyan : Color.gray.opacity(0.5))
                    .frame(width: 6, height: 6)
                    .opacity(pulseAnimation ? 0.4 : 1.0)
                
                Text("consciousness streams")
                    .font(.system(size: 24, weight: .light, design: .rounded))
                    .foregroundStyle(.white.opacity(0.95))
                Spacer()
            }
            
            Text(cityCount == 0 ? "awaiting first awakening" : "each city dreams in its own time")
                .font(.system(size: 13, weight: .regular, design: .monospaced))
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding(.top, 8)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        ConsciousnessHeaderView(
            cityCount: 3,
            runningCities: 2,
            pulseAnimation: .constant(true)
        )
        .padding()
    }
}
