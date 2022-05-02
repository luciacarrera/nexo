//
//  BLEManager.swift
//
//  Created by Lucía on 4/14/22.
//

//------------------------------------------------------------------------------------------------------------------------
// MARK: Imports
import Foundation
import CoreBluetooth
import UIKit

//------------------------------------------------------------------------------------------------------------------------
// MARK: Peripheral Struct
// we will create an array where we can append the name and RSSI of every device we discover by scanning
struct Peripheral: Identifiable {
    let id: Int
    let peripheral: CBPeripheral
    let name: String
    var rssi: Int
    
    // function to compare peripherals scanned to see if we already have them in array
    static func == (p1: Peripheral, p2: Peripheral) -> Bool {
            return p1.peripheral == p2.peripheral
        }
}

//------------------------------------------------------------------------------------------------------------------------
// MARK: BLE Manager Class
// we need to import the CoreBluetooth framework, define a variable of type CBCentralManager, and define the required CBCentralManagerDelegate methods
class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralManagerDelegate {
    
    //--------------------------------------------------------------------------------------------------------------------
    // MARK: Global Vars & Consts
    // central and peripheral bluetooth manager
    var myCentral: CBCentralManager!
    var myPeripheralManager: CBPeripheralManager!
    
    // UUID constants in our BLEManager class: one for the peripheral service and another for its characteristic.
    let peripheralServiceUUID = CBUUID(string: "00001011-0000-1100-1000-00123456789A")
    let notifyCharacteristicUUID = CBUUID(string: "00001012-0000-1100-1000-00123456789A")
    let readCharacteristicUUID = CBUUID(string: "00001012-0000-1100-1000-00123456790A")

    // service and peripheral
    var myService: CBMutableService! // Beter name ??
    var myPeripheral: CBPeripheral!  // Beter name ??
    
    // status of bluetooth in device
    @Published var isSwitchedOn = false
    @Published var isConnected = false
    @Published var keepScanning = true // ??
    
    // array of peripherals found
    @Published var scannedPeripherals = [Peripheral]()
    
    //--------------------------------------------------------------------------------------------------------------------
    // MARK: BLE Initialization
    // the following function initialises the central manager & Peripheral Manager
    override init() {
        
        super.init()
        self.myCentral = CBCentralManager(delegate: self, queue: nil)
        self.myCentral.delegate = self
        self.myPeripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
    }
    
    //--------------------------------------------------------------------------------------------------------------------
    // MARK: Central Manager
    // Function that checks state of Central Device (bluetooth on = .powerOn)
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        // if true then make global var true
        if central.state == .poweredOn {
            self.isSwitchedOn = true
        }
        else {
            self.isSwitchedOn = false
        }
        self.isConnected = isConnected // IS this true ??
        
    }
    
    // Function that discovers peripherals and adds them to the scannedPeripherals array
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        // If RSSI bigger than - 100 than it is considered too far away for a successful connection
        guard RSSI.intValue >= -100
                else {
                    print("Discovered perhiperal not in expected range, at %d", RSSI.intValue)
                    return
        }
         
        // unwrap name of peripheral from advertisement data
        var peripheralName: String!
        if let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            peripheralName = name
        }
        else {
            peripheralName = "Unknown"
        }
       
        // get peripheral scanned
        let newPeripheral = Peripheral(id: scannedPeripherals.count, peripheral: peripheral, name: peripheralName, rssi: RSSI.intValue)
        print(newPeripheral)
        
        var temp = [Peripheral]()
        temp.append(newPeripheral)
        print(temp)
        
        // check if temp and peripherals contain the same or have changed
        var hasChanged = false
        
        // if they dont have the same number of entries then something has definitely changed
        if temp.count != scannedPeripherals.count{
            hasChanged = true
            
        // double checking something has changed even if same number of entries
        } else{
            if temp.count != 0 {
                for i in 0...temp.count - 1 {
                    if temp[i] == scannedPeripherals[i] {
                        hasChanged = true
                    }
                }
            }
            
        }
        
        if hasChanged {
            scannedPeripherals = temp
            print("changed")
        }
        // restart temp
        temp = []
    
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // Successfully connected. Store reference to peripheral if not already done.
        print("\n\nCentral connected\n\n")
        myPeripheral.discoverServices([peripheralServiceUUID]) // look for what we want to look for specifically
        
    }
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        // Handle error
        print("failed to connect")

    }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let error = error {
            // Handle error
            print("Error disconnecting")
            return
        }
        // Successfully disconnected
    }
    
    //--------------------------------------------------------------------------------------------------------------------
    // MARK: Peripheral Manager
    // Function that checks if bluetooth is on and if so creates the service for the peripheral
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        // print updating state
        print("peripheralManagerDidUpdateState \(peripheral.state.rawValue)")
                
        // if bluetooth on then create service
        if self.myPeripheralManager.state == .poweredOn {
            self.myService = CBMutableService(type: peripheralServiceUUID, primary: true)
        }
        
    }
    
    // Function that adds services and characteristeristics to myPeripheral
    func addServicesAndCharacteristics() {
        
        //create read characteristic
        let readCharData = "READ"
        let readChar = CBMutableCharacteristic.init(type: self.readCharacteristicUUID, properties: [.read], value: readCharData.data(using: .utf8), permissions: [.readable])
        
        // create notification characteristic
        let notifyChar = CBMutableCharacteristic.init(type: self.notifyCharacteristicUUID, properties: [.read,.notify,.write], value:nil, permissions: [.readable,.writeable])
        
        // add characteristics to service
        self.myService?.characteristics = []
        self.myService?.characteristics?.append(readChar)
        self.myService?.characteristics?.append(notifyChar)
        
        // add service to peripheral manager
        self.myPeripheralManager.add(self.myService!)
        
        print(self.myService) // delete
    }
    
    // Function that checks if the myservice has been added correctly
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        
        // Handle error if service doesn't work
        if let error = error {
            print("Add service failed: \(error.localizedDescription)")
            return
        }
        // Print in terminal if it works
        print("Add service succeeded")
    }
    
    
    
    func startAdvertising() {
        /*
         - CBAdvertisementDataLocalNameKey: This is our peripheral’s local name that other central devices will be able to see in their scan result.
         - CBAdvertisementDataServiceUUIDsKey: This is an array (list) of UUIDs of each service that our peripheral is exposing to a central device.
         */
        // first check if service has been added
        if myService == nil {
            print("adding services and chars")
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
        myService = nil
        
    }
    
    // prints if if is advertising
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        print("Advertising started...")
    }
    
    // MARK: Code forCentral Manager
    
        
    func startScanning() {
        print("Scanning...")
        scannedPeripherals = []
        myCentral.scanForPeripherals(withServices: [peripheralServiceUUID], options: nil)
            /* DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                self.startScanning()
            } */
    }
    
    func stopScanning() {
        print("stopScanning")
        myCentral.stopScan()
        scannedPeripherals = []
    }
    
    // MARK: Connect to Peripheral
    
    func connect(peripheral: CBPeripheral) {
        print(peripheral)
        self.myPeripheral = peripheral
        myCentral.connect(peripheral, options: nil)
        isConnected = true
        myCentral.stopScan()
        self.myPeripheral.delegate = self
     }

    
    
    func disconnect(peripheral: CBPeripheral) {
        myCentral.cancelPeripheralConnection(peripheral)
    }
    
    
    
 
    // Call after connecting to peripheral
    func discoverServices(peripheral: CBPeripheral) {
        peripheral.discoverServices([peripheralServiceUUID])
    }
     
    // Call after discovering services
    func discoverCharacteristics(peripheral: CBPeripheral) {
        guard let services = peripheral.services else {
            return
        }
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
}

