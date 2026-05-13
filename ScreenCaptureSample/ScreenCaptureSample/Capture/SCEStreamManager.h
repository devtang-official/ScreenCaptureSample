//
//  SCEStreamManager.h
//  ScreenCaptureSample


#import <Foundation/Foundation.h>
#import <ScreenCaptureKit/ScreenCaptureKit.h>
#import <CoreMedia/CoreMedia.h>

NS_ASSUME_NONNULL_BEGIN

@class SCEStreamManager;

@protocol SCEStreamManagerDelegate <NSObject>
@required
- (void)streamManager:(SCEStreamManager *)manager didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer;
@optional
- (void)streamManager:(SCEStreamManager *)manager didFailWithError:(NSError *)error;
@end

@interface SCEStreamManager : NSObject

@property (nonatomic, weak, nullable) id<SCEStreamManagerDelegate> delegate;
@property (nonatomic, assign) NSInteger frameRate;
@property (nonatomic, assign) BOOL showsCursor;

- (BOOL)startCaptureWithDisplay:(SCDisplay *)display error:(NSError **)error;
- (void)stopCapture;
- (void)updateStreamConfiguration;

@end

NS_ASSUME_NONNULL_END
