//
//  AppDelegate.m
//  PreviewApp
//
//  Created by u1 on 26.10.2023.
//

#import "AppDelegate.h"
#import "matrixwatchView.h"

@interface AppDelegate ()

@property (strong) IBOutlet NSWindow *window;
@property (strong, nonatomic) matrixwatchView *dwView;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    _dwView = [[matrixwatchView alloc] initWithFrame:CGRectZero isPreview:NO];
    _dwView.frame = _window.contentView.bounds;
    _window.backgroundColor = [NSColor blueColor];
    [_window.contentView addSubview:_dwView];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didResize:) name:NSWindowDidResizeNotification object:nil];

    [_dwView startAnimation];

}

- (void)didResize:(NSNotification *) notify{
    _dwView.frame = _window.contentView.bounds;
    [_dwView startAnimation];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}


@end
