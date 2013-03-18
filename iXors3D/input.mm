//
//  input.mm
//  iXors3D
//
//  Created by Knightmare on 05.09.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import <TargetConditionals.h>
#import "input.h"
#import "render.h"

#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR

#import <algorithm>

xInputManager * xInputManager::_instance = NULL;

xInputManager::xInputManager()
{
	_acceleration                 = xVector(0.0f, 0.0f, 0.0f);
	_gravitation                  = xVector(0.0f, 0.0f, 0.0f);
	_gravitationLast              = xVector(0.0f, 0.0f, 0.0f);
	_accelerometer                = nil;
}

xInputManager::xInputManager(const xInputManager & other)
{
}

xInputManager & xInputManager::operator=(const xInputManager & other)
{
	return *this;
}

xInputManager::~xInputManager()
{
	_accelerometer.delegate = nil;
}

xInputManager * xInputManager::Instance()
{
	if(_instance == NULL) _instance = new xInputManager();
	return _instance;
}

void xInputManager::EnableAccelerometer(bool state)
{
	if(state)
	{
		_accelerometer                = [UIAccelerometer sharedAccelerometer];
		_accelerometer.updateInterval = 0.1f;
		_accelerometer.delegate       = [xAccelerometer Instance];
	}
	else if(_accelerometer != nil)
	{
		_accelerometer.delegate = nil;
		_accelerometer          = nil;
	}
}

void xInputManager::AddAcceleration(xVector acceleration)
{
	_gravitation  = acceleration;
	_acceleration = _gravitation - _gravitationLast;
}

xVector xInputManager::GetAcceleration()
{
#if TARGET_IPHONE_SIMULATOR
	return xVector(0.0f, 0.0f, 0.0f);
#endif
	return _acceleration;
}

xVector xInputManager::GetGravitation()
{
#if TARGET_IPHONE_SIMULATOR
	return xVector(0.0f, -1.0f, 0.0f);
#endif
	return _gravitation.Normalized();
}

void xInputManager::SetAccelerometerInterval(float interval)
{
	if(_accelerometer == nil) return;
	_accelerometer.updateInterval = interval;
}

float xInputManager::GetAccelerometerInterval()
{
	if(_accelerometer == nil) return 0.0f;
	return _accelerometer.updateInterval;
}

void xInputManager::EnableMultiTouch()
{
	xRender::Instance()->GetView().multipleTouchEnabled = true; 
}

void xInputManager::DisableMultiTouch()
{
	xRender::Instance()->GetView().multipleTouchEnabled = false;
}

void xInputManager::FlushAcceleration()
{
	_acceleration = xVector(0.0f, 0.0f, 0.0f);
}

void xInputManager::AddTouch(UITouch * touch)
{
	@synchronized([xTouchResponder Instance])
	{
		xTouch newTouch;
		newTouch.systemTouch  = touch;
		newTouch.prevLocation = xVector(-100, -100, 0);
		newTouch.first        = true;
		newTouch.phase        = 1;
		newTouch.released     = false;
		newTouch.moved        = false;
		newTouch.tapCount     = [touch tapCount];
		newTouch.touchTime    = [touch timestamp];
		float scale = xRender::Instance()->GetScaleFactor();
		CGPoint location       = TransformTouch([newTouch.systemTouch locationInView: nil]);
		newTouch.prevLocation.x  = location.x * scale;
		newTouch.prevLocation.y  = location.y * scale;
		newTouch.location.x      = location.x * scale;
		newTouch.location.y      = location.y * scale;
		_touches.push_back(newTouch);
	}
}

CGPoint xInputManager::TransformTouch(CGPoint point)
{
	float scale = xRender::Instance()->GetScaleFactor();
	int width  = xRender::Instance()->GetWindowWidth()  / scale;
	int height = xRender::Instance()->GetWindowHeight() / scale;
	switch(xRender::Instance()->GetDeviceOrientation())
	{
		case 1: return CGPointMake(point.y,          width  - point.x);
		case 2: return CGPointMake(width  - point.x, height - point.y);
		case 3: return CGPointMake(height - point.y, point.x);
	}
	return point;
}

