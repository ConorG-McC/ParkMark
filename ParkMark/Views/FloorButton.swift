import SwiftUI

// MARK: — Equatable FloorButton (small grid cell)
struct FloorButton: View, Equatable {
    let code: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(code)
                .font(.title2.weight(.medium))
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.blue.opacity(0.8) : Color(UIColor.systemGray5))
                )
                .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }

    static func == (lhs: FloorButton, rhs: FloorButton) -> Bool {
        lhs.code == rhs.code && lhs.isSelected == rhs.isSelected
    }
}

