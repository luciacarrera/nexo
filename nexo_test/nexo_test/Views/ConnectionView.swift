//
//  ConnectionView.swift
//  nexo_test
//
//  Created by Lucía on 4/27/22.
//

import SwiftUI

struct ConnectionView: View {
    
    // MARK: Vars & Constants
    @StateObject var bleManager = BLEManager()
    @State private var navigatePeripheral = false
    @State private var navigateCentral = false
    @State private var showAlert = false
    
    var instructionText: some View {
        Text("Choose your setting...")
            .padding(5)
            .font(.title2)
    }
    
    var cameraButton: some View {
        Button("Camera", action: {
            if bleManager.isSwitchedOn {
                navigatePeripheral.toggle()
            } else {
                showAlert.toggle()
            }
        }).buttonStyle(GradientBtn(color1: Color.green, color2: Color.mint)) // End Button
    }
    
    var viewfinderButton: some View {
        Button("Viewfinder", action: {
            if bleManager.isSwitchedOn {
                navigateCentral.toggle()
            } else {
                showAlert.toggle()
            }
        }).buttonStyle(GradientBtn(color1: Color.teal, color2: Color.blue)) // End Button
    }
    
    // MARK: Body
    var body: some View {
            
        NavigationView{
            ZStack {
                NavigationLink(destination: PeripheralView().navigationBarBackButtonHidden(true), isActive: $navigatePeripheral){
                }
                NavigationLink(destination: CentralView().navigationBarBackButtonHidden(true), isActive: $navigateCentral){
                }
            
                VStack(alignment: .center){
                    
                    Spacer()
                    instructionText
                    Spacer().frame(height: 30)
                    cameraButton
                    Spacer().frame(height: 30)
                    viewfinderButton
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
