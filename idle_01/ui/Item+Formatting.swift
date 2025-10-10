import Foundation

extension Item {
    var formattedTimestamp: String {
        timestamp.formatted(date: .numeric, time: .standard)
    }
}