void xInputManager::SyncTouch(int index)
{
	if(_touches[index].phase == 4 || _touches[index].released || _touches[index].moved) return;
	_touches[index].tapCount  = [_touches[index].systemTouch tapCount];
	_touches[index].touchTime = [_touches[index].systemTouch timestamp];
	if(_touches[index].first)
	{
		float scale = xRender::Instance()->GetScaleFactor();
		CGPoint location                = TransformTouch([_touches[index].systemTouch locationInView: nil]);
		_touches[index].prevLocation.x  = location.x * scale;
		_touches[index].prevLocation.y  = location.y * scale;
		_touches[index].location.x      = location.x * scale;
		_touches[index].location.y      = location.y * scale;
	}
	else
	{
		if(_touches[index].location.x == _touches[index].prevLocation.x && _touches[index].location.y == _touches[index].prevLocation.y
		   && _touches[index].systemTouch.phase == UITouchPhaseStationary)
		{
			_touches[index].phase = 3;
		}
	}
}

void xInputManager::Update()
{
	std::vector<xTouch>::iterator itr = _touches.begin();
	while(itr != _touches.end())
	{
		if((*itr).phase == 4)
		{
			itr = _touches.erase(itr);
		}
		else if(!(*itr).released && !(*itr).moved)
		{
			float scale = xRender::Instance()->GetScaleFactor();
			CGPoint location       = TransformTouch([(*itr).systemTouch locationInView: nil]);
			(*itr).prevLocation.x  = (*itr).first ? location.x * scale : (*itr).location.x;
			(*itr).prevLocation.y  = (*itr).first ? location.y * scale : (*itr).location.y;
			(*itr).location.x      = location.x * scale;
			(*itr).location.y      = location.y * scale;
			(*itr).first           = false;
			if((*itr).location.x < 0.0f) (*itr).location.x = 0.0f;
			if((*itr).location.x > xRender::Instance()->GraphicsWidth()) (*itr).location.x = xRender::Instance()->GraphicsWidth();
			if((*itr).location.y < 0.0f) (*itr).location.y = 0.0f;
			if((*itr).location.y > xRender::Instance()->GraphicsHeight()) (*itr).location.y = xRender::Instance()->GraphicsHeight();
			if((*itr).prevLocation.x < 0.0f) (*itr).prevLocation.x = 0.0f;
			if((*itr).prevLocation.x > xRender::Instance()->GraphicsWidth()) (*itr).prevLocation.x = xRender::Instance()->GraphicsWidth();
			if((*itr).prevLocation.y < 0.0f) (*itr).prevLocation.y = 0.0f;
			if((*itr).prevLocation.y > xRender::Instance()->GraphicsHeight()) (*itr).prevLocation.y = xRender::Instance()->GraphicsHeight();
			itr++;
		}
		else if((*itr).moved)
		{
			(*itr).phase        = 2;
			(*itr).first        = false;
			(*itr).moved        = false;
			(*itr).prevLocation = (*itr).prevLocationMoved;
			(*itr).location     = (*itr).locationMoved;
			itr++;
		}
		else
		{
			(*itr).phase    = 4;
			(*itr).released = false;
			itr++;
		}
	}
	_acceleration    = xVector(0.0f, 0.0f, 0.0f);
	_gravitationLast = _gravitation;
}

