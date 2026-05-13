//
//  SCETestPanelController.m
//  ScreenCaptureSample
//
//  SCEEngine 테스트 컨트롤 패널
//

#import "SCETestPanelController.h"
#import "SCEEngine.h"

@interface SCETestPanelController () <SCEEngineDelegate>

@property (nonatomic, strong) SCEEngine *engine;
@property (nonatomic, strong) NSTextField *stateLabel;
@property (nonatomic, strong) NSTextField *frameCountLabel;
@property (nonatomic, strong) NSPopUpButton *monitorPopUp;
@property (nonatomic, strong) NSButton *startStopButton;
@property (nonatomic, assign) NSUInteger frameCount;

@end

@implementation SCETestPanelController

- (instancetype)init {
    NSWindow *window = [[NSWindow alloc]
        initWithContentRect:NSMakeRect(0, 0, 360, 600)
                  styleMask:(NSWindowStyleMaskTitled |
                             NSWindowStyleMaskClosable |
                             NSWindowStyleMaskMiniaturizable |
                             NSWindowStyleMaskResizable)
                    backing:NSBackingStoreBuffered
                      defer:NO];
    window.title = @"SCE Test Panel";
    window.minSize = NSMakeSize(360, 400);
    [window center];

    self = [super initWithWindow:window];
    if (self) {
        _engine = [[SCEEngine alloc] init];
        _engine.delegate = self;
        _frameCount = 0;
        [self setupUI];
    }
    return self;
}

#pragma mark - Private Methods

- (void)setupUI {
    NSView *contentView = self.window.contentView;
    CGFloat y = 550;

    self.stateLabel = [NSTextField labelWithString:@"State: Stopped (0)"];
    self.stateLabel.font = [NSFont monospacedSystemFontOfSize:13 weight:NSFontWeightMedium];
    self.stateLabel.frame = NSMakeRect(20, y, 320, 20);
    [contentView addSubview:self.stateLabel];
    y -= 30;

    self.frameCountLabel = [NSTextField labelWithString:@"Frames: 0"];
    self.frameCountLabel.font = [NSFont monospacedSystemFontOfSize:13 weight:NSFontWeightRegular];
    self.frameCountLabel.frame = NSMakeRect(20, y, 320, 20);
    [contentView addSubview:self.frameCountLabel];
    y -= 40;

    NSTextField *monitorLabel = [NSTextField labelWithString:@"Monitor:"];
    monitorLabel.font = [NSFont systemFontOfSize:12 weight:NSFontWeightMedium];
    monitorLabel.frame = NSMakeRect(20, y, 70, 20);
    [contentView addSubview:monitorLabel];

    self.monitorPopUp = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(90, y - 2, 190, 25) pullsDown:NO];
    [self.monitorPopUp addItemWithTitle:@"(Refresh to load)"];
    [contentView addSubview:self.monitorPopUp];

    NSButton *refreshButton = [NSButton buttonWithTitle:@"Refresh" target:self action:@selector(refreshMonitors:)];
    refreshButton.frame = NSMakeRect(285, y - 2, 55, 25);
    refreshButton.font = [NSFont systemFontOfSize:11];
    [contentView addSubview:refreshButton];
    y -= 40;

    self.startStopButton = [NSButton buttonWithTitle:@"Start" target:self action:@selector(startStopClicked:)];
    self.startStopButton.bezelStyle = NSBezelStyleRounded;
    self.startStopButton.frame = NSMakeRect(20, y, 320, 32);
    self.startStopButton.font = [NSFont systemFontOfSize:14 weight:NSFontWeightMedium];
    [contentView addSubview:self.startStopButton];

    [self refreshMonitors:nil];
}

- (void)refreshMonitors:(nullable id)sender {
    [self.engine refreshDisplays];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateMonitorPopUp];
    });
}

- (void)updateMonitorPopUp {
    [self.monitorPopUp removeAllItems];

    NSUInteger count = self.engine.displayCount;
    if (count == 0) {
        [self.monitorPopUp addItemWithTitle:@"(No displays found)"];
        return;
    }

    for (NSUInteger i = 0; i < count; i++) {
        SCEDisplayInfo *info = [self.engine displayInfoForIndex:i];
        if (info) {
            NSString *title = [NSString stringWithFormat:@"%lu: %@ (%ldx%ld)",
                               (unsigned long)i, info.name, (long)info.width, (long)info.height];
            [self.monitorPopUp addItemWithTitle:title];
        }
    }
}

- (void)startStopClicked:(id)sender {
    if (self.engine.state == SCEEngineStateStopped) {
        self.engine.monitorIndex = self.monitorPopUp.indexOfSelectedItem;

        NSError *error = nil;
        if (![self.engine start:&error]) {
            NSLog(@"[SCE] Start failed: %@", error.localizedDescription);
            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = @"Start Failed";
            alert.informativeText = error.localizedDescription ?: @"Unknown error";
            [alert addButtonWithTitle:@"OK"];
            [alert runModal];
        }
    } else {
        [self.engine stop];
    }
}

- (void)updateUIForState:(SCEEngineState)state {
    NSString *stateName;
    switch (state) {
        case SCEEngineStateStopped:        stateName = @"Stopped"; break;
        case SCEEngineStateRunning:        stateName = @"Running"; break;
        case SCEEngineStatePaused:         stateName = @"Paused"; break;
        case SCEEngineStateOptionChanging: stateName = @"OptionChanging"; break;
        case SCEEngineStateOptionChanged:  stateName = @"OptionChanged"; break;
        case SCEEngineStateFailed:         stateName = @"Failed"; break;
        case SCEEngineStateInitFailed:     stateName = @"InitFailed"; break;
        case SCEEngineStateCaptureFailed:  stateName = @"CaptureFailed"; break;
        case SCEEngineStateEncoderFailed:  stateName = @"EncoderFailed"; break;
        default:                           stateName = @"Unknown"; break;
    }

    self.stateLabel.stringValue = [NSString stringWithFormat:@"State: %@ (%ld)", stateName, (long)state];

    BOOL isRunning = (state == SCEEngineStateRunning);
    self.startStopButton.title = isRunning ? @"Stop" : @"Start";
    self.monitorPopUp.enabled = !isRunning;

    if (state == SCEEngineStateStopped) {
        self.frameCount = 0;
        self.frameCountLabel.stringValue = @"Frames: 0";
    }
}

#pragma mark - SCEEngineDelegate

- (void)engine:(SCEEngine *)engine didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.frameCount++;
        self.frameCountLabel.stringValue = [NSString stringWithFormat:@"Frames: %lu", (unsigned long)self.frameCount];
    });
}

- (void)engine:(SCEEngine *)engine didChangeState:(SCEEngineState)state {
    [self updateUIForState:state];
}

- (void)engine:(SCEEngine *)engine didFailWithError:(NSError *)error {
    NSLog(@"[SCE] Engine error: %@", error.localizedDescription);
    if (self.engine.state == SCEEngineStateStopped) {
        self.engine.monitorIndex = self.monitorPopUp.indexOfSelectedItem;

        NSError *error = nil;
        if (![self.engine start:&error]) {
            NSLog(@"[SCE] Start failed: %@", error.localizedDescription);
            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = @"Start Failed";
            alert.informativeText = error.localizedDescription ?: @"Unknown error";
            [alert addButtonWithTitle:@"OK"];
            [alert runModal];
        }
    } else {
        [self.engine stop];
    }
}

@end
