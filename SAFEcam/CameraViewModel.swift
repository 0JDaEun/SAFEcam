//
//  CameraViewModel.swift
//  SAFEcam
//
//  Created by 정다은 on 1/15/25.
//

import Foundation
import AVFoundation
import Photos
import UIKit

class CameraViewModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var captureSession: AVCaptureSession?
    private var currentCamera: AVCaptureDevice?
    private var isFlashOn = false
    private var photoOutput: AVCapturePhotoOutput?

    func setupCamera() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let session = AVCaptureSession()
            session.sessionPreset = .photo
            
            guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                print("No back camera available.")
                return
            }
            
            self?.currentCamera = backCamera
            
            do {
                let input = try AVCaptureDeviceInput(device: backCamera)
                if session.canAddInput(input) {
                    session.addInput(input)
                }
                
                let photoOutput = AVCapturePhotoOutput()
                if session.canAddOutput(photoOutput) {
                    session.addOutput(photoOutput)
                    self?.photoOutput = photoOutput
                }
                
                // Start session on the background thread
                session.startRunning()
                
                DispatchQueue.main.async {
                    self?.captureSession = session
                }
            } catch {
                print("Error setting up camera: \(error)")
            }
        }
    }
    
    func capturePhoto() {
        guard let photoOutput = photoOutput else { return }
        let settings = AVCapturePhotoSettings()
        
        // 플래시 설정 추가
        settings.flashMode = isFlashOn ? .on : .off
        
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    private func saveImageToGallery(imageData: Data) {
        PHPhotoLibrary.shared().performChanges({
            if let image = UIImage(data: imageData) {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
        }) { success, error in
            DispatchQueue.main.async {
                if success {
                    print("사진이 갤러리에 저장되었습니다.")
                } else if let error = error {
                    print("갤러리 저장 실패: \(error)")
                }
            }
        }
    }
    
    // AVCapturePhotoCaptureDelegate 메서드
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error.localizedDescription)")
            return
        }
        
        if let imageData = photo.fileDataRepresentation() {
            saveImageToGallery(imageData: imageData)
        } else {
            print("Failed to process photo data.")
        }
    }
    
    // 추가된 메서드들
    func applyFilter() {
        print("필터 적용")
    }
    
    func toggleFlash() {
        isFlashOn.toggle()
        print("플래시 상태: \(isFlashOn ? "켜짐" : "꺼짐")")
    }
    
    func showInfo() {
        print("정보 표시")
    }
    
    func switchCamera() {
        print("카메라 전환")
    }
    
    func setTimer() {
        print("타이머 설정")
    }
    
    func changeAspectRatio() {
        print("비율 변경")
    }
}
