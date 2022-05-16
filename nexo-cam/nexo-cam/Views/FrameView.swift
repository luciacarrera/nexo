//
//  FrameView.swift
//  nexo-cam
//
//  Created by Lucía on 5/16/22.
//

import SwiftUI

struct FrameView: View {
    var image: CGImage?
    private let label = Text("Camera feed")
    
    var body: some View {
        
        // Conditionally unwrap the optional image.
        if let image = image {
            
          // Set up a GeometryReader to access the size of the view. This is necessary to ensure the image is clipped to the screen bounds. Otherwise, UI elements on the screen could potentially be anchored to the bounds of the image instead of the screen.
          GeometryReader { geometry in
              
            // Create Image from CGImage, scale it to fill the frame and clip it to the bounds. Here, you set the orientation to .upMirrored, because you’ll be using the front camera. If you wanted to use the back camera, this would need to be .up.
            Image(image, scale: 1.0, orientation: .upMirrored, label: label)
              .resizable()
              .scaledToFill()
              .frame(
                width: geometry.size.width,
                height: geometry.size.height,
                alignment: .center)
              .clipped()
          }
        } else {
          // Return a black view if the image property is nil.
          Color.green
        }
    }
}

struct FrameView_Previews: PreviewProvider {
    static var previews: some View {
        FrameView()
    }
}
