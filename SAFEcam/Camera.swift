//
//  Camera.swift
//  SAFEcam
//
//  Created by 정다은 on 1/21/25.
//

// UIKit과 비교했을 때 속도가 더 빠르고, UI의 변화를 실시간 확인 가능, 하나의 코드베이스로 여러 Apple 플랫폼에서 동작하는 앱 제작 가능 등
import SwiftUI

// @MainActor : 프로토콜의 모든 요구사항이 메인 스레드에서 실행되어야 하는 것을 나타내는 어노테이션
@MainActor
// protocol : 프로토콜을 정의하는 키워드, Camera : 파일명, AnyObject : 이 프로토콜은 클래스 타입에만 적용될 수 있음을 나타냄
protocol Camera: AnyObject {
    // var : 변수 선언, status : 프로퍼티의 타입
    // property란? 변수, 함수, 클래스, 객체를 아우른 것. CameraStatus : 타입
    // var 변수명: 타입
    // swift에서는 모든 선언을 var(변수) 또는 let(상수)로 하고, 그 다음에 오는게 프로퍼티
    // 프로퍼티에서의 함수 기능은 일종의 자바 객체 함수와 유사함. 사용법도. 일반 func은 매개변수 사용 및 반환 가능.
    // { get }은 해당 프로퍼티가 '읽기 전용'이라는 뜻. 다시 말해 값을 가져오는 것만 가능하다는 것을 의미.
    // 카메라의 상태를 가져오는 것으로 추정됨
    var status: CameraStatus { get }

    // 카메라로 찍은 사진을 가져오는 것으로 추정됨
    var captureActivity: CaptureActivity { get }

    // 카메라 프리뷰 화면, 즉 보여지는 화면을 가져오는 것으로 추정됨
    var previewSource: PreviewSource { get }
    
    // func : 함수, start() : 이 앱의 실행을 담당하는건가?, async : 함수가 비동기적으로 실행됨을 나타냄(=백그라운드에서 실행됨)
    // 유연성과 코드 재사용성을 위해 해당 함수는 이 프로토콜을 채택하는 클래스에서 구현될 것.
    func start() async

    // 사진을 찍는 모드 즉 해당 기능에 달하는 버튼과 연관이 있을 것으로 추정됨 값을 가져오고 변경 또한 가능
    var captureMode: CaptureMode { get set }
    
    // 모드 전환을 위한 변수. 이것 또한 가져오는 것만 허용됨 why?
    // 예상컨데 해당 변수로 버튼의 클릭 여부를 판단해 플래시 버튼같은 것을 조작할듯
    var isSwitchingModes: Bool { get }
    
    // UI를 최소화할것인지의 여부. 이건 핵심 기능이라고 볼수는 없겠지만, 차후 확장성을 위해 필요한 변수같다. 복잡한 기능이 어렵게 느껴질 사람들을 위한 라이트 버전 제작시 사용 가능할듯
    var prefersMinimizedUI: Bool { get }

    // 비동기. 전/후면 카메라 전환에 사용될 것으로 예측
    func switchVideoDevices() async
    
    // 현재 비디오 장치로 전환중인지 아닌지 판별하는 변수. 상태 가져오기만 가능. 비디오 상태인지 아닌지에 따라 사용되는 로직이 달라져서인듯
    var isSwitchingVideoDevices: Bool { get }
    
    // 사용자가 터치한 부분에 자동 초점 및 노출 조정이 가능하게끔 하는 함수
    // at : 외부 매개변수 이름으로 함수를 호출할 때 사용, point : 내부 매개변수 이름으로 어느 부분에 초점을 맞추는지?, CGPoint : 매개변수의 타입. x,y값을 가짐.
    func focusAndExpose(at point: CGPoint) async
    
    // 라이브 포토 캡처 기능이 활성화 되어 있는지 아닌지 여부. 읽고 쓰지 다 되는거 보니 켜고 끌 수 있는 버튼.
    var isLivePhotoEnabled: Bool { get set }
    
    // 사진 캡처시 품질과 속도의 우선순위를 나타내며 읽고 쓰기 가능
    var qualityPrioritization: QualityPrioritization { get set }
    
    // 사진 찍어서 갤러리에 저장. 비동기. 갤러리에 저장될때까지 기다림.
    func capturePhoto() async
    
    // 사용자가 사진을 촬영시 특별한 모션을 제공할지 여부 ex. 셔터 버튼에 화면이 깜빡이는 효과
    var shouldFlashScreen: Bool { get }
    
    // 카메라가 HDR 비디오 녹화를 지원하는지 여부 나타냄.
    var isHDRVideoSupported: Bool { get }
    
    // HDR 비디오 버튼 켜고 끄기
    var isHDRVideoEnabled: Bool { get set }
    
    // 동영상 녹화 시작 및 중지. 사용자의 갤러리에 저장.
    func toggleRecording() async
    
    // 사용자가 가장 최근에 캡처한 사진이나 비디오의 썸네일 이미지. 미리보기 혹은 갤러리 버튼 표지에 사용 가능
    // 찍은 사진이 없을 경우 nil일 수 있어서 ? 써주기
    var thumbnail: CGImage? { get }
    
    // 에러가 발생했는지. 이것 또한 null값일 수 있음
    var error: Error? { get }
    
    // 카메라의 상태를 저장된 값과 동기화.
    func syncState() async
}