void xInputManager::MoveTouch(UITouch * touch)
{
	@synchronized([xTouchResponder Instance])
	{
		for(int i = 0; i < _touches.size(); i++)
		{
			if(touch == _touches[i].systemTouch && !_touches[i].first) 
			{
				_touches[i].phase = 2;
			}
			else if(!_touches[i].released)
			{
				if(!_touches[i].moved)
				{
					_touches[i].moved               = true;
					float scale                     = xRender::Instance()->GetScaleFactor();
					CGPoint location                = TransformTouch([touch locationInView: nil]);
					CGPoint locationPrev            = TransformTouch([touch previousLocationInView: nil]);
					_touches[i].locationMoved.x     = location.x     * scale;
					_touches[i].locationMoved.y     = location.y     * scale;
					_touches[i].prevLocationMoved.x = locationPrev.x * scale;
					_touches[i].prevLocationMoved.y = locationPrev.y * scale;
				}
				else
				{
					float scale                 = xRender::Instance()->GetScaleFactor();
					CGPoint location            = TransformTouch([touch locationInView: nil]);
					_touches[i].locationMoved.x = location.x * scale;
					_touches[i].locationMoved.y = location.y * scale;
				}
			}
		}
	}
}

int xInputManager::GetTouchCounter()
{
	return _touches.size();
}

void xInputManager::Flush()
{
	_touches.clear();
}

xTouch * xInputManager::GetTouch(int index)
{
	if(index < 0 || index >= _touches.size()) return NULL;
	SyncTouch(index);
	return &_touches[index];
}

void xInputManager::DeleteTouch(UITouch * touch)
{
	@synchronized([xTouchResponder Instance])
	{
		std::vector<xTouch>::iterator itr = _touches.begin();
		while(itr != _touches.end())
		{
			if((*itr).systemTouch == touch) 
			{
				if(!(*itr).first) 
				{
					(*itr).phase = 4;
				}
				else
				{
					(*itr).released = true;
				}
			}
			itr++;
		}
	}
}

// responder implementation

xTouchResponder * instance = nil;
xAccelerometer  * ainstance = nil;

@implementation xTouchResponder

+(xTouchResponder*)Instance
{
	if(instance == nil) instance = [[xTouchResponder alloc] init];
	return instance;
}

-(void)touchesBegan: (NSSet *)touches withEvent: (UIEvent *)event
{
	for(UITouch * touch in touches) xInputManager::Instance()->AddTouch(touch);
}

-(void)touchesCancelled: (NSSet *)touches withEvent: (UIEvent *)event
{
	for(UITouch * touch in touches) xInputManager::Instance()->DeleteTouch(touch);
}

-(void)touchesEnded: (NSSet *)touches withEvent: (UIEvent *)event
{
	for(UITouch * touch in touches) xInputManager::Instance()->DeleteTouch(touch);
}

-(void)touchesMoved: (NSSet *)touches withEvent: (UIEvent *)event
{
	for(UITouch * touch in touches) xInputManager::Instance()->MoveTouch(touch);
}

@end

@implementation xAccelerometer

+(xAccelerometer*)Instance
{
	if(ainstance == nil) ainstance = [[xAccelerometer alloc] init];
	return ainstance;
}

-(void)accelerometer: (UIAccelerometer *)accelerometer didAccelerate: (UIAcceleration *)acceleration
{
	xInputManager::Instance()->AddAcceleration(xVector(acceleration.y, acceleration.x, acceleration.z));
}

@end

#else

#import <ApplicationServices/ApplicationServices.h>

xInputManager * xInputManager::_instance = NULL;

