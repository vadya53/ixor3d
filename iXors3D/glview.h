//
//  glview.h
//  iXors3D
//
//  Created by Knightmare on 01.09.09.
//  Copyright Xors3D Team 2009. All rights reserved.
//

#import <TargetConditionals.h>
#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR

#import <UIKit/UIKit.h>

@interface xGLView : UIView
{
	bool registered;
}

-(void)orientationChanged: (NSNotification *)notification;
-(void)registerObserver;
-(void)deleteObserver;
-(void)touchesBegan: (NSSet *)touches withEvent: (UIEvent *)event;
-(void)touchesCancelled: (NSSet *)touches withEvent: (UIEvent *)event;
-(void)touchesEnded: (NSSet *)touches withEvent: (UIEvent *)event;
-(void)touchesMoved: (NSSet *)touches withEvent: (UIEvent *)event;

@end 
#else

#import <AppKit/AppKit.h>

@interface xGLView : NSView
{
}

- (void)mouseDown:(NSEvent *)event;
- (void)rightMouseDown:(NSEvent *)event;
- (void)otherMouseDown:(NSEvent *)event;
- (void)mouseUp:(NSEvent *)event;
- (void)rightMouseUp:(NSEvent *)event;
- (void)otherMouseUp:(NSEvent *)event;
- (void)mouseMoved:(NSEvent *)event;
- (void)scrollWheel:(NSEvent *)event;
- (void)mouseDragged:(NSEvent *)event;
- (void)rightMouseDragged:(NSEvent *)event;
- (void)otherMouseDragged:(NSEvent *)event;

@end 

#endif