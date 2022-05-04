//
//  CentralView.swift
//  nexo_test
//
//  Created by Lucía on 4/27/22.
//

import SwiftUI

struct CentralView: View {

    @EnvironmentObject var bleManager: BLEManager
    @State private var showAlert = false

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
                Alert(title: Text(bleManager.pairValue), message: Text("This is your pairing code"), dismissButton: .default(Text("Got it!")))
            }
            
        } // Zstack
        .onAppear() {
            showAlert.toggle()
            print(showAlert)
        } // onAppear
        
    } // body
} // view

struct CentralView_Previews: PreviewProvider {
    static var previews: some View {
        CentralView()
    }
}
