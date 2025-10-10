import SwiftUI

struct ItemRow: View {
    let item: Item
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Title and Badge
            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title ?? "Untitled")
                        .font(.body)
                        .lineLimit(2)
                    
                    Text(item.formattedTimestamp)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                ItemTypeBadge(itemType: item.itemType, urgency: item.urgency, compact: true)
            }
            
            // Urgency Bar
            if item.urgency > 0.5 {
                HStack(spacing: 4) {
                    Image(systemName: "timer")
                        .font(.caption2)
                        .foregroundColor(urgencyColor)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.gray.opacity(0.2))
                            
                            RoundedRectangle(cornerRadius: 2)
                                .fill(urgencyColor)
                                .frame(width: geometry.size.width * item.urgency)
                        }
                    }
                    .frame(height: 4)
                    
                    Text("\(Int(item.urgency * 100))%")
                        .font(.caption2)
                        .foregroundColor(urgencyColor)
                        .frame(width: 35, alignment: .trailing)
                }
            }
            
            // Response indicator
            if item.response != nil {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption2)
                        .foregroundColor(.green)
                    Text("Answered")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
        .contextMenu {
            Button("Delete", role: .destructive, action: onDelete)
        }
    }
    
    private var urgencyColor: Color {
        if item.urgency > 0.8 { return .red }
        else if item.urgency > 0.6 { return .orange }
        else { return .yellow }
    }
}
