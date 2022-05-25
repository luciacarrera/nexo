//
//  CameraModel.swift
//  nexo_test
//
//  Created by Lucía on 5/19/22.
//

import Foundation

import SwiftUI
import Combine
import AVFoundation

// Model of Camera to pass all information from the camera service to the view
final class CameraModel: ObservableObject {
    
    // MARK: Vars & Constants
    private let service = CameraService()
    
    @Published var photo: Photo!
        
    @Published var showAlertError = false
    
    @Published var isFlashOn = false
    
    @Published var willCapturePhoto = false
    
    @Published var photosSaved = false
    
    @Published var done = false
    
    var alertError: AlertError!
    
    var session: AVCaptureSession
    
    private var subscriptions = Set<AnyCancellable>()
    private var bleManager: BLEManager?
    
    // MARK: Initializer
    init() {
        self.session = service.session
        
        service.$photo.sink { [weak self] (photo) in
            guard let pic = photo else { return }
            self?.photo = pic
        }
        .store(in: &self.subscriptions)
        
        service.$shouldShowAlertView.sink { [weak self] (val) in
            self?.alertError = self?.service.alertError
            self?.showAlertError = val
        }
        .store(in: &self.subscriptions)
        
        service.$flashMode.sink { [weak self] (mode) in
            self?.isFlashOn = mode == .on
        }
        .store(in: &self.subscriptions)
        
        service.$willCapturePhoto.sink { [weak self] (val) in
            self?.willCapturePhoto = val
        }.store(in: &self.subscriptions)
        
        
        service.$photosSaved.sink { [weak self] (val) in
            self?.photosSaved = val
        }.store(in: &self.subscriptions)
        
    }
    
    // MARK: Functions
    func configure() {
        service.checkForPermissions()
        service.configure()
    }
    
    func capturePhoto() {
        service.capturePhoto()
    }
    
    func flipCamera() {
        service.changeCamera()
    }
    
    func zoom(with factor: CGFloat) {
        service.set(zoom: factor)
    }
    
    func switchFlash() {
        service.flashMode = service.flashMode == .on ? .off : .on
    }
    
    func savePhoto(photoData: Data){
        service.savePhoto(data: photoData)
    }
    
}
