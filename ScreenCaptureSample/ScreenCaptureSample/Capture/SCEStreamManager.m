//
//  SCEStreamManager.m
//  ScreenCaptureSample
//
//  ScreenCaptureKit SCStream 래퍼
//

#import "SCEStreamManager.h"
#import "SCEDefines.h"

@interface SCEStreamManager () <SCStreamOutput, SCStreamDelegate>

@property (nonatomic, strong, nullable) SCStream *stream;
@property (nonatomic, strong) dispatch_queue_t captureQueue;
@property (nonatomic, assign) NSInteger captureWidth;
@property (nonatomic, assign) NSInteger captureHeight;

@end

@implementation SCEStreamManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _frameRate = kSCEDefaultFrameRate;
        _showsCursor = YES;
        _captureQueue = dispatch_queue_create("com.sce.capture", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

#pragma mark - Public Methods

- (BOOL)startCaptureWithDisplay:(SCDisplay *)display error:(NSError **)error {
    if (self.stream) {
        [self stopCapture];
    }

    self.captureWidth = (NSInteger)display.width;
    self.captureHeight = (NSInteger)display.height;

    SCStreamConfiguration *config = [self buildStreamConfiguration];
    SCContentFilter *filter = [self buildContentFilterWithDisplay:display];

    self.stream = [[SCStream alloc] initWithFilter:filter configuration:config delegate:self];

    NSError *addOutputError = nil;
    BOOL added = [self.stream addStreamOutput:self
                                         type:SCStreamOutputTypeScreen
                               sampleHandlerQueue:self.captureQueue
                                        error:&addOutputError];
    if (!added) {
        if (error) {
            *error = addOutputError;
        }
        self.stream = nil;
        return NO;
    }

    __weak typeof(self) weakSelf = self;
    [self.stream startCaptureWithCompletionHandler:^(NSError * _Nullable startError) {
        if (startError) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([strongSelf.delegate respondsToSelector:@selector(streamManager:didFailWithError:)]) {
                    [strongSelf.delegate streamManager:strongSelf didFailWithError:startError];
                }
            });
        }
    }];

    return YES;
}

- (void)stopCapture {
    if (!self.stream) return;

    [self.stream stopCaptureWithCompletionHandler:^(NSError * _Nullable error) {}];
    self.stream = nil;
}

- (void)updateStreamConfiguration {
    if (!self.stream) return;

    SCStreamConfiguration *config = [self buildStreamConfiguration];

    __weak typeof(self) weakSelf = self;
    [self.stream updateConfiguration:config completionHandler:^(NSError * _Nullable error) {
        if (error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([strongSelf.delegate respondsToSelector:@selector(streamManager:didFailWithError:)]) {
                    [strongSelf.delegate streamManager:strongSelf didFailWithError:error];
                }
            });
        }
    }];
}

#pragma mark - Private Methods

- (SCStreamConfiguration *)buildStreamConfiguration {
    SCStreamConfiguration *config = [[SCStreamConfiguration alloc] init];
    config.width = self.captureWidth;
    config.height = self.captureHeight;
    config.minimumFrameInterval = CMTimeMake(1, (int32_t)self.frameRate);
    config.pixelFormat = kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange; // NV12
    config.showsCursor = self.showsCursor;
    config.capturesAudio = NO;
    return config;
}

- (SCContentFilter *)buildContentFilterWithDisplay:(SCDisplay *)display {
    return [[SCContentFilter alloc] initWithDisplay:display excludingWindows:@[]];
}

#pragma mark - SCStreamOutput

- (void)stream:(SCStream *)stream didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer ofType:(SCStreamOutputType)type {
    if (type != SCStreamOutputTypeScreen) return;
    if (!CMSampleBufferIsValid(sampleBuffer)) return;

    [self.delegate streamManager:self didOutputSampleBuffer:sampleBuffer];
}

#pragma mark - SCStreamDelegate

- (void)stream:(SCStream *)stream didStopWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(streamManager:didFailWithError:)]) {
            [self.delegate streamManager:self didFailWithError:error];
        }
    });
}

@end
