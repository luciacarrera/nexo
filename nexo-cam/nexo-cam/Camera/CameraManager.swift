//
//  CameraManager.swift
//  nexo-cam
//
//  Created by Lucía on 5/16/22.
//

import AVFoundation

// Created a class that conforms to ObservableObject to make it easier to use with future Combine code.
class CameraManager: ObservableObject {
    
    // An error to represent any camera-related error. You made it a published property so that other objects can subscribe to this stream and handle any errors as necessary.
    @Published var error: CameraError?

    // AVCaptureSession, which will coordinate sending the camera images to the appropriate data outputs.
    let session = AVCaptureSession()

    // A session queue, which you’ll use to change any of the camera configurations.
    private let sessionQueue = DispatchQueue(label: "lucia.SessionQ")

    // The video data output that will connect to AVCaptureSession. You’ll want this stored as a property so you can change the delegate after the session is configured
    private let videoOutput = AVCaptureVideoDataOutput()

    // The current status of the camera.
    private var status = Status.unconfigured


    // Added an internal enumeration to represent the status of the camera.
    enum Status {
    case unconfigured
    case configured
    case unauthorized
    case failed
    }

    // Included a static shared instance of the camera manager to make it easily accessible.
    static let shared = CameraManager()

    // Turned the camera manager into a singleton by making init private.
    private init() {
    configure()
    }
    
    private func configure() {
        checkPermissions()
        sessionQueue.async {
          self.configureCaptureSession()
          self.session.startRunning()
        }
    } // end of configure
    
    private func set(error: CameraError?) {
      DispatchQueue.main.async {
        self.error = error
      }
    } // End of set
    
    private func checkPermissions() {
      // 1
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .notDetermined:
                sessionQueue.suspend()
                AVCaptureDevice.requestAccess(for: .video) { authorized in
                  // 3
                  if !authorized {
                    self.status = .unauthorized
                    self.set(error: .deniedAuthorization)
                  }
                  self.sessionQueue.resume()
                }

            case .restricted:
                status = .unauthorized
                set(error: .restrictedAuthorization)
            
            case .denied:
                status = .unauthorized
                set(error: .deniedAuthorization)

            case .authorized:
                break

            @unknown default:
                status = .unauthorized
                set(error: .unknownAuthorization)
      }
        
    } // End of checkpermissions
    
    private func configureCaptureSession() {
        guard status == .unconfigured else {
            return
        }
        session.beginConfiguration()
        defer {
            session.commitConfiguration()
        }
        
        let device = AVCaptureDevice.default(
          .builtInWideAngleCamera,
          for: .video,
          position: .back)
        
        guard let camera = device else {
          set(error: .cameraUnavailable)
          status = .failed
          return
        }
        
        do {
          // 1
          let cameraInput = try AVCaptureDeviceInput(device: camera)
          // 2
          if session.canAddInput(cameraInput) {
            session.addInput(cameraInput)
          } else {
            // 3
            set(error: .cannotAddInput)
            status = .failed
            return
          }
        } catch {
          // 4
          set(error: .createCaptureInput(error))
          status = .failed
          return
        }
        
        if session.canAddOutput(videoOutput) {
          session.addOutput(videoOutput)
          // 2
          videoOutput.videoSettings =
            [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
          // 3
          let videoConnection = videoOutput.connection(with: .video)
          videoConnection?.videoOrientation = .portrait
        } else {
          // 4
          set(error: .cannotAddOutput)
          status = .failed
          return
        }
        
        status = .configured

    } // End of configureCaptureSession
    
    func set(
      _ delegate: AVCaptureVideoDataOutputSampleBufferDelegate,
      queue: DispatchQueue
    ) {
      sessionQueue.async {
        self.videoOutput.setSampleBufferDelegate(delegate, queue: queue)
      }
    } // End of set
}

