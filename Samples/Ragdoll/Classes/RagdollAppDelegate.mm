//
//  RagdollAppDelegate.m
//  Ragdoll
//
//  Created by Knightmare on 11.08.10.
//  Copyright 2010 XorsTeam. All rights reserved.
//

#import "RagdollAppDelegate.h"
#import "splash.h"
#import <iostream>

@implementation RagdollAppDelegate

@synthesize window;
@synthesize animationTimer;
@synthesize animationInterval;

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	// disable status bar
    [application setStatusBarHidden:YES animated:YES];
	// initialize engine
	xGraphics3D(1, false, window);
	// enable multi-touch support
	xEnableMultiTouch();
	// start menu stage
	SplashStage * splashStage = new SplashStage();
	splashStage->Load();
	// start drawing
	animationInterval = 1.0 / 60.0;
	[self startAnimation];
}

- (void)drawView
{
	// check stage
	if(Stage::GetActive() == NULL) return;
	// update stage
	Stage::GetActive()->Update();
	// render stage
	Stage::GetActive()->Render();
}

- (void)layoutSubviews
{
    xResetGraphics();
    [self drawView];
}

- (void)startAnimation
{
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval target:self selector:@selector(drawView) userInfo:nil repeats:YES];
}

- (void)stopAnimation
{
    self.animationTimer = nil;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	animationInterval = 1.0 / 5.0;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	animationInterval = 1.0 / 60.0;
}

- (void)dealloc
{
	[window release];
	[super dealloc];
}

@end