import SwiftUI

struct DetailView: View {
    enum Destination {
        case item
        case dashboard
        case model
    }

    let item: Item?
    @State private var destination: Destination = .dashboard
    @State private var responseText: String = ""
    @State private var showResponseConfirmation: Bool = false

    var body: some View {
        Group {
            if let it = item {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Item Type Badge
                        ItemTypeBadge(itemType: it.itemType, urgency: it.urgency)
                        
                        // Title
                        Text(it.title ?? "Unknown")
                            .font(.largeTitle)
                            .bold()
                        
                        // Time Information
                        HStack(spacing: 24) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Created").font(.caption).foregroundStyle(.secondary)
                                Text(it.timestamp, style: .date)
                            }
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Elapsed").font(.caption).foregroundStyle(.secondary)
                                TimelineView(.periodic(from: .now, by: 0.1)) { _ in
                                    Text(it.elapsedString).monospacedDigit()
                                }
                            }
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Remaining").font(.caption).foregroundStyle(.secondary)
                                TimelineView(.periodic(from: .now, by: 1.0)) { _ in
                                    Text(it.remainingString).monospacedDigit()
                                }
                            }
                        }
                        
                        Divider()
                        
                        // Response Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your Response")
                                .font(.headline)
                            
                            if let existingResponse = it.response {
                                // Show existing response
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                        Text("You responded:")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Text(existingResponse)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.green.opacity(0.1))
                                        .cornerRadius(8)
                                }
                            } else {
                                // Input field for new response
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("The city is waiting for your input...")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .italic()
                                    
                                    TextField("Your answer or guidance...", text: $responseText, axis: .vertical)
                                        .textFieldStyle(.roundedBorder)
                                        .lineLimit(3...6)
                                    
                                    Button(action: submitResponse) {
                                        Label("Submit Response", systemImage: "paperplane.fill")
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .disabled(responseText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                                    
                                    if showResponseConfirmation {
                                        HStack {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                            Text("Response recorded. The city acknowledges your guidance.")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        .transition(.opacity)
                                    }
                                }
                            }
                        }
                        
                        if let s = it.scenario {
                            Divider()
                            Text("Scenario").font(.headline)
                            HStack {
                                Text(s.name)
                                Spacer()
                                ProgressView(value: s.progress).frame(width: 160)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding()
                }
            } else {
                // Fallback if nothing selected
                VStack(spacing: 12) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                    Text("Select a task to view details.")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .onAppear {
            if let it = item {
                responseText = it.response ?? ""
            }
        }
    }
    
    private func submitResponse() {
        guard let it = item, 
              let scenario = it.scenario,
              !responseText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        scenario.respondToRequest(it, response: responseText)
        
        withAnimation {
            showResponseConfirmation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showResponseConfirmation = false
            }
        }
    }
}




#Preview {
    DetailView(item: nil)
}
