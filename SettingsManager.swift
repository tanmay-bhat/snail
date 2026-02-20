import Foundation
import Combine
import SwiftUI

enum SpeedUnit: String, CaseIterable, Identifiable {
    case mbps = "Mbps (Megabits)"
    case MBps = "MB/s (Megabytes)"
    
    var id: String { self.rawValue }
    
    func format(bytesPerSecond: Double) -> String {
        switch self {
        case .MBps:
            return String(format: "%.1f MB/s", bytesPerSecond / 1_000_000)
        case .mbps:
            return String(format: "%.1f Mbps", (bytesPerSecond * 8) / 1_000_000)
        }
    }
    
    func formatTotal(bytes: UInt64) -> String {
        let megabytes = Double(bytes) / 1_000_000
        if megabytes > 1000 {
            return String(format: "%.2f GB", megabytes / 1000)
        } else {
            return String(format: "%.1f MB", megabytes)
        }
    }
}

enum TextSize: String, CaseIterable, Identifiable {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
    
    var id: String { self.rawValue }
    
    var nsFont: NSFont {
        switch self {
        case .small: return NSFont.monospacedDigitSystemFont(ofSize: 10, weight: .regular)
        case .medium: return NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        case .large: return NSFont.monospacedDigitSystemFont(ofSize: 14, weight: .regular)
        }
    }
}

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    @AppStorage("preferredSpeedUnit") var preferredUnit: SpeedUnit = .MBps
    @AppStorage("preferredTextSize") var preferredTextSize: TextSize = .medium
}
