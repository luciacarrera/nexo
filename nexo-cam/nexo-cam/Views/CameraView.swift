//
//  ContentView.swift
//  nexo-cam
//
//  Created by Lucía on 5/16/22.
//

import SwiftUI

struct CameraView: View {
    
    @StateObject private var model = CameraViewModel()
    
    
  var body: some View {
    ZStack {
        Color.orange.edgesIgnoringSafeArea(.all)

        
        FrameView(image: model.frame)
        
        CameraErrorView(error: model.error)
        
        CameraControlView()
        
    } // End of ZStack
  } // End of body
} // End of View struct

struct CameraView_Previews: PreviewProvider {
  static var previews: some View {
    CameraView()
  }
}
