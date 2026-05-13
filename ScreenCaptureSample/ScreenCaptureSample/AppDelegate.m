//
//  AppDelegate.m
//  ScreenCaptureSample
//
//  Created by devtang on 5/7/26.
//

#import "AppDelegate.h"
#import "SCETestPanelController.h"

@interface AppDelegate ()

@property (strong) IBOutlet NSWindow *window;
@property (strong) SCETestPanelController *testPanelController;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.testPanelController = [[SCETestPanelController alloc] init];
    [self.testPanelController showWindow:nil];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}


@end
