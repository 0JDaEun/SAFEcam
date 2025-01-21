//
//  CameraModel.swift
//  SAFEcam
//
//  Created by 정다은 on 1/21/25.
//

import SwiftUI
// Apple의 반응형 프로그래밍 프레임워크, 비동기 이벤트 처리를 위해 사용
import Combine

// SwiftUI에서 이 클래스의 프로퍼티 변경을 관찰할 수 잇게 해주는 매크로
@Observable
// final로 선언했으므로 해당 클래스는 상속 불가능. Camera 프로토콜 준수함
final class CameraModel: Camera {
    
    // private(set) : 외부에서 읽을수는 있지만 변경은 내부에서만 가능 CameraStatus.unknown : 카메라의 초기 상태 나타냄
    private(set) var status = CameraStatus.unknown
    
    // 현재 사진 또는 동영상 캡처가 진행중 여부
    private(set) var captureActivity = CaptureActivity.idle
    
    // 비디오 장치 전환 여부 나타냄
    private(set) var isSwitchingVideoDevices = false
    
    // UI 최소화 상태 선호 여부
    private(set) var prefersMinimizedUI = false
    
    // 모드 전환 상태 여부
    private(set) var isSwitchingModes = false
    
    // 촬영시 시각적 피드백 제공 여부
    private(set) var shouldFlashScreen = false
    
    // 썸네일 이미지 저장. 처음일시 nil값 존재 가능
    private(set) var thumbnail: CGImage?
    
    // 에러 상태 나타냄
    private(set) var error: Error?
    
    // 촬영 세션과 비디오 프리뷰 레이어(비디오 촬영중이면 해당 화면이 보이므로)간의 연결을 제공하는 객체
    // 계산 프로퍼티로 'previewSource' 반환 why
    var previewSource: PreviewSource { captureService.previewSource }
    
    // HDR 비디오 지원 여부
    private(set) var isHDRVideoSupported = false
    
    // 촬영된 미디어를 사용자의 라이브러리에 젖아하는 객체
    // private let 클래스 내부에서만 접근 가능한 상수 - 미디어 값은 변경되면 안되기에 상수처리
    private let mediaLibrary = MediaLibrary()
    
    // 앱의 촬영 기능을 관리하는 객체 why
    private let captureService = CaptureService()
    
    // 앱과 촬영 확장간의 공유되는 지속적인 상태 why
    private var cameraState = CameraState()
    
    // 초기화 메서드 현재 구현되지 않음
    init() {
        //
    }
    
    // MARK: - Starting the camera
    // 카메라 시작 함수. 비동기적으로 실행됨
    func start() async {
        // 비동기 조건 : 권한 받은 상태인지 여부
        // 권한이 없다면 상태를 .unauthorized로 설정 후 함수 종료
        guard await captureService.isAuthorized else {
            status = .unauthorized
            return
        }
        // do-catch 블록
        do {
            // syncState()로 상태 동기화.
            await syncState()
            // cameraState로 촬영 서비스 시작
            try await captureService.start(with: cameraState)
            // 상태 관찰 시작
            observeState()
            // 성공시 상태를 '.running'으로 설정
            status = .running
        } catch {
            // 실패시 에러 로그를 남기고 상태를 .failed로 설정
            logger.error("Failed to start capture service. \(error)")
            status = .failed
        }
    }
    
    // 상태 동기화 함수
    func syncState() async {
        // 현재 카메라의 상태를 가져와서 해당하는 값들에 넣기
        cameraState = await CameraState.current
        captureMode = cameraState.captureMode
        qualityPrioritization = cameraState.qualityPrioritization
        isLivePhotoEnabled = cameraState.isLivePhotoEnabled
        isHDRVideoEnabled = cameraState.isVideoHDREnabled
    }
    
    // MARK: - Changing modes and devices
    
    // 캡처모드.사진 을 초기값으로 가지는 프로퍼티
    var captureMode = CaptureMode.photo {
        // didSet : 프로퍼티 옵저버를 통해 값이 변경될 때 행해지는 동작 정의
        // captureMode가 변경 될때마다 실행됨
        didSet {
            // 카메라가 .running중이 아니라면 바로 반환
            guard status == .running else { return }
            // Task : 이 블록으로 비동기 작업 생성
            Task {
                // 모드 전환이 시작될 때 isSwitchingModes true로
                isSwitchingModes = true
                // defer : 현재 스코프가 종료될 때 실행되며, 모드 전환 완료 후 해당 버튼을 다시 false로 변경
                defer { isSwitchingModes = false }
                // setCaptureMode 함수를 호출해 실제 카메라 하드웨어의 촬영 모드 변경
                // try? : 오류가 발생해도 프로그램을 중단하지 않고 계속 실행하라는 뜻
                try? await captureService.setCaptureMode(captureMode)
                // 변경된 촬영 모드를 cameraState에 반영
                cameraState.captureMode = captureMode
            }
        }
    }
    
    // 사진 모드에서 비디오 모드로 전환하는 함수
    func switchVideoDevices() async {
        // 해당 변수값을 true로 작성
        isSwitchingVideoDevices = true
        // defer : 이 함수 종료시 해당 값을 false로 바꿔줌
        defer { isSwitchingVideoDevices = false }
        // 촬영서비스의 다음 비디오 장치 선택 함수를 요청
        await captureService.selectNextVideoDevice()
    }
    
    // MARK: - Photo capture
    
