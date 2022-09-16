//
//  WeightTrackerApp.swift
//  WeightTracker
//
//  Created by James Maguire on 14/09/2022.
//

import SwiftUI

@main
struct WeightTrackerApp: App {
    @StateObject private var store = EntryStore()
    @ObservedObject var bleProvider = BleProvider()
    @State private var errorWrapper: ErrorWrapper?
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                WeightTrackerView(entries: $store.entries, bleProvider: bleProvider) {
                    Task {
                        do {
                            try await EntryStore.save(entries: store.entries)
                        } catch {
                            errorWrapper = ErrorWrapper(error: error, guidance: "Try again later.")
                        }
                    }
                }
            }
            .task {
                do {
                    store.entries = try await EntryStore.load()
                } catch {
                    errorWrapper = ErrorWrapper(error: error, guidance: "Will load sample data and continue.")
                }
            }
            .sheet(item: $errorWrapper, onDismiss: {
                store.entries = WeightEntry.sampleData
            }) { wrapper in
                ErrorView(errorWrapper: wrapper)
            }
        }
    }
}
