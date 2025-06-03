import Foundation
import WidgetKit

struct ParkingEntry: TimelineEntry {
    let date: Date
    let parkName: String
    let floorCode: String
    let lastSaved: Date
}
