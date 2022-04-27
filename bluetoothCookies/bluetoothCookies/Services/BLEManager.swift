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
    
    static func == (p1: Peripheral, p2: Peripheral) -> Bool {
            return p1.peripheral == p2.peripheral
        }
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
    @Published var keepScanning = true
    
    // array of peripherals found
    @Published var peripherals = [Peripheral]()
    
    // for connected peripherals
    var connectedPeripheral: CBPeripheral?
    
    
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
        print("stopAdvertising")
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
       
        let newPeripheral = Peripheral(id: peripherals.count, peripheral: peripheral, name: peripheralName, rssi: RSSI.intValue)
        print(newPeripheral)
        
        // tempPeripherals constantly updates
        var temp = [Peripheral]()
        
        // if not in array then append
        if newPeripheral.name != "Unknown" {
            temp.append(newPeripheral)
        }
        print(temp)
        
        // check if temp and peripherals contain the same or have changed
        var hasChanged = false
        
        // if they dont have the same number of entries then something has definitely changed
        if temp.count != peripherals.count{
            hasChanged = true
            
        // double checking something has changed even if same number of entries
        } else{
            if temp.count != 0 {
                for i in 0...temp.count - 1 {
                    if temp[i] == peripherals[i] {
                        hasChanged = true
                    }
                }
            }
            
        }
        
        if hasChanged {
            peripherals = temp
            print("changed")
        }
        // restart temp
        temp = []
    }
        
    func startScanning() {
        if keepScanning {
            print("startScanning")
            peripherals = []
            myCentral.scanForPeripherals(withServices: [peripheralServiceUUID], options: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                self.startScanning()
            }
        }
    }
    
    func stopScanning() {
        print("stopScanning")
        myCentral.stopScan()
        peripherals = []
        keepScanning = false
    }
    
    // MARK: Connect to Peripheral
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // Successfully connected. Store reference to peripheral if not already done.
        self.connectedPeripheral = peripheral
    }
    
    func connect(peripheral: CBPeripheral) {
        myCentral.connect(peripheral, options: nil)
        print("Connected")
     }
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        // Handle error
        print("failed to connect")
    }
    
    func disconnect(peripheral: CBPeripheral) {
        myCentral.cancelPeripheralConnection(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let error = error {
            // Handle error
            print("Error disconnecting")
            return
        }
        // Successfully disconnected
    }
}
