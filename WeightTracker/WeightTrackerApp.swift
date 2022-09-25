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
    @State private var errorWrapper: ErrorWrapper?
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                WeightTrackerView(dataStore: $store.dataStore) {
                    Task {
                        do {
                            try await EntryStore.save(entries: store.dataStore)
                        } catch {
                            errorWrapper = ErrorWrapper(error: error, guidance: "Try again later.")
                        }
                    }
                }
            }
            .task {
                do {
                    store.dataStore = try await EntryStore.load()
                } catch {
                    errorWrapper = ErrorWrapper(error: error, guidance: "Will load sample data and continue.")
                }
            }
            .sheet(item: $errorWrapper, onDismiss: {
                store.dataStore = DataStore.sampleData
            }) { wrapper in
                ErrorView(errorWrapper: wrapper)
            }
        }
    }
}
