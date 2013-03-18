//
//  PhysicsAppDelegate.h
//  Physics
//
//  Created by Knightmare on 07.02.10.
//  Copyright XorsTeam 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "xors3d.h"

@interface PhysicsAppDelegate : NSObject <UIApplicationDelegate>
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