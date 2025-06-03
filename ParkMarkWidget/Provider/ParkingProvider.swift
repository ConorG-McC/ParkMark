import WidgetKit

// 2) Provider reads from SharedDefaults
struct ParkingProvider: TimelineProvider {
    func placeholder(in context: Context) -> ParkingEntry {
        ParkingEntry(
            date: Date(),
            parkName: "Park",
            floorCode: "—",
            lastSaved: .distantPast
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (ParkingEntry) -> Void) {
        guard let active = SharedDefaults.activeCarPark else {
            completion(
                ParkingEntry(
                    date: Date(),
                    parkName: "Park",
                    floorCode: "—",
                    lastSaved: .distantPast
                )
            )
            return
        }
        let entry = ParkingEntry(
            date: Date(),
            parkName: active.name,
            floorCode: active.selectedFloor.isEmpty ? "—" : active.selectedFloor,
            lastSaved: active.lastSaved
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ParkingEntry>) -> Void) {
        guard let active = SharedDefaults.activeCarPark else {
            let entry = ParkingEntry(
                date: Date(),
                parkName: "Park",
                floorCode: "—",
                lastSaved: .distantPast
            )
            completion(Timeline(entries: [entry], policy: .never))
            return
        }
        let entry = ParkingEntry(
            date: Date(),
            parkName: active.name,
            floorCode: active.selectedFloor.isEmpty ? "—" : active.selectedFloor,
            lastSaved: active.lastSaved
        )
        completion(Timeline(entries: [entry], policy: .never))
    }
}
