//
//  SwiftUIView.swift
//  bluetoothCookies
//
//  Created by Lucía on 4/13/22.
//

import SwiftUI
import CoreBluetooth

@available(iOS 15.0, *)


struct DeviceView: View {

    @ObservedObject var bleManager = BLEManager()
    
    
    @State var action: String
    @State private var selectedDevice: Device?
    
    struct Device: Identifiable {
        var id: String { name }
        let name: String
    }

    @available(iOS 15.0, *)
    var body: some View {
        
        if #available(iOS 15.0, *) {
            VStack (spacing: 10) {
                
                Text("Devices")
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                // MARK: Device List
                List(bleManager.peripherals) { peripheral in
                    HStack {
                        Text(peripheral.name)
                        Spacer()
                        Text(String(peripheral.rssi))
                    }.onTapGesture {
                        selectedDevice = Device(name: peripheral.name)
                        
                    }
                }.frame(height: 300)
                
                Spacer()
                
                // MARK: Status
                Text("STATUS")
                    .font(.headline)
                // Status goes here
                if bleManager.isSwitchedOn {
                    Text("Bluetooth is switched on")
                        .foregroundColor(.green)
                }
                else {
                    Text("Bluetooth is NOT switched on")
                        .foregroundColor(.red)
                }
                
                Text("Currently " + action).foregroundColor(.orange)
                
                Spacer()
                
                // MARK: Stop
                Button("STOP") {
                    if self.action == "selling" {
                        bleManager.stopScanning()
                        action = "not selling"
                    }
                    if self.action == "buying" {
                        bleManager.stopAdvertising()
                        action = "not buying"
                    }
                }.padding()
                
                Spacer()
            }
            .alert(item: $selectedDevice) { show in
                Alert(
                    title: Text("Connect to " + show.name),
                                message: Text("There is no undo"),
                    primaryButton: .default(Text("Connect")) {
                                    print("Connecting...")
                                },
                                secondaryButton: .cancel()
                )
            }
            .onAppear {
                if self.action == "selling"{
                    self.bleManager.startScanning()
                }
                if self.action == "buying" {
                    self.bleManager.startAdvertising()
                }
                
            }
        } else {
            // Fallback on earlier versions
        }
        
        }
        
    }
struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 15.0, *) {
            DeviceView(action: "selling")
            
        } else {
            // Fallback on earlier versions
        }
        
    }
}
