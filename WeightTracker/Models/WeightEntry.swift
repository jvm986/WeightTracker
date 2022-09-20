//
//  WeightEntry.swift
//  WeightTracker
//
//  Created by James Maguire on 14/09/2022.
//

import Foundation

let day = 86400.0
let hour = 3600.0

struct Entry: Codable, Identifiable {
    let id: UUID
    var date: Date
    var weight: Double
    
    init(id: UUID = UUID(), date: Date, weight: Double) {
        self.id = id
        self.date = date
        self.weight = weight
    }
}

struct WeightEntry: Codable, Identifiable {
    let id: UUID
    var date: Date
    var entries: [Entry]
    
    init(id: UUID = UUID(), date: Date, entries: [Entry]) {
        self.id = id
        self.date = date
        self.entries = entries
    }
    
    var averageWeight: Double {
        entries.map{ $0.weight }.reduce(0, +) / Double(entries.count)
    }
}

extension WeightEntry {
    static let sampleData: [WeightEntry] = [
        WeightEntry(date: Date(), entries: [
            Entry(date: Date(), weight: 95.2),
            Entry(date: Date(timeIntervalSinceNow: hour), weight: 95.3)
        ]),
        WeightEntry(date: Date(timeIntervalSinceNow: -day), entries: [
            Entry(date: Date(timeIntervalSinceNow: -day), weight: 95.2),
            Entry(date: Date(timeIntervalSinceNow: -day + hour), weight: 95.3)
        ])
    ]
}

