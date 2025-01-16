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
            // 카메라 프리뷰
            if let session = viewModel.captureSession {
                CameraPreview(session: session)
                    .edgesIgnoringSafeArea(.all)
            } else {
                Text("Loading Camera...")
                    .foregroundColor(.gray)
            }
            
            // 상단 버튼
            VStack {
                HStack(spacing: 24) {
                    CameraActionButton(icon: "camera.filters", label: "필터", action: viewModel.applyFilter)
                    CameraActionButton(icon: "bolt.circle", label: "플래시", action: viewModel.toggleFlash)
                    CameraActionButton(icon: "info.circle", label: "정보", action: viewModel.showInfo)
                    CameraActionButton(icon: "arrow.triangle.2.circlepath.camera", label: "전환", action: viewModel.switchCamera)
                    CameraActionButton(icon: "timer", label: "타이머", action: viewModel.setTimer)
                    CameraActionButton(icon: "aspectratio", label: "비율", action: viewModel.changeAspectRatio)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 24)
                .padding(.horizontal)
                .background(Color.white.opacity(0.9))
                
                Spacer()
                
                // 하단 촬영 버튼
                Button(action: {
                    viewModel.capturePhoto()
                }) {
                    Rectangle()
                        .fill(Color.white)
                        .frame(maxWidth: .infinity, maxHeight: 100)
                        .shadow(radius: 5)
                }
                .padding(.bottom, 0)
            }
        }
        .onAppear {
            viewModel.setupCamera()
        }
    }
}

struct CameraActionButton: View {
    let icon: String
    let label: String
    let action: () -> Void
    
    var body: some View {
        VStack {
            Button(action: action) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.black)
            }
            Text(label)
                .font(.caption)
                .foregroundColor(.black)
        }
    }
}
