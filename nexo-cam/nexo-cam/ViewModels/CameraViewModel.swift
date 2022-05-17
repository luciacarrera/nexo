//
//  CameraViewModel.swift
//  nexo-cam
//
//  Created by Lucía on 5/16/22.
//

import CoreImage

class CameraViewModel: ObservableObject {
    @Published var frame: CGImage?
    private let frameManager = FrameManager.shared
    @Published var error: Error?
    let cameraManager = CameraManager.shared

    init() {
    setupSubscriptions()
    }
    // 3
    func setupSubscriptions() {
        
        // Tap into the Publisher provided automatically for the published CameraManager.error.
        cameraManager.$error
        
          // Receive it on the main thread.
          .receive(on: RunLoop.main)
        
          //Map it to itself, because otherwise Swift will complain in the next line that you can’t assign a CameraError to an Error.
          .map { $0 }
          // Assign it to error.
          .assign(to: &$error)
            
          // 1
          frameManager.$current
            // 2
            .receive(on: RunLoop.main)
            // 3
            .compactMap { buffer in
              return CGImage.create(from: buffer)
            }
            // 4
            .assign(to: &$frame)
    }
}
