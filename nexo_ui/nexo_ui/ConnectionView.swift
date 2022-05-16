//
//  ContentView.swift
//  nexo_ui
//
//  Created by Lucía on 5/16/22.
//

import SwiftUI

struct ConnectionView: View {
    var body: some View {
        VStack{
            Spacer()
            Text("Choose your setting:").padding()
            VStack(alignment: .leading) {
                HStack{
                    Circle()
                        .foregroundColor(.green)
                        .frame(width: 15, height: 15)
                    Text("Camera")
                        
                } // End of HStack
                .padding()
                HStack{
                    Circle()
                        .foregroundColor(.blue)
                        .frame(width: 15, height: 15
                        )
                    Text("Viewfinder")
                        
                } // End of HStack
                .padding()
            }
            Spacer()
            
        } // End of VStack
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionView()
    }
}
