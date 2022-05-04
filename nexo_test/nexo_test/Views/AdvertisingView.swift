//
//  AdvertisingView.swift
//  nexo_test
//
//  Created by Lucía on 4/27/22.
//

import SwiftUI

struct AdvertisingView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var bleManager: BLEManager
    @State private var navigate = false
    

    var body: some View {
        NavigationView{
            ZStack{
                NavigationLink(destination: PeripheralView().navigationBarBackButtonHidden(true), isActive: $navigate){
                } // Navigation Link
                VStack{
                    Text("Advertising")
                    
                } // Vstack
                
                .alert(isPresented: $bleManager.isPairing, TextAlert(title: "Insert Pairing Code:", action: {
                            print("Callback \($0 ?? "")")
                    
                        })) // Alert
            } // ZStack
            
        } // Navigation View
        .navigationBarItems(leading:
            Button(action: {
                bleManager.stopAdvertising()
              self.presentationMode.wrappedValue.dismiss()
            }) {
              HStack {
                Image(systemName: "arrow.left")
                Text("Back")
              } // End of HStack
          }) // NavBarItem
        .onAppear() {
            bleManager.startAdvertising()
        } // On Appear
        
    } // body
} // view

struct AdvertisingView_Previews: PreviewProvider {
    static var previews: some View {
        AdvertisingView()
    }
}

//--------------------------------------------