xInputManager::xInputManager()
{
	pthread_mutexattr_t mutexattr;
	pthread_mutexattr_init(&mutexattr);
	int mutexError = pthread_mutex_init(&_mutex, &mutexattr);
	if(mutexError != 0)
	{
		printf("ERROR(%s:%i): Error of creating input thread mutex.\n", __FILE__, __LINE__);
	}
	pthread_mutexattr_destroy(&mutexattr);
	for(int i = 0; i < 8; i++)
	{
		_mouseDown[i] = false;
		_mouseUp[i]   = false;
		_mouseHits[i] = 0;
	}
	for(int i = 0; i < 250; i++)
	{
		_keysRemap[i] = i;
		_keysDown[i]  = false;
		_keysUp[i]    = false;
		_keysHits[i]  = 0;
	}
	// KEYS REMAPING TO WINDOWS KEYCODES
#ifndef USE_MACOS_KEYCODES
	_keysRemap[1]   = 53;  // escape
	_keysRemap[59]  = 122; // f1
	_keysRemap[60]  = 120; // f2
	_keysRemap[61]  = 99;  // f3
	_keysRemap[62]  = 118; // f4
	_keysRemap[63]  = 96;  // f5
	_keysRemap[64]  = 97;  // f6
	_keysRemap[65]  = 98;  // f7
	_keysRemap[66]  = 100; // f8
	_keysRemap[67]  = 101; // f9
	_keysRemap[68]  = 109; // f10
	_keysRemap[87]  = 103; // f11
	_keysRemap[88]  = 111; // f12
	_keysRemap[86]  = 50;  // tild
	_keysRemap[2]   = 18;  // 1
	_keysRemap[3]   = 19;  // 2
	_keysRemap[4]   = 20;  // 3
	_keysRemap[5]   = 21;  // 4
	_keysRemap[6]   = 23;  // 5
	_keysRemap[7]   = 22;  // 6
	_keysRemap[8]   = 26;  // 7
	_keysRemap[9]   = 28;  // 8
	_keysRemap[10]  = 25;  // 9
	_keysRemap[11]  = 29;  // 0
	_keysRemap[12]  = 27;  // -
	_keysRemap[13]  = 24;  // =
	_keysRemap[14]  = 51;  // backspace
	_keysRemap[15]  = 48;  // tab
	_keysRemap[16]  = 12;  // q
	_keysRemap[17]  = 13;  // w
	_keysRemap[18]  = 14;  // e
	_keysRemap[19]  = 15;  // r
	_keysRemap[20]  = 17;  // t
	_keysRemap[21]  = 16;  // y
	_keysRemap[22]  = 32;  // u
	_keysRemap[23]  = 34;  // i
	_keysRemap[24]  = 31;  // o
	_keysRemap[25]  = 35;  // p
	_keysRemap[26]  = 33;  // [
	_keysRemap[27]  = 30;  // ]
	_keysRemap[28]  = 36;  // return
	_keysRemap[58]  = 57;  // CAPS LOCK
	_keysRemap[30]  = 0;   // a
	_keysRemap[31]  = 1;   // s
	_keysRemap[32]  = 2;   // d
	_keysRemap[33]  = 3;   // f
	_keysRemap[34]  = 5;   // g
	_keysRemap[35]  = 4;   // h
	_keysRemap[36]  = 38;  // j
	_keysRemap[37]  = 40;  // k
	_keysRemap[38]  = 37;  // l
	_keysRemap[39]  = 41;  // ;
	_keysRemap[40]  = 39;  // '
	_keysRemap[42]  = 56;  // left shift
	_keysRemap[43]  = 42;  // slash
	_keysRemap[44]  = 6;   // z
	_keysRemap[45]  = 7;   // x
	_keysRemap[46]  = 8;   // c
	_keysRemap[47]  = 9;   // v
	_keysRemap[48]  = 11;  // b
	_keysRemap[49]  = 45;  // n
	_keysRemap[50]  = 46;  // m
	_keysRemap[51]  = 43;  // ,
	_keysRemap[52]  = 47;  // .
	_keysRemap[53]  = 44;  // /
	_keysRemap[54]  = 60;  // right shift
	_keysRemap[29]  = 59;  // left control
	_keysRemap[56]  = 59;  // left option
	_keysRemap[219] = 55;  // left command
	_keysRemap[57]  = 49;  // space
	_keysRemap[220] = 54;  // right command
	_keysRemap[184] = 61;  // right option
	_keysRemap[157] = 62;  // right control
	_keysRemap[210] = 114; // insert
	_keysRemap[211] = 117; // delete
	_keysRemap[199] = 115; // home
	_keysRemap[207] = 119; // end
	_keysRemap[201] = 116; // pg up
	_keysRemap[209] = 121; // pg down
	_keysRemap[200] = 126; // up
	_keysRemap[208] = 125; // down
	_keysRemap[203] = 123; // left
	_keysRemap[205] = 124; // right
	_keysRemap[69]  = 71;  // num lock
	_keysRemap[181] = 75;  // /
	_keysRemap[55]  = 67;  // *
	_keysRemap[74]  = 78;  // -
	_keysRemap[71]  = 89;  // 7
	_keysRemap[72]  = 91;  // 8
	_keysRemap[73]  = 92;  // 9
	_keysRemap[78]  = 69;  // +
	_keysRemap[75]  = 86;  // 4
	_keysRemap[76]  = 87;  // 5
	_keysRemap[77]  = 88;  // 6
	_keysRemap[79]  = 83;  // 1
	_keysRemap[80]  = 84;  // 2
	_keysRemap[81]  = 85;  // 3
	_keysRemap[156] = 76;  // enter
	_keysRemap[82]  = 82;  // 0
	_keysRemap[83]  = 65;  // .
#endif
}

