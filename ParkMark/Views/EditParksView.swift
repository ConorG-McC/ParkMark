import SwiftUI

struct EditParksView: View {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: ParkingViewModel
    
    // Local copy of park names for inline editing
    @State private var editedNames: [UUID: String] = [:]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.carParks) { park in
                    HStack {
                        // Inline rename: TextField bound to a local dictionary
                        TextField(
                            "Park Name",
                            text: Binding(
                                get: { editedNames[park.id] ?? park.name },
                                set: { newValue in editedNames[park.id] = newValue }
                            )
                        )
                        .autocapitalization(.words)
                        .disableAutocorrection(true)
                        
                        Spacer()
                        
                        // If this is active park, show a checkmark
                        if park.id == viewModel.activePark?.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.accentColor)
                        }
                    }
                    .onDisappear {
                        // When the row disappears (or user finishes editing), push changes back
                        if let newName = editedNames[park.id]?.trimmingCharacters(in: .whitespacesAndNewlines),
                           !newName.isEmpty,
                           newName != park.name
                        {
                            var updated = park
                            updated.name = newName
                            viewModel.updatePark(updated)
                        }
                    }
                    .onTapGesture {
                        // Tap to make this park active immediately
                        viewModel.setActivePark(park)
                    }
                }
                .onDelete(perform: deleteParks)
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Edit Parks")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
            .onAppear {
                // Seed editedNames with current names
                viewModel.carParks.forEach { park in
                    editedNames[park.id] = park.name
                }
            }
        }
    }

    private func deleteParks(at offsets: IndexSet) {
        for idx in offsets {
            let park = viewModel.carParks[idx]
            viewModel.removePark(park)
        }
    }
}
