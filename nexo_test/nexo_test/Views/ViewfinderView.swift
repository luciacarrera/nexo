//
//  PeripheralView.swift
//  nexo_test
//
//  Created by Lucía on 4/27/22.
//

import SwiftUI

struct ViewfinderView: View {
    
    // MARK: BLE Constants & Vars
    @EnvironmentObject var bleManager: BLEManager
    
    // MARK: Camera Constants & Vars
    @StateObject var model = CameraModel()
    @State var currentZoomFactor: CGFloat = 1.0
    @State private var alertSavePhotos = false
    @State private var photoCaputured = false
    //var cameraPreviewFound = true

    var capturedPhotoThumbnail: some View {
        Group {
            if let pic = UIImage(data: model.photo.originalData) {
                Image(uiImage: pic)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    //.animation(.spring())
                
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 60, height: 60, alignment: .center)
                    .foregroundColor(.black)
            }
        }
    }
    
    var captureButton: some View {
        Button(action: {
            bleManager.shutterPressed()
        }, label: {
            Circle()
                .fill(LinearGradient(gradient: Gradient(colors: [Color.green, Color.mint]), startPoint: .leading, endPoint: .trailing))
                .frame(width: 70, height: 70)
                .padding()
        }).buttonStyle(ScaleBtn())
    }
    
    var captureRing: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(gradient: Gradient(colors: [Color.green, Color.mint]), startPoint: .leading, endPoint: .trailing))
                .frame(width: 80, height: 80)

            Circle()
                .fill(Color.white)
                .frame(width: 75, height: 75)
        }
    }
    
    var flipCameraButton: some View {
        Button(action: {
            print("Flip camera request")
        }, label: {
            Circle()
                .fill(LinearGradient(gradient: Gradient(colors: [Color.green, Color.mint]), startPoint: .leading, endPoint: .trailing))
                .frame(width: 45, height: 45, alignment: .center)
                .overlay(
                    Image(systemName: "camera.rotate.fill")
                        .foregroundColor(.white))
        })
    }
    
    var flashButton: some View {
        Button(action: {
            print("Flash request")
        }, label: {
            Circle()
                .fill(LinearGradient(gradient: Gradient(colors: [Color.green, Color.mint]), startPoint: .leading, endPoint: .trailing))
                .frame(width: 45, height: 45, alignment: .center)
                .overlay(
                Image(systemName: model.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                    .font(.system(size: 20, weight: .medium, design: .default))
                )
            
        })
        .accentColor(model.isFlashOn ? .yellow : .white)
    }
    
    var body: some View {
        
        if bleManager.isPaired {
            GeometryReader { reader in
                let width = reader.size.width
                let height43 = width / 3 * 4
                    VStack {
                        Text("Viewfinder")
                        if model.photosSaved == false{
                            VStack{
                                //Spacer()
                                //Text("Everything is setup")
                                Text("You can start taking pictures")
                                //Spacer()
                            }//.frame(width: width, height: height43, alignment: .center)
                        } else {
                            //photo
                            capturedPhotoThumbnail
                        }
                        HStack {
                            flashButton
                            Spacer()
                            ZStack{
                                captureRing
                                captureButton
                            }
                            Spacer()
                            flipCameraButton
                        }// End of Hstack
                        .padding(.horizontal, 50)
                                           
                    } // End of VStack
                    .onAppear {
                        bleManager.configureCamera(camera: model)
                    }
            }
        } else{
            VStack {
                Spacer()
                Text("Your code:")
                Text(bleManager.pairValue).font(.largeTitle)
                Spacer()
            }
        }
       
    }
}

struct ViewfinderView_Previews: PreviewProvider {
    static var previews: some View {
        ViewfinderView()
    }
}
