//
//  EntryStore.swift
//  WeightTracker
//
//  Created by James Maguire on 16/09/2022.
//

import Foundation
import SwiftUI

class EntryStore: ObservableObject {
    @Published var dataStore: DataStore = DataStore(entries: [], userData: UserData(dob: Date(), gender: Gender.male, height: 100))
    
    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                       in: .userDomainMask,
                                       appropriateFor: nil,
                                       create: false)
            .appendingPathComponent("entries.data")
    }
    
    static func load() async throws -> DataStore {
        try await withCheckedThrowingContinuation { continuation in
            load { result in
                switch result {
                case .failure(let error):
                    continuation.resume(throwing: error)
                case .success(let scrums):
                    continuation.resume(returning: scrums)
                }
            }
        }
    }
    
    static func load(completion: @escaping (Result<DataStore, Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try fileURL()
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                    DispatchQueue.main.async {
                        completion(.success(DataStore(entries: [], userData: UserData(dob: Date(), gender: Gender.male, height: 100))))
                    }
                    return
                }
                let dailyScrums = try JSONDecoder().decode(DataStore.self, from: file.availableData)
                DispatchQueue.main.async {
                    completion(.success(dailyScrums))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    @discardableResult
    static func save(entries: DataStore) async throws -> Int {
        try await withCheckedThrowingContinuation { continuation in
            save(entries: entries) { result in
                switch result {
                case .failure(let error):
                    continuation.resume(throwing: error)
                case .success(let entriesSaved):
                    continuation.resume(returning: entriesSaved)
                }
            }
        }
    }
    
    static func save(entries: DataStore, completion: @escaping (Result<Int, Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try JSONEncoder().encode(entries)
                let outfile = try fileURL()
                try data.write(to: outfile)
                DispatchQueue.main.async {
                    completion(.success(entries.entries.count))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}


