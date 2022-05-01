//
//  ConnectionView.swift
//  nexo_test
//
//  Created by Lucía on 4/27/22.
//

import SwiftUI

struct ConnectionView: View {
    @StateObject var bleManager = BLEManager()
    @State private var navigate1 = false
    @State private var navigate2 = false
    @State private var showAlert = false

    var body: some View {
            
        NavigationView{
            ZStack {
                NavigationLink(destination: ScanningView().navigationBarBackButtonHidden(true), isActive: $navigate1){
                }
                NavigationLink(destination: AdvertisingView().navigationBarBackButtonHidden(true), isActive: $navigate2){
                }
            
                VStack(alignment: .center){
                    Spacer()
                
                    // Link to scanning view
                    // Check if bluetooth on if not alert
                    Text("Act as Central").onTapGesture {
                        if bleManager.isSwitchedOn {
                            navigate1.toggle()
                        } else {
                            showAlert.toggle()
                        }
                    }.padding()
                    
                    Spacer()
                
                    // Link to scanning view
                    // Check if bluetooth on if not alert
                    Text("Act as Peripheral").onTapGesture {
                        if bleManager.isSwitchedOn {
                            navigate2.toggle()
                        } else {
                            showAlert.toggle()
                        }
                    }.padding()

                    Spacer()
                }
                .alert("Please turn on Bluetooth", isPresented: $showAlert){
                    Button("OK", role: .cancel) { }
                }
            }
        }
        .environmentObject(bleManager)
    }
}

struct ConnectionView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionView()
    }
}
