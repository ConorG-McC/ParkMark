// CarPark.swift
// Model for a single Car Park

import Foundation

/// A single “Car Park” data model.
/// - `name`: User‐visible park name (e.g. “Work” or “Shops”).
/// - `floorCodes`: The exact array of labels for this park (e.g. `["A","B",…,"R"]` or `["1","2",…,"12"]` or a custom list).
/// - `selectedFloor`: Which label is currently saved (must be one of `floorCodes`, or empty if none chosen).
/// - `lastSaved`: When `selectedFloor` was last written.
struct CarPark: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var floorCodes: [String]
    var selectedFloor: String
    var lastSaved: Date

    init(
        id: UUID = .init(),
        name: String,
        floorCodes: [String],
        selectedFloor: String = "",
        lastSaved: Date = .distantPast
    ) {
        self.id = id
        self.name = name
        self.floorCodes = floorCodes
        self.selectedFloor = selectedFloor
        self.lastSaved = lastSaved
    }
}
