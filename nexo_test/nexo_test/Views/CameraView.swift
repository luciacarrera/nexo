//
//  CentralView.swift
//  nexo_test
//
//  Created by Lucía on 4/27/22.
//

import SwiftUI

struct CameraView: View {
    
    // MARK: BLE Constants & Vars
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var bleManager: BLEManager
    @State private var showAlert = false
    @Environment(\.dismiss) var dismiss
    
    // MARK: Camera Constants & Vars
    @StateObject var model = CameraModel()
    @State var currentZoomFactor: CGFloat = 1.0
    @State private var alertSavePhotos = false
    
    var flipCameraButton: some View {
        Button(action: {
            model.flipCamera()
        }, label: {
            Circle()
                .fill(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.mint]), startPoint: .leading, endPoint: .trailing))
                .frame(width: 45, height: 45, alignment: .center)
                .overlay(
                    Image(systemName: "camera.rotate.fill")
                        .foregroundColor(.white))
        })
    }
    
    var flashButton: some View {
        Button(action: {
            model.switchFlash()
        }, label: {
            Circle()
                .fill(LinearGradient(gradient: Gradient(colors: [Color.teal, Color.blue]), startPoint: .leading, endPoint: .trailing))
                .frame(width: 45, height: 45, alignment: .center)
                .overlay(
                Image(systemName: model.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                    .font(.system(size: 20, weight: .medium, design: .default))
                )
            
        })
        .accentColor(model.isFlashOn ? .yellow : .white)
    }
    
    
    // MARK: Body
    // ---------------------------------------------------------------------
    @ViewBuilder
    var body: some View {
            VStack{
                GeometryReader{ reader in
                    VStack {
                        Text("Camera")
                        CameraPreview(session: model.session)
                            .gesture(
                                DragGesture().onChanged({ (val) in
                                    //  Only accept vertical drag
                                    if abs(val.translation.height) > abs(val.translation.width) {
                                        //  Get the percentage of vertical screen space covered by drag
                                        let percentage: CGFloat = -(val.translation.height / reader.size.height)
                                        //  Calculate new zoom factor
                                        let calc = currentZoomFactor + percentage
                                        //  Limit zoom factor to a maximum of 5x and a minimum of 1x
                                        let zoomFactor: CGFloat = min(max(calc, 1), 5)
                                        //  Store the newly calculated zoom factor
                                        currentZoomFactor = zoomFactor
                                        //  Sets the zoom factor to the capture device session
                                        model.zoom(with: zoomFactor)
                                    }
                                })
                            ) // End of CameraPreview.gesture
                        
                            .onAppear {
                                model.configure()
                                bleManager.configureCamera(camera: model)
                            }
                            .alert(isPresented: $model.showAlertError, content: {
                                Alert(title: Text(model.alertError.title), message: Text(model.alertError.message), dismissButton: .default(Text(model.alertError.primaryButtonTitle), action: {
                                    model.alertError.primaryAction?()
                                }))
                            }) // end of alert
                            .overlay(
                                withAnimation(.easeInOut(duration: 4)) {
                                    Group {
                                        if model.willCapturePhoto {
                                            //model.capturePhoto()
                                            Color.white
                                        }
                                    }
                                }
                            ) // End of overlay
                        HStack {
                            flashButton
                            Spacer()
                            flipCameraButton
                        }// End of Hstack
                        .padding(.horizontal, 20)
                    } // End of VStack
                }
                
            } // Vstack
    } // body
} // view

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
