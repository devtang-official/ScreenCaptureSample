//
//  SCEDisplayManager.m
//  ScreenCaptureSample
//
//  디스플레이 열거 및 관리
//

#import "SCEDisplayManager.h"
#import "SCEDefines.h"

@interface SCEDisplayManager ()

@property (nonatomic, strong) NSArray<SCEDisplayInfo *> *displays;
@property (nonatomic, strong) NSArray<SCDisplay *> *scDisplays;

@end

@implementation SCEDisplayManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _displays = @[];
        _scDisplays = @[];
    }
    return self;
}

#pragma mark - Public Methods

- (void)refreshDisplayList {
    [SCShareableContent getShareableContentWithCompletionHandler:^(SCShareableContent * _Nullable content, NSError * _Nullable error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(displayManager:didFailWithError:)]) {
                    [self.delegate displayManager:self didFailWithError:error];
                }
            });
            return;
        }

        [self processShareableContent:content];

        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(displayManagerDidUpdateDisplays:)]) {
                [self.delegate displayManagerDidUpdateDisplays:self];
            }
        });
    }];
}

- (BOOL)refreshDisplayListSync {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL success = NO;

    [SCShareableContent getShareableContentWithCompletionHandler:^(SCShareableContent * _Nullable content, NSError * _Nullable error) {
        if (!error && content) {
            [self processShareableContent:content];
            success = YES;
        }
        dispatch_semaphore_signal(semaphore);
    }];

    long result = dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC));
    return (result == 0) && success;
}

- (nullable SCEDisplayInfo *)displayInfoForIndex:(NSInteger)index {
    if (index < 0 || index >= (NSInteger)self.displays.count) {
        return nil;
    }
    return self.displays[index];
}

- (nullable SCDisplay *)scDisplayForIndex:(NSInteger)index {
    if (index < 0 || index >= (NSInteger)self.scDisplays.count) {
        return nil;
    }
    return self.scDisplays[index];
}

#pragma mark - Private Methods

// 메인 디스플레이를 인덱스 0에 배치하고, SCDisplay → SCEDisplayInfo 변환
- (void)processShareableContent:(SCShareableContent *)content {
    NSArray<SCDisplay *> *rawDisplays = content.displays;
    if (rawDisplays.count == 0) {
        self.scDisplays = @[];
        self.displays = @[];
        return;
    }

    CGDirectDisplayID mainID = CGMainDisplayID();
    NSMutableArray<SCDisplay *> *sorted = [NSMutableArray arrayWithCapacity:rawDisplays.count];

    for (SCDisplay *d in rawDisplays) {
        if (d.displayID == mainID) {
            [sorted addObject:d];
            break;
        }
    }
    for (SCDisplay *d in rawDisplays) {
        if (d.displayID != mainID) {
            [sorted addObject:d];
        }
    }

    self.scDisplays = [sorted copy];

    NSMutableArray<SCEDisplayInfo *> *infos = [NSMutableArray arrayWithCapacity:sorted.count];
    for (SCDisplay *d in sorted) {
        [infos addObject:[[SCEDisplayInfo alloc] initWithSCDisplay:d]];
    }
    self.displays = [infos copy];
}

- (NSUInteger)displayCount {
    return self.displays.count;
}

@end
