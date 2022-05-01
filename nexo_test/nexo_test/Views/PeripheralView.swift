//
//  PeripheralView.swift
//  nexo_test
//
//  Created by Lucía on 4/27/22.
//

import SwiftUI

struct PeripheralView: View {
    @EnvironmentObject var bleManager: BLEManager

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        
    }
}

struct PeripheralView_Previews: PreviewProvider {
    static var previews: some View {
        PeripheralView()
    }
}
