//
//  InvadersAppDelegate.h
//  Invaders
//
//  Created by Knightmare on 08.10.09.
//  Copyright XorsTeam 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "xors3d.h"

@interface InvadersAppDelegate : NSObject <UIApplicationDelegate>
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

