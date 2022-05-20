//
//  ContentView.swift
//  nexo-cam2
//
//  Created by Lucía on 5/18/22.
//

import SwiftUI

struct CameraView: View {
    @StateObject private var camera = CameraModel()

    var body: some View {
        GeometryReader { geometry in
            let viewHeight = geometry.size.height
            let viewWidth = geometry.size.width
        ZStack{
            
            // Going to Be Camera preview...
            if camera.previewSetup{
                
                camera.preview.frame 
                
            } // if previewSetup
            
        }.onAppear(perform: {
            
            camera.Check() // Check if we have access to camera
        }).alert(isPresented: $camera.alert) {
            Alert(title: Text("Please Enable Camera Access"))
        }
        } // geometryReader
        
    } // body
} // View

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
