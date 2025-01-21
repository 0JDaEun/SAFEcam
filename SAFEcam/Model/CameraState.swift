// 카메라의 상태를 나타내는 파일

import os
// Foundation : 기본적인 데이터 타입과 기능을 제공하는 프레임워크
import Foundation

// 해당 구조체를 Codable 프로토콜을 선택해 인코딩과 디코딩이 가능하게함
struct CameraState: Codable {
    
    // 라이브 포토, 속도및품질, HDR비디오 지원여부, HDR비디오 켜짐여부, 촬영모드들 가져와서 저장
    var isLivePhotoEnabled = true {
        didSet { save() }
    }
    
    var qualityPrioritization = QualityPrioritization.quality {
        didSet { save() }
    }
    
    var isVideoHDRSupported = true {
        didSet { save() }
    }
    
    var isVideoHDREnabled = true {
        didSet { save() }
    }
    
    var captureMode = CaptureMode.photo {
        didSet { save() }
    }
    
    // save 함수. 이곳 내에서만 사용 가능
    private func save() {
        Task {
            do {
                // 앱의 목적을 현재 앱의 상황을 반영하여 업데이트
                try await AVCamCaptureIntent.updateAppContext(self)
            } catch {
                // 실패시 디버그 로그 남기기
                os.Logger().debug("Unable to update intent context: \(error.localizedDescription)")
            }
        }
    }
    
    // 정적 프로퍼티, 현재 카메라의 상태
    static var current: CameraState {
        // 비동기적으로 가져오기
        get async {
            do {
                // AVCamCaptureIntent 위에서 저장한 컨텍스트 값을 가져와서 반환
                if let context = try await AVCamCaptureIntent.appContext {
                    return context
                }
            } catch {
                // 실패시 로그 남기기고 새로운 CameraState() 인스턴스 반환
                os.Logger().debug("Unable to fetch intent context: \(error.localizedDescription)")
            }
            return CameraState()
        }
    }
}