xInputManager::xInputManager(const xInputManager & other)
{
}

xInputManager & xInputManager::operator=(const xInputManager & other)
{
	return *this;
}

xInputManager::~xInputManager()
{
}

xInputManager * xInputManager::Instance()
{
	if(_instance == NULL) _instance = new xInputManager();
	return _instance;
}

void xInputManager::Update()
{
	pthread_mutex_lock(&_mutex);
	_mouseSpeed = xVector(0.0f, 0.0f, 0.0f);
	for(int i = 0; i < 8; i++)
	{
		if(_mouseUp[i]) _mouseDown[i] = false;
		_mouseUp[i]   = false;
		_mouseHits[i] = 0;
	}
	for(int i = 0; i < 250; i++)
	{
		if(_keysUp[i]) _keysDown[i] = false;
		_keysUp[i]   = false;
		_keysHits[i] = 0;
	}
	pthread_mutex_unlock(&_mutex);
}

void xInputManager::MoveMouse(xVector speed)
{
	pthread_mutex_lock(&_mutex);
	_mouseSpeed += speed;
	pthread_mutex_unlock(&_mutex);
}

void xInputManager::DownMouse(int key)
{
	if(key < 0 || key > 7) return;
	pthread_mutex_lock(&_mutex);
	_mouseDown[key] = true;
	_mouseHits[key]++;
	pthread_mutex_unlock(&_mutex);
}

void xInputManager::UpMouse(int key)
{
	if(key < 0 || key > 7) return;
	pthread_mutex_lock(&_mutex);
	_mouseUp[key]   = true;
	pthread_mutex_unlock(&_mutex);
}

void xInputManager::FlushMouse()
{
	pthread_mutex_lock(&_mutex);
	_mouseSpeed = xVector(0.0f, 0.0f, 0.0f);
	for(int i = 0; i < 8; i++)
	{
		_mouseDown[i] = false;
		_mouseUp[i]   = false;
		_mouseHits[i] = 0;
	}
	pthread_mutex_unlock(&_mutex);
}

void xInputManager::DownKey(int key)
{
	if(key < 0 || key > 249) return;
	pthread_mutex_lock(&_mutex);
	_keysDown[key] = true;
	_keysHits[key]++;
	pthread_mutex_unlock(&_mutex);
}

void xInputManager::UpKey(int key)
{
	if(key < 0 || key > 249) return;
	pthread_mutex_lock(&_mutex);
	_keysUp[key]   = true;
	pthread_mutex_unlock(&_mutex);
}

void xInputManager::FlushKeyboard()
{
	pthread_mutex_lock(&_mutex);
	for(int i = 0; i < 250; i++)
	{
		_keysDown[i] = false;
		_keysUp[i]   = false;
		_keysHits[i] = 0;
	}
	pthread_mutex_unlock(&_mutex);
}