extension BLEManager: CBPeripheralDelegate {
    // In CBPeripheralDelegate class/extension
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("discover services")
        print(peripheral.services)
        for service in myPeripheral.services! {
            print(service)

            peripheral.discoverCharacteristics([peripheralServiceUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("discovering characteristics")
        if let chars = service.characteristics {
            print(chars)
            for characteristic in chars {
                /*if characteristic.uuid == readCharacteristicUUID || characteristic.uuid == notifyCharacteristicUUID {
                    peripheral.setNotifyValue(true, for: characteristic) // subscribes to characteristic?
                }*/
                print(characteristic)
                if characteristic.properties.contains(.read) {
                  print("\(characteristic.uuid): properties contains .read")
                }
                if characteristic.properties.contains(.notify) {
                  print("\(characteristic.uuid): properties contains .notify")
                }

                /* ..UUID ||
                 characteristic.uuid == heartRateCharacteristicUUID ||
                 characteristic.uuid == runningSpeedCharacteristicUUID */
            }
        }
    }
    
    /*
     *   This callback lets us know more data has arrived via notification on the characteristic
     */
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // Deal with errors (if any)
        if let error = error {
            print("Error discovering characteristics: %s", error.localizedDescription)
            return
        }
        
        guard let characteristicData = characteristic.value,
            let stringFromData = String(data: characteristicData, encoding: .utf8) else { return }
        
        print("Received %d bytes: %s", characteristicData.count, stringFromData)
        /*
         // Have we received the end-of-message token?
         if stringFromData == "EOM" {
             // End-of-message case: show the data.
             // Dispatch the text view update to the main queue for updating the UI, because
             // we don't know which thread this method will be called back on.
             DispatchQueue.main.async() {
                 self.textView.text = String(data: self.data, encoding: .utf8)
             }
             
             // Write test data
             writeData()
         } else {
             // Otherwise, just append the data to what we have previously received.
             data.append(characteristicData)
         } */
    }

    /*
     *  The peripheral letting us know whether our subscribe/unsubscribe happened or not
     */
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        // Deal with errors (if any)
        if let error = error {
            print("Error changing notification state: %s", error.localizedDescription)
            return
        }
        
        // Exit if it's not the transfer characteristic
        guard characteristic.uuid == readCharacteristicUUID || characteristic.uuid == notifyCharacteristicUUID else { return }
        
        if characteristic.isNotifying {
            // Notification has started
            print("Notification began on %@", characteristic)
        } else {
            // Notification has stopped, so disconnect from the peripheral
            print("Notification stopped on %@. Disconnecting", characteristic)
        }
        
    }
    
    /*
     *  This is called when peripheral is ready to accept more data when using write without response
     */
    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        print("Peripheral is ready, send data")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
    }
    
    
}
