//
//  ControlView.swift
//  nexo-cam
//
//  Created by Lucía on 5/16/22.
//

import SwiftUI

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.80 : 1)
    }
}

struct CameraControlView: View {
    @EnvironmentObject var camera: CameraViewModel

  var body: some View {
      let manager = camera.cameraManager

    VStack {
        HStack{
            Spacer()
            Image(systemName: "x.circle.fill").resizable()
                .frame(width: 30.0, height: 30.0)
                .foregroundColor(.white).padding()
            Spacer().frame(width: 5.0)
        }
        
        
      Spacer()
        /*HStack{
            Button(action: {
                manager.toggleFlash()
            }, label: {
                if manager.flashMode == .off {
                    Image(systemName: "bolt.slash").resizable()
                        .frame(width: 30.0, height: 30.0)
                        .foregroundColor(.white).padding()

                }else {
                    Image(systemName: "bolt").resizable()
                        .frame(width: 30.0, height: 30.0)
                        .foregroundColor(.white).padding()
                }
            })*/
        ZStack{
            Circle()
                .stroke(Color.white,style: StrokeStyle(lineWidth: 5))
                .frame(width: 80, height: 80)
                
                
            Button(action: {
                print("take pic")
            }, label: {
                Circle()
                    .frame(width: 70, height: 70)
                    .foregroundColor(.white)
                    .padding()
            }).buttonStyle(ScaleButtonStyle()) // End of button
        }.padding() // End of ZStack
           
                   //Spacer()
        //}// End of HStack for flash
        
        
    } // End of VStack
  } // End of body
} // End of View

struct CameraControlView_Previews: PreviewProvider {
  static var previews: some View {
    ZStack {
      Color.green
        .edgesIgnoringSafeArea(.all)

      CameraControlView()
    }
  }
}

