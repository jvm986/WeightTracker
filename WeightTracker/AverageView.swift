//
//  AverageView.swift
//  WeightTracker
//
//  Created by James Maguire on 24/09/2022.
//

import SwiftUI

struct AverageView: View {
    var dataStore: DataStore
    
    var body: some View {
        HStack {
            Label("Weight", systemImage: "scalemass")
            Spacer()
            if dataStore.sevenDayWeight(date: Date()) > 0 {
                Text(String(format: "%.2f kg", dataStore.sevenDayWeight(date: Date())))
            } else {
                Text("No data yet")
            }
        }
        HStack {
            Label("Body Fat", systemImage: "percent")
            Spacer()
            if dataStore.sevenDayImpedence(date: Date()) > 0 {
                Text(String(format: "%.2f %%", dataStore.fatFromImpedenceAndWeight(impedence: dataStore.sevenDayImpedence(date: Date()), weight: dataStore.sevenDayWeight(date: Date()))))
            } else {
                Text("No data yet")
            }
        }
    }
}

struct AverageView_Previews: PreviewProvider {
    static var previews: some View {
        AverageView(dataStore: DataStore.sampleData)
    }
}
