//
//  AdvertisingView.swift
//  nexo_test
//
//  Created by Lucía on 4/27/22.
//

import SwiftUI

struct AdvertisingView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var bleManager = BLEManager()

    var body: some View {
        NavigationView{
            Text("Advertising")
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
