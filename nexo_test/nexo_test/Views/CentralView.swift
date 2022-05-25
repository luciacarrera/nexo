//
//  ScanningView.swift
//  nexo_test
//
//  Created by Lucía on 4/27/22.
//

import SwiftUI

// This is the view for the phone that will act as a central device and be the viewfinder
struct CentralView: View {
    
    // MARK: Constants & Vars
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var bleManager: BLEManager
    @State private var selectedDevice: Peripheral?
    @State private var navigate = false
    @State private var goBack = false
    
    var deviceList: some View {
        VStack (spacing: 10) {
            List(bleManager.scannedPeripherals) { peripheral in
                Button (action: {
                    selectedDevice = peripheral
                }, label: {
                    Text(peripheral.name)
                    Spacer()
                    Text(String(peripheral.rssi))
                })
            }
        }
    }
    
    var backButton: some View {
        Button(action: {
            print("\n\n\n\n\n")
            bleManager.stopScanning()
            bleManager.disconnectIfConnected()
          self.presentationMode.wrappedValue.dismiss()
        }) {
          HStack {
            Image(systemName: "arrow.left")
            Text("Back")
          }
      }
    }
    
    // MARK: Body
    var body: some View {
        NavigationView{
            ZStack {
                NavigationLink(destination: ViewfinderView().navigationBarBackButtonHidden(true), isActive: $navigate){
                }
                deviceList
            }.alert(item: $selectedDevice) { show in
                Alert(
                    title: Text("Connect to " + show.name),
                                message: Text("There is no undo"),
                    primaryButton: .default(Text("Connect")) {
                        bleManager.connect(peripheral: show.peripheral)
                        navigate.toggle()
                        },
                    secondaryButton: .cancel()
                )
            }
        }
        .navigationBarItems(leading: backButton) // Nav bar items
        .onAppear {
            bleManager.startScanning()
        } // on appear
    } // End of body
} // End of View

struct CameraPairingView_Previews: PreviewProvider {
    static var previews: some View {
        CentralView()
    }
}
