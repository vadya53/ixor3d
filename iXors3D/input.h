//
//  input.h
//  iXors3D
//
//  Created by Knightmare on 05.09.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import <TargetConditionals.h>
#import "x3dmath.h"
#import <vector>

#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

struct xTouch
{
	xVector   location;
	xVector   prevLocation;
	int       phase;
	float     touchTime;
	int       tapCount;
	UITouch * systemTouch;
	bool      first;
	bool      released;
	bool      moved;
	xVector   locationMoved;
	xVector   prevLocationMoved;
};

class xInputManager
{
private:
	std::vector<xTouch>    _touches;
	static xInputManager * _instance;
	xVector                _acceleration;
	xVector                _gravitation;
	xVector                _gravitationLast;
	UIAccelerometer      * _accelerometer;
private:
	xInputManager();
	xInputManager(const xInputManager & other);
	xInputManager & operator=(const xInputManager & other);
	~xInputManager();
	void SyncTouch(int index);
	CGPoint TransformTouch(CGPoint point);
public:
	static xInputManager * Instance();
	void AddTouch(UITouch * touch);
	void MoveTouch(UITouch * touch);
	void DeleteTouch(UITouch * touch);
	int GetTouchCounter();
	xTouch * GetTouch(int index);
	void Update();
	void Flush();
	void AddAcceleration(xVector acceleration);
	xVector GetAcceleration();
	xVector GetGravitation();
	void SetAccelerometerInterval(float interval);
	float GetAccelerometerInterval();
	void FlushAcceleration();
	void EnableAccelerometer(bool state);
	void EnableMultiTouch();
	void DisableMultiTouch();
};

@interface xTouchResponder : UIResponder
{
}

+(xTouchResponder*)Instance;
-(void)touchesBegan: (NSSet *)touches withEvent: (UIEvent *)event;
-(void)touchesCancelled: (NSSet *)touches withEvent: (UIEvent *)event;
-(void)touchesEnded: (NSSet *)touches withEvent: (UIEvent *)event;
-(void)touchesMoved: (NSSet *)touches withEvent: (UIEvent *)event;

@end

@interface xAccelerometer : NSObject<UIAccelerometerDelegate>
{
}

+(xAccelerometer*)Instance;
-(void)accelerometer: (UIAccelerometer *)accelerometer didAccelerate: (UIAcceleration *)acceleration;

@end
#else

#include <AppKit/AppKit.h>
#import <pthread.h>

class xInputManager
{
private:
	static xInputManager * _instance;
	pthread_mutex_t        _mutex;
	xVector                _mouseSpeed;
	bool                   _mouseDown[8];
	bool                   _mouseUp[8];
	int                    _mouseHits[8];
	bool                   _keysDown[250];
	bool                   _keysUp[250];
	int                    _keysHits[250];
	int                    _keysRemap[250];
private:
	xInputManager();
	xInputManager(const xInputManager & other);
	xInputManager & operator=(const xInputManager & other);
	~xInputManager();
public:
	static xInputManager * Instance();
	void Update();
	void MoveMouse(xVector speed);
	void DownMouse(int key);
	void UpMouse(int key);
	void FlushMouse();
	void DownKey(int key);
	void UpKey(int key);
	void FlushKeyboard();
	bool KeyDown(int key);
	bool KeyUp(int key);
	int KeyHit(int key);
	bool MouseDown(int key);
	bool MouseUp(int key);
	int MouseHit(int key);
	xVector MouseSpeed();
	xVector MousePosition();
	void SetMousePosition(int x, int y);
	void HideCursor();
	void ShowCursor();
};

@interface InputResponder : NSResponder
{
}

+(InputResponder*)Instance;
- (BOOL)acceptsFirstResponder;
- (BOOL)becomeFirstResponder;
- (BOOL)resignFirstResponder;
- (void)mouseDown:(NSEvent *)event;
- (void)rightMouseDown:(NSEvent *)event;
- (void)otherMouseDown:(NSEvent *)event;
- (void)mouseUp:(NSEvent *)event;
- (void)rightMouseUp:(NSEvent *)event;
- (void)otherMouseUp:(NSEvent *)event;
- (void)mouseMoved:(NSEvent *)event;
- (void)scrollWheel:(NSEvent *)event;
- (void)rightMouseDragged:(NSEvent *)event;
- (void)otherMouseDragged:(NSEvent *)event;
- (void)keyDown:(NSEvent *)event;
- (void)keyUp:(NSEvent *)event;
- (void)flagsChanged:(NSEvent*)event;

@end


#endif