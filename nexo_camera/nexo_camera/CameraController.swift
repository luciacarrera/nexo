//
//  CameraController.swift
//  nexo_camera
//
//  Created by Lucía on 5/16/22.
//

import Foundation
import UIKit
import SwiftUI

struct CameraController: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = UIImagePickerController
    
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        let viewController = UIViewControllerType()
        viewController.delegate = context.coordinator
        viewController.sourceType = .camera
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    func makeCoordinator() -> CameraController.Coordinator {
        return Coordinator(self)
    }
}

extension CameraController {
    class Coordinator : NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: CameraController
        
        init(_ parent: CameraController) {
            self.parent = parent
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            print("Cancel pressed")
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
        }
    }
}
