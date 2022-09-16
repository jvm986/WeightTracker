//
//  Helpers.swift
//  WeightTracker
//
//  Created by James Maguire on 16/09/2022.
//

import Foundation

func bits(fromBytes data: Data) -> [[Int]] {
    var bitArray = [[Int]]()
    for byte in data {
        var byte = byte
        var bits = [Int](repeating: .zero, count: 8)
        for i in 0..<8 {
            let currentBit = byte & 0x01
            if currentBit != 0 {
                bits[i] = 1
            }
            
            byte >>= 1
        }
        bitArray.append(bits)
    }
    return bitArray
}


