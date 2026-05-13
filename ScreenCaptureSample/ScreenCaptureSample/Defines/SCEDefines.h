//
//  SCEDefines.h
//  ScreenCaptureSample
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - SCECaptureType

/**
 * @brief 화면 캡처 방식을 지정하는 열거형
 * @discussion 현재는 ScreenCaptureKit만 지원. 나머지는 향후 확장용으로 정의만 존재.
 */
typedef NS_ENUM(NSInteger, SCECaptureType) {
    SCECaptureTypeScreenCaptureKit = 0,  // ScreenCaptureKit (기본값, macOS 14.4+)
    SCECaptureTypeAVFoundation     = 1,  // 미구현
    SCECaptureTypeCGDisplayStream  = 2,  // 미구현
    SCECaptureTypeExternal         = 3,  // 미구현
};

#pragma mark - SCEEncoderType

/**
 * @brief VideoToolbox HW 인코더 코덱 종류
 * @discussion 모든 인코더는 VideoToolbox 하드웨어 가속을 사용한다.
 */
typedef NS_ENUM(NSInteger, SCEEncoderType) {
    SCEEncoderTypeH264 = 0,  // H.264 HW 인코더
    SCEEncoderTypeH265 = 1,  // HEVC HW 인코더
    SCEEncoderTypeAV1  = 2,  // AV1 HW 인코더
};

#pragma mark - SCEEngineState

/**
 * @brief 엔진의 현재 동작 상태
 * @discussion 양수 값은 정상 상태, 음수 값은 오류 상태를 나타낸다.
 */
typedef NS_ENUM(NSInteger, SCEEngineState) {
    SCEEngineStateStopped        =    0,  // 정지 상태 (초기값)
    SCEEngineStateRunning        =    1,  // 캡처 + 인코딩 동작 중
    SCEEngineStatePaused         =    2,  // 일시 정지 (pause mask에 의해 결정)
    SCEEngineStateOptionChanging =    3,  // 옵션 변경 진행 중
    SCEEngineStateOptionChanged  =    4,  // 옵션 변경 완료
    SCEEngineStateFailed         = -100,  // 일반 실패
    SCEEngineStateInitFailed     = -101,  // 초기화 실패
    SCEEngineStateCaptureFailed  = -102,  // 캡처 실패
    SCEEngineStateEncoderFailed  = -103,  // 인코더 실패
};

#pragma mark - SCEPauseMask

/**
 * @brief 일시 정지 원인을 비트마스크로 표현
 * @discussion 여러 원인이 동시에 존재할 수 있다. 모든 비트가 해제되어야 resume 된다.
 */
typedef NS_OPTIONS(NSUInteger, SCEPauseMask) {
    SCEPauseMaskNone           = 0,       // 정지 원인 없음
    SCEPauseMaskUser           = 1 << 0,  // 사용자가 수동으로 일시 정지
    SCEPauseMaskSleep          = 1 << 1,  // 시스템 슬립으로 인한 일시 정지
    SCEPauseMaskInvalidSession = 1 << 2,  // 세션 무효로 인한 일시 정지
};

#pragma mark - SCEErrorCode

/**
 * @brief SCE 에러 도메인에서 사용하는 에러 코드
 * @discussion NSError의 code 값으로 사용. 도메인은 kSCEErrorDomain.
 */
typedef NS_ENUM(NSInteger, SCEErrorCode) {
    SCEErrorCodeInvalidDisplay    = 100,  // 유효하지 않은 디스플레이
    SCEErrorCodeInvalidSession    = 101,  // 유효하지 않은 세션
    SCEErrorCodeInvalidDesktop    = 102,  // 유효하지 않은 데스크톱
    SCEErrorCodeResolutionChanged = 103,  // 해상도 변경 감지
    SCEErrorCodeCaptureTimeout    = 104,  // 캡처 타임아웃
    SCEErrorCodeEncoderInit       = 105,  // 인코더 초기화 실패
    SCEErrorCodePermissionDenied  = 106,  // 화면 녹화 권한 거부
    SCEErrorCodeNoDisplayFound    = 107,  // 디스플레이를 찾을 수 없음
};

#pragma mark - SCEChromaType

/**
 * @brief 인코더 크로마 서브샘플링 타입
 * @discussion 현재는 4:2:0만 구현. 4:4:4는 정의만 존재 (구현 보류).
 */
typedef NS_ENUM(NSInteger, SCEChromaType) {
    SCEChromaType420 = 0,  // YUV 4:2:0 (기본)
    SCEChromaType444 = 1,  // YUV 4:4:4
};

#pragma mark - SCEQualityParams

/**
 * @brief 인코딩 품질 관련 파라미터를 묶어서 전달하는 구조체
 */
typedef struct {
    int quality;     // CRF/QP 값 (낮을수록 고화질)
    int qualityMax;  // 최대 CRF/QP 상한값
    int qualityStep; // 적응형 품질 조절 시 스텝 크기
    int bitrate;     // 목표 비트레이트 (kbps). 0이면 CRF 모드
    int bufferSize;  // VBV 버퍼 크기 (kbps)
} SCEQualityParams;

#pragma mark - 상수

extern NSErrorDomain const kSCEErrorDomain;
extern const NSInteger kSCEDefaultFrameRate;

NS_ASSUME_NONNULL_END
