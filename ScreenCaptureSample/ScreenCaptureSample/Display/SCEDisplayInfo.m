//
//  SCEDisplayInfo.m
//  ScreenCaptureSample
//
//  디스플레이 한 개의 정보를 담는 모델 클래스
//

#import "SCEDisplayInfo.h"
#import <ScreenCaptureKit/ScreenCaptureKit.h>

@interface SCEDisplayInfo ()

@property (nonatomic, assign) CGDirectDisplayID displayID;
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, assign) CGFloat scaleFactor;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) BOOL isMainDisplay;

@end

@implementation SCEDisplayInfo

- (instancetype)initWithSCDisplay:(SCDisplay *)scDisplay {
    self = [super init];
    if (self) {
        _displayID = scDisplay.displayID;
        _width = (NSInteger)scDisplay.width;
        _height = (NSInteger)scDisplay.height;
        _isMainDisplay = CGDisplayIsMain(_displayID);
        _scaleFactor = [self scaleFactorForDisplayID:_displayID];
        _name = [self nameForDisplayID:_displayID];
    }
    return self;
}

#pragma mark - Private Methods

// NSScreen.deviceDescription의 NSScreenNumber로 SCDisplay와 매칭
- (CGFloat)scaleFactorForDisplayID:(CGDirectDisplayID)displayID {
    for (NSScreen *screen in [NSScreen screens]) {
        NSDictionary *desc = screen.deviceDescription;
        NSNumber *screenNumber = desc[@"NSScreenNumber"];
        if (screenNumber && (CGDirectDisplayID)screenNumber.unsignedIntValue == displayID) {
            return screen.backingScaleFactor;
        }
    }
    return 1.0;
}

- (NSString *)nameForDisplayID:(CGDirectDisplayID)displayID {
    for (NSScreen *screen in [NSScreen screens]) {
        NSDictionary *desc = screen.deviceDescription;
        NSNumber *screenNumber = desc[@"NSScreenNumber"];
        if (screenNumber && (CGDirectDisplayID)screenNumber.unsignedIntValue == displayID) {
            return screen.localizedName;
        }
    }
    return @"Unknown Display";
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %@ (%ldx%ld @%.0fx) main=%@>",
            NSStringFromClass([self class]),
            self.name,
            (long)self.width,
            (long)self.height,
            self.scaleFactor,
            self.isMainDisplay ? @"YES" : @"NO"];
}

@end
