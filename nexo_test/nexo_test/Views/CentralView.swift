//
//  CentralView.swift
//  nexo_test
//
//  Created by Lucía on 4/27/22.
//

import SwiftUI

struct CentralView: View {

    @EnvironmentObject var bleManager: BLEManager
    @State private var showAlert = true

    var body: some View {
        ZStack {
            VStack{
                Spacer()
                Text("Trying to connect")
                if bleManager.isConnected {
                    Text("Connected").foregroundColor(.green)
                } else{
                    Text("Disconnected").foregroundColor(.red)
                }
                Spacer()
                Text(bleManager.myReadString)
                Spacer()
            } // Vstack
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Pairing Code:"), message: Text(bleManager.pairValue), dismissButton: .default(Text("Got it!")))
            }
            
        } // Zstack
        
    }
}

struct CentralView_Previews: PreviewProvider {
    static var previews: some View {
        CentralView()
    }
}
