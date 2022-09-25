//
//  ContentView.swift
//  WeightTracker
//
//  Created by James Maguire on 14/09/2022.
//

import SwiftUI
import CoreBluetooth
import Charts

struct WeightTrackerView: View {
    @Binding var dataStore: DataStore
    @Environment(\.scenePhase) private var scenePhase
    let saveAction: ()->Void
    @State private var isPresentingEditView = false
    
    func deleteDay(at offsets: IndexSet) {
        dataStore.entries.remove(atOffsets: offsets)
        saveAction()
    }
    
    func getStrideCount(entries: [WeightEntry]) -> Int {
        if entries.count < 5 {
            return 1
        }
        
        return entries.count / 5
    }
    
    var body: some View {
        List {
            Section(header: Text("Weight Info")) {
                AverageView(dataStore: dataStore)
            }
            Section(header: Text("Trend")) {
                TrendView(dataStore: dataStore)
                    .frame(height: 100)
                    .padding(.top)
            }
            Section(header: Text("Record Entry")) {
                WeightRecorderView(dataStore: $dataStore, saveAction: saveAction)
            }
            Section(header: Text("Entries")) {
                if dataStore.entries.isEmpty {
                    Label("No entries yet", systemImage: "calendar.badge.exclamationmark")
                }
                ForEach($dataStore.entries) { $entry in
                    NavigationLink(destination: WeightEntryDetailView(dataStore: dataStore, weightEntry: $entry, saveAction: saveAction)) {
                        HStack {
                            Label(entry.date.formatted(date: .long, time: .omitted), systemImage: "calendar")
                        }
                    }
                }
                .onDelete(perform: deleteDay)
            }
        }
        .navigationTitle("Weight Tracker")
        .toolbar {
            Button("User Data") {
                isPresentingEditView = true
            }
        }
        .sheet(isPresented: $isPresentingEditView) {
            NavigationView {
                UserDataEditView(dataStore: $dataStore, saveAction: saveAction)
                    .navigationTitle("User Data")
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                isPresentingEditView = false
                                saveAction()
                            }
                        }
                    }
            }
        }
    }
}

struct WeightEntries_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WeightTrackerView(dataStore: .constant(DataStore.sampleData), saveAction: {})
        }
    }
}
