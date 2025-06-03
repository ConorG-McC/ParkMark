import SwiftUI

struct AddCarParkView: View {
    @Binding var isPresented: Bool
    var onCreate: (_ name: String, _ scheme: FloorScheme) -> Void

    @State private var name: String = ""
    @State private var schemeType: SchemeType = .alphabetical
    @State private var alphaStart: String = "A"
    @State private var alphaEnd: String = "R"
    @State private var numStart: String = "1"
    @State private var numEnd: String = "12"
    @State private var customRawList: String = ""

    enum SchemeType: String, CaseIterable, Identifiable {
        case alphabetical = "Alphabetical"
        case numeric = "Numeric"
        case custom = "Custom"
        var id: Self { self }
    }

    enum FloorScheme {
        case alphabetical(start: Character, end: Character)
        case numeric(start: Int, end: Int)
        case custom(raw: String)
    }

    private var canCreate: Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return false }

        switch schemeType {
        case .alphabetical:
            guard
                let startChar = alphaStart.uppercased().first,
                let endChar = alphaEnd.uppercased().first,
                startChar.isLetter, endChar.isLetter,
                let sAsc = startChar.asciiValue,
                let eAsc = endChar.asciiValue,
                sAsc <= eAsc
            else { return false }
            return true

        case .numeric:
            guard
                let sNum = Int(numStart),
                let eNum = Int(numEnd),
                sNum > 0, eNum >= sNum
            else { return false }
            return true

        case .custom:
            let codes = customRawList
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            return !codes.isEmpty
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                // MARK: – Park Name
                Section(header: Text("Park Name")) {
                    TextField("e.g. Work, Shops, Airport", text: $name)
                        .autocapitalization(.words)
                }

                // MARK: – Scheme Type
                Section(header: Text("Floor Scheme")) {
                    Picker("Scheme Type", selection: $schemeType) {
                        ForEach(SchemeType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.bottom, 8)

                    // Alphabetical controls
                    if schemeType == .alphabetical {
                        HStack {
                            Text("Start Letter:")
                            Spacer()
                            TextField("A", text: $alphaStart)
                                .frame(width: 50)
                                .autocapitalization(.allCharacters)
                                .disableAutocorrection(true)
                                .textFieldStyle(.roundedBorder)
                        }
                        HStack {
                            Text("End Letter:")
                            Spacer()
                            TextField("R", text: $alphaEnd)
                                .frame(width: 50)
                                .autocapitalization(.allCharacters)
                                .disableAutocorrection(true)
                                .textFieldStyle(.roundedBorder)
                        }
                        Text("Enter single letters (A–Z), and Start ≤ End.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    // Numeric controls
                    if schemeType == .numeric {
                        HStack {
                            Text("Start Number:")
                            Spacer()
                            TextField("1", text: $numStart)
                                .frame(width: 60)
                                .keyboardType(.numberPad)
                                .textFieldStyle(.roundedBorder)
                        }
                        HStack {
                            Text("End Number:")
                            Spacer()
                            TextField("12", text: $numEnd)
                                .frame(width: 60)
                                .keyboardType(.numberPad)
                                .textFieldStyle(.roundedBorder)
                        }
                        Text("Enter positive integers (Start ≤ End).")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    // Custom controls
                    if schemeType == .custom {
                        TextField("B2, B1, G, 1, 2, 3", text: $customRawList)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                        Text("Comma-separate labels (at least one).")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Add Car Park")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        switch schemeType {
                        case .alphabetical:
                            let startChar = alphaStart.uppercased().first!
                            let endChar = alphaEnd.uppercased().first!
                            onCreate(trimmedName, .alphabetical(start: startChar, end: endChar))

                        case .numeric:
                            let sNum = Int(numStart)!
                            let eNum = Int(numEnd)!
                            onCreate(trimmedName, .numeric(start: sNum, end: eNum))

                        case .custom:
                            onCreate(trimmedName, .custom(raw: customRawList))
                        }
                        isPresented = false
                    }
                    .disabled(!canCreate)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
}
