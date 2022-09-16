//
//  WeightEntry.swift
//  WeightTracker
//
//  Created by James Maguire on 14/09/2022.
//

import Foundation

let day = 86400.0

struct WeightEntry: Codable, Identifiable {
    let id: UUID
    var date: Date
    var weight: Double
    
    init(id: UUID = UUID(), date: Date, weight: Double) {
        self.id = id
        self.date = date
        self.weight = weight
    }
}

extension WeightEntry {
    static let sampleData: [WeightEntry] = [
        WeightEntry(date: Date(), weight: 95.1),
        WeightEntry(date: Date(timeIntervalSinceNow: -day), weight: 95.2)
    ]
}

