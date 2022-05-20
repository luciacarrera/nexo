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
                    Text("Choose your setting...")
                        .padding(5)
                        .font(.title2)
                    
                    Spacer().frame(height: 30)
                    
                    Button("Camera", action: {
                        if bleManager.isSwitchedOn {
                            navigate1.toggle()
                        } else {
                            showAlert.toggle()
                        }
                    }).buttonStyle(GradientBtn(color1: Color.green, color2: Color.mint)) // End Button
                    
                    Spacer().frame(height: 30)
                    
                    Button("Viewfinder", action: {
                        if bleManager.isSwitchedOn {
                            navigate2.toggle()
                        } else {
                            showAlert.toggle()
                        }
                    }).buttonStyle(GradientBtn(color1: Color.teal, color2: Color.blue)) // End Button
                    
                    
                    Spacer()
            
                }
                .alert("Please turn on Bluetooth", isPresented: $showAlert){
                    Button("OK", role: .cancel) { }
                }
            } // End of ZStack
        }
        .environmentObject(bleManager)
    }
}

struct ConnectionView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionView()
    }
}
