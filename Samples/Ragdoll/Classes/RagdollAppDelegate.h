//
//  RagdollAppDelegate.h
//  Ragdoll
//
//  Created by Knightmare on 11.08.10.
//  Copyright 2010 XorsTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "xors3d.h"

@interface RagdollAppDelegate : NSObject <UIApplicationDelegate>
{
    UIWindow       * window;
    NSTimer        * animationTimer;
    NSTimeInterval   animationInterval;
}

@property (nonatomic, retain) IBOutlet UIWindow * window;
@property (nonatomic, assign) NSTimer           * animationTimer;
@property NSTimeInterval                          animationInterval;

- (void)startAnimation;
- (void)stopAnimation;
- (void)drawView;

@end

