//
//  TerminalToggle.swift
//  idle_01
//
//  Terminal-styled toggle switch with ASCII art ON/OFF states
//

import SwiftUI

struct TerminalToggle: View {
    let label: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 12) {
            Text(label.uppercased())
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundStyle(Color.green.opacity(0.8))
                .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: { isOn.toggle() }) {
                HStack(spacing: 4) {
                    Text("[")
                        .foregroundStyle(Color.green.opacity(0.6))

                    Text(isOn ? "ON " : "OFF")
                        .frame(width: 28, alignment: .center)
                        .foregroundStyle(isOn ? Color.green.opacity(0.9) : Color.green.opacity(0.5))

                    Text("]")
                        .foregroundStyle(Color.green.opacity(0.6))
                }
                .font(.system(size: 10, weight: .bold, design: .monospaced))
            }
            .buttonStyle(.plain)
            .help("Toggle \(label)")
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.green.opacity(isOn ? 0.05 : 0.02))
        )
    }
}

#Preview {
    VStack(spacing: 12) {
        TerminalToggle(label: "CRT Effect", isOn: .constant(true))
        TerminalToggle(label: "Auto Save", isOn: .constant(false))
        TerminalToggle(label: "Debug Mode", isOn: .constant(true))
    }
    .padding()
    .background(Color.black)
}
