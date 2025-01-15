//
//  ContentView.swift
//  SAFEcam
//
//  Created by 정다은 on 1/15/25.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var viewModel = CameraViewModel()
    
    var body: some View {
        ZStack {
            // 카메라 프리뷰 표시
            CameraPreview(session: viewModel.captureSession ?? AVCaptureSession())
                .edgesIgnoringSafeArea(.all)
            
            // 버튼 UI
            VStack {
                Spacer() // 위쪽 공간 확보
                HStack {
                    CameraActionButton(icon: "photo.on.rectangle", label: "갤러리") {
                        viewModel.openGallery()
                    }
                    Spacer()
                    CameraActionButton(icon: "camera.circle", label: "촬영", action: viewModel.takePhoto)
                    Spacer()
                    CameraActionButton(icon: "gearshape", label: "설정", action: viewModel.openSettings)
                }
                .padding()
                .background(Color.white.opacity(0.8)) // 버튼 배경색
                .cornerRadius(16)
                .padding(.bottom, 16) // 아래쪽 간격
            }
        }
        .onAppear {
            viewModel.checkCameraPermission() // 카메라 권한 확인
        }
    }
}
