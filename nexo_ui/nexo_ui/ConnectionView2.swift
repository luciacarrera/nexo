//
//  ConnectionView2.swift
//  nexo_ui
//
//  Created by Lucía on 5/16/22.
//

import SwiftUI

struct ConnectionView2: View {
    var body: some View {
        VStack (alignment: .center){
            Spacer()
            Text("Choose your setting...")
                .padding(5)
                .font(.title2)
            
            Spacer().frame(height: 30)
            
            Button("Camera", action: {
                print("camera")
            }).buttonStyle(CustomButton(color1: Color.green, color2: Color.mint)) // End Button
            
            Spacer().frame(height: 30)
            
            Button("Viewfinder", action: {
                print("viewfinder")
            }).buttonStyle(CustomButton(color1: Color.teal, color2: Color.blue)) // End Button
            
            Spacer()
            
        } // End of Vstack 1
    }
}

struct ConnectionView2_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionView2()
    }
}
