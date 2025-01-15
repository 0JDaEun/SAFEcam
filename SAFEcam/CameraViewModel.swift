//
//  CameraViewModel.swift
//  SAFEcam
//
//  Created by 정다은 on 1/15/25.
//

import AVFoundation
import UIKit

class CameraViewModel: NSObject, ObservableObject {
    @Published var captureSession: AVCaptureSession?
    private var videoDevice: AVCaptureDevice?

    func setupCamera() {
        let session = AVCaptureSession()
        session.sessionPreset = .photo
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
        self.videoDevice = device
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            session.addInput(input)
        } catch {
            print("Error setting up camera input: \(error)")
        }
        
        self.captureSession = session
        self.captureSession?.startRunning()
    }
    
    func takePhoto() {
        guard let captureSession = captureSession else { return }
        let photoOutput = AVCapturePhotoOutput()
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.flashMode = .auto // 플래시 설정
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
}

extension CameraViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            return
        }
        guard let imageData = photo.fileDataRepresentation() else { return }
        let image = UIImage(data: imageData)
        // 저장 또는 UI 업데이트
    }
}
