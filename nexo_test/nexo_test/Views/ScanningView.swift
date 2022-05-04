//
//  ScanningView.swift
//  nexo_test
//
//  Created by Lucía on 4/27/22.
//

import SwiftUI

struct ScanningView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var bleManager: BLEManager

    @State private var selectedDevice: Peripheral?
    @State private var navigate = false
    @State private var goBack = false
    
    var body: some View {
        NavigationView{
                    ZStack {
                        NavigationLink(destination: CentralView().navigationBarBackButtonHidden(true), isActive: $navigate){
                        }

                        VStack (spacing: 10) {
                            
                            // MARK: Device List
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
                    } // End of ZStack
            
    
            .alert(item: $selectedDevice) { show in
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
        } // End of Navigation View
        .navigationBarItems(leading:
            Button(action: {
                print("\n\n\n\n\n")
                bleManager.stopScanning()
              self.presentationMode.wrappedValue.dismiss()
            }) {
              HStack {
                Image(systemName: "arrow.left")
                Text("Back")
              }
          }) // Nav bar items
                        
        .onAppear {
            bleManager.startScanning()
        } // on appear
        
    } // End of body
} // End of View

struct ScanningView_Previews: PreviewProvider {
    static var previews: some View {
        ScanningView()
    }
}
