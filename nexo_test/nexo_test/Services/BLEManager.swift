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
import SwiftUI

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
    var myCharacteristics: [CBCharacteristic]!
    var connectedCentral: CBCentral!
    
    // UUID constants in our BLEManager class: one for the peripheral service and another for its characteristic.
    let peripheralServiceUUID = CBUUID(string: "00001011-0000-1100-1000-00123456789A")
    
    let shutterUUID = CBUUID(string: "00001012-0000-1100-1000-00123456789A")
    let picturesUUID = CBUUID(string: "00001012-0000-1100-1000-00123456750A")
    let sendCodeUUID = CBUUID(string: "00001012-0000-1100-1000-00123456691A")
    let pairResultUUID = CBUUID(string: "00001012-0000-1100-1000-00123456692A")
    var charsUUIDs: [CBUUID] = []
    //var picIndex = 0
    var ready = false
    private let sessionQueue = DispatchQueue(label: "picture queue")
    // service and peripheral
    var myService: CBMutableService! // Beter name ??
    var myPeripheral: CBPeripheral!  // Beter name ??
    @Published var click: Bool = false
    
    // status of bluetooth in device
    @Published var isSwitchedOn = false
    @Published var isConnected = false
    @Published var keepScanning = true // ??
    @Published var isPaired = false
    @Published var pairValue = "?"
    @Published var isDisconnected = false// NOT the opposite of isConnected but kind of, will tell view to go back
    @Published var noPicturesTaken = true

    // array of peripherals found
    @Published var scannedPeripherals = [Peripheral]()
    
    // Camera Model
    var camera: CameraModel?
    var pictureData = Data()
    
    
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
                    print("CENTRAL // Discovered perhiperal not in expected range, at %d", RSSI.intValue)
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
        
        // Append new peripherals and disconnect ones that no longer exist
        var temp = [Peripheral]()
        temp.append(newPeripheral)
        print(temp)
        // check if temp and peripherals contain the same or have changed
        var hasChanged = false
        // if they dont have the same number of entries then something has definitely changed
        if temp.count != self.scannedPeripherals.count{
            hasChanged = true
        // double checking something has changed even if same number of entries
        } else{
            if temp.count != 0 {
                for i in 0...temp.count - 1 {
                    if temp[i] == self.scannedPeripherals[i] {
                        hasChanged = true
                    }
                }
            }
        }
        // if it has changed then update actual array
        if hasChanged {
            self.scannedPeripherals = temp
            print("CENTRAL // Scanned Peripherals changed")
        }
    
    }
    
    // Function that once Central is connected tries to discover the peripherals
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        // Successfully connected. Store reference to peripheral if not already done.
        print("\n\nCENTRAL // Connected\n\n")
        self.myPeripheral.discoverServices([peripheralServiceUUID]) // look for what we want to look for specifically
        
    }
    
    // Function that handles error if central fails to connect to peripheral
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        
        // Handle error
        print("CENTRAL // Error connecting")
    }
    
    // Function to handle disconnection from Peripheral
    // Missing ??
    
    // Handles error if Central doesn't succesfully disconnect to Peripheral
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        self.isDisconnected = true
        
        if error != nil {
            // Handle error
            print("CENTRAL // Error disconnecting")
            return
        }
    }
    
    //--------------------------------------------------------------------------------------------------------------------
    // MARK: Peripheral Manager
    // Functions that control the Peripheral Device
    
    // Function that checks if bluetooth is on and if so creates the service for the peripheral
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        // print updating state
        print("PERIPHERAL // peripheralManagerDidUpdateState \(peripheral.state.rawValue)")
        
    }
    
    // Function that notifies developer if peripheral has started advertising
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        print("PERIPHERAL //Advertising started...")
        self.connectedCentral = nil
    }
    
    // Should this be somewhere else ??
    // Function that adds services and characteristeristics to myPeripheral
    func addServicesAndCharacteristics() {
        
        // Initialize service
        self.myService = CBMutableService(type: peripheralServiceUUID, primary: true)
        
        // create characteristic to write the pair code
        let sendCodeChar = CBMutableCharacteristic.init(type: self.sendCodeUUID, properties: [.notify,.write], value:nil, permissions: [.readable,.writeable]) // Do I need all these properties/permisions ??
        
        // create characteristic to read the result of the pair code
        let pairResultChar = CBMutableCharacteristic.init(type: self.pairResultUUID, properties: [.read, .notify], value: nil, permissions: [.readable])
        
        // create characteristic to write the pair code
        let shutterChar = CBMutableCharacteristic.init(type: self.shutterUUID, properties: [.notify,.write], value:nil, permissions: [.readable,.writeable]) // Do I need all these properties/permisions ??
        
        // create characteristic to read the camera preview
        let picturesChar = CBMutableCharacteristic.init(type: self.picturesUUID, properties: [.read, .notify], value: nil, permissions: [.readable])
        
        // safekeeping of all chars uuids added
        self.charsUUIDs = [sendCodeUUID, pairResultUUID, shutterUUID, picturesUUID]
        
        // add characteristics to service
        self.myService?.characteristics = []
        self.myService?.characteristics?.append(sendCodeChar)
        self.myService?.characteristics?.append(pairResultChar)
        self.myService?.characteristics?.append(shutterChar)
        self.myService?.characteristics?.append(picturesChar)

        
        // add service to peripheral manager
        self.myPeripheralManager.add(self.myService!) // DOES THIS WORK ??
        print(self.myService ?? "PERIPHERAL //No Service in Peripheral") // delete
    }
    
    // Function that checks if the myservice has been added correctly
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        
        // Handle error if service doesn't work
        if let error = error {
            print("PERIPHERAL //Add service failed: \(error.localizedDescription)")
            return
        }
        // Print in terminal if it works
        print("PERIPHERAL //Add service succeeded")
    }
    
    // Handles subscribtions
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        
        // Only add if not already added
        if self.connectedCentral == nil {
            // check if already added
            self.connectedCentral = central
        }
            
    }
    
    // Handles write requests
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        
        // Go through all requests
        for request in requests {
            
            // For pairing Request
            if request.characteristic.uuid == sendCodeUUID{
                print("PERIPHERAL // Received Send Code Write Request...")
                if let receivedValue = request.value { // unwrapping
                    // get pairValue
                    self.pairValue =  String(data: receivedValue, encoding: .utf8) ?? "no code yet"
                    print("PERIPHERAL //\(pairValue)")
                    if self.pairValue != "no code yet" {
                        self.isPaired = true
                    }
                    
                    // Tell central we received pairing value
                    peripheral.respond(to: request, withResult: .success)
                }
            }
            
            // For shutter Request
            if request.characteristic.uuid == shutterUUID{
                print("PERIPHERAL // Received Shutter Write Request...")
                if let receivedValue = request.value { // unwrapping
                    let value = String(data: receivedValue, encoding: .utf8) ?? "shutter not pressed yet"
                    print(value)
                    print("PERIPHERAL // Told that shutter was pressed")
                    // Tell central we received pairing value
                    peripheral.respond(to: request, withResult: .success)
                    
                    // change value of click byte
                    if let cam = self.camera {
                        cam.capturePhoto()
                        print("sending photo")
                        self.sendPhotoTaken()
        
                    }
                    self.click = false
                    
                }
            }
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) { // dont think this is handled correctly
        if request.characteristic.uuid == self.pairResultUUID {
            print("PERIPHERAL // Received Pair Result Read Request...")
            peripheral.respond(to: request, withResult: .success)
        }
        
        if request.characteristic.uuid == self.picturesUUID {
            print("PERIPHERAL // Received Pictures Read Request...")
            peripheral.respond(to: request, withResult: .success)
        }
    }
    
    // I dont think I use this
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
            print("PERIPHERAL // ready")
        self.ready = true
    }
    
    /*func updateValue( _ value: Data, for characteristic: CBMutableCharacteristic, onSubscribedCentrals centrals: [CBCentral]?) -> Bool {
           return myPeripheralManager.updateValue(value, for: characteristic, onSubscribedCentrals: centrals)
       }*/
    
    

    //--------------------------------------------------------------------------------------------------------------------
    // MARK: View Functions
    // Functions called by the views to access the Bluetooth Managers
    
    /* ADVERTISING */
    // Function View calls when they want the Peripheral to start Advertising
    func startAdvertising() {
        
        // Definitions:
        // - CBAdvertisementDataLocalNameKey: This is our peripheral’s local name that other central devices will be able to see in their scan result.
        // - CBAdvertisementDataServiceUUIDsKey: This is an array (list) of UUIDs of each service that our peripheral is exposing to a central device.

        // first check if service has been added
        if self.myService == nil {
            print("PERIPHERAL //Adding services and chars...")
            self.addServicesAndCharacteristics()
        }

        // Tell the Peripheral Manager to start advertising
        self.myPeripheralManager.startAdvertising([
            CBAdvertisementDataLocalNameKey: UIDevice.current.name,
            CBAdvertisementDataServiceUUIDsKey: [peripheralServiceUUID]
        ])
    }
    
    // Function a view calls to tell the peripheral to stop advertisiting
    func stopAdvertising() {
        
        // Stop & Remove all services to completely stop it
        self.myPeripheralManager.stopAdvertising()
        self.myPeripheralManager.removeAllServices()
        self.myService = nil
        print("PERIPHERAL //Advertising stopped...")
        
        // make sure all status vars are reset
        self.isConnected = false
        self.isDisconnected = true
        self.isPaired = false
        self.noPicturesTaken = true
        
    }
    
    /* SCANNING */
    // Function that view calls to tell central to start scanning for peripherals
    func startScanning() {

        self.scannedPeripherals = []
        self.myCentral.scanForPeripherals(withServices: [peripheralServiceUUID], options: nil)
        print("CENTRAL //Scanning started...")
            /* DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                self.startScanning()
            } */
    }
    
    // Function that view calls to tell central to stop scanning for peripherals
    func stopScanning() {
        
        myCentral.stopScan()
        scannedPeripherals = []
        print("CENTRAL //Scanning stopped...")
    }
    
    /* CONNECTING */
    // Function that view calls to tell central to connect to a specific peripheral
    func connect(peripheral: CBPeripheral) {
        print("CENTRA: //Peripheral to connect to: \(peripheral)")
        self.myPeripheral = peripheral
        self.myCentral.connect(peripheral, options: nil)
        self.isConnected = true
        self.myCentral.stopScan()
        self.myPeripheral.delegate = self
        print("CENTRAL //Connecting started...")
     }

    // Function that view calls to tell central to disconnect to a specific peripheral
    func disconnect(peripheral: CBPeripheral) {
        myCentral.cancelPeripheralConnection(peripheral)
        print("CENTRAL //Disconnecting started...")
        self.isDisconnected = true
        self.isConnected = false
        self.isPaired = false
        self.noPicturesTaken = true
        self.pairValue = "?"
    }
    
    // function that peripheral uses to tell central if the pairing was successful or not
    func pairSuccessful(result: Bool){
        
        // Search for pair result char
        guard let chars = self.myService.characteristics else { return }
        var myChar: CBMutableCharacteristic?
        for char in chars {
            if char.uuid == pairResultUUID {
                myChar = char as? CBMutableCharacteristic
                // Set value
                var value = ""
                if result {
                    value = "success"
                } else {
                    value = "sad"
                }
                
                // Update Value
                let data = value.data(using: .utf8)
                myPeripheralManager.updateValue(data!, for: myChar!, onSubscribedCentrals: nil)
            }
        }
    
    }
    
    func shutterPressed(){
        // Search for shutter char
        guard let chars = self.myCharacteristics else { return }
        for char in chars {
            if char.uuid == shutterUUID {
                
                // Update click
                if self.click == false {
                    self.click = true
                }else {
                    self.click = false
                }
                let data = Data(bytes: &self.click,
                                     count: MemoryLayout.size(ofValue: click))
                print("Shutter Pressed data: \(data)")
                
                // ask for a response and write value
                self.myPeripheral.writeValue(data, for: char, type: .withResponse)

                print("CENTRAL // telling perihpheral that shutter was pressed")
            }
        }
        
    }
    func disconnectIfConnected(){
        if self.isConnected {
            disconnect(peripheral: self.myPeripheral)
        }
    }
    
    func configureCamera(camera: CameraModel){
        self.camera = camera
    }


    
    func sendPhotoTaken(){
        // unwrap camera model just in case
        if let cam = self.camera {
            if cam.photo != nil { // unwrap photo just in case
                // Search for pair result char
                guard let chars = self.myService.characteristics else { return }
                var myChar: CBMutableCharacteristic?
                for char in chars {
                    if char.uuid == picturesUUID {
                        
                        myChar = char as? CBMutableCharacteristic
                        // first we need to know how much data we have to send
                        // Get the data
                        let dataToSend = cam.photo.originalData
                        
                        // Reset the index
                        var sendDataIndex = 0
                        
                        
                        var didSend = true
                        while didSend {
                            // Work out how big it should be
                            var amountToSend = dataToSend.count - sendDataIndex
                            if let mtu = connectedCentral?.maximumUpdateValueLength {
                                amountToSend = min(amountToSend, mtu)
                            }
                            
                            // Copy out the data we want
                            let chunk = dataToSend.subdata(in: sendDataIndex..<(sendDataIndex + amountToSend))
                            
                            // Send it if peripheral ready
                            didSend = myPeripheralManager.updateValue(chunk, for: myChar!, onSubscribedCentrals: nil)
                            
                            // If it didn't work, drop out and wait for the callback
                            if !didSend {
                                print("failed to send")
                                return
                            }
                            
                            print("Sent bytes: ", chunk.count)
                            
                            // It did send, so update our index
                            sendDataIndex += amountToSend
                            
                            if sendDataIndex >= dataToSend.count {
                                // We have finished sending all the data
                                
                                //Send it
                                let eomSent = myPeripheralManager.updateValue("EOM".data(using: .utf8)!,
                                                                             for: myChar!, onSubscribedCentrals: nil)
                                
                                if eomSent {
                                    // It sent; we're all done
                                    print("Sent: EOM")
                                }
                                return
                            }
                        }
                        
                            
                        /*print("PERIPHERAL // sending photo")
                        myChar = char as? CBMutableCharacteristic
                        
                        
                        let buffer: [UInt8]
                        buffer = Array(cam.photo.originalData)
                        
                        let biggerBuffer = createBufferToSend(buffer)
             
                        let imageSize = biggerBuffer.count
                        // let imageProgress = -1
                        print("IMAGE SIZE: \(imageSize)")
                        let start = "I:"+String(imageSize)
                        
                        // sends the size of the image
                        myPeripheralManager.updateValue(start.data(using: .utf8)!, for: myChar!, onSubscribedCentrals: nil)
                        
                        // Now we actually send the data
                        
                        
                        var index = 0
                        // sends image bytes in packs
                        biggerBuffer.forEach{ b in
                        
                            // creates the data pack - might be redundant
                            let data = NSData(bytes: b, length: MemoryLayout<UInt8>.size*b.count)
                            
                                
                            myPeripheralManager.updateValue(data as Data, for: myChar!, onSubscribedCentrals: self.connectedCentrals)
                            
                            print("PERIPHERAL // Sending packet \(index)")
                            index += 1
                            
                        } // end of if loop*/
                        
                    } // end of if char uuid
                } // end of for loop searching for char
            } // end of unwrapping photo
            else{
                print("no photo yet")
            }
        } // end of unwrapping cam model
        
    } // end of send photo taken

    
} // end of class
    
