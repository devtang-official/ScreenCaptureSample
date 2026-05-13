//
//  SCEDisplayManager.h
//  ScreenCaptureSample
//
//

#import <Foundation/Foundation.h>
#import "SCEDisplayInfo.h"
#import <ScreenCaptureKit/ScreenCaptureKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SCEDisplayManager;

@protocol SCEDisplayManagerDelegate <NSObject>
@optional
- (void)displayManagerDidUpdateDisplays:(SCEDisplayManager *)manager;
- (void)displayManager:(SCEDisplayManager *)manager didFailWithError:(NSError *)error;
@end

/**
 * @brief SCShareableContent 기반 디스플레이 열거/관리
 * @discussion 메인 디스플레이를 인덱스 0에 배치한다.
 */
@interface SCEDisplayManager : NSObject

@property (nonatomic, weak, nullable) id<SCEDisplayManagerDelegate> delegate;
@property (nonatomic, readonly) NSArray<SCEDisplayInfo *> *displays;
@property (nonatomic, readonly) NSUInteger displayCount;

- (void)refreshDisplayList;

// 동기 버전. 타임아웃 3초. 메인 스레드에서 호출 금지.
- (BOOL)refreshDisplayListSync;

- (nullable SCEDisplayInfo *)displayInfoForIndex:(NSInteger)index;
- (nullable SCDisplay *)scDisplayForIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
