//
//  SwiftUIView.swift
//  bluetoothCookies
//
//  Created by Lucía on 4/13/22.
//

import SwiftUI

@available(iOS 15.0, *)


struct DeviceView: View {

    @ObservedObject var bleManager = BLEManager()
    @State var action: String
    @State var showConnectAlert: Bool = false
    
    struct connectionDevice {
        let peripheralName: String
        let rssi: Int
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
                        showConnectAlert = true
                        
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
            .alert("Connect to ...",isPresented: $showConnectAlert){
                Button("Connect"){
                    
                }
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
        //bleManager.peripherals = [Peripheral(id: 3, name: "My iPhone", rssi: 5)]
    }
}
