import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ParkingViewModel()
    @State private var showingAddSheet = false
    @State private var showingEditParks = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: — Header
                headerView
                    .background(Color(.secondarySystemBackground))

                Divider()

                // MARK: — Main Content
                if viewModel.activePark == nil {
                    // No parks at all
                    VStack {
                        Spacer()
                        Text("No Car Parks.\nTap + to add one.")
                            .font(.subheadline.italic())
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))
                } else {
                    // There is at least one park
                    VStack {
                        Spacer()

                        floorGridCard

                        Spacer()

                        bottomSection
                            .padding(.horizontal)
                            .padding(.bottom, 24)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))
                }
            }
            .ignoresSafeArea(edges: .top)
            // ─────────────── Attach sheets here ─────────────────
            .sheet(isPresented: $showingAddSheet) {
                AddCarParkView(isPresented: $showingAddSheet) { name, scheme in
                    switch scheme {
                    case .alphabetical(let start, let end):
                        let codes = alphaFloorCodes(from: start, to: end)
                        viewModel.addPark(named: name, floorCodes: codes)
                    case .numeric(let startNum, let endNum):
                        let codes = numericFloorCodes(from: startNum, to: endNum)
                        viewModel.addPark(named: name, floorCodes: codes)
                    case .custom(let rawList):
                        let codes = rawList
                            .split(separator: ",")
                            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                            .filter { !$0.isEmpty }
                        viewModel.addPark(named: name, floorCodes: codes)
                    }
                }
            }
            .sheet(isPresented: $showingEditParks) {
                EditParksView(isPresented: $showingEditParks, viewModel: viewModel)
            }
        }
    }

    // MARK: — Header View
    private var headerView: some View {
        ZStack {
            // Centered Title
            Text("ParkMark")
                .font(.title.weight(.semibold))
                .foregroundColor(.primary)

            HStack {
                // Park Picker on the left
                if !viewModel.carParks.isEmpty {
                    Menu {
                        ForEach(viewModel.carParks) { park in
                            Button {
                                viewModel.setActivePark(park)
                            } label: {
                                Text(park.name)
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(viewModel.activePark?.name ?? "No Park")
                                .font(.title2.weight(.medium))
                            Image(systemName: "chevron.down")
                                .font(.subheadline)
                        }
                        .foregroundColor(.accentColor)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color(.systemBackground).opacity(0.001))
                    }
                    .buttonStyle(.borderless)
                    .padding(.leading, 12)
                } else {
                    Text("No Park")
                        .font(.body.weight(.medium))
                        .foregroundColor(.secondary)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .padding(.leading, 12)
                }

                Spacer()

                // Add + Edit Buttons on the right
                HStack(spacing: 10) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                            .padding(5)
                    }
                    .buttonStyle(.borderless)
                    .accessibilityLabel("Add Car Park")

                    Button {
                        showingEditParks = true
                    } label: {
                        Image(systemName: "pencil.circle.fill")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                            .padding(5)
                    }
                    .buttonStyle(.borderless)
                    .accessibilityLabel("Edit Car Parks")
                }
                .padding(.trailing, 12)
            }
        }
        .frame(height: 44 + safeAreaTopInset())
        .padding(.top, safeAreaTopInset() - 4)
    }

    // MARK: — Floor Grid Card (centered)
    private var floorGridCard: some View {
        Group {
            if let active = viewModel.activePark, !active.floorCodes.isEmpty {
                VStack(spacing: 16) {
                    // Centered “Select Floor”
                    Text("Select Floor")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)

                    // Grid of floor buttons
                    LazyVGrid(columns: Self.gridColumns, spacing: 12) {
                        ForEach(active.floorCodes, id: \.self) { code in
                            FloorButton(
                                code: code,
                                isSelected: viewModel.stagedFloor == code
                            ) {
                                viewModel.stagedFloor = code
                            }
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.secondarySystemBackground))
                )
                .padding(.horizontal)
            } else {
                Text("No floors configured.")
                    .font(.subheadline.italic())
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.secondarySystemBackground))
                    )
                    .padding(.horizontal)
            }
        }
    }

    // MARK: — Bottom Section (Save Button + “Last saved” below)
    private var bottomSection: some View {
        VStack(spacing: 8) {
            Button(action: viewModel.saveFloor) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Save Floor")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(viewModel.canSave ? Color.accentColor : Color.gray.opacity(0.4))
                .cornerRadius(10)
            }
            .disabled(!viewModel.canSave)

            if let active = viewModel.activePark,
               !active.selectedFloor.isEmpty
            {
                Text("Last saved: \(Self.savedFormatter.string(from: active.lastSaved))")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: — Helpers

    private func safeAreaTopInset() -> CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.windows.first }
            .first?
            .safeAreaInsets.top ?? 0
    }

    private static let gridColumns = Array(
        repeating: GridItem(.flexible(), spacing: 10),
        count: 4
    )

    private static let savedFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .none
        df.timeStyle = .short
        return df
    }()
}
