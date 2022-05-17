//
//  ContentView.swift
//  nexo-cam
//
//  Created by Lucía on 5/16/22.
//

import SwiftUI

struct CameraView: View {
    
    @StateObject private var camera = CameraViewModel()
    
    
  var body: some View {
    ZStack {
        Color.orange.edgesIgnoringSafeArea(.all)

        
        FrameView(image: camera.frame)
        
        CameraErrorView(error: camera.error)
        
        CameraControlView()
        
    } // End of ZStack
    .environmentObject(camera)
  } // End of body
} // End of View struct
    

struct CameraView_Previews: PreviewProvider {
  static var previews: some View {
    CameraView()
  }
}
