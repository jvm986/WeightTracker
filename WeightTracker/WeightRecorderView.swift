//
//  WeightRecorderView.swift
//  WeightTracker
//
//  Created by James Maguire on 24/09/2022.
//

import SwiftUI

struct WeightRecorderView: View {
    @Binding var dataStore: DataStore
    @State var wasRecorded = false
    @State var newEntry: Entry = Entry(date: Date(), weight: 0.0, impedence: 0.0)
    @State var isPresentingManualEntry = false
    @ObservedObject var scaleProvider = ScaleProvider()
    let saveAction: ()->Void
    
    private func recordWeight(entry: Entry) {
        dataStore.recordEntry(entry: entry)
        saveAction()
        scaleProvider.turnOffDisplay()
        wasRecorded = true
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            wasRecorded = false
        }
    }
    
    var body: some View {
        if wasRecorded {
            Label("Entry Recorded!", systemImage: "checkmark")
        } else if scaleProvider.weightIsStable && scaleProvider.impedenceIsStable {
            Button(action: {
                recordWeight(entry: Entry(date: Date(), weight: scaleProvider.weight, impedence: scaleProvider.impedence))
            }) {
                Label(String("Record weight (\(scaleProvider.impedence))"), systemImage: "plus")
            }
            .buttonStyle(.borderless)
        } else if scaleProvider.weightIsStable && !scaleProvider.impedenceIsStable {
            Label("Reading impedence...", systemImage: "powerplug")
        } else if scaleProvider.isConnected {
            Label("Stabalizing weight...", systemImage: "waveform.path.ecg")
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
        Button(action: {
            isPresentingManualEntry = true
        }) {
            Label(String("Manual Entry"), systemImage: "list.number")
        }
        .sheet(isPresented: $isPresentingManualEntry) {
            NavigationView {
                ManualEntryView(entry: $newEntry)
                    .navigationTitle("Manual Entry")
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                isPresentingManualEntry = false
                                recordWeight(entry: newEntry)
                                saveAction()
                                newEntry = Entry(date: Date(), weight: 0.0, impedence: 0.0)
                            }
                        }
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                isPresentingManualEntry = false
                                newEntry = Entry(date: Date(), weight: 0.0, impedence: 0.0)
                            }
                        }
                    }
            }
        }    }
}


struct WeightRecorderView_Previews: PreviewProvider {
    static var previews: some View {
        WeightRecorderView(dataStore: .constant(DataStore.sampleData), saveAction: {})
    }
}
