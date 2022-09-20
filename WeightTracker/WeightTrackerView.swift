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
    @ObservedObject var scaleProvider: ScaleProvider
    let saveAction: ()->Void
    @State private var wasRecorded = false
    
    private var sevenDayAverage: Double {
        let after = Date(timeIntervalSinceNow: -(day * 7))
        let filteredEntries = entries.filter{ $0.date > after }
        return filteredEntries.map{ $0.averageWeight }.reduce(0, +) / Double(filteredEntries.count)
    }
    
    private var sevenDayMin: Double {
        let after = Date(timeIntervalSinceNow: -(day * 7))
        let filteredEntries = entries.filter{ $0.date > after }
        if let min = filteredEntries.map({ $0.averageWeight }).min() { return min }
        return 0
    }
    
    private func recordWeight(weight: Double) {
        let newEntry = Entry(date: Date(), weight: weight)
        if let idx = entries.firstIndex(where: { $0.date.formatted(date: .abbreviated, time: .omitted) == Date().formatted(date: .abbreviated, time: .omitted) }) {
            entries[idx].entries.append(newEntry)
        } else {
            entries.append(WeightEntry(date: Date(), entries: [newEntry]))
        }
        saveAction()
        scaleProvider.turnOffDisplay()
        wasRecorded = true
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            wasRecorded = false
        }
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
                } else if scaleProvider.weightIsStable {
                    Button(action: {
                        recordWeight(weight: scaleProvider.weight)
                    }) {
                        Label("Record weight", systemImage: "plus")
                    }
                    .buttonStyle(.borderless)
                } else if scaleProvider.isConnected {
                    Label("Stabalizing...", systemImage: "waveform.path.ecg")
                } else if scaleProvider.isConnecting {
                    Label("Connecting...", systemImage: "clock")
                } else {
                    Button(action: {
                        scaleProvider.startScanning()
                    }) {
                        Label("Connect to scale", systemImage: "wifi.router")
                    }
                    .buttonStyle(.borderless)
                }
            }
            Section(header: Text("Entries")) {
                if entries.isEmpty {
                    Label("No entries yet", systemImage: "calendar.badge.exclamationmark")
                }
                ForEach(entries.reversed()) { entry in
                    NavigationLink(destination: WeightEntryDetailView(weightEntry: entry)) {
                        HStack {
                            Label(entry.date.formatted(date: .long, time: .omitted), systemImage: "calendar")
                        }
                    }
                }
            }
        }
        .navigationTitle("Weight Tracker")
        .onChange(of: scenePhase) { phase in
            if phase == .inactive { scaleProvider.reset() }
        }
    }
}

struct WeightEntries_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WeightTrackerView(entries: .constant(WeightEntry.sampleData), scaleProvider: ScaleProvider(),
                              saveAction: {})
        }
    }
}