//------------------------------------------------------------------------------------------------------------------------
// MARK: Peripheral Delegate
// Functions that control the management of the peripheral IN the Central Device
extension BLEManager: CBPeripheralDelegate {
        
    // Function that discover the services in the peripheral
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("CENTRAL // Error discovering services: %s", error.localizedDescription)
            return
        }
        
        // Loop through the newly filled peripheral.services array, just in case there's more than one.
        guard let peripheralServices = peripheral.services else { return }
        print("CENTRAL // Discovering services...")

        for service in peripheralServices {
            // must have all characteristics uuid
            peripheral.discoverCharacteristics(self.charsUUIDs, for: service)
            
        }
    }
    
    // Function that discovers the characteristics of a service in the peripheral
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        // If error discovering characteristics
        if let error = error {
            print("CENTRAL // Error discovering characteristics: %s", error.localizedDescription)
            return
        }
        
        print("CENTRAL // Discovering characteristics...")
        
        // Unwrap characteristics
        if let chars = service.characteristics {
            self.myCharacteristics = service.characteristics
            for characteristic in chars {
                
                if characteristic.uuid == pairResultUUID {
                    print("\(characteristic.uuid): pair result characteristic with read and notify")

                    // We are now subscribed to characteristics
                    peripheral.setNotifyValue(true, for: characteristic)
                    peripheral.readValue(for: characteristic)
                    print("CENTRAL // reading pair result")
                }
                
                if characteristic.uuid == picturesUUID {
                    print("\(characteristic.uuid): pictures characteristic with read and notify")
                    
                    // We are now subscribed to characteristics
                    peripheral.setNotifyValue(true, for: characteristic)
                    peripheral.readValue(for: characteristic)
                    print("CENTRAL // reading pictures result")
                }
                
                // Pairing Notification
                if characteristic.uuid == sendCodeUUID{
                    print("CENTRAL // \(characteristic.uuid): send code characteristic with write and notify")
                    
                    // We are now subscribed to characteristics
                    peripheral.setNotifyValue(true, for: characteristic)
                    
                    // Write pairing code
                    let value = String(Int.random(in: 1000...9999))
                    self.pairValue = value
                    print(pairValue)
                    let data = value.data(using: .utf8)
                    // ask for a response
                    peripheral.writeValue(value.data(using: .utf8)!, for: characteristic, type: .withResponse)
                    if let mydata = data {
                        let mystr = String(data: mydata, encoding: .utf8)!
                        print(mystr)
                    }
                    print("CENTRAL // written code")
                }
                
                // Shutter Notification
                if characteristic.uuid == shutterUUID{
                    print("CENTRAL // \(characteristic.uuid): shutter characteristic with write and notify")
                    // We are now subscribed to characteristics
                    peripheral.setNotifyValue(true, for: characteristic)
                    
                }
            }
        }
    }
    
    // Function to check pairing
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if let error = error {
            disconnect(peripheral: peripheral)
            print("CENTRAL // Error getting write Notification : %s", error.localizedDescription)
            return
        }

    }
    
    // Function to check update value of a specific characteristic
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        // Handles type of characteristic
        switch characteristic.uuid {
            
            // If send code characteristic characteristic
            case sendCodeUUID:
                print(characteristic.value ?? "send code has no value")
                /*guard let characteristicData = characteristic.value,
                let stringFromData = String(data: characteristicData, encoding: .utf8) else { return }*/
            
            // If send code characteristic characteristic
            case shutterUUID:
                print("Shutter value: ")
                print(characteristic.value ?? "no value")
            
            // If pair result characteristic
            case pairResultUUID:
                print("Pair Result value: ")
                print(characteristic.value ?? "no value")
                guard let characteristicData = characteristic.value,
                let stringFromData = String(data: characteristicData, encoding: .utf8) else { return }
                print(stringFromData)
                if stringFromData == "success" {
                    self.isPaired = true
                }
                if stringFromData == "sad" {
                    self.disconnect(peripheral: peripheral)
                }
            
        case picturesUUID:
            print("Pictures value:")
            print(characteristic.value ?? "no value")
            
            // if nil then do not continue
            guard let characteristicData = characteristic.value,
            let stringFromData = String(data: characteristicData, encoding: .utf8) else { return }
            print("string from data:\(stringFromData)")
            
            // if initial characteristic value sent then do not pass
            if stringFromData != "" {
                
                if stringFromData == "EOM" {
                    // End-of-message case: show the data.
                    // Dispatch the text view update to the main queue for updating the UI, because
                    // we don't know which thread this method will be called back on.
                    DispatchQueue.main.async() {
                        if let cam = self.camera {
                            print("Saving Pictures")
                            cam.savePhoto(photoData: characteristicData)
                            self.noPicturesTaken = false
                        }
                    }
                    
                    
                } else {
                    // Otherwise, just append the data to what we have previously received.
                    pictureData.append(characteristicData)
                }
            }
            
            /* guard let characteristicData = characteristic.value else { return }
            if let cam = self.camera {
                print("Saving Pictures")
                cam.savePhoto(photoData: characteristicData)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    self.noPicturesTaken = false
                }
            } */
            
            
            // If other type of characteristic
            default:
              print("CENTRAL // Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }
    
    // Function that handles errors if subscribtion or unsubscribtion has errors
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("CENTRAL // Error subscribing to characteristics: %s", error.localizedDescription)
            return
        }
        
    }
    
    // Function if service is modified ??
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
    }
    
}
