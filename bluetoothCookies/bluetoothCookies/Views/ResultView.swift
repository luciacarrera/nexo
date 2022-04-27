//
//  ResultView.swift
//  bluetoothCookies
//
//  Created by Lucía on 4/26/22.
//

import SwiftUI

struct ResultView: View {
    var received: String
    var body: some View {
        Text(received)
    }
}

struct ResultView_Previews: PreviewProvider {
    static var previews: some View {
        ResultView(received: "hello")
    }
}
