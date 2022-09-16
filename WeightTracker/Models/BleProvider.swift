//
//  BluetoothProvider.swift
//  WeightTracker
//
//  Created by James Maguire on 15/09/2022.
//

import Foundation
import CoreBluetooth

// Codes for Mi Body Composition Scale 2
let compositionService = "181B"
let compositionCharacteristic = "2A9C"

let services: [CBUUID] = [CBUUID(string: compositionService)]
let characteristics: [CBUUID] = [CBUUID(string: compositionCharacteristic)]


class BleProvider: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var myCentral: CBCentralManager!
    var myPeripheral: CBPeripheral!
    var myCharacteristic: CBCharacteristic!
    @Published var isSwitchedOn = false
    @Published var isConnecting = false
    @Published var isConnected = false
    @Published var weightIsStable = false
    @Published var impedenceIsStable = false
    @Published var weight: Double = 0.0
    
    override init() {
        super.init()
        myCentral = CBCentralManager(delegate: self, queue: nil)
        myCentral.delegate = self
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            isSwitchedOn = true
        }
        else {
            isSwitchedOn = false
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        stopScanning()
        myPeripheral = peripheral
        myPeripheral.delegate = self
        myCentral.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        isConnected = true
        isConnecting = false
        myPeripheral.discoverServices(services)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        reset()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            myPeripheral.discoverCharacteristics(characteristics, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {
        print(service)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            print(characteristic)
            myPeripheral.setNotifyValue(true, for: characteristic)
            myPeripheral.readValue(for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let value = characteristic.value {
            weight = (Double(value[12])*256 + Double(value[11])) / 200
            weightIsStable = false
            impedenceIsStable = false
            let control = bits(fromBytes: value[0..<2])
            if control[1][5] == 1 {
                weightIsStable = true
            }
            if control[1][7] == 1 {
                impedenceIsStable = true
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print(characteristic)
    }
    
    func reset() {
        isSwitchedOn = false
        isConnecting = false
        isConnected = false
        weightIsStable = false
        impedenceIsStable = false
        weight = 0.0
    }
    
    func startScanning() {
        isConnecting = true
        myCentral.scanForPeripherals(withServices: services, options: nil)
    }
    
    func stopScanning() {
        myCentral.stopScan()
    }
}
