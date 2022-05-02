//
//  CentralView.swift
//  nexo_test
//
//  Created by Lucía on 4/27/22.
//

import SwiftUI

struct CentralView: View {

    @EnvironmentObject var bleManager: BLEManager

    var body: some View {
        VStack{
            Text("Trying to connect")
            if bleManager.isConnected {
                Text("Connected").foregroundColor(.green)
            } else{
                Text("Disconnected").foregroundColor(.red)
            }
            Spacer()
            Text(bleManager.myReadString)
        }
    }
}

struct CentralView_Previews: PreviewProvider {
    static var previews: some View {
        CentralView()
    }
}
