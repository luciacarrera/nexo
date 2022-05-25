//
//  PhotoSave.swift
//  nexo_test
//
//  Created by Lucía on 5/24/22.
//

import Foundation
import Photos


class PhotoSaveProcessor: NSObject {
    
    private(set) var requestedPhotoSettings: AVCapturePhotoSettings
        
    private let completionHandler: (PhotoSaveProcessor) -> Void
    
    private let photoProcessingHandler: (Bool) -> Void
    
//    The actual captured photo's data
    var photoData: Data?

    //    Init takes multiple closures to be called in each step of the photco captureprocess
    init(with requestedPhotoSettings: AVCapturePhotoSettings, completionHandler: @escaping (PhotoSaveProcessor) -> Void, photoProcessingHandler: @escaping (Bool) -> Void) {
            
            self.requestedPhotoSettings = requestedPhotoSettings
            self.completionHandler = completionHandler
            self.photoProcessingHandler = photoProcessingHandler
            
        }
    
    
    // MARK: Saves capture to photo library
    func saveToPhotoLibrary(photoData: Data) {
        self.photoData = photoData
        
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges({
                    let options = PHAssetResourceCreationOptions()
                    let creationRequest = PHAssetCreationRequest.forAsset()
                    options.uniformTypeIdentifier = self.requestedPhotoSettings.processedFileType.map { $0.rawValue }
                    creationRequest.addResource(with: .photo, data: photoData, options: options)
                    
                    
                }, completionHandler: { _, error in
                    if let error = error {
                        print("Error occurred while saving photo to photo library: \(error)")
                    }
                    
                    DispatchQueue.main.async {
                        self.completionHandler(self)
                    }
                }
                )
            } else {
                DispatchQueue.main.async {
                    self.completionHandler(self)
                }
            }
        }
    }
}