    // 사진을 촬영해서 갤러리에 저장하는 함수
    func capturePhoto() async {
        do {
            // 촬영 옵션 확인, 라이브 포토가 켜져있는지, 품질과 속도 우선순위가 어떤지 확인
            let photoFeatures = PhotoFeatures(isLivePhotoEnabled: isLivePhotoEnabled, qualityPrioritization: qualityPrioritization)
            // photoFeatures : 사진 촬영 옵션 설정, 옵션 설정해서 사진 촬영. 사진은 상수로 저장.
            let photo = try await captureService.capturePhoto(with: photoFeatures)
            // 갤러리에 사진 저장
            try await mediaLibrary.save(photo: photo)
        } catch {
            // 에러 발생시 self.error에 에러 저장
            self.error = error
        }
    }
    
    // 라이브 포토 값 트루로 기본 설정
    var isLivePhotoEnabled = true {
        didSet {
            // 해당 값이 변경될때마다 상태 업데이트
            cameraState.isLivePhotoEnabled = isLivePhotoEnabled
        }
    }
    
    // 사진 촬영 시 품질과 속도의 우선순위 관리
    // QualityPrioritization.quality에서 가져옴
    var qualityPrioritization = QualityPrioritization.quality {
        didSet {
            // 값이 변경될 때 상태 업데이트
            cameraState.qualityPrioritization = qualityPrioritization
        }
    }
    
    // 지정된 좌표에서 초점 조절하는 함수
    func focusAndExpose(at point: CGPoint) async {
        await captureService.focusAndExpose(at: point)
    }
    
    // 촬영이 진행중임을 시각적으로 표현하는 함수. 내부에서만 변경 가능
    private func flashScreen() {
        // 해당 변수값 true fh
        shouldFlashScreen = true
        // doslapdltus vyrhk wjrdyd. 0.01초동안 선형 애니메이션
        withAnimation(.linear(duration: 0.01)) {
            // 해당 작업이 끝난 후 다시 값을 false로
            shouldFlashScreen = false
        }
    }
    
    // MARK: - Video capture
    // HDR비디오. 평소에는 false
    var isHDRVideoEnabled = false {
        didSet {
            // 비디오 모드가 실행중일때만 작동. 아니면 return
            guard status == .running, captureMode == .video else { return }
            // 실행중일때 할 일
            Task {
                // HDR비디오모드로 변경
                await captureService.setHDRVideoEnabled(isHDRVideoEnabled)
                // 해당 상태 업데이트 반영
                cameraState.isVideoHDREnabled = isHDRVideoEnabled
            }
        }
    }
    
    // 녹화 상태 전환
    func toggleRecording() async {
        // 촬영 상태 가져와서 스위치문
        switch await captureService.captureActivity {
        // 만약 동영상 촬영 상태라면
        case .movieCapture:
            do {
                // 동영상 촬영이 stop까지 기다렸다가 동영상 받아옴
                let movie = try await captureService.stopRecording()
                // 갤러리에 동영상으로 저장
                try await mediaLibrary.save(movie: movie)
            } catch {
                // 에러 발생시 저장
                self.error = error
            }
        default:
            // 기본적으로는 start레코딩 상태
            await captureService.startRecording()
        }
    }
    
    // MARK: - Internal state observations
    
    // 카메라의 다양한 상태를 관찰하는 함수
    private func observeState() {
        // 1. 썸네일 관찰
        Task {
            // 라이브러리에서 생성되는 새 썸네일을 관찰 및 업데이트
            // compactMap : 시퀀스의 각 요소에 클로저를 적용해서 nil이 아닌 결과만을 포함하는 컬렉션 반환
            // { $0 } : 각 요소를 그대로 반환하는 클로저
            // 클로저란? 이름 없는 함수, 실행 가능한 코드블록. 변수나 상수에 저장하거나 함수의 인자로 전달 가능
            for await thumbnail in
                mediaLibrary.thumbnails.compactMap({ $0 }) {
                self.thumbnail = thumbnail
            }
        }
        
        // 2. 촬영의 활동 상태 관찰
        Task {
            // & : 프로퍼티 래퍼 구문. captureActivity가 관찰 가능한 프로퍼티임을 나타냄
            // .values로 값에 접근
            for await activity in await
                captureService.$captureActivity.values {
                // 곧 촬영이 시작된다면
                if activity.willCapture {
                    // 촬영시 시각적 피드백 함수 작동
                    flashScreen()
                } else {
                    // 아니라면 아닌 현재 값을 프로퍼티에 할당
                    captureActivity = activity
                }
            }
        }
        
        // 3. 촬영 서비스의 기능 업데이트를 관찰
        Task {
            // HDR비디오 지원여부 값을 가져와서 업데이트
            for await capabilities in await captureService.$captureCapabilities.values {
                isHDRVideoSupported = capabilities.isHDRSupported
                cameraState.isVideoHDRSupported = capabilities.isHDRSupported
            }
        }
        
        // 4. 전체 화면 컨트롤의 표시 여부 관찰
        Task {
            for await isShowingFullscreenControls in await captureService.$isShowingFullscreenControls.values {
                // withAnimation : SwiftUI의 애니메이션ㄴ함수. 해당 블록 내의 상태 변경이 애니메이션과 함께 적용되게끔
                withAnimation {
                    // 전체 화면 컨트롤이 표시될 때 UI를 최소화하겠다
                    prefersMinimizedUI = isShowingFullscreenControls
                }
            }
        }
    }
}
