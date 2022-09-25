//
//  ManualEntryView.swift
//  WeightTracker
//
//  Created by James Maguire on 25/09/2022.
//

import SwiftUI

struct ManualEntryView: View {
    @Binding var entry: Entry
    
    var body: some View {
        Form {
            Section(header: Text("Manual Entry")) {
                DatePicker("Date", selection: $entry.date)
                HStack {
                    Slider(value: $entry.weight, in: 85...100, step: 0.1) {
                        Text("Weight")
                    }
                    .accessibilityValue("\(entry.weight) kg")
                    Spacer()
                    Text(String(format: "%.1f kg", entry.weight))
                        .accessibilityHidden(true)
                }
                HStack {
                    Slider(value: $entry.impedence, in: 180...200, step: 0.1) {
                        Text("Impedence")
                    }
                    .accessibilityValue("\(entry.impedence) z")
                    Spacer()
                    Text(String(format: "%.1f z", entry.impedence))
                        .accessibilityHidden(true)
                }
            }
        }
    }
}

struct ManualEntryView_Previews: PreviewProvider {
    static var previews: some View {
        ManualEntryView(entry: .constant(DataStore.sampleData.entries[0].entries[0]))
    }
}
