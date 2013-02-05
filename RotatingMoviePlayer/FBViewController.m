//
//  FBViewController.m
//  RotatingMoviePlayer
//
//  Created by Fábio Bernardo on 2/4/13.
//  Copyright (c) 2013 Fábio Bernardo. All rights reserved.
//

#import "FBViewController.h"
#import "FBMoviePlayerController.h"

@interface FBViewController ()
@property (nonatomic, strong) MPMoviePlayerController *moviePlayerController;
@end

@implementation FBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGRect videoRect = (CGRect) {
        .size.width = 300,
        .size.height = 169,
        .origin.x = roundf((CGRectGetWidth(self.view.bounds) - 300) / 2),
        .origin.y = roundf((CGRectGetHeight(self.view.bounds) - 169) / 2)
    };
    
    self.moviePlayerController = [[FBMoviePlayerController alloc]
                                           initWithContentURL:[NSURL URLWithString:@"http://videos.sapo.pt/sl2RhMW2OoSOlacLWSFB/mov/1"]];
    
    self.moviePlayerController.view.frame = videoRect;
    self.moviePlayerController.view.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin |
                                                        UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    [self.moviePlayerController prepareToPlay];
    
    
    [self.view addSubview:self.moviePlayerController.view];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    //for FBMoviePlayer to have complete control over the rotation animations you should return NO here.
    return self.moviePlayerController.isFullscreen ? NO : toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
