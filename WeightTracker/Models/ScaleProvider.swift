//
//  BluetoothProvider.swift
//  WeightTracker
//
//  Created by James Maguire on 15/09/2022.
//

import Foundation
import CoreBluetooth

// Codes for Mi Body Composition Scale 2
let compositionServiceUuid = "181B"
let compositionCharacteristicUuid = "2A9C"

let configServiceUuid = "00001530-0000-3512-2118-0009AF100700"
let configCharacteristicUuid = "00001542-0000-3512-2118-0009AF100700"

let services: [CBUUID] = [CBUUID(string: compositionServiceUuid), CBUUID(string: configServiceUuid)]
let characteristics: [CBUUID] = [CBUUID(string: compositionCharacteristicUuid), CBUUID(string: configCharacteristicUuid)]


class ScaleProvider: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var central: CBCentralManager!
    var scalePeripheral: CBPeripheral!
    
    var compositionCharacteristic: CBCharacteristic!
    var configCharacteristic: CBCharacteristic!

    @Published var isSwitchedOn = false
    @Published var isConnecting = false
    @Published var isConnected = false
    @Published var weightIsStable = false
    @Published var impedenceIsStable = false
    @Published var weight: Double = 0.0
    @Published var impedence: Double = 0.0
    
    override init() {
        super.init()
        central = CBCentralManager(delegate: self, queue: nil)
        central.delegate = self
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
        scalePeripheral = peripheral
        scalePeripheral.delegate = self
        central.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        isConnected = true
        isConnecting = false
        scalePeripheral.discoverServices(services)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        reset()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            scalePeripheral.discoverCharacteristics(characteristics, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            scalePeripheral.setNotifyValue(true, for: characteristic)
            switch characteristic.uuid.uuidString {
            case compositionCharacteristicUuid:
                compositionCharacteristic = characteristic
                scalePeripheral.readValue(for: compositionCharacteristic)
            case configCharacteristicUuid:
                configCharacteristic = characteristic
            default:
                continue
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let value = characteristic.value {
            weight = (Double(value[12])*256 + Double(value[11])) / 200
            impedence = (Double(value[9]) + Double(value[10]))
            weightIsStable = false
            impedenceIsStable = false
            let control = bits(fromBytes: value[0..<2])
            if control[1][5] == 1 {
                weightIsStable = true
            }
            if control[1][1] == 1 {
                impedenceIsStable = true
            }
        }
    }
    
    func reset() {
        if central.state == .poweredOn {
            isSwitchedOn = true
        }
        else {
            isSwitchedOn = false
        }
        isConnecting = false
        isConnected = false
        weightIsStable = false
        impedenceIsStable = false
        weight = 0.0
        impedence = 0.0
    }
    
    func startScanning() {
        reset()
        if isSwitchedOn {
            isConnecting = true
            central.scanForPeripherals(withServices: services, options: nil)
        }
    }
    
    func stopScanning() {
        central.stopScan()
    }
    
    // Note: The device stops transmitting values when the display turns off
    func turnOffDisplay() {
        if let c = configCharacteristic {
            scalePeripheral.writeValue(Data([UInt8]([4,3])), for: c, type: .withResponse)
        }
    }
}
