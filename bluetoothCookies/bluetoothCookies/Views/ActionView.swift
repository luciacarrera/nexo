//
//  ContentView.swift
//  bluetoothCookies
//
//  Created by Lucía on 4/13/22.
//

import SwiftUI

struct ActionView: View {
    
    var body: some View {
        NavigationView{
            VStack(alignment: .center){
                Spacer()
                
                // LInk to detail view
                if #available(iOS 15.0, *) {
                    NavigationLink(
                        destination: DeviceView(action: "selling"),
                        label: {
                            // Each author card in the scrollview
                            Text("Sell Cookie")
                        }).padding()
                } else {
                    // Fallback on earlier versions
                }
                
                if #available(iOS 15.0, *) {
                    NavigationLink(
                        destination: DeviceView(action: "buying"),
                        label: {
                            // Each author card in the scrollview
                            Text("Buy Cookie")
                            
                        }).padding()
                } else {
                    // Fallback on earlier versions
                }
                Spacer()
            }
        }
        
        
            
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ActionView()
    }
}
