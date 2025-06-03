import SwiftUI
import WidgetKit

struct ParkingMediumView: View {
    let entry: ParkingEntry

    private static let timeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .none
        df.timeStyle = .short
        return df
    }()

    var body: some View {
        Color.clear
            .containerBackground(for: .widget) {
                Color.clear
            }
            .overlay {
                VStack(spacing: 12) {
                    // Park name
                    Text(entry.parkName)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.secondary)

                    HStack(spacing: 16) {
                        // Car icon
                        Image(systemName: "car.fill")
                            .font(.title)
                            .foregroundColor(.accentColor)

                        // Floor code
                        Text(entry.floorCode)
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.primary)
                    }

                    // Last saved or “Not saved”
                    if entry.lastSaved > Date.distantPast {
                        Text("Last saved \(Self.timeFormatter.string(from: entry.lastSaved))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Not saved")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(12)
            }
    }
}

struct ParkMarkMediumWidget: Widget {
    let kind: String = "ParkMarkMediumWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ParkingProvider()) { entry in
            ParkingMediumView(entry: entry)
        }
        .configurationDisplayName("ParkMark (Medium)")
        .description("Show active car park name, floor code, and last saved (medium).")
        .supportedFamilies([.systemMedium])
    }
}
