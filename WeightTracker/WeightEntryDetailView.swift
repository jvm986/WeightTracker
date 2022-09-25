//
//  WeightEntryDetailView.swift
//  WeightTracker
//
//  Created by James Maguire on 14/09/2022.
//

import SwiftUI

struct WeightEntryDetailView: View {
    var dataStore: DataStore
    @Binding var weightEntry: WeightEntry
    let saveAction: ()->Void
    
    func deleteEntry(at offsets: IndexSet) {
        if weightEntry.entries.count > 1 {
            weightEntry.entries.remove(atOffsets: offsets)
            saveAction()
        }
    }
    
    var body: some View {
        List {
            Section(header: Text("Entries")) {
                ForEach(weightEntry.entries) { entry in
                    HStack {
                        Label(entry.date.formatted(date: .omitted, time: .standard), systemImage: "clock")
                        Spacer()
                        Text(String(format: "%.2f kg / %.2f %%",
                                    weightEntry.averageWeight,
                                    dataStore.fatFromImpedenceAndWeight(impedence: weightEntry.averageImpedence, weight: weightEntry.averageWeight)
                                   ))
                    }
                }
                .onDelete(perform: deleteEntry)
            }
        }
        .navigationTitle(weightEntry.date.formatted(date: .long, time: .omitted))
    }
}

struct WeightEntryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        WeightEntryDetailView(dataStore: DataStore.sampleData, weightEntry: .constant(DataStore.sampleData.entries[0]), saveAction: {})
    }
}
