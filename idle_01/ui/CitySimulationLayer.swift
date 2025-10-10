import SwiftUI

struct CitySimulationLayer: View {
    let scenario: ScenarioRun
    @State private var pulse = false

    var body: some View {
        ZStack {
            // Background changes with progress
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    Color.blue.opacity(0.4 + scenario.progress * 0.6)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Central pulse that “breathes” with simulation
            Circle()
                .fill(Color.cyan.opacity(0.4 + scenario.progress * 0.4))
                .frame(width: pulse ? 200 : 240, height: pulse ? 200 : 240)
                .blur(radius: 80)
                .animation(.easeInOut(duration: 1.2).repeatForever(), value: pulse)
                .onAppear { pulse.toggle() }

            VStack {
                Spacer()
                Text("The city is self-aware.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 12)
            }
        }
    }
}
