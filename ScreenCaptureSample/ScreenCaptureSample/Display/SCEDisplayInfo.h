//
//  SCEDisplayInfo.h
//  ScreenCaptureSample
//


#import <Cocoa/Cocoa.h>
#import <CoreGraphics/CoreGraphics.h>
#import <ScreenCaptureKit/ScreenCaptureKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief 디스플레이 한 개의 정보를 담는 모델 클래스
 * @discussion SCEDisplayManager가 열거한 디스플레이 정보를 외부에 전달할 때 사용한다.
 */
@interface SCEDisplayInfo : NSObject

@property (nonatomic, readonly) CGDirectDisplayID displayID;
@property (nonatomic, readonly) NSInteger width;
@property (nonatomic, readonly) NSInteger height;
@property (nonatomic, readonly) CGFloat scaleFactor;
@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly) BOOL isMainDisplay;

- (instancetype)initWithSCDisplay:(SCDisplay *)scDisplay;

@end

NS_ASSUME_NONNULL_END
