//
//  glview.m
//  iXors3D
//
//  Created by Knightmare on 01.09.09.
//  Copyright Xors3D Team 2009. All rights reserved.
//

#import <TargetConditionals.h>
#import "glview.h"
#import "input.h"
#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR

#import <QuartzCore/QuartzCore.h>
#import "render.h"
#import <pthread.h>

@implementation xGLView

+(Class)layerClass
{
    return [CAEAGLLayer class];
}

-(id)initWithCoder: (NSCoder*)coder
{
	return [super initWithCoder:coder];
}

-(void)registerObserver
{
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] addObserver: self 
											 selector: @selector(orientationChanged:)
												 name: UIDeviceOrientationDidChangeNotification 
											   object: nil];
	registered = true;
}

-(void)deleteObserver
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
	registered = false;
}

-(void)dealloc
{
	if(registered) [self deleteObserver];
    [super dealloc];
}

-(void)orientationChanged: (NSNotification *)notification
{
	xRender::Instance()->SetOrientation([UIDevice currentDevice].orientation);
}

-(void)touchesBegan: (NSSet *)touches withEvent: (UIEvent *)event
{
	[[xTouchResponder Instance] touchesBegan: touches withEvent: event];
}

-(void)touchesCancelled: (NSSet *)touches withEvent: (UIEvent *)event
{
	[[xTouchResponder Instance] touchesCancelled: touches withEvent: event];
}

-(void)touchesEnded: (NSSet *)touches withEvent: (UIEvent *)event
{
	[[xTouchResponder Instance] touchesEnded: touches withEvent: event];
}

-(void)touchesMoved: (NSSet *)touches withEvent: (UIEvent *)event
{
	[[xTouchResponder Instance] touchesMoved: touches withEvent: event];
}

@end

#else

@implementation xGLView

- (void)mouseDown:(NSEvent *)event
{
	[[InputResponder Instance] mouseDown: event];
}

- (void)rightMouseDown:(NSEvent *)event
{
	[[InputResponder Instance] rightMouseDown: event];
}

- (void)otherMouseDown:(NSEvent *)event
{
	[[InputResponder Instance] otherMouseDown: event];
}

- (void)mouseUp:(NSEvent *)event
{
	[[InputResponder Instance] mouseUp: event];
}

- (void)rightMouseUp:(NSEvent *)event
{
	[[InputResponder Instance] rightMouseUp: event];
}

- (void)otherMouseUp:(NSEvent *)event
{
	[[InputResponder Instance] otherMouseUp: event];
}

- (void)mouseMoved:(NSEvent *)event
{
	[[InputResponder Instance] mouseMoved: event];
}

- (void)scrollWheel:(NSEvent *)event
{
	[[InputResponder Instance] scrollWheel: event];
}

- (void)mouseDragged:(NSEvent *)event
{
	[[InputResponder Instance] mouseDragged: event];
}

- (void)rightMouseDragged:(NSEvent *)event
{
	[[InputResponder Instance] rightMouseDragged: event];
}

- (void)otherMouseDragged:(NSEvent *)event
{
	[[InputResponder Instance] otherMouseDragged: event];
}

@end


#endif