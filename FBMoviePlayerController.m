//
//  FBMoviePlayerController.m
//  RotatingMoviePlayer
//
//  Created by Fábio Bernardo on 2/4/13.
//  Copyright (c) 2013 Fábio Bernardo. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "FBMoviePlayerController.h"

@implementation FBMoviePlayerController {
    BOOL _observingNotifications;
    BOOL _forceRotations;

    CGAffineTransform _previousWindowTransform;
    CGRect _previousWindowBounds;
    UIInterfaceOrientation _previousStatusBarOrientation;

    UIInterfaceOrientation _lastOrientation;
}

- (id)initWithContentURL:(NSURL *)url {
    self = [super initWithContentURL:url];
    if (self) {
        //Force rotations to iOS 5
        _forceRotations = [self isIOS5];

        if (_forceRotations) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterFullscreen:) name:MPMoviePlayerWillEnterFullscreenNotification object:self];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willExitFullscreen:) name:MPMoviePlayerWillExitFullscreenNotification object:self];
        }
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - MPMoviePlayerController Notifications

- (void)willEnterFullscreen:(NSNotification *)notification {
    //Save window state
    UIApplication *app = [UIApplication sharedApplication];
    UIWindow *window = app.keyWindow;
    _previousWindowTransform = window.transform;
    _previousWindowBounds = window.bounds;
    _lastOrientation = _previousStatusBarOrientation = app.statusBarOrientation;

    //Start listening for device orientation changes
    [self subscribeOrientationNotifications];
}

- (void)willExitFullscreen:(NSNotification *)notification {
    //Stop listening for device orientation changes
    [self unsubscribeOrientationNotifications];

    //Restore window state
    UIApplication *app = [UIApplication sharedApplication];
    UIWindow *window = app.keyWindow;
    window.transform = _previousWindowTransform;
    window.bounds = _previousWindowBounds;
    app.statusBarOrientation = _previousStatusBarOrientation;
}

#pragma mark - UIDeviceOrientation Notifications

- (void)deviceDidChangeOrientation:(NSNotification *)notification {
    //Force window to follow device orientation
    UIDeviceOrientation toInterfaceOrientation = [[UIDevice currentDevice] orientation];

    UIApplication *app = [UIApplication sharedApplication];
    if (toInterfaceOrientation == UIDeviceOrientationLandscapeLeft) {
        [self animateStatusBarToOrientation:UIInterfaceOrientationLandscapeRight];
    } else if (toInterfaceOrientation == UIDeviceOrientationLandscapeRight) {
        [self animateStatusBarToOrientation:UIInterfaceOrientationLandscapeLeft];
    } else if (toInterfaceOrientation == UIDeviceOrientationPortrait) {
        [self animateStatusBarToOrientation:UIInterfaceOrientationPortrait];
    }


    //Fix the movie player fullscreen view
    //it's ugly but it works
    //if you know a better way issue a pull request or something
    UIWindow *window = app.keyWindow;
    UIView *thatSpecialView = [[[self.backgroundView superview] superview] superview];
    CGRect rect = window.bounds;
    rect.origin.y -= 20;
    thatSpecialView.frame = rect;
}

#pragma mark - UIApplication Notifications

- (void)statusBarWillChangeOrientation:(NSNotification *)notification {
    NSNumber *number = notification.userInfo[UIApplicationStatusBarOrientationUserInfoKey];
    if (!number) return;
    [self forceWindowIntoOrientation:(UIInterfaceOrientation) [number integerValue] animated:YES];
}

#pragma mark - Private Methods

- (void)forceWindowIntoOrientation:(UIInterfaceOrientation)orientation animated:(BOOL)animated {
    UIApplication *app = [UIApplication sharedApplication];
    UIWindow *window = app.keyWindow;
    UIScreen *screen = window.screen;

    CGFloat angle = 0;
    CGSize screenSize = screen.bounds.size;
    CGRect windowBounds = (CGRect) {.size = screenSize};

    switch (orientation) {
        case UIInterfaceOrientationLandscapeLeft: {
            windowBounds.size = (CGSize) {.width = screenSize.height, .height = screenSize.width };
            angle = (CGFloat) -M_PI_2;
            break;
        }
        case UIInterfaceOrientationLandscapeRight: {
            windowBounds.size = (CGSize) {.width = screenSize.height, .height = screenSize.width };
            angle = (CGFloat) M_PI_2;
            break;
        }
    }

    if (animated) {
        NSTimeInterval duration = [self animationDurationFromOrientation:_lastOrientation to:orientation];
        [UIView beginAnimations:@"windowTransform" context:NULL];
        [UIView setAnimationDuration:duration];
        [UIView setAnimationBeginsFromCurrentState:YES];
    }

    window.transform = CGAffineTransformMakeRotation(angle);        
    window.bounds = windowBounds;

    if (animated) {
        [UIView commitAnimations];
    }

    _lastOrientation = orientation;

}

- (NSTimeInterval)animationDurationFromOrientation:(UIInterfaceOrientation)fromOrientation
                                                to:(UIInterfaceOrientation)toOrientation {
    if (fromOrientation == toOrientation) return 0;

    UIApplication *app = [UIApplication sharedApplication];
    NSTimeInterval duration = app.statusBarOrientationAnimationDuration;
    if ((UIInterfaceOrientationIsLandscape(fromOrientation) && UIInterfaceOrientationIsLandscape(toOrientation)) ||
            (UIInterfaceOrientationIsPortrait(fromOrientation) && UIInterfaceOrientationIsPortrait(toOrientation))) {
        duration*=2;
    }
    return duration;
}

- (void)animateStatusBarToOrientation:(UIInterfaceOrientation)orientation {
    UIApplication *app = [UIApplication sharedApplication];
    UIInterfaceOrientation fromOrientation = app.statusBarOrientation;
    if (fromOrientation != orientation) {
        [UIView beginAnimations:@"statusBarRotation" context:NULL];
        [UIView setAnimationDuration:[self animationDurationFromOrientation:fromOrientation to:orientation]];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [app setStatusBarOrientation:orientation animated:NO];
        [UIView commitAnimations];
    }
}

- (BOOL)isIOS5 {
    NSComparisonResult result = [@"6" compare:[[UIDevice currentDevice] systemVersion] options:NSNumericSearch];
    BOOL prior6 = result == NSOrderedDescending;

    result = [@"5" compare:[[UIDevice currentDevice] systemVersion] options:NSNumericSearch];
    BOOL after5 = result == NSOrderedAscending || result == NSOrderedSame;

    BOOL iOS5 = prior6 && after5;
    return iOS5;
}

- (void)subscribeOrientationNotifications {
    if (_observingNotifications) return;

    UIDevice *device = [UIDevice currentDevice];
    [device beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(statusBarWillChangeOrientation:)
                                                 name:UIApplicationWillChangeStatusBarOrientationNotification
                                               object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceDidChangeOrientation:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:device];

    _observingNotifications = YES;
}

- (void)unsubscribeOrientationNotifications {
    if (!_observingNotifications) return;

    UIDevice *device = [UIDevice currentDevice];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:device];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillChangeStatusBarOrientationNotification
                                                  object:[UIApplication sharedApplication]];
    [device endGeneratingDeviceOrientationNotifications];

    _observingNotifications = NO;
}

@end
