//
//  BLEManager.swift
//  bluetoothCookies
//
//  Created by Lucía on 4/14/22.
//

import Foundation
import CoreBluetooth
import UIKit

// we will create an array where we can append the name and RSSI of every device we discover by scanning
struct Peripheral: Identifiable {
    let id: Int
    let peripheral: CBPeripheral
    let name: String
    var rssi: Int
    var lastUpdated: Date
}

// we need to import the CoreBluetooth framework, define a variable of type CBCentralManager, and define the required CBCentralManagerDelegate methods
class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralManagerDelegate {
    
    
    // central and peripheral bluetooth manager
    var myCentral: CBCentralManager!
    var myPeripheralManager: CBPeripheralManager!
    
    // UUID constants in our BLEManager class: one for the peripheral service and another for its characteristic.
    let peripheralServiceUUID = CBUUID(string: "00001011-0000-1100-1000-00123456789A")
    let peripheralCharacteristicUUID = CBUUID(string: "00001012-0000-1100-1000-00123456789A")
    var myService: CBMutableService!
    
    // status of bluetooth in device
    @Published var isSwitchedOn = false
    @Published var isConnected = false
    
    // array of peripherals found
    @Published var peripherals = [Peripheral]()
    
    // the following function initialises the central manager
    override init() {
            super.init()

            myCentral = CBCentralManager(delegate: self, queue: nil)
            myCentral.delegate = self
            myPeripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    // MARK: Code for Peripheral Manager
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
    }
    
    func addServicesAndCharacteristics() {
        myService = CBMutableService(type: peripheralServiceUUID, primary: true)
        let charData = "COOKIES"
        let myCharacteristic = CBMutableCharacteristic(type: peripheralCharacteristicUUID, properties: [.read], value: charData.data(using: .utf8), permissions: [.readable])
        myService.characteristics = [myCharacteristic]
        myPeripheralManager.add(myService)
        
    }
    
    func startAdvertising() {
        /*
         - CBAdvertisementDataLocalNameKey: This is our peripheral’s local name that other central devices will be able to see in their scan result.
         - CBAdvertisementDataServiceUUIDsKey: This is an array (list) of UUIDs of each service that our peripheral is exposing to a central device.
         */
        // first check if service has been added
        if myService == nil {
                addServicesAndCharacteristics()
        }

        myPeripheralManager.startAdvertising([
            CBAdvertisementDataLocalNameKey: UIDevice.current.name,
            CBAdvertisementDataServiceUUIDsKey: [peripheralServiceUUID]
        ])
    }
    
    func stopAdvertising() {
        myPeripheralManager.stopAdvertising()
        myPeripheralManager.removeAllServices()
        
    }
    
    // prints if if is advertising
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        print("Advertising started...")
    }
    
    // MARK: Code forCentral Manager
    // Function that checks if bluetooth is on
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            isSwitchedOn = true
        }
        else {
            isSwitchedOn = false
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        guard RSSI.intValue >= -100
                else {
                    print("Discovered perhiperal not in expected range, at %d", RSSI.intValue)
                    return
        }
         
        var peripheralName: String!
       
        if let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            peripheralName = name
        }
        else {
            peripheralName = "Unknown"
        }
       
        let newPeripheral = Peripheral(id: peripherals.count, peripheral: peripheral, name: peripheralName, rssi: RSSI.intValue, lastUpdated: Date())
        print(newPeripheral)
        
        // check if peripheral already in array
        var inArray = false
        for (index, item) in peripherals.enumerated(){
            // if found then update rssi and last Updated
            if item.peripheral == newPeripheral.peripheral {
                peripherals[index].rssi = newPeripheral.rssi
                peripherals[index].lastUpdated = Date()
                inArray = true
            }
        }
        
        // if not in array then append
        if !inArray && newPeripheral.name != "Unknown" {
            peripherals.append(newPeripheral)
        }
        
        
    }
    
    // function to check if peripherals in peripherals array are still advertising (active)
    func checkIfActive() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
            let now = Date()
            for (index, item) in peripherals.enumerated() {
                let difference = now.timeIntervalSince(item.lastUpdated)
                // if the difference is bigger than five seconds then it is considered inactive
                if difference > TimeInterval(5.0) {
                    peripherals.remove(at: index)
                }
                
            }
            self.checkIfActive()
        }
        
    }
    func startScanning() {
            print("startScanning")
            myCentral.scanForPeripherals(withServices: [peripheralServiceUUID], options: nil)
    }
    
    func stopScanning() {
            print("stopScanning")
            myCentral.stopScan()
            peripherals = []
    }
    
}
