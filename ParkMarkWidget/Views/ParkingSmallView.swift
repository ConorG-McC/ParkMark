import WidgetKit
import SwiftUI

struct ParkingSmallView: View {
    let entry: ParkingEntry

    // Reuse a single DateFormatter for “Last Saved”
    private static let timeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .none
        df.timeStyle = .short
        return df
    }()

    var body: some View {
        // 1) Use containerBackground(for: .widget) to let the system draw the proper backdrop.
        //    Inside, we supply Color.clear so the system’s default “Material” shows through.
        Color.clear
            .containerBackground(for: .widget) {
                // You could pick a tinted background if you want, e.g. Color.accentColor.opacity(0.1).
                Color.clear
            }
            .overlay {
                // 2) Your content sits on top of that container background.
                VStack(spacing: 6) {
                    // Park name
                    Text(entry.parkName)
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(.secondary)

                    // Car icon + floor code
                    HStack(spacing: 4) {
                        Image(systemName: "car.fill")
                            .font(.caption)
                            .foregroundColor(.accentColor)
                        Text(entry.floorCode)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                    }

                    // Last saved or “Not saved”
                    if entry.lastSaved > Date.distantPast {
                        Text(Self.timeFormatter.string(from: entry.lastSaved))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Not saved")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(8)
            }
    }
}


struct ParkMarkSmallWidget: Widget {
    let kind: String = "ParkMarkSmallWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ParkingProvider()) { entry in
            ParkingSmallView(entry: entry)
        }
        .configurationDisplayName("ParkMark (Small)")
        .description("Show active car park name, floor code, and last saved (small).")
        .supportedFamilies([.systemSmall])
    }
}
