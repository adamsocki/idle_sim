//
//  TerminalSlider.swift
//  idle_01
//
//  Terminal-styled slider with ASCII art value bar
//

import SwiftUI

struct TerminalSlider: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let unit: String?

    init(
        label: String,
        value: Binding<Double>,
        range: ClosedRange<Double> = 0...100,
        step: Double = 1,
        unit: String? = nil
    ) {
        self.label = label
        self._value = value
        self.range = range
        self.step = step
        self.unit = unit
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Label and value
            HStack {
                Text(label.uppercased())
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color.green.opacity(0.8))

                Spacer()

                Text(formattedValue)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color.green.opacity(0.9))
            }

            // ASCII slider bar
            HStack(spacing: 0) {
                Text("[")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(Color.green.opacity(0.6))

                sliderBar

                Text("]")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(Color.green.opacity(0.6))
            }

            // Slider control
            Slider(value: $value, in: range, step: step)
                .tint(Color.green.opacity(0.6))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.green.opacity(0.02))
        )
    }

    private var sliderBar: some View {
        GeometryReader { geometry in
            let percentage = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
            let barWidth = geometry.size.width
            let fillCount = Int(percentage * 20) // 20 character bar
            let emptyCount = 20 - fillCount

            HStack(spacing: 0) {
                Text(String(repeating: "█", count: fillCount))
                    .foregroundStyle(Color.green.opacity(0.7))
                Text(String(repeating: "░", count: emptyCount))
                    .foregroundStyle(Color.green.opacity(0.3))
            }
            .font(.system(size: 10, design: .monospaced))
            .frame(width: barWidth)
        }
        .frame(height: 16)
    }

    private var formattedValue: String {
        if let unit = unit {
            return "\(Int(value))\(unit)"
        } else if step < 1 {
            return String(format: "%.2f", value)
        } else {
            return String(format: "%.0f", value)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        TerminalSlider(label: "Coherence", value: .constant(75), range: 0...100, unit: "%")
        TerminalSlider(label: "Font Size", value: .constant(12), range: 8...24, unit: "pt")
        TerminalSlider(label: "Trust Level", value: .constant(0.85), range: 0...1, step: 0.01)
        TerminalSlider(label: "Population", value: .constant(5000), range: 0...10000, step: 100)
    }
    .padding()
    .background(Color.black)
}
