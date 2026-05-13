//
//  SCEEngine.m
//  ScreenCaptureSample
//
//  SCE Facade — 전체 API 제공, 상태 관리
//

#import "SCEEngine.h"
#import "SCEDisplayManager.h"
#import "SCEStreamManager.h"

@interface SCEEngine () <SCEStreamManagerDelegate, SCEDisplayManagerDelegate>

@property (nonatomic, assign) SCEEngineState state;
@property (nonatomic, strong) SCEDisplayManager *displayManager;
@property (nonatomic, strong) SCEStreamManager *streamManager;

@end

@implementation SCEEngine

- (instancetype)init {
    self = [super init];
    if (self) {
        _state = SCEEngineStateStopped;
        _captureType = SCECaptureTypeScreenCaptureKit;
        _frameRate = kSCEDefaultFrameRate;
        _showsCursor = YES;
        _monitorIndex = 0;

        _displayManager = [[SCEDisplayManager alloc] init];
        _displayManager.delegate = self;

        _streamManager = [[SCEStreamManager alloc] init];
        _streamManager.delegate = self;
    }
    return self;
}

- (void)dealloc {
    [self stop];
}

#pragma mark - Public Methods

- (BOOL)start:(NSError **)error {
    if (self.state != SCEEngineStateStopped) {
        return NO;
    }

    BOOL refreshed = [self.displayManager refreshDisplayListSync];
    if (!refreshed || self.displayManager.displayCount == 0) {
        if (error) {
            *error = [NSError errorWithDomain:kSCEErrorDomain
                                         code:SCEErrorCodeNoDisplayFound
                                     userInfo:@{NSLocalizedDescriptionKey: @"디스플레이를 찾을 수 없습니다."}];
        }
        [self transitionToState:SCEEngineStateInitFailed];
        return NO;
    }

    SCDisplay *targetDisplay = [self.displayManager scDisplayForIndex:self.monitorIndex];
    if (!targetDisplay) {
        if (error) {
            *error = [NSError errorWithDomain:kSCEErrorDomain
                                         code:SCEErrorCodeInvalidDisplay
                                     userInfo:@{NSLocalizedDescriptionKey: @"유효하지 않은 디스플레이 인덱스입니다."}];
        }
        [self transitionToState:SCEEngineStateInitFailed];
        return NO;
    }

    self.streamManager.frameRate = self.frameRate;
    self.streamManager.showsCursor = self.showsCursor;

    NSError *captureError = nil;
    BOOL success = [self.streamManager startCaptureWithDisplay:targetDisplay error:&captureError];
    if (!success) {
        if (error) {
            *error = captureError;
        }
        [self transitionToState:SCEEngineStateCaptureFailed];
        return NO;
    }

    [self transitionToState:SCEEngineStateRunning];
    return YES;
}

- (void)stop {
    if (self.state == SCEEngineStateStopped) return;

    [self.streamManager stopCapture];
    [self transitionToState:SCEEngineStateStopped];
}

- (void)refreshDisplays {
    [self.displayManager refreshDisplayList];
}

- (nullable SCEDisplayInfo *)displayInfoForIndex:(NSInteger)index {
    return [self.displayManager displayInfoForIndex:index];
}

#pragma mark - Private Methods

- (void)transitionToState:(SCEEngineState)newState {
    if (self.state == newState) return;

    self.state = newState;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate engine:self didChangeState:newState];
    });
}

#pragma mark - SCEStreamManagerDelegate

- (void)streamManager:(SCEStreamManager *)manager didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    [self.delegate engine:self didOutputSampleBuffer:sampleBuffer];
}

- (void)streamManager:(SCEStreamManager *)manager didFailWithError:(NSError *)error {
    [self transitionToState:SCEEngineStateCaptureFailed];
    if ([self.delegate respondsToSelector:@selector(engine:didFailWithError:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate engine:self didFailWithError:error];
        });
    }
}

#pragma mark - SCEDisplayManagerDelegate

- (void)displayManagerDidUpdateDisplays:(SCEDisplayManager *)manager {
}

- (void)displayManager:(SCEDisplayManager *)manager didFailWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(engine:didFailWithError:)]) {
        [self.delegate engine:self didFailWithError:error];
    }
}

- (NSUInteger)displayCount {
    return self.displayManager.displayCount;
}

@end
