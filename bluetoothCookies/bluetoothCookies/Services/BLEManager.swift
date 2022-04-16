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
        print(myPeripheralManager.isAdvertising)
        
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
       
        let newPeripheral = Peripheral(id: peripherals.count, peripheral: peripheral, name: peripheralName, rssi: RSSI.intValue)
        print(newPeripheral)
        
        // check if peripheral already in array
        var inArray = false
        for (index, item) in peripherals.enumerated(){
            // if found then update rssi
            if item.peripheral == newPeripheral.peripheral {
                peripherals[index].rssi = newPeripheral.rssi
                inArray = true
            }
            // if it has stopped advertising its name will change to unknown, we need to delete it from the peripherals array
            /*if item.peripheral == newPeripheral.peripheral{
                peripherals.remove(at: index)
                inArray = true
            }*/
        }
        
        // if not in array then append
        if !inArray && newPeripheral.name != "Unknown" {
            peripherals.append(newPeripheral)
        }
        
        
        
        /*let peripheralToUpdate = peripherals.filter({$0.peripheral == newPeripheral.peripheral})
        
        if peripheralToUpdate.count == 1 {
            peripherals[peripheralToUpdate.id].rssi = peripheral.rssi
        } else{
            peripherals.append(newPeripheral)
        }
        
        // if peripheral advertising data we want append to list
         let data = ["cookie_connection"]
         if data == advertisementData {
         
         }
         */
        
    }
    
    func startScanning() {
            print("startScanning")
            myCentral.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func stopScanning() {
            print("stopScanning")
            myCentral.stopScan()
            peripherals = []
    }
    
}
