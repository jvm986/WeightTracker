//
//  WeightEntryDetailView.swift
//  WeightTracker
//
//  Created by James Maguire on 14/09/2022.
//

import SwiftUI

struct WeightEntryDetailView: View {
    var entry: WeightEntry
    
    var body: some View {
        VStack {
            Text(entry.date, style: .date)
                .font(.title2)
            Text(entry.date, style: .time)
                .font(.callout)
            Text(String(format: "%.2f kg", entry.weight))
                .font(.largeTitle)
                .padding(.top)
        }
    }
}

struct WeightEntryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        WeightEntryDetailView(entry: WeightEntry.sampleData[0])
    }
}
