//
//  WeightEntryDetailView.swift
//  WeightTracker
//
//  Created by James Maguire on 14/09/2022.
//

import SwiftUI

struct WeightEntryDetailView: View {
    var weightEntry: WeightEntry
    
    var body: some View {
                List {
                    Section(header: Text("Entries")) {
                        ForEach(weightEntry.entries) {entry in
                        HStack {
                            Label(entry.date.formatted(date: .omitted, time: .shortened), systemImage: "clock")
                            Spacer()
                            Text(String(format: "%.2f kg", entry.weight))
                        }
                    }
                }
            }
                .navigationTitle(weightEntry.date.formatted(date: .long, time: .omitted))
    }
}

struct WeightEntryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        WeightEntryDetailView(weightEntry: WeightEntry.sampleData[0])
    }
}
