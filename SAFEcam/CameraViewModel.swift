//
//  CameraViewModel.swift
//  SAFEcam
//
//  Created by 정다은 on 1/15/25.
//

import Foundation
import AVFoundation

class CameraViewModel: ObservableObject {
    @Published var captureSession: AVCaptureSession?
    private var currentCamera: AVCaptureDevice?
    private var isFlashOn = false
    
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
                
                DispatchQueue.main.async {
                    self?.captureSession = session
                }
                
                session.startRunning()
            } catch {
                print("Error setting up camera: \(error)")
            }
        }
    }
    
    func applyFilter() {
        print("필터 기능 실행")
    }
    
    func toggleFlash() {
        guard let camera = currentCamera else { return }
        do {
            try camera.lockForConfiguration()
            if camera.hasTorch {
                camera.torchMode = isFlashOn ? .off : .on
                isFlashOn.toggle()
            }
            camera.unlockForConfiguration()
        } catch {
            print("Flash toggle failed: \(error)")
        }
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
    
    func capturePhoto() {
        print("사진 촬영")
    }
}
