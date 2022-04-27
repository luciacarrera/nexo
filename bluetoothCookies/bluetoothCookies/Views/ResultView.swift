//
//  ResultView.swift
//  bluetoothCookies
//
//  Created by Lucía on 4/26/22.
//

import SwiftUI

struct ResultView: View {
    @ObservedObject var bleManager = BLEManager()

    var body: some View {
        let received = "Placecard"
        Text(received)
    }
}

struct ResultView_Previews: PreviewProvider {
    static var previews: some View {
        ResultView()
    }
}
