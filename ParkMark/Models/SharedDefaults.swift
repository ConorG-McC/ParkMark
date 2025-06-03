// SharedDefaults.swift
// Reads/writes `[CarPark]` and tracks the “active” CarPark in App Group UserDefaults.

import Foundation

struct SharedDefaults {
    static let appGroupID = "group.com.cgmcc.ParkMark"
    
    /// Always returns a non‐nil UserDefaults: either the App Group suite or `.standard` if unavailable.
    static var suite: UserDefaults {
        UserDefaults(suiteName: appGroupID) ?? .standard
    }
    
    // MARK: – Keys
    private static let carParksKey = "CarParks"
    private static let activeParkIDKey = "ActiveCarParkID"
    
    // MARK: – Stored array of CarPark
    static var carParks: [CarPark] {
        get {
            guard let data = suite.data(forKey: carParksKey) else { return [] }
            let decoder = JSONDecoder()
            return (try? decoder.decode([CarPark].self, from: data)) ?? []
        }
        set {
            let encoder = JSONEncoder()
            if let data = try? encoder.encode(newValue) {
                suite.set(data, forKey: carParksKey)
            }
        }
    }
    
    // MARK: – Which CarPark is “active” right now?
    static var activeCarParkID: UUID? {
        get {
            guard let str = suite.string(forKey: activeParkIDKey) else { return nil }
            return UUID(uuidString: str)
        }
        set {
            if let uuid = newValue {
                suite.set(uuid.uuidString, forKey: activeParkIDKey)
            } else {
                suite.removeObject(forKey: activeParkIDKey)
            }
        }
    }
    
    /// Computed property to fetch or update the `activeCarPark` in one shot.
    static var activeCarPark: CarPark? {
        get {
            guard let id = activeCarParkID else { return nil }
            return carParks.first { $0.id == id }
        }
        set {
            guard let updated = newValue else {
                activeCarParkID = nil
                return
            }
            var parks = carParks
            if let idx = parks.firstIndex(where: { $0.id == updated.id }) {
                parks[idx] = updated
            } else {
                parks.append(updated)
            }
            carParks = parks
            activeCarParkID = updated.id
        }
    }
}

// MARK: – Helper functions for generating floor lists

/// Generates `[String]` from `start` → `end` inclusive, where each is a single uppercase letter.
/// Example: `alphaFloorCodes(from: "A", to: "R")` → `["A","B",…,"R"]`.
func alphaFloorCodes(from start: Character, to end: Character) -> [String] {
    guard
        let sAsc = start.uppercased().first?.asciiValue,
        let eAsc = end.uppercased().first?.asciiValue,
        sAsc <= eAsc
    else {
        return []
    }
    return (sAsc...eAsc).compactMap { codePoint in
        guard let scalar = UnicodeScalar(UInt32(codePoint)) else { return nil }
        return String(scalar)
    }
}

/// Generates `[String]` from `from` → `to` inclusive, where each is a positive integer.
/// Example: `numericFloorCodes(from: 1, to: 12)` → `["1","2",…,"12"]`.
func numericFloorCodes(from: Int, to: Int) -> [String] {
    guard from > 0, to >= from else { return [] }
    return (from...to).map { String($0) }
}
