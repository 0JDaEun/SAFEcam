//
//  SAFEcamApp.swift
//  SAFEcam
//
//  Created by 정다은 on 1/15/25.
//

// os : Apple의 운영 체제 관련 기능을 제공하는 프레임워크. 로깅할 때 사용됨.
import os
import SwiftUI

// @main : 하단의 구조체가 앱의 시작점임을 의미함
@main
// struct : 구조체, SAFEcamAPP : 앱 이름, App : SwiftUI의 'App'프로토콜 준수. 앱의 구조와 동작 정의.
struct SAFEcamApp: App {
    // @State : 상태 관리. 값이 변경되면 자동으로 업데이트 됨. property wrapper
    // 프라이빗 변수로 카메라 선언
    @State private var camera = CameraModel()
    // @Environment : 환경 값에 접근할 수 있게 해주는 property wrapper
    // scenePhase : 앱의 현재 상태(활성, 비활성, 백그라운드 등)을 가져와서 변수에 담음.
    @Environment(\.scenePhase) var scenePhase
    
    // 프로토콜 필수 구현 부분. 앱의 내용을 정의함.
    var body: some Scene {
        // WindowGroup : 앱의 주 창을 의미.
        WindowGroup {
            // CameraView를 표시함. 'camera'인스턴스를 매개변수로 받음 ?
            CameraView(camera: camera)
            // 상태바를 숨김
                .statusBarHidden(true)
            // 비동기 카메라 시작까지 기다리기
                .task {
                    await camera.start()
                }
            // .onChange : scenePhase가 변경될 때마다 호출되는 클로저 정의. 그러니까 카메라냐 동영상이냐 플래시 버튼을 눌렀냐 안눌렀냐 등등 특정 값이 변경될때마다 호출됨 ?
                .onChange(of: scenePhase) { _, newPhase in
                    // guard : 해당 문장은 카메라가 실행중이고 && 앱이 활성 상태일때만 코드 실행하라는 뜻
                    // 조건문 if같은것
                    // guard 조건 else 로 썼을 경우, 조기탈출 가능
                    guard camera.status == .running, newPhase == .active else { return }
                    // 메인 스레드에서 비동기 작업 수행
                    Task { @MainActor in
                        // 카메라 상태 동기화
                        await camera.syncState()
                    }
                }
        }
    }
}

// 로그 가져와야하니까. 상수
let logger = Logger()
