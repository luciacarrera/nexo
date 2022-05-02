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
            ZStack {
                NavigationLink(destination: PeripheralView().navigationBarBackButtonHidden(true), isActive: $navigate){
                }
            
                VStack{
                    Text("Advertising")
                }
            }
            
        }.navigationBarItems(leading:
            Button(action: {
                bleManager.stopAdvertising()
              self.presentationMode.wrappedValue.dismiss()
            }) {
              HStack {
                Image(systemName: "arrow.left")
                Text("Back")
              }
          })
        .onAppear() {
            bleManager.startAdvertising()
        }
        
    }
}

struct AdvertisingView_Previews: PreviewProvider {
    static var previews: some View {
        AdvertisingView()
    }
}
