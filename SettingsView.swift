import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings = SettingsManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Speed Unit")
                    .font(.headline)
                Picker("", selection: $settings.preferredUnit) {
                    ForEach(SpeedUnit.allCases) { unit in
                        Text(unit.rawValue).tag(unit)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .labelsHidden()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Text Size")
                    .font(.headline)
                Picker("", selection: $settings.preferredTextSize) {
                    ForEach(TextSize.allCases) { size in
                        Text(size.rawValue).tag(size)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .labelsHidden()
            }
            
            Text("Adjust the speed unit and the font size of the menu bar text.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(24)
        .frame(width: 380)
    }
}
