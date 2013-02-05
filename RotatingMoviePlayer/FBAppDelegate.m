//
//  FBAppDelegate.m
//  RotatingMoviePlayer
//
//  Created by Fábio Bernardo on 2/4/13.
//  Copyright (c) 2013 Fábio Bernardo. All rights reserved.
//

#import "FBAppDelegate.h"

#import "FBViewController.h"

@implementation FBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    FBViewController *controller = [[FBViewController alloc] initWithNibName:nil bundle:nil];
    
    self.window.rootViewController = controller;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
