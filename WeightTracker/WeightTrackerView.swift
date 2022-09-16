//
//  ContentView.swift
//  WeightTracker
//
//  Created by James Maguire on 14/09/2022.
//

import SwiftUI
import CoreBluetooth

struct WeightTrackerView: View {
    @Binding var entries: [WeightEntry]
    @Environment(\.scenePhase) private var scenePhase
    @ObservedObject var bleProvider: BleProvider
    let saveAction: ()->Void
    @State private var wasRecorded = false
    
    private var sevenDayAverage: Double {
        let after = Date(timeIntervalSinceNow: -(day * 7))
        let filteredEntries = entries.filter{ $0.date > after }
        return filteredEntries.map{ $0.weight }.reduce(0, +) / Double(filteredEntries.count)
    }
    
    private var sevenDayMin: Double {
        let after = Date(timeIntervalSinceNow: -(day * 7))
        let filteredEntries = entries.filter{ $0.date > after }
        if let min = filteredEntries.map({ $0.weight }).min() { return min }
        return 0
    }
    
    private func recordWeight(weight: Double) {
        let newEntry = WeightEntry(date: Date(), weight: weight)
        if let idx = entries.firstIndex(where: { $0.date.formatted(date: .abbreviated, time: .omitted) == Date().formatted(date: .abbreviated, time: .omitted) }) {
            entries[idx] = newEntry
        } else {
            entries.append(WeightEntry(date: Date(), weight: weight))
        }
        saveAction()
        wasRecorded = true
        Task {
            await delayText()
        }
    }
    
    private func delayText() async {
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        wasRecorded = false
    }
    
    var body: some View {
        List {
            Section(header: Text("Weight Info")) {
                HStack {
                    Label("7 Day Average", systemImage: "chart.bar")
                    Spacer()
                    Text(String(format: "%.2f kg", sevenDayAverage))
                }
                HStack {
                    Label("7 Day Minimum", systemImage: "arrowtriangle.down")
                    Spacer()
                    Text(String(format: "%.2f kg", sevenDayMin))
                }
            }
            Section(header: Text("Record Entry")) {
                if wasRecorded {
                    Label("Entry Recorded!", systemImage: "checkmark")
                } else if bleProvider.weightIsStable {
                    Button(action: {
                        recordWeight(weight: bleProvider.weight)
                    }) {
                        Label("Record weight", systemImage: "plus")
                    }
                } else if bleProvider.isConnected {
                    Label("Stabalizing...", systemImage: "waveform.path.ecg")
                } else if bleProvider.isConnecting {
                    Label("Connecting...", systemImage: "clock")
                } else {
                    Button(action: {
                        bleProvider.startScanning()
                    }) {
                        Label("Connect to scale", systemImage: "wifi.router")
                    }
                }
            }
            Section(header: Text("Entries")) {
                if entries.isEmpty {
                    Label("No entries yet", systemImage: "calendar.badge.exclamationmark")
                }
                ForEach(entries) { entry in
                    NavigationLink(destination: WeightEntryDetailView(entry: entry)) {
                        HStack {
                            Label(entry.date.formatted(date: .long, time: .omitted), systemImage: "calendar")
                        }
                    }
                }
            }
        }
        .navigationTitle("Weight Tracker")
        .onChange(of: scenePhase) { phase in
            if phase == .inactive { bleProvider.reset() }
        }
    }
}

struct WeightEntries_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WeightTrackerView(entries: .constant(WeightEntry.sampleData), bleProvider: BleProvider(),
                              saveAction: {})
        }
    }
}
