//
//  SCEEngine.h
//  ScreenCaptureSample
//
//

#import <Foundation/Foundation.h>
#import "SCEDefines.h"
#import "SCEDisplayInfo.h"
#import <CoreMedia/CoreMedia.h>

NS_ASSUME_NONNULL_BEGIN

@class SCEEngine;

@protocol SCEEngineDelegate <NSObject>
@required
- (void)engine:(SCEEngine *)engine didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer;
- (void)engine:(SCEEngine *)engine didChangeState:(SCEEngineState)state;
@optional
- (void)engine:(SCEEngine *)engine didFailWithError:(NSError *)error;
@end

@interface SCEEngine : NSObject

@property (nonatomic, weak, nullable) id<SCEEngineDelegate> delegate;
@property (nonatomic, readonly) SCEEngineState state;
@property (nonatomic, readonly) SCECaptureType captureType;
@property (nonatomic, assign) NSInteger monitorIndex;
@property (nonatomic, readonly) NSUInteger displayCount;
@property (nonatomic, assign) NSInteger frameRate;
@property (nonatomic, assign) BOOL showsCursor;

// state가 Stopped일 때만 호출 가능
- (BOOL)start:(NSError **)error;
- (void)stop;

- (void)refreshDisplays;
- (nullable SCEDisplayInfo *)displayInfoForIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
