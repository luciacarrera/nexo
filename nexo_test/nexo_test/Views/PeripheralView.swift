//
//  AdvertisingView.swift
//  nexo_test
//
//  Created by Lucía on 4/27/22.
//

import SwiftUI

// This is the view for the phone that will act as a peripheral device and be the viewfinder
struct PeripheralView: View {
    
    // MARK: Constants & Vars
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var bleManager: BLEManager
    @State private var navigate = false
    
    var backButton: some View {
        Button(action: {
            bleManager.stopAdvertising()
          self.presentationMode.wrappedValue.dismiss()
        }) {
          HStack {
            Image(systemName: "chevron.backward")
            Text("Back")
          } // End of HStack
      }
    }
    
    var pairingAlert: TextAlert {
        TextAlert(title: "Insert Pairing Code:", action: {
            let input = $0 ?? "Canceled"
            // Check if correct input
            print("Input: \(input)\nPair value: \(bleManager.pairValue)")
            if input == bleManager.pairValue {
                print("Correct code")
                bleManager.pairSuccessful(result: true)
                navigate = true
            } else {
                print("Incorrect code")
                bleManager.pairSuccessful(result: false)
                self.presentationMode.wrappedValue.dismiss()
            }
        })
    }

    // MARK: Body
    var body: some View {
        NavigationView{
            ZStack{
                NavigationLink(destination: CameraView().navigationBarBackButtonHidden(true), isActive: $navigate){
                } // Navigation Link
                
                VStack{
                    Text("Searching for Viewfinders...")
                } // Vstack
                .alert(isPresented: $bleManager.isPaired, pairingAlert) // Alert
            } // ZStack
        } // Navigation View
        .navigationBarItems(leading: backButton) // NavBarItem
        .onAppear() {
            bleManager.startAdvertising()
        } // On Appear
    } // body
} // view

struct AdvertisingView_Previews: PreviewProvider {
    static var previews: some View {
        PeripheralView()
    }
}
