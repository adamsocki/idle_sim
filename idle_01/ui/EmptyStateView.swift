//
//  EmptyStateView.swift
//  idle_01
//
//  Created by Adam Socki on 10/10/25.
//

import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 40, weight: .thin))
                .foregroundStyle(.white.opacity(0.3))
                .padding(.top, 60)
            
            VStack(spacing: 8) {
                Text("The void awaits consciousness")
                    .font(.system(size: 16, weight: .light, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
                
                Text("Begin the first awakening")
                    .font(.system(size: 12, weight: .regular, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.4))
            }
            .padding(.bottom, 60)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(.white.opacity(0.15), lineWidth: 1))
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        EmptyStateView()
            .padding()
    }
}
