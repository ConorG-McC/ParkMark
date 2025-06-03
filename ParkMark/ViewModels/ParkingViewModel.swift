import Foundation
import SwiftUI
import WidgetKit

final class ParkingViewModel: ObservableObject {
    // MARK: – Published properties for UI binding
    @Published var carParks: [CarPark] = []
    @Published var activePark: CarPark? = nil
    @Published var stagedFloor: String = ""

    init() {
        // Load the array of parks and the active park off the main thread
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let parks = SharedDefaults.carParks
            let active = SharedDefaults.activeCarPark  // May be nil if none saved

            DispatchQueue.main.async {
                self.carParks = parks
                self.activePark = active
                if let current = active {
                    self.stagedFloor = current.selectedFloor
                } else if let first = parks.first {
                    self.setActivePark(first)
                }
                // If both parks and active are nil/empty, UI will show “No Car Parks.”
            }
        }
    }

    /// Returns true if `stagedFloor` differs from the active park’s saved floor.
    var canSave: Bool {
        guard let active = activePark else { return false }
        return !stagedFloor.isEmpty && stagedFloor != active.selectedFloor
    }

    /// Writes `stagedFloor` into `activePark.selectedFloor` + updates `lastSaved`, then refreshes widgets.
    func saveFloor() {
        guard var active = activePark else { return }

        active.selectedFloor = stagedFloor
        active.lastSaved = Date()

        SharedDefaults.activeCarPark = active

        // Update published properties on main thread
        DispatchQueue.main.async {
            self.activePark = active
            // Reload only home-screen widgets
            WidgetCenter.shared.reloadTimelines(ofKind: "ParkMarkSmallWidget")
            WidgetCenter.shared.reloadTimelines(ofKind: "ParkMarkMediumWidget")
        }
    }

    /// Switches the “activePark” to the given park and updates `stagedFloor`.
    func setActivePark(_ park: CarPark) {
        activePark = park
        stagedFloor = park.selectedFloor
        SharedDefaults.activeCarPark = park
    }

    /// Creates and persists a new CarPark with a given name and floorCodes, then makes it active.
    func addPark(named name: String, floorCodes: [String]) {
        var parks = SharedDefaults.carParks
        let newPark = CarPark(name: name, floorCodes: floorCodes)
        parks.append(newPark)
        SharedDefaults.carParks = parks

        DispatchQueue.main.async {
            self.carParks = parks
            self.setActivePark(newPark)
        }
    }

    /// Updates an existing CarPark (e.g. to rename it or modify floorCodes).
    func updatePark(_ park: CarPark) {
        var parks = SharedDefaults.carParks
        if let idx = parks.firstIndex(where: { $0.id == park.id }) {
            parks[idx] = park
            SharedDefaults.carParks = parks
            DispatchQueue.main.async {
                self.carParks = parks
                if self.activePark?.id == park.id {
                    self.activePark = park
                    self.stagedFloor = park.selectedFloor
                }
            }
        }
    }

    /// Removes a CarPark. If it was active, picks another or sets `activePark` to nil if none remain.
    func removePark(_ park: CarPark) {
        var parks = SharedDefaults.carParks
        parks.removeAll { $0.id == park.id }
        SharedDefaults.carParks = parks

        DispatchQueue.main.async {
            self.carParks = parks

            if self.activePark?.id == park.id {
                if parks.isEmpty {
                    // No parks left at all → set everything to nil/empty
                    self.activePark = nil
                    self.stagedFloor = ""
                    SharedDefaults.activeCarPark = nil
                } else {
                    // Switch to first park in the list
                    self.setActivePark(parks[0])
                }
            }
        }
    }
}
