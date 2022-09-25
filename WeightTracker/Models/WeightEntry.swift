//
//  WeightEntry.swift
//  WeightTracker
//
//  Created by James Maguire on 14/09/2022.
//

import Foundation

let day = 86400.0
let hour = 3600.0

enum Gender: String, CaseIterable, Identifiable, Codable {
    case male = "male"
    case female = "female"
    
    var name: String {
        rawValue.capitalized
    }
    var id: String {
        name
    }
}

struct UserData: Codable {
    var dob: Date
    var gender: Gender
    var height: Double
    
    init(dob: Date, gender: Gender, height: Double) {
        self.dob = dob
        self.gender = gender
        self.height = height
    }
    
    var age: Int {
        let calendar = Calendar.current
        
        let ageComponents = calendar.dateComponents([.year], from: self.dob, to: Date())
        return ageComponents.year!
    }
}

struct DataStore: Codable {
    var entries: [WeightEntry]
    var userData: UserData
    
    init(entries: [WeightEntry], userData: UserData) {
        self.entries = entries
        self.userData = userData
    }
    
    func sevenDayWeight(date: Date) -> Double {
        let after = date.addingTimeInterval(-(day * 7))
        let filteredEntries = self.entries.filter{ $0.date > after  && $0.date <= date}
        let weight = filteredEntries.map{ $0.averageWeight }.reduce(0, +) / Double(filteredEntries.count)
        return weight
    }
    
    func sevenDayImpedence(date: Date) -> Double {
        let after = date.addingTimeInterval(-(day * 7))
        let filteredEntries = self.entries.filter{ $0.date > after  && $0.date <= date}
        let impedence = filteredEntries.map{ $0.averageImpedence }.reduce(0, +) / Double(filteredEntries.count)
        return impedence
    }
    
    func sevenDayFat(date: Date) -> Double {
        let after = date.addingTimeInterval(-(day * 7))
        let filteredEntries = self.entries.filter{ $0.date > after  && $0.date <= date}
        let impedence = filteredEntries.map{ $0.averageImpedence }.reduce(0, +) / Double(filteredEntries.count)
        let weight = filteredEntries.map{ $0.averageWeight }.reduce(0, +) / Double(filteredEntries.count)
        
        return fatFromImpedenceAndWeight(impedence: impedence, weight: weight)
    }
    
    func fatFromImpedenceAndWeight(impedence: Double, weight: Double) -> Double {
        // TODO: https://github.com/lolouk44/xiaomi_mi_scale/tree/master/src for tables
        let coefficient = 1.0
        let const = 0.8
        
        var lbm = (self.userData.height * 9.058 / 100) * (self.userData.height / 100)
        lbm += (weight * 0.32 + 12.226)
        lbm -= impedence * 0.0068
        lbm -= Double(self.userData.age) * 0.0542
        
        let fat = (1 - (((lbm - const) * coefficient) / weight)) * 100
        
        return fat
    }
    
    func lastDays(days: Int) -> [WeightEntry] {
        let after = Date().addingTimeInterval(-(day * Double(days)))
        return self.entries.filter{ Date() > after && $0.date <= Date()}
    }
    
    mutating func recordEntry(entry: Entry) -> Void {
        if let idx = self.entries.firstIndex(where: { $0.date.formatted(date: .abbreviated, time: .omitted) == entry.date.formatted(date: .abbreviated, time: .omitted) }) {
            self.entries[idx].entries.append(entry)
        } else {
            if let idx = self.entries.lastIndex(where: { entry.date < $0.date }) {
                print("older")
                self.entries.insert(WeightEntry(date: entry.date, entries: [entry]), at: idx + 1)
            } else {
                self.entries.insert(WeightEntry(date: entry.date, entries: [entry]), at: 0)
            }
        }
    }
    
    var dateRange: Int {
        if self.entries.count > 1 {
            return Calendar.current.dateComponents([.day], from: self.entries.last!.date, to: self.entries.first!.date).day!
        }
        return 1
    }
}

struct Entry: Codable, Identifiable {
    let id: UUID
    var date: Date
    var weight: Double
    var impedence: Double
    
    init(id: UUID = UUID(), date: Date, weight: Double, impedence: Double) {
        self.id = id
        self.date = date
        self.weight = weight
        self.impedence = impedence
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
    
    var averageImpedence: Double {
        entries.map{ $0.impedence }.reduce(0, +) / Double(entries.count)
    }
}

extension DataStore {
    static let sampleData = generateSampleData()
}

func generateSampleData() -> DataStore {
    let calendar = Calendar(identifier: .gregorian)
    let components = DateComponents(year: 1986, month: 10, day: 16, hour: 0, minute: 0, second: 0)
    let dob = calendar.date(from: components)!
    
    let userData = UserData(dob: dob, gender: Gender.male, height: 193)
    
    var entries = [WeightEntry]()
    for i in 1...30 {
        entries.append(
            WeightEntry(
                date: Date(timeIntervalSinceNow: -day * Double(i)),
                entries: [
                    Entry(
                        date: Date(timeIntervalSinceNow: -day * Double(i)),
                        weight: Double.random(in: 90...100),
                        impedence: Double.random(in: 150...300)
                    )
                ]
            )
        )
    }
    
    let sampleData = DataStore(entries: entries, userData: userData)
    
    return sampleData
}
