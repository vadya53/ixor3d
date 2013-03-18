//
//  iXors3DAppDelegate.h
//  iXors3D
//
//  Created by Knightmare on 01.09.09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "xors3d.h"

@interface iXors3DAppDelegate : NSObject <UIApplicationDelegate>
{
    UIWindow *window;
	int image;
	int entity;
	int control;
	int camera;
    NSTimer *animationTimer;
    NSTimeInterval animationInterval;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, assign) NSTimer *animationTimer;
@property NSTimeInterval animationInterval;

- (void)startAnimation;
- (void)stopAnimation;
- (void)drawView;

@end