bool xInputManager::KeyDown(int key)
{
	if(key < 0 || key > 249) return false;
	return _keysDown[_keysRemap[key]];
}

bool xInputManager::KeyUp(int key)
{
	if(key < 0 || key > 249) return false;
	return _keysUp[_keysRemap[key]];
}

int xInputManager::KeyHit(int key)
{
	if(key < 0 || key > 249) return 0;
	int result = _keysHits[_keysRemap[key]];
	_keysHits[_keysRemap[key]]--;
	if(_keysHits[_keysRemap[key]] < 0) _keysHits[_keysRemap[key]] = 0;
	return result;
}

bool xInputManager::MouseDown(int key)
{
	key--;
	if(key < 0 || key > 7) return false;
	return _mouseDown[key];
}

bool xInputManager::MouseUp(int key)
{
	key--;
	if(key < 0 || key > 7) return false;
	return _mouseUp[key];
}

int xInputManager::MouseHit(int key)
{
	key--;
	if(key < 0 || key > 7) return 0;
	int result = _mouseHits[key];
	_mouseHits[key]--;
	if(_mouseHits[key] < 0) _mouseHits[key] = 0;
	return result;
}

xVector xInputManager::MouseSpeed()
{
	return _mouseSpeed;
}

xVector xInputManager::MousePosition()
{
	NSPoint mouseLocation = [NSEvent mouseLocation];
	mouseLocation         = [xRender::Instance()->GetWindow() convertScreenToBase: mouseLocation];
	mouseLocation.y       = xRender::Instance()->GraphicsHeight() - mouseLocation.y - 1;
	if(mouseLocation.x < 0) mouseLocation.x = 0;
	if(mouseLocation.y < 0) mouseLocation.y = 0;
	if(mouseLocation.x > xRender::Instance()->GraphicsWidth()) mouseLocation.x = xRender::Instance()->GraphicsWidth();
	if(mouseLocation.y > xRender::Instance()->GraphicsHeight()) mouseLocation.y = xRender::Instance()->GraphicsHeight();
	return xVector(mouseLocation.x, mouseLocation.y, 0.0f);
}

void xInputManager::SetMousePosition(int x, int y)
{
	NSPoint targetLocation = [xRender::Instance()->GetWindow() convertBaseToScreen: NSMakePoint(x, xRender::Instance()->GraphicsHeight() - y - 1)];
	CGPoint target         = { targetLocation.x, [xRender::Instance()->GetWindow() screen].frame.size.height - targetLocation.y };
	CGEventPost(kCGHIDEventTap, CGEventCreateMouseEvent(NULL, kCGEventMouseMoved, target, 0));
}

void xInputManager::HideCursor()
{
	CGDisplayHideCursor(kCGDirectMainDisplay);
}

void xInputManager::ShowCursor()
{
	CGDisplayShowCursor(kCGDirectMainDisplay);
}

InputResponder * ___x3d_respInstance;

@implementation InputResponder

