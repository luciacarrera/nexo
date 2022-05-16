//
//  ContentView.swift
//  nexo-cam
//
//  Created by Lucía on 5/16/22.
//

import SwiftUI

struct CameraView: View {
  var body: some View {
    ZStack {
        FrameView(image: nil)
          .edgesIgnoringSafeArea(.all)
    } // End of ZStack
  } // End of body
} // End of View struct

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    CameraView()
  }
}