+(InputResponder*)Instance
{
	if(___x3d_respInstance == nil) ___x3d_respInstance = [[InputResponder alloc] init];
	return ___x3d_respInstance;
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (BOOL)becomeFirstResponder
{
	return YES;
}

- (BOOL)resignFirstResponder
{
	return NO;
}

- (void)mouseDown:(NSEvent *)event
{
	xInputManager::Instance()->DownMouse(event.buttonNumber);
}

- (void)rightMouseDown:(NSEvent *)event
{
	xInputManager::Instance()->DownMouse(event.buttonNumber);
}

- (void)otherMouseDown:(NSEvent *)event
{
	xInputManager::Instance()->DownMouse(event.buttonNumber);
}

- (void)mouseUp:(NSEvent *)event
{
	xInputManager::Instance()->UpMouse(event.buttonNumber);
}

- (void)rightMouseUp:(NSEvent *)event
{
	xInputManager::Instance()->UpMouse(event.buttonNumber);
}

- (void)otherMouseUp:(NSEvent *)event
{
	xInputManager::Instance()->UpMouse(event.buttonNumber);
}

- (void)mouseMoved:(NSEvent *)event
{
	xInputManager::Instance()->MoveMouse(xVector(event.deltaX, event.deltaY, 0.0f));
}

- (void)scrollWheel:(NSEvent *)event
{
	xInputManager::Instance()->MoveMouse(xVector(0.0f, 0.0f, event.deltaY));
}

- (void)mouseDragged:(NSEvent *)event
{
	xInputManager::Instance()->MoveMouse(xVector(event.deltaX, event.deltaY, 0.0f));
}

- (void)rightMouseDragged:(NSEvent *)event
{
	xInputManager::Instance()->MoveMouse(xVector(event.deltaX, event.deltaY, 0.0f));
}

- (void)otherMouseDragged:(NSEvent *)event
{
	xInputManager::Instance()->MoveMouse(xVector(event.deltaX, event.deltaY, 0.0f));
}

- (void)keyDown:(NSEvent *)event
{
	if(!event.isARepeat) xInputManager::Instance()->DownKey(event.keyCode);
}

- (void)keyUp:(NSEvent *)event
{
	xInputManager::Instance()->UpKey(event.keyCode);
}

- (void)flagsChanged:(NSEvent *)event
{
	if(event.keyCode == 57)
	{
		if(event.modifierFlags & NSAlphaShiftKeyMask)
		{
			xInputManager::Instance()->DownKey(event.keyCode);
		}
		else
		{
			xInputManager::Instance()->UpKey(event.keyCode);
		}
	}
	else if(event.keyCode == 56)
	{
		if(event.modifierFlags & NSShiftKeyMask)
		{
			xInputManager::Instance()->DownKey(event.keyCode);
		}
		else
		{
			xInputManager::Instance()->UpKey(event.keyCode);
		}
	}
	else if(event.keyCode == 60)
	{
		if(event.modifierFlags & NSShiftKeyMask)
		{
			xInputManager::Instance()->DownKey(event.keyCode);
		}
		else
		{
			xInputManager::Instance()->UpKey(event.keyCode);
		}
	}
	else if(event.keyCode == 59)
	{
		if(event.modifierFlags & NSControlKeyMask)
		{
			xInputManager::Instance()->DownKey(event.keyCode);
		}
		else
		{
			xInputManager::Instance()->UpKey(event.keyCode);
		}
	}
	else if(event.keyCode == 55)
	{
		if(event.modifierFlags & NSCommandKeyMask)
		{
			xInputManager::Instance()->DownKey(event.keyCode);
		}
		else
		{
			xInputManager::Instance()->UpKey(event.keyCode);
		}
	}
	else if(event.keyCode == 58)
	{
		if(event.modifierFlags & NSAlternateKeyMask)
		{
			xInputManager::Instance()->DownKey(event.keyCode);
		}
		else
		{
			xInputManager::Instance()->UpKey(event.keyCode);
		}
	}
	else if(event.keyCode == 61)
	{
		if(event.modifierFlags & NSAlternateKeyMask)
		{
			xInputManager::Instance()->DownKey(event.keyCode);
		}
		else
		{
			xInputManager::Instance()->UpKey(event.keyCode);
		}
	}
	else if(event.keyCode == 54)
	{
		if(event.modifierFlags & NSCommandKeyMask)
		{
			xInputManager::Instance()->DownKey(event.keyCode);
		}
		else
		{
			xInputManager::Instance()->UpKey(event.keyCode);
		}
	}
	else if(event.keyCode == 62)
	{
		if(event.modifierFlags & NSControlKeyMask)
		{
			xInputManager::Instance()->DownKey(event.keyCode);
		}
		else
		{
			xInputManager::Instance()->UpKey(event.keyCode);
		}
	}
}

@end


#endif