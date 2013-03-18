//
//  xors3d.m
//  iXors3D
//
//  Created by Knightmare on 25.08.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import "xors3d.h"
#import "render.h"
#import "image.h"
#import "buffer.h"
#import "surface.h"
#import "camera.h"
#import "brush.h"
#import "input.h"
#import "glview.h"
#import "light.h"
#import "bone.h"
#import <sys/time.h>
#import "simulator.h"
#import "terrain.h"
#import "audiomanager.h"
#import "sound.h"
#import "channel.h"
#import "font.h"
#import "sprite.h"
#import "filesystem.h"
#import "movie.h"
#import "netmanager.h"
#import "2dworld.h"
#import "2datlas.h"
#import "sysinfo.h"
#import "texturemanager.h"
#import "GCPlayer.h"

int activeBuffer    = 0;
int lastTime        = 0;
xFont * defaultFont = NULL;
xVector tformed;

// time limeted trial code
#if !TARGET_OS_EMBEDDED && !TARGET_IPHONE_SIMULATOR
	#define X3D_TIMETRIAL
#else
	//#define X3D_TIMETRIAL
#endif
#ifdef X3D_TIMETRIAL
int __x3dTrialTime  = 5;
int __x3dLaunchTime = 0;
uint timeGetTime();
#endif

int Clamp(int value, int minvalue, int maxvalue)
{
	if(value > maxvalue) return maxvalue;
	if(value < minvalue) return minvalue;
	return value;
}

float Clamp(float value, float minvalue, float maxvalue)
{
	if(value > maxvalue) return maxvalue;
	if(value < minvalue) return minvalue;
	return value;
}

#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
UIView * xGraphics3D(int orientation, bool retinaSupport, UIWindow * window)
{
#ifdef X3D_TIMETRIAL
	__x3dLaunchTime = timeGetTime();
#endif
	if(window == nil) window = [UIApplication sharedApplication].keyWindow;
	int windowWidth  = window.bounds.size.width;
	int windowHeight = window.bounds.size.height;
	if(orientation == 0)
	{
		[[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationPortrait animated: NO];
	}
	else if(orientation == 1)
	{
		[[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationLandscapeRight animated: NO];
	}
	else if(orientation == 2)
	{
		[[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationPortraitUpsideDown animated: NO];
	}
	else if(orientation == 3)
	{
		[[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationLandscapeLeft animated: NO];
	}
	xGLView * glView = [[xGLView alloc] initWithFrame: window.bounds];
	float scaleFactor     = 1.0f;
	NSString * reqSysVer  = @"4.0";
	NSString * currSysVer = [[UIDevice currentDevice] systemVersion];
	if([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
	{
		if([[UIScreen mainScreen] scale] == 2.0 && retinaSupport)
		{
			scaleFactor = 2.0f;
			glView.contentScaleFactor = scaleFactor;
		}
	}		
	[glView registerObserver];
	[window addSubview: glView];
	[xTouchResponder Instance];
	xRender::Instance()->SetScaleFactor(scaleFactor);
	xRender::Instance()->SetDeviceOrientation(orientation);
	xRender::Instance()->SetWindow(window);
	xRender::Instance()->SetView(glView);
	xRender::Instance()->SetWindowSize(windowWidth * scaleFactor, windowHeight * scaleFactor);
	bool result = xRender::Instance()->Initialize((CAEAGLLayer *)glView.layer);
	xRender::Instance()->SetViewport(0, 0, xRender::Instance()->GraphicsWidth(), xRender::Instance()->GraphicsHeight());
	xAudioManager::Instance();
	xFileSystem::Instance();
	xSysInfo::Instance();
	xPlayerManager::Instance();
	return (result == false ? NULL : glView);
}
#else

@interface X3DWindow : NSWindow
{
}

- (BOOL)canBecomeKeyWindow;

@end

@implementation X3DWindow

- (BOOL)canBecomeKeyWindow
{
	return YES;
}

@end

NSView * xGraphics3D(int width, int height, int depth, bool fullScreen)
{
#ifdef X3D_TIMETRIAL
	__x3dLaunchTime = timeGetTime();
#endif
	bool noResolutionChange = false;
	if(width <= 0 || height <= 0)
	{
		NSRect screenSize  = [[NSScreen mainScreen] frame];
		width              = screenSize.size.width;
		height             = screenSize.size.height;
		noResolutionChange = true;
	}
	else if([[NSScreen mainScreen] frame].size.width == width && [[NSScreen mainScreen] frame].size.height == height)
	{
		noResolutionChange = true;
	}
	if(fullScreen)
	{
		if(!noResolutionChange)
		{
			if(CGDisplayCapture(kCGDirectMainDisplay) != kCGErrorSuccess)
			{
				printf("ERROR(%s:%i): Unable to capture main screen.\n", __FILE__, __LINE__);
			}
			CGDisplayConfigRef config;
			// start screen configure
			if(CGBeginDisplayConfiguration(&config) != kCGErrorSuccess)
			{
				printf("ERROR(%s:%i): Unable to confugure main screen.\n", __FILE__, __LINE__);
			}
			else 
			{
				CFDictionaryRef mode = CGDisplayBestModeForParameters(kCGDirectMainDisplay, 24, width, height, NULL);
				// change resolution
				if(mode == NULL|| CGConfigureDisplayMode(config, kCGDirectMainDisplay, mode) != kCGErrorSuccess)
				{
					printf("ERROR(%s:%i): Unable to confugure main screen.\n", __FILE__, __LINE__);
				}
				else
				{
					// commit changes
					if(CGCompleteDisplayConfiguration(config, kCGConfigureForAppOnly) != kCGErrorSuccess)
					{
						printf("ERROR(%s:%i): Unable to confugure main screen.\n", __FILE__, __LINE__);
					}
				}
			}
		}
	}
	[NSApplication sharedApplication];
	xGLView   * view   = [[xGLView alloc] initWithFrame: NSMakeRect(0, 0, width, height)];
	X3DWindow * window = [[X3DWindow alloc] initWithContentRect: NSMakeRect(0, 0, width, height) 
													  styleMask: (fullScreen ? NSBorderlessWindowMask : NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask) 
														backing: NSBackingStoreBuffered
														  defer: NO];
	if(fullScreen)
	{
		[window setLevel: CGShieldingWindowLevel()]; 
		[window setFrameOrigin: NSMakePoint(0, 0)];
	}
	else
	{
		[window center];
	}
	[window setContentView: view];
	[window setTitle: [NSString stringWithUTF8String: xRender::Instance()->GetAppTitle()]];
	[window makeKeyAndOrderFront: [NSApplication sharedApplication]];
	[window makeFirstResponder: [InputResponder Instance]];
	[window setAcceptsMouseMovedEvents: YES];
	[window setReleasedWhenClosed: NO];
	xRender::Instance()->SetWindow(window);
	xRender::Instance()->SetView(view);
	xRender::Instance()->SetWindowSize(width, height);
	bool result = xRender::Instance()->Initialize(width, height, depth, fullScreen, view);
	xRender::Instance()->SetViewport(0, 0, xRender::Instance()->GraphicsWidth(), xRender::Instance()->GraphicsHeight());
	xAudioManager::Instance();
	xFileSystem::Instance();
	xSysInfo::Instance();
	return (result == false ? NULL : view);
}

void xAppTitle(const char * title)
{
	xRender::Instance()->SetAppTitle(title);
}

void xHideWindow()
{
	xRender::Instance()->HideWindow();
}

void xShowWindow()
{
	xRender::Instance()->ShowWindow();
}
#endif


#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
void xEnableOrientations(int mask)
{
	xRender::Instance()->SetOrientationMask(mask);
}

int xOrientationsMask()
{
	return xRender::Instance()->GetOrientationMask();
}

void xSetOrientation(int orientation)
{
	UIDeviceOrientation systemOrientation;
	switch(orientation)
	{
		case 0:  systemOrientation = UIDeviceOrientationPortrait;           break;
		case 1:  systemOrientation = UIDeviceOrientationLandscapeLeft;      break;
		case 2:  systemOrientation = UIDeviceOrientationPortraitUpsideDown; break;
		case 3:  systemOrientation = UIDeviceOrientationLandscapeRight;     break;
		default: systemOrientation = UIDeviceOrientationPortrait;           break;
	}
	xRender::Instance()->SetOrientation(systemOrientation);
}

int xGetOrientation()
{
	return xRender::Instance()->GetDeviceOrientation();
}

int xDeviceOrientation()
{
	switch([UIDevice currentDevice].orientation)
	{
		case UIDeviceOrientationPortrait:           return 0;
		case UIDeviceOrientationLandscapeLeft:      return 1;
		case UIDeviceOrientationPortraitUpsideDown: return 2;
		case UIDeviceOrientationLandscapeRight:     return 3;
        default:                                    return 0;
	}
	return 0;
}

void xScreenLocking(bool state)
{
	if(state)
	{
		[UIApplication sharedApplication].idleTimerDisabled = YES;
		[UIApplication sharedApplication].idleTimerDisabled = NO;
	}
	else 
	{
		[UIApplication sharedApplication].idleTimerDisabled = NO;
		[UIApplication sharedApplication].idleTimerDisabled = YES;
	}
}
#endif

void xViewport(int x, int y, int width, int height)
{
	xRender::Instance()->SetViewport(x, y, width, height);
}

void xDefaultViewport()
{
	xRender::Instance()->SetViewport(0, 0, xRender::Instance()->GraphicsWidth(), xRender::Instance()->GraphicsHeight());
}

size_t xLoadFont(const char * path)
{
	xFont * newFont = new xFont();
	if(!newFont->Load(path)) return 0;
	if(defaultFont == NULL) defaultFont = newFont;
	return (size_t)newFont;
}

void xFontTextureColor(size_t font, bool state)
{
	((xFont*)font)->EnableTextureColor(state);
}

void xSetFont(size_t font)
{
	defaultFont = (xFont*)font;
}

void xText(int x, int y, const char * text, bool centerx, bool centery)
{
	if(defaultFont == NULL) return;
	defaultFont->DrawText(text, x, y, centerx, centery);
}

void xTextEx(int x, int y, int width, const char * text)
{
	if(defaultFont == NULL) return;
	defaultFont->DrawTextEx(text, x, y, width);
}

void xFreeFont(size_t font)
{
	((xFont*)font)->Release();
	if(((xFont*)font) == defaultFont) defaultFont = NULL;
}

int xFontWidth()
{
	if(defaultFont == NULL) return 0; 
	return defaultFont->GetFontWidth();
}

int xFontHeight()
{
	if(defaultFont == NULL) return 0;
	return defaultFont->GetFontHeight();
}

int xStringWidth(const char * text)
{
	if(defaultFont == NULL) return 0;
	return defaultFont->GetStringWidth(text);
}

int xStringHeight(const char * text)
{
	if(defaultFont == NULL) return 0;
	return defaultFont->GetStringHeight(text);
}

void xRotateFont(size_t font, float angle)
{
	((xFont*)font)->SetRotate(angle);
}

void xHandleFont(size_t font, int x, int y)
{
	((xFont*)font)->SetHandle(x, y);
}

void xScaleFont(size_t font, float x, float y)
{
	((xFont*)font)->SetScale(x, y);
}

void xFontAlpha(size_t font, float alpha)
{
	alpha = Clamp(alpha, 0.0f, 1.0f);
	((xFont*)font)->SetAlpha(alpha);
}

void xFontBlend(size_t font, int mode)
{
	mode = Clamp(mode, 1, 5);
	((xFont*)font)->SetBlend(mode);
}


void xFontColor(size_t font, int r, int g, int b)
{
	((xFont*)font)->SetColor( r,  g,  b);
}

bool xResetGraphics()
{
	// delete old frme buffer
	xRender::Instance()->DeleteFrameBuffer();
	// create frame buffer
	xRender::Instance()->CreateFrameBuffer();
	return true;
}

void xCls()
{
	xRender::Instance()->Cls();
}

void xFlip()
{
#ifdef X3D_TIMETRIAL
	if(timeGetTime() > __x3dLaunchTime + (__x3dTrialTime * 60 * 1000))
	{
		printf("WARNING! Trial application's launch time expired. Render disabled.\n");
		return;
	}
#endif
	xRender::Instance()->Flip();
	xInputManager::Instance()->Update();
}

void xClsColor(int red, int green, int blue)
{
	red   = Clamp(red,   0, 255);
	green = Clamp(green, 0, 255);
	blue  = Clamp(blue,  0, 255);
	xRender::Instance()->ClsColor(red, green, blue);
}

int xGraphicsWidth()
{
	return xRender::Instance()->GraphicsWidth();
}

int xGraphicsHeight()
{
	return xRender::Instance()->GraphicsHeight();
}

void xLine(int x, int y, int dx, int dy)
{
	xRender::Instance()->DrawLine(x, y, dx, dy);
}

void xColor(int red, int green, int blue)
{
	xRender::Instance()->Color(red, green, blue);
}

void xRect(int x, int y, int width, int height, bool solid)
{
	xRender::Instance()->DrawRect(x, y, width, height, solid);
}

void xOval(int x, int y, int width, int height, bool solid)
{
	xRender::Instance()->DrawOval(x, y, width, height, solid);
}

void xPlot(int x, int y)
{
	xRender::Instance()->DrawPoint(x, y);
}

size_t xLoadImage(const char * path)
{
	xImage * newImage = new xImage();
	if(!newImage->Load(path)) return 0;
	return (size_t)newImage;
}

size_t xLoadAnimImage(const char * path, int frameWidth, int frameHeight, int firstFrame, int frames)
{
	xImage * newImage = new xImage();
	if(!newImage->LoadAnimated(path, frameWidth, frameHeight, firstFrame, frames)) return 0;
	return (size_t)newImage;
}

size_t xCreateImage(int frameWidth, int frameHeight, int frames)
{
	xImage * newImage = new xImage();
	if(!newImage->Create(frameWidth, frameHeight, frames)) return 0;
	return (size_t)newImage;
}

void xDrawImage(size_t image, float x, float y, int frame)
{
	((xImage*)image)->Draw(x, y, frame);
}

void xDrawImageRect(size_t image, int x, int y, int rectX, int rectY, int rectWidth, int rectHeight, int frame)
{
	((xImage*)image)->DrawRect(x, y, frame, rectX, rectY, rectWidth, rectHeight);
}

void xDrawBlock(size_t image, int x, int y, int frame)
{
	((xImage*)image)->DrawBlock(x, y, frame);
}

void xDrawBlockRect(size_t image, int x, int y, int rectX, int rectY, int rectWidth, int rectHeight, int frame)
{
	((xImage*)image)->DrawBlockRect(x, y, frame, rectX, rectY, rectWidth, rectHeight);
}

void xRotateImage(size_t image, float angle)
{
	((xImage*)image)->SetRotate(angle);
}

void xHandleImage(size_t image, int x, int y)
{
	((xImage*)image)->SetHandle(x, y);
}

void xScaleImage(size_t image, float x, float y)
{
	((xImage*)image)->SetScale(x, y);
}

void xResizeImage(size_t image, int width, int height)
{
	((xImage*)image)->Resize(width, height);
}

float xImageAngle(size_t image)
{
	return ((xImage*)image)->GetAngle();
}

int xImageWidth(size_t image)
{
	return ((xImage*)image)->GetWidth();
}

int xImageHeight(size_t image)
{
	return ((xImage*)image)->GetHeight();
}

int xImageXHandle(size_t image)
{
	return ((xImage*)image)->GetXHandle();
}

int xImageYHandle(size_t image)
{
	return ((xImage*)image)->GetYHandle();
}

void xMidHandle(size_t image)
{
	((xImage*)image)->MidHandle();
}

void xAutoMidHandle(bool state)
{
	xImage::AutoMidHandle(state);
}

void xFreeImage(size_t image)
{
	((xImage*)image)->Release();
	delete ((xImage*)image);
}

int xBackBuffer()
{
	return 0; // 0 reserved for backbuffer
}

int xImageBuffer(size_t image, int frame)
{
	return AddImageBuffer((xImage*)image, frame);
}

int xTextureBuffer(size_t texture, int frame)
{
	return AddTextureBuffer((xTexture*)texture, frame);
}

void xSetBuffer(int buffer)
{
	if(buffer == 0) 
	{
		xRender::Instance()->SetFrameBuffer();
		xRender::Instance()->SetViewport(0, 0, xRender::Instance()->GraphicsWidth(), xRender::Instance()->GraphicsHeight());
	}
	activeBuffer = buffer;
	xBuffer * bufferPtr = GetBufferByID(activeBuffer);
	if(bufferPtr == NULL) return;
	if(bufferPtr->_texture != NULL)
	{
		bufferPtr->_texture->SetTarget(bufferPtr->_frame);
		xRender::Instance()->SetViewport(0, 0, bufferPtr->_texture->GetWidth(), bufferPtr->_texture->GetHeight());
	}
	else if(bufferPtr->_image != NULL)
	{
		bufferPtr->_image->SetTarget(bufferPtr->_frame);
		xRender::Instance()->SetViewport(0, 0, bufferPtr->_image->GetWidth(), bufferPtr->_image->GetHeight());
	}
}

void xLockBuffer(int buffer)
{
	if(buffer < 0) buffer = activeBuffer;
	if(buffer == 0)
	{
		xRender::Instance()->LockBB();
	}
	else
	{
		xBuffer * bufferPtr = GetBufferByID(buffer);
		if(bufferPtr == NULL) return;
		if(bufferPtr->_texture != NULL)
		{
			bufferPtr->_texture->Lock(bufferPtr->_frame);
		}
		else if(bufferPtr->_image != NULL)
		{
			bufferPtr->_image->Lock(bufferPtr->_frame);
		}
	}
}

void xUnlockBuffer(int buffer)
{
	if(buffer < 0) buffer = activeBuffer;
	if(buffer == 0)
	{
		xRender::Instance()->UnlockBB();
	}
	else
	{
		xBuffer * bufferPtr = GetBufferByID(buffer);
		if(bufferPtr == NULL) return;
		if(bufferPtr->_texture != NULL)
		{
			bufferPtr->_texture->Unlock(bufferPtr->_frame);
		}
		else if(bufferPtr->_image != NULL)
		{
			bufferPtr->_image->Unlock(bufferPtr->_frame);
		}
	}
}

int xReadPixel(int x, int y, int buffer)
{
	if(buffer < 0) buffer = activeBuffer;
	if(buffer == 0)
	{
		return xRender::Instance()->ReadPixelBB(x, y);
	}
	else
	{
		xBuffer * bufferPtr = GetBufferByID(buffer);
		if(bufferPtr == NULL) return 0;
		if(bufferPtr->_texture != NULL)
		{
			return bufferPtr->_texture->ReadPixel(x, y, bufferPtr->_frame);
		}
		else if(bufferPtr->_image != NULL)
		{
			return bufferPtr->_image->ReadPixel(x, y, bufferPtr->_frame);
		}
	}
	return 0;
}

void xWritePixel(int x, int y, int color, int buffer)
{
	if(buffer < 0) buffer = activeBuffer;
	if(buffer == 0)
	{
		xRender::Instance()->WritePixelBB(x, y, color);
	}
	else
	{
		xBuffer * bufferPtr = GetBufferByID(buffer);
		if(bufferPtr == NULL) return;
		if(bufferPtr->_texture != NULL)
		{
			bufferPtr->_texture->WritePixel(x, y, color, bufferPtr->_frame);
		}
		else if(bufferPtr->_image != NULL)
		{
			bufferPtr->_image->WritePixel(x, y, color, bufferPtr->_frame);
		}
	}
}

void xWritePixelFast(int x, int y, int color, int buffer)
{
	xWritePixel(x, y, color, buffer);
}

int xReadPixelFast(int x, int y, int buffer)
{
	return xReadPixel(x, y, buffer);
}

void xCopyPixel(int sourceX, int sourceY, int sourceBuff, int destX, int destY, int destBuff)
{
	if(sourceBuff < 0) sourceBuff = activeBuffer;
	if(destBuff   < 0) destBuff   = activeBuffer;
	xWritePixel(destX, destY, xReadPixel(sourceX, sourceY, sourceBuff), destBuff);
}

void xCopyRect(int sourceX, int sourceY, int rectWidth, int rectHeight, int destX, int destY, int sourceBuff, int destBuff)
{
	if(sourceBuff < 0) sourceBuff = activeBuffer;
	if(destBuff   < 0) destBuff   = activeBuffer;
	bool lockedSrc  = true;
	bool lockedDest = true;
	if(!IsBufferLocked(sourceBuff))
	{
		xLockBuffer(sourceBuff);
		lockedSrc = false;
	}
	if(!IsBufferLocked(destBuff))
	{
		xLockBuffer(destBuff);
		lockedDest = false;
	}
	for(int x = 0; x < rectWidth; x++)
	{
		for(int y = 0; y < rectHeight; y++)
		{
			xWritePixel(destX + x, destY + y, xReadPixel(sourceX + x, sourceY + y, sourceBuff), destBuff);
		}
	}
	if(!lockedSrc)  xUnlockBuffer(sourceBuff);
	if(!lockedDest) xUnlockBuffer(destBuff);
}

void xCaptureWorld()
{
	std::vector<xEntity*>           * entities = xRender::Instance()->GetEntitiesArray();
	std::vector<xEntity*>::iterator   nodeItr  = entities->begin();
	while(nodeItr != entities->end())
	{
		(*nodeItr)->Capture();
		nodeItr++;
	}
	std::vector<xCamera*>           * cameras = xRender::Instance()->GetCamerasArray();
	std::vector<xCamera*>::iterator   camItr  = cameras->begin();
	while(camItr != cameras->end())
	{
		(*camItr)->Capture();
		camItr++;
	}
}

void xRenderWorld(float tween)
{
#ifdef X3D_TIMETRIAL
	if(timeGetTime() > __x3dLaunchTime + (__x3dTrialTime * 60 * 1000))
	{
		printf("WARNING! Trial application's launch time expired. Render disabled.\n");
		return;
	}
#endif
	xAudioManager::Instance()->Update();
	xRender::Instance()->SetContext();
	xRender::Instance()->DrawQueue();
	glEnable(GL_LIGHTING);
	glEnable(GL_DEPTH_TEST);
	std::vector<xCamera*> * cameras  = xRender::Instance()->GetCamerasArray();
	std::vector<xEntity*> * entities = xRender::Instance()->GetEntitiesArray();
	std::vector<xCamera*>::iterator camItr = cameras->begin();
	while(camItr != cameras->end())
	{
		xCamera * currCamera = *camItr;
		currCamera->ApplyTweening(tween);
		if(currCamera->SetActive())
		{
			xRender::Instance()->ResetLights();
			xRender::Instance()->RenderPreOrder();
			std::vector<xEntity*>::iterator nodeItr = entities->begin();
			while(nodeItr != entities->end())
			{
				xEntity * currNode = *nodeItr;
				currNode->ApplyTweening(tween);
				if(currNode->GetType() == ENTITY_CAMERA || currNode->GetType() == ENTITY_LIGHT
					|| ((currNode->GetType() == ENTITY_NODE || currNode->GetType() == ENTITY_BONE)
					&& currNode->CountSurfaces() == 0) || currNode->GetOrder() != 0)
				{
					nodeItr++;
					continue;
				}
				currNode->Draw();
				nodeItr++;
			}
			xRender::Instance()->RenderTransparent();
			xRender::Instance()->RenderPostOrder();
		}
		camItr++;
	}
	glDisable(GL_FOG);
}

int xFPSCounter()
{
	return xRender::Instance()->GetFPSCount();
}

int xTrisRendered()
{
	return xRender::Instance()->GetTrianglesCount();
}

int xDIPCalls()
{
	return xRender::Instance()->GetDIPCount();
}

void xUpdateWorld(float speed)
{
	timeval time;
	gettimeofday(&time, NULL);
	uint currentTime = (time.tv_sec * 1000) + (time.tv_usec / 1000);	
	if(lastTime == 0)
	{
		lastTime = currentTime;
		return;
	}
	float delta = float(currentTime - lastTime) / 1000.0f;
	lastTime = currentTime;
	std::vector<xCamera*> * cameras   = xRender::Instance()->GetCamerasArray();
	std::vector<xBone*>   * entities  = xRender::Instance()->GetAnimatedArray();
	std::vector<xEntity*> * md2Meshes = xRender::Instance()->GetMD2Array();
	std::vector<xEntity*> skinned;
	// animate
	std::vector<xCamera*>::iterator camItr = cameras->begin();
	while(camItr != cameras->end())
	{
		xCamera * currCamera = *camItr;
		if(currCamera->IsVisible() && currCamera->GetProjMode() != 0)
		{
			std::vector<xBone*>::iterator nodeItr = entities->begin();
			while(nodeItr != entities->end())
			{
				xBone * currNode = *nodeItr;
				if(currNode->IsSkinned())
				{
					skinned.push_back((xEntity*)currNode);
				}
				else
				{
					currNode->UpdateAnimation(delta * speed);
					currNode->ComputeFinalTransform();
				}
				nodeItr++;
			}
		}
		camItr++;
	}
	// update md2
	std::vector<xEntity*>::iterator md2Itr = md2Meshes->begin();
	while(md2Itr != md2Meshes->end())
	{
		(*md2Itr)->UpdateMD2(delta * speed);
		md2Itr++;
	}
	// update skin
	/*
	std::vector<xEntity*>::iterator nodeItr = skinned.begin();
	while(nodeItr != skinned.end())
	{
		xEntity * currNode = *nodeItr;
		currNode->UpdateSkin();
		nodeItr++;
	}
	*/
	// physics
	if(xRender::Instance()->PhysNodesBegin() != xRender::Instance()->PhysNodesEnd())
	{
		std::vector<xEntity*>::iterator itr = xRender::Instance()->PhysNodesBegin();
		while(itr != xRender::Instance()->PhysNodesEnd())
		{
			(*itr)->SyncBodyTransform();
			itr++;
		}
		xRender::Instance()->GetPhysWorld()->Update(speed);
		itr = xRender::Instance()->PhysNodesBegin();
		while(itr != xRender::Instance()->PhysNodesEnd())
		{
			(*itr)->SyncEntityTransform();
			itr++;
		}
	}
	// simulate
	xSimulator::Instance()->Update(delta * speed);
}

void xAnimate(size_t entity, int mode, float speed, int setID, float smooth)
{
	((xEntity*)entity)->Animate(mode, speed, setID, smooth);
}

size_t xLoadAnimMesh(const char * path, size_t parent)
{
	xEntity * newEntity = new xEntity();
	if(!newEntity->LoadAnimMesh(path)) return 0;
	if(parent != 0) newEntity->SetParent((xEntity*)parent);
	return (size_t)newEntity;
}

void xEntityOrder(size_t entity, int order)
{
	((xEntity*)entity)->SetOrder(order);
}

void xEntityAutoFade(size_t entity, float nearValue, float farValue)
{
	((xEntity*)entity)->SetAutoFade(nearValue, farValue);
}

size_t xCreateLight(int type, size_t parent)
{
	type = Clamp(type, 0, 2);
	xLight * newLight = new xLight(type);
	xRender::Instance()->AddLight(newLight);
	if(parent != 0) newLight->SetParent((xEntity*)parent);
	return (size_t)newLight;
}

void xLightRange(size_t light, float range)
{
	((xLight*)light)->SetRange(range);
}

void xLightConeAngles(size_t light, float inner, float outer)
{
	inner = Clamp(inner, 0.0f, 180.0f);
	outer = Clamp(outer, 0.0f, 180.0f);
	((xLight*)light)->SetAngles(inner / 2.0f, outer / 2.0f);
}

void xLightColor(size_t light, int red, int green, int blue)
{
	((xLight*)light)->SetColor(red, green, blue);
}

float xMeshWidth(size_t entity)
{
	return ((xEntity*)entity)->GetMeshWidth();
}

float xVectorYaw(float x, float y, float z)
{
	return xVector(x, y, z).Yaw();
}

float xVectorPitch(float x, float y, float z)
{
	return xVector(x, y, z).Pitch();
}

void xPointEntity(size_t src, size_t dest, float roll)
{
	xVector direction = ((xEntity*)dest)->GetPosition(true) - ((xEntity*)src)->GetPosition(true);
	((xEntity*)src)->SetQuaternion(RotationQuaternion(-direction.Pitch(), direction.Yaw() + 180.0f, roll), true);
}

void xAlignToVector(size_t entity, float x, float y, float z, int axis, float rate)
{
	xVector ax(x, y, z);
	float length = ax.Length();
	if(length <= X3DEPSILON) return;
	ax /= length;
	xQuaternion quat = ((xEntity*)entity)->GetQuaternion(true);
	xVector tv = (axis == 1) ? quat.i() : (axis == 2 ? quat.j() : quat.k());
	float dp = ax.Dot(tv);
	if(dp >= 1.0f - X3DEPSILON) return;
	if(dp <= -1.0f + X3DEPSILON)
	{
		float an   = 3.415f * rate / 2;
		xVector cp = (axis == 1) ? quat.j() : (axis == 2 ? quat.k() : quat.i());
		cp = cp * sin(an);
		((xEntity*)entity)->SetQuaternion(xQuaternion(cp.x, cp.y, cp.z, cos(an)) * quat, true);
		return;
	}
	float an   = acos(dp) * rate / 2;
	xVector cp = ax.Cross(tv).Normalized();
	cp = cp * sin(an);
	((xEntity*)entity)->SetQuaternion(xQuaternion(cp.x, cp.y, cp.z, cos(an)) * quat, true);
}

float xMeshHeight(size_t entity)
{
	return ((xEntity*)entity)->GetMeshHeight();
}

float xMeshDepth(size_t entity)
{
	return ((xEntity*)entity)->GetMeshDepth();
}

void xPositionMesh(size_t entity, float x, float y, float z)
{
	((xEntity*)entity)->PositionMesh(x, y, z);
}

void xRotateMesh(size_t entity, float pitch, float yaw, float roll)
{
	((xEntity*)entity)->RotateMesh(pitch, yaw, roll);
}

void xScaleMesh(size_t entity, float x, float y, float z)
{
	((xEntity*)entity)->ScaleMesh(x, y, z);
}

void xUpdateNormals(size_t entity)
{
	((xEntity*)entity)->GenerateNormals();
}

void xPaintEntity(size_t entity, size_t brush)
{
	((xEntity*)entity)->ApplyBrush((xBrush*)brush, true);
}

void xPaintMesh(size_t entity, size_t brush)
{
	((xEntity*)entity)->ApplyBrush((xBrush*)brush, false);
}

void xFlipMesh(size_t entity)
{
	((xEntity*)entity)->FlipMesh();
}

void xAddMesh(size_t srcMesh, size_t destMesh)
{
	((xEntity*)destMesh)->AddMesh((xEntity*)srcMesh);
}

size_t xCopyEntity(size_t entity, size_t parent)
{
	xEntity * result = ((xEntity*)entity)->Clone((xEntity*)parent, false);
	result->SetPosition(0.0f, 0.0f, 0.0f, false);
	result->SetScale(1.0f, 1.0f, 1.0f, false);
	result->SetRotation(0.0f, 0.0f, 0.0f, false);
	if(result->GetType() == ENTITY_SPRITE)
	{
		((xSprite*)result)->SetOffset(0.0f, 0.0f);
		((xSprite*)result)->SetScale(1.0f, 1.0f);
		((xSprite*)result)->SetRotation(0.0f);
		((xSprite*)result)->SetViewMode(1);
	}
	return (size_t)result;
}

size_t xCopyMesh(size_t entity, size_t parent)
{
	xEntity * result = ((xEntity*)entity)->Clone((xEntity*)parent, true);
	result->SetPosition(0.0f, 0.0f, 0.0f, false);
	result->SetScale(1.0f, 1.0f, 1.0f, false);
	result->SetRotation(0.0f, 0.0f, 0.0f, false);
	if(result->GetType() == ENTITY_SPRITE)
	{
		((xSprite*)result)->SetOffset(0.0f, 0.0f);
		((xSprite*)result)->SetScale(1.0f, 1.0f);
		((xSprite*)result)->SetRotation(0.0f);
		((xSprite*)result)->SetViewMode(1);
	}
	return (size_t)result;
}

size_t xCloneEntity(size_t entity)
{
	return (size_t)((xEntity*)entity)->Clone(((xEntity*)entity)->GetParent(), false);
}

size_t xCloneMesh(size_t entity)
{
	return (size_t)((xEntity*)entity)->Clone(((xEntity*)entity)->GetParent(), true);
}

int xAddVertex(size_t surface, float x, float y, float z, float tu, float tv)
{
	return ((xSurface*)surface)->AddVertex(x, y, z, tu, tv);
}

int xAddTriangle(size_t surface, int v0, int v1, int v2)
{
	return ((xSurface*)surface)->AddTriangle(v0, v1, v2);
}

void xVertexCoords(size_t surface, int index, float x, float y, float z)
{
	((xSurface*)surface)->VertexCoords(index, x, y, z);
}

void xVertexNormal(size_t surface, int index, float x, float y, float z)
{
	((xSurface*)surface)->VertexNormal(index, x, y, z);
}

void xVertexColor(size_t surface, int index, int red, int green, int blue, float alpha)
{
	red   = Clamp(red, 0, 255);
	green = Clamp(green, 0, 255);
	blue  = Clamp(blue, 0, 255);
	alpha = Clamp(alpha, 0.0f, 1.0f);
	((xSurface*)surface)->VertexColor(index, red, green, blue, alpha);
}

void xVertexTexCoords(size_t surface, int index, float tu, float tv, float tw, int setNum)
{
	((xSurface*)surface)->VertexTexCoords(index, tu, tv, tw, setNum);
}

int xCountVertices(size_t surface)
{
	return ((xSurface*)surface)->CountVertices();
}

int xCountTriangles(size_t surface)
{
	return ((xSurface*)surface)->CountTriangles();
}

float xVertexX(size_t surface, int index)
{
	return ((xSurface*)surface)->GetVertexCoords(index).x;
}

float xVertexY(size_t surface, int index)
{
	return ((xSurface*)surface)->GetVertexCoords(index).y;
}

float xVertexZ(size_t surface, int index)
{
	return ((xSurface*)surface)->GetVertexCoords(index).z;
}

float xVertexNX(size_t surface, int index)
{
	return ((xSurface*)surface)->GetVertexNormal(index).x;
}

float xVertexNY(size_t surface, int index)
{
	return ((xSurface*)surface)->GetVertexNormal(index).y;
}

float xVertexNZ(size_t surface, int index)
{
	return ((xSurface*)surface)->GetVertexNormal(index).z;
}

int xVertexRed(size_t surface, int index)
{
	return ((xSurface*)surface)->GetVertexColor(index).x;
}

int xVertexGreen(size_t surface, int index)
{
	return ((xSurface*)surface)->GetVertexColor(index).y;
}

int xVertexBlue(size_t surface, int index)
{
	return ((xSurface*)surface)->GetVertexColor(index).z;
}

float xVertexAlpha(size_t surface, int index)
{
	return ((xSurface*)surface)->GetVertexAlpha(index);
}

float xVertexU(size_t surface, int index, int setNum)
{
	return ((xSurface*)surface)->GetVertexTexCoords(index, setNum).x;
}

float xVertexV(size_t surface, int index, int setNum)
{
	return ((xSurface*)surface)->GetVertexTexCoords(index, setNum).y;
}

float xVertexW(size_t surface, int index, int setNum)
{
	return ((xSurface*)surface)->GetVertexTexCoords(index, setNum).z;
}

int xTriangleVertex(size_t surface, int index, int corner)
{
	corner = Clamp(corner, 0, 2);
	return ((xSurface*)surface)->TriangleVertex(index, corner);
}

void xClearSurface(size_t surface, bool vertices, bool triangles)
{
	((xSurface*)surface)->Clear(vertices, triangles);
}

void xAmbientLight(int red, int green, int blue)
{
	red   = Clamp(red, 0, 255);
	green = Clamp(green, 0, 255);
	blue  = Clamp(blue, 0, 255);
	GLfloat ambient[] = { (float)red / 255.0f, (float)green / 255.0f, (float)blue / 255.0f, 1.0f };
	glLightModelfv(GL_LIGHT_MODEL_AMBIENT, ambient);
}

size_t xCreateBrush(int red, int green, int blue)
{
	red   = Clamp(red, 0, 255);
	green = Clamp(green, 0, 255);
	blue  = Clamp(blue, 0, 255);
	xBrush * newBrush = new xBrush();
	newBrush->red   = red;
	newBrush->green = green;
	newBrush->blue  = blue;
	return (size_t)newBrush;
}

size_t xLoadBrush(const char * path, int flags, float uscale, float vscale)
{
	xBrush * newBrush = new xBrush();
	newBrush->textures[0].texture = xTextureManager::Instance()->LoadTexture(path, flags);
	if(newBrush->textures[0].texture == NULL) return 0;
	newBrush->textures[0].texture->SetScale(uscale, vscale);
	return (size_t)newBrush;
}

void xFreeBrush(size_t brush)
{
	delete ((xBrush*)brush);
}

void xBrushColor(size_t brush, int red, int green, int blue)
{
	red   = Clamp(red, 0, 255);
	green = Clamp(green, 0, 255);
	blue  = Clamp(blue, 0, 255);
	((xBrush*)brush)->red   = red;
	((xBrush*)brush)->green = green;
	((xBrush*)brush)->blue  = blue;
}

void xBrushAlpha(size_t brush, float alpha)
{
	alpha = Clamp(alpha, 0.0f, 1.0f);
	((xBrush*)brush)->alpha = alpha;
}

void xBrushShininess(size_t brush, float shininess)
{
	shininess = Clamp(shininess, 0.0f, 1.0f);
	((xBrush*)brush)->alpha = shininess;
}

void xBrushTexture(size_t brush, size_t texture, int frame, int index)
{
	if(index < 0 || index >= xRender::Instance()->GetMaxTextureUnits()) return;
	if(((xBrush*)brush)->textures[index].texture != NULL)
	{
		xTextureManager::Instance()->ReleaseTexture(((xBrush*)brush)->textures[index].texture);
	}
	((xBrush*)brush)->textures[index].texture = (xTexture*)texture;
	((xBrush*)brush)->textures[index].frame   = frame;
	if(((xBrush*)brush)->textures[index].texture != NULL) ((xBrush*)brush)->textures[index].texture->Retain();
}

void xBrushBlend(size_t brush, int blend)
{
	blend = Clamp(blend, 1, 3);
	((xBrush*)brush)->blendMode = blend;
}

void xBrushFX(size_t brush, int fx)
{
	((xBrush*)brush)->FX = fx;
}

size_t xGetEntityBrush(size_t entity)
{
	xBrush * newBrush = new xBrush();
	newBrush->Copy(((xEntity*)entity)->GetBrush());
	return (size_t)newBrush;
}

size_t xGetSurfaceBrush(size_t surface)
{
	return (size_t)((xSurface*)surface)->GetBrush();
}

size_t xCreateTexture(int width, int height, int flags, int frames)
{
	return (size_t)xTextureManager::Instance()->CreateTexture(flags, width, height, frames);
}

size_t xLoadTexture(const char * path, int flags)
{
	return (size_t)xTextureManager::Instance()->LoadTexture(path, flags);
}

size_t xLoadAnimTexture(const char * path, int flags, int frameWidth, int frameHeight, int firstFrame, int frames)
{
	return (size_t)xTextureManager::Instance()->LoadAnimTexture(path, flags, frameWidth, frameHeight, firstFrame, frames);
}

void xFreeTexture(size_t texture)
{
	xTextureManager::Instance()->ReleaseTexture((xTexture*)texture);
}

void xTextureBlend(size_t texture, int blend)
{
	blend = Clamp(blend, 0, 5);
	((xTexture*)texture)->SetBlendMode(blend);
}

void xTextureCoords(size_t texture, int setNum)
{
	((xTexture*)texture)->SetCoordsSet(setNum);
}

void xScaleTexture(size_t texture, float u, float v)
{
	((xTexture*)texture)->SetScale(u, v);
}

void xPositionTexture(size_t texture, float u, float v)
{
	((xTexture*)texture)->SetOffset(u, v);
}

void xRotateTexture(size_t texture, float angle)
{
	((xTexture*)texture)->SetRotation(angle);
}

int xTextureWidth(size_t texture)
{
	return ((xTexture*)texture)->GetWidth();
}

int xTextureHeight(size_t texture)
{
	return ((xTexture*)texture)->GetHeight();
}

const char * xTextureName(size_t texture)
{
	return ((xTexture*)texture)->GetPath();
}

size_t xGetBrushTexture(size_t brush, int index)
{
	if(index < 0 || index >= xRender::Instance()->GetMaxTextureUnits()) return 0;
	xTexture * texture = ((xBrush*)brush)->textures[index].texture;
	if(texture != NULL) texture->Retain();
	return (size_t)texture;
}

void xPaintSurface(size_t surface, size_t brush)
{
	((xSurface*)surface)->ApplyBrush((xBrush*)brush);
}

size_t xCreateSurface(size_t entity, size_t brush)
{
	return (size_t)((xEntity*)entity)->CreateSurface((xBrush*)brush);
}

size_t xFindSurface(size_t entity, size_t brush)
{
	return (size_t)((xEntity*)entity)->FindSurface((xBrush*)brush);
}

size_t xCreateMesh(size_t parent)
{
	xEntity * newEntity = new xEntity();
	newEntity->SetParent((xEntity*)parent);
	return (size_t)newEntity;
}

int xCountSurfaces(size_t entity)
{
	return ((xEntity*)entity)->CountSurfaces();
}

size_t xGetSurface(size_t entity, int index)
{
	return (size_t)((xEntity*)entity)->GetSurface(index);
}

size_t xCreateCube(size_t parent)
{
	xEntity * newEntity = new xEntity();
	newEntity->CreateCube();
	if(parent != 0) newEntity->SetParent((xEntity*)parent);
	return (size_t)newEntity;
}

size_t xCreateSphere(int segments, size_t parent)
{
	xEntity * newEntity = new xEntity();
	newEntity->CreateSphere(segments);
	if(parent != 0) newEntity->SetParent((xEntity*)parent);
	return (size_t)newEntity;
}

size_t xCreateCyllinder(int segments, bool solid, size_t parent)
{
	xEntity * newEntity = new xEntity();
	newEntity->CreateCyllinder(segments, solid);
	if(parent != 0) newEntity->SetParent((xEntity*)parent);
	return (size_t)newEntity;
}

size_t xCreateCone(int segments, bool solid, size_t parent)
{
	xEntity * newEntity = new xEntity();
	newEntity->CreateCone(segments, solid);
	if(parent != 0) newEntity->SetParent((xEntity*)parent);
	return (size_t)newEntity;
}

void xFitMesh(size_t entity, float x, float y, float z, float width, float height, float depth, bool uniform)
{
	((xEntity*)entity)->FitMesh(x, y, z, width, height, depth, uniform);
}

size_t xCreateCamera(size_t parent)
{
	xCamera * newCamera = new xCamera();
	newCamera->SetParent((xEntity*)parent);
	return (size_t)newCamera;
}

void xCameraProjMode(size_t camera, int mode)
{
	mode = Clamp(mode, 0, 2);
	((xCamera*)camera)->SetProjMode(mode);
}

void xCameraFogMode(size_t camera, int mode)
{
	mode = Clamp(mode, 0, 1);
	((xCamera*)camera)->SetFogMode(mode);
}

void xCameraFogRange(size_t camera, float fogStart, float fogEnd)
{
	((xCamera*)camera)->SetFogRange(fogStart, fogEnd);
}

void xCameraFogColor(size_t camera, int red, int green, int blue)
{
	red   = Clamp(red,   0, 255);
	green = Clamp(green, 0, 255);
	blue  = Clamp(blue,  0, 255);
	((xCamera*)camera)->SetFogColor(red, green, blue);
}

void xCameraViewport(size_t camera, int x, int y, int width, int height)
{
	((xCamera*)camera)->SetViewport(x, y, width, height);
}

void xCameraClsMode(size_t camera, bool clearColor, bool clearZBuffer)
{
	((xCamera*)camera)->SetClearMode(clearColor, clearZBuffer);
}

void xCameraClsColor(size_t camera, int red, int green, int blue)
{
	red   = Clamp(red,   0, 255);
	green = Clamp(green, 0, 255);
	blue  = Clamp(blue,  0, 255);
	((xCamera*)camera)->SetClearColor(red, green, blue);
}

void xCameraRange(size_t camera, float nearValue, float farValue)
{
	((xCamera*)camera)->SetRange(nearValue, farValue);
}

void xCameraZoom(size_t camera, float zoom)
{
	((xCamera*)camera)->SetZoom(zoom);
}

void xEntityInView(size_t entity, size_t camera)
{
	((xEntity*)entity)->InView((xCamera*)camera);
}

void xScaleEntity(size_t entity, float x, float y, float z, bool global)
{
	((xEntity*)entity)->SetScale(x, y, z, global);
}

void xPositionEntity(size_t entity, float x, float y, float z, bool global)
{
	((xEntity*)entity)->SetPosition(x, y, z, global);
}

void xMoveEntity(size_t entity, float x, float y, float z, bool global)
{
	((xEntity*)entity)->Move(x, y, z, global);
}

void xTranslateEntity(size_t entity, float x, float y, float z)
{
	((xEntity*)entity)->Translate(x, y, z);
}

void xRotateEntity(size_t entity, float pitch, float yaw, float roll, bool global)
{
	((xEntity*)entity)->SetRotation(pitch, yaw, roll, global);
}

void xTurnEntity(size_t entity, float pitch, float yaw, float roll, bool global)
{
	((xEntity*)entity)->Turn(pitch, yaw, roll, global);
}

void xFreeEntity(size_t entity)
{
	((xEntity*)entity)->Release();
	delete ((xEntity*)entity);
}

void xEntityColor(size_t entity, int red, int green, int blue)
{
	red   = Clamp(red,   0, 255);
	green = Clamp(green, 0, 255);
	blue  = Clamp(blue,  0, 255);
	((xEntity*)entity)->SetColor(red, green, blue);
}

void xSetAlphaFunc(size_t entity, int function)
{
	((xEntity*)entity)->SetAlphaFunc(function);
}

int xGetAlphaFunc(size_t entity)
{
	return ((xEntity*)entity)->GetAlphaFunc();
}

void xSetAlphaRef(size_t entity, int reference)
{
	((xEntity*)entity)->SetAlphaRef(float(reference) / 255.0f);
}

int xGetAlphaRef(size_t entity)
{
	return ((xEntity*)entity)->GetAlphaRef() * 255;
}

void xSetEntityUserData(size_t entity, void * data)
{
	((xEntity*)entity)->SetUserData(data);
}

void * xGetEntityUserData(size_t entity)
{
	return ((xEntity*)entity)->GetUserData();
}

void xEntityAlpha(size_t entity, float alpha)
{
	alpha = Clamp(alpha, 0.0f, 1.0f);
	((xEntity*)entity)->SetAlpha(alpha);
}

void xEntityShininess(size_t entity, float shininess)
{
	shininess = Clamp(shininess, 0.0f, 1.0f);
	((xEntity*)entity)->SetShininess(shininess);
}

void xEntityTexture(size_t entity, size_t texture, int frame, int index)
{
	((xEntity*)entity)->SetTexture(index, (xTexture*)texture, frame);
}

void xEntityBlend(size_t entity, int blend)
{
	blend = Clamp(blend, 1, 3);
	((xEntity*)entity)->SetBlendMode(blend);
}

void xEntityFX(size_t entity, int fx)
{
	((xEntity*)entity)->SetFXFlags(fx);
}

void xShowEntity(size_t entity)
{
	((xEntity*)entity)->Show();
}

void xHideEntity(size_t entity)
{
	((xEntity*)entity)->Hide();
}

void xNameEntity(size_t entity, const char * name)
{
	((xEntity*)entity)->SetName(name);
}

void xEntityParent(size_t entity, size_t parent, bool global)
{
	if(((xEntity*)entity)->GetParent() == (xEntity*)parent) return;
	if(global)
	{
		xVector position = ((xEntity*)entity)->GetPosition(true);
		xVector rotation = ((xEntity*)entity)->GetRotation(true);
		xVector scale    = ((xEntity*)entity)->GetScale(true);
		((xEntity*)entity)->SetParent((xEntity*)parent);
		((xEntity*)entity)->SetPosition(position.x, position.y, position.z, global);
		((xEntity*)entity)->SetRotation(rotation.x, rotation.y, rotation.z, global);
		((xEntity*)entity)->SetScale(scale.x, scale.y, scale.z, global);
	}
	else
	{
		((xEntity*)entity)->SetParent((xEntity*)parent);
	}
}

size_t xGetParent(size_t entity)
{
	return (size_t)((xEntity*)entity)->GetParent();
}

float xEntityX(size_t entity, bool global)
{
	return ((xEntity*)entity)->GetPosition(global).x;
}

float xEntityY(size_t entity, bool global)
{
	return ((xEntity*)entity)->GetPosition(global).y;
}

float xEntityZ(size_t entity, bool global)
{
	return ((xEntity*)entity)->GetPosition(global).z;
}

float xEntityRoll(size_t entity, bool global)
{
	return ((xEntity*)entity)->GetRotation(global).z;
}

float xEntityYaw(size_t entity, bool global)
{
	return ((xEntity*)entity)->GetRotation(global).y;
}

float xEntityPitch(size_t entity, bool global)
{
	return ((xEntity*)entity)->GetRotation(global).x;
}

const char * xEntityName(size_t entity)
{
	return ((xEntity*)entity)->GetName();
}

int xCountChildren(size_t entity)
{
	return ((xEntity*)entity)->CountChilds();
}

size_t xGetChild(size_t entity, int index)
{
	return (size_t)((xEntity*)entity)->GetChild(index);
}

size_t xFindChild(size_t entity, const char * name)
{
	return (size_t)((xEntity*)entity)->FindChild(name);
}

float xEntityDistance(size_t entity, size_t entity2)
{
	return ((xEntity*)entity)->GetPosition(true).Distance(((xEntity*)entity2)->GetPosition(true));
}

#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
int xCountTouches()
{
	return xInputManager::Instance()->GetTouchCounter();
}

void xFlushTouches()
{
	return xInputManager::Instance()->Flush();
}

void xEnableMultiTouch()
{
	xInputManager::Instance()->EnableMultiTouch();
}

void xDisableMultiTouch()
{
	xInputManager::Instance()->DisableMultiTouch();
}

int xTouchPhase(int index)
{
	xTouch * touch = xInputManager::Instance()->GetTouch(index);
	if(touch == NULL) return 0;
	return touch->phase;
}

int xTouchX(int index)
{
	xTouch * touch = xInputManager::Instance()->GetTouch(index);
	if(touch == NULL) return 0;
	return touch->location.x;
}

int xTouchY(int index)
{
	xTouch * touch = xInputManager::Instance()->GetTouch(index);
	if(touch == NULL) return 0;
	return touch->location.y;
}

int xTouchPrevX(int index)
{
	xTouch * touch = xInputManager::Instance()->GetTouch(index);
	if(touch == NULL) return 0;
	return touch->prevLocation.x;
}

int xTouchPrevY(int index)
{
	xTouch * touch = xInputManager::Instance()->GetTouch(index);
	if(touch == NULL) return 0;
	return touch->prevLocation.y;
}

float xTouchTime(int index)
{
	xTouch * touch = xInputManager::Instance()->GetTouch(index);
	if(touch == NULL) return 0.0f;
	return touch->touchTime;
}

int xTouchTapCount(int index)
{
	xTouch * touch = xInputManager::Instance()->GetTouch(index);
	if(touch == NULL) return 0;
	return touch->tapCount;
}

void xEnableAccelerometer(bool state)
{
	xInputManager::Instance()->EnableAccelerometer(state);
}

float xAccelerationX()
{
	return xInputManager::Instance()->GetAcceleration().x;
}

float xAccelerationY()
{
	return xInputManager::Instance()->GetAcceleration().y;
}

float xAccelerationZ()
{
	return xInputManager::Instance()->GetAcceleration().z;
}

float xGravitationX()
{
	return xInputManager::Instance()->GetGravitation().x;
}

float xGravitationY()
{
	return xInputManager::Instance()->GetGravitation().y;
}

float xGravitationZ()
{
	return xInputManager::Instance()->GetGravitation().z;
}

void xFlushAcceleration()
{
	xInputManager::Instance()->FlushAcceleration();
}

void xAccelerometerInterval(float interval)
{
	xInputManager::Instance()->SetAccelerometerInterval(interval);
}

float xGetAccelerometerInterval()
{
	return xInputManager::Instance()->GetAccelerometerInterval();
}
#else
bool xKeyDown(int key)
{
	return xInputManager::Instance()->KeyDown(key);
}

bool xKeyUp(int key)
{
	return xInputManager::Instance()->KeyUp(key);
}

int xKeyHit(int key)
{
	return xInputManager::Instance()->KeyHit(key);
}

bool xMouseDown(int key)
{
	return xInputManager::Instance()->MouseDown(key);
}

bool xMouseUp(int key)
{
	return xInputManager::Instance()->MouseUp(key);
}

int xMouseHit(int key)
{
	return xInputManager::Instance()->MouseHit(key);
}

int xMouseX()
{
	return xInputManager::Instance()->MousePosition().x;
}

int xMouseY()
{
	return xInputManager::Instance()->MousePosition().y;
}

float xMouseXSpeed()
{
	return xInputManager::Instance()->MouseSpeed().x;
}

float xMouseYSpeed()
{
	return xInputManager::Instance()->MouseSpeed().y;
}

float xMouseZSpeed()
{
	return xInputManager::Instance()->MouseSpeed().z;
}

void xFlushKeys()
{
	xInputManager::Instance()->FlushKeyboard();
}

void xFlushMouse()
{
	xInputManager::Instance()->FlushMouse();
}

void xMoveMouse(int x, int y)
{
	xInputManager::Instance()->SetMousePosition(x, y);
}

void xShowCursor()
{
	xInputManager::Instance()->ShowCursor();
}

void xHideCursor()
{
	xInputManager::Instance()->HideCursor();
}
#endif

size_t xLoadMesh(const char * path, size_t parent)
{
	xEntity * newEntity = new xEntity();
	if(!newEntity->LoadMesh(path)) return 0;
	if(parent != 0) newEntity->SetParent((xEntity*)parent);
	return (size_t)newEntity;
}

bool xImagesCollide(size_t image1, int x1, int y1, int frame1, size_t image2, int x2, int y2, int frame2)
{
	return ((xImage*)image1)->Collide(x1, y1, frame1, (xImage*)image2, x2, y2, frame2);
}

bool xImagesOverlap(size_t image1, int x1, int y1, size_t image2, int x2, int y2)
{
	return ((xImage*)image1)->CollideBox(x1, y1, (xImage*)image2, x2, y2);
}

bool xImageRectCollide(size_t image, int x, int y, int frame, int rectx, int recty, int rectWidth, int rectHeight)
{
	return ((xImage*)image)->CollideRect(x, y, frame, rectx, recty, rectWidth, rectHeight);
}

bool xImageRectOverlap(size_t image, int x, int y, int rectx, int recty, int rectWidth, int rectHeight)
{
	return ((xImage*)image)->CollideBoxRect(x, y, rectx, recty, rectWidth, rectHeight);
}

bool xRectsOverlap(int rect1X, int rect1Y, int rect1Width, int rect1Height, int rect2X, int rect2Y, int rect2Width, int rect2Height)
{
	int ax1 = rect1X + rect1Width;
	int ay1 = rect1Y + rect1Height;
	int bx1 = rect2X + rect2Width;
	int by1 = rect2Y + rect2Height;
	if((bx1 < rect1X) || (ax1 < rect2X)) return false;
	if((by1 < rect1Y) || (ay1 < rect2Y)) return false;
	return true;
}

void xMaskImage(size_t image, int red, int green, int blue)
{
	((xImage*)image)->Mask(red, green, blue);
}

size_t xCopyImage(size_t image)
{
	return (size_t)((xImage*)image)->Clone();
}

void xTFormPoint(float x, float y, float z, size_t src, size_t dest)
{
	tformed = xVector(x, y, z);
	if(src  != 0) tformed = ((xEntity*)src)->GetWorldTransform()             * tformed;
	if(dest != 0) tformed = ((xEntity*)dest)->GetWorldTransform().Inversed() * tformed;
}

void xTFormVector(float x, float y, float z, size_t src, size_t dest)
{
	tformed = xVector(x, y, z);
	if(src  != 0) tformed = ((xEntity*)src)->GetWorldTransform()                    * tformed;
	if(dest != 0) tformed = ((xEntity*)dest)->GetWorldTransform().matrix.Inversed() * tformed;
}

void xTFormNormal(float x, float y, float z, size_t src, size_t dest)
{
	tformed = xVector(x, y, z);
	if(src  != 0) tformed = ((xEntity*)src)->GetWorldTransform().matrix.Cofactor()             * tformed;
	if(dest != 0) tformed = ((xEntity*)dest)->GetWorldTransform().matrix.Inversed().Cofactor() * tformed;
	tformed.Normalize();
}

float xTFormedX()
{
	return tformed.x;
}

float xTFormedY()
{
	return tformed.y;
}

float xTFormedZ()
{
	return tformed.z;
}

float xDeltaYaw(size_t src, size_t dest)
{
	float x = ((xEntity*)src)->GetWorldTransform().matrix.k.Yaw();
	float y = (((xEntity*)dest)->GetWorldTransform().position - ((xEntity*)src)->GetWorldTransform().position).Yaw();
	float d = y - x;
	if(d < -180.0f) return d + 360.0f;
	if(d >= 180.0f) return d - 360.0f;
	return d;
}

float xDeltaPitch(size_t src, size_t dest)
{
	float x = ((xEntity*)src)->GetWorldTransform().matrix.k.Pitch();
	float y = (((xEntity*)dest)->GetWorldTransform().position - ((xEntity*)src)->GetWorldTransform().position).Pitch();
	float d = y - x;
	if(d < -180.0f) return d + 360.0f;
	if(d >= 180.0f) return d - 360.0f;
	return d;
}

bool xImagePicked(size_t image, int x, int y, int frame, int px, int py)
{
	return ((xImage*)image)->Picked(x, y, frame, px, py);
}

bool xImageBoxPicked(size_t image, int x, int y, int px, int py)
{
	return ((xImage*)image)->BoxPicked(x, y, px, py);
}

size_t xCreatePivot(size_t parent)
{
	xEntity * newEntity = new xEntity();
	if(parent != 0) newEntity->SetParent((xEntity*)parent);
	return (size_t)newEntity;
}

void xSetAnimTime(size_t entity, float value)
{
	((xEntity*)entity)->SetAnimationTime(value);
}

void xSetAnimSpeed(size_t entity, float value)
{
	((xEntity*)entity)->SetAnimationSpeed(value);
}

int xAnimSeq(size_t entity)
{
	return ((xEntity*)entity)->AnimationSet();
}

float xAnimLength(size_t entity)
{
	return ((xEntity*)entity)->AnimationLength();
}

float xAnimTime(size_t entity)
{
	return ((xEntity*)entity)->AnimationTime();
}

float xAnimSpeed(size_t entity)
{
	return ((xEntity*)entity)->AnimationSpeed();
}

bool xAnimating(size_t entity)
{
	return ((xEntity*)entity)->Animated();
}

int xExtractAnimSeq(size_t entity, int startFrame, int endFrame, int setID)
{
	return ((xEntity*)entity)->ExtractAnimationSet(startFrame, endFrame, setID);
}

int xLoadAnimSeq(size_t entity, const char * path)
{
	return ((xEntity*)entity)->LoadAnimationSet(path);
}

void xEntityPickMode(size_t entity, int mode)
{
	mode = Clamp(mode, 0, 3);
	((xEntity*)entity)->SetPickMode(mode);
}

size_t xLinePick(float x, float y, float z, float dx, float dy, float dz, float radius)
{
	return (size_t)xRender::Instance()->LinePick(xVector(x, y, z), xVector(dx, dy, dz), radius);
}

float xPickedX()
{
	return xRender::Instance()->GetPickPosition().x;
}

float xPickedY()
{
	return xRender::Instance()->GetPickPosition().y;
}

float xPickedZ()
{
	return xRender::Instance()->GetPickPosition().z;
}

float xPickedNX()
{
	return xRender::Instance()->GetPickNormal().x;
}

float xPickedNY()
{
	return xRender::Instance()->GetPickNormal().y;
}

float xPickedNZ()
{
	return xRender::Instance()->GetPickNormal().z;
}

float xPickedTime()
{
	return xRender::Instance()->GetPickTime();
}

size_t xPickedEntity()
{
	return (size_t)xRender::Instance()->GetPickEntity();
}

size_t xPickedSurface()
{
	return (size_t)xRender::Instance()->GetPickSurface();
}

int xPickedTriangle()
{
	return xRender::Instance()->GetPickTriangle();
}

size_t xCameraPick(size_t camera, int x, int y)
{
	return (size_t)((xCamera*)camera)->Pick(x, y);
}

size_t xEntityPick(size_t entity, float radius)
{
	return (size_t)xRender::Instance()->LinePick(((xEntity*)entity)->GetPosition(true), ((xEntity*)entity)->GetQuaternion(true) * xVector(0.0, 0.0, -1.0f), radius);
}

void xCollisions(int srcType, int destType, int method, int response)
{
	xSimulator::Instance()->AddCollision(srcType, destType, method, response);
}

void xClearCollisions()
{
	xSimulator::Instance()->ClearCollisions();
}

void xResetEntity(size_t entity)
{
	((xEntity*)entity)->Reset();
}

void xEntityRadius(size_t entity, float xRadius, float yRadius)
{
	xVector radii(xRadius, yRadius ? yRadius : xRadius, xRadius);
	((xEntity*)entity)->SetCollisionRadii(radii);
}

void xEntityBox(size_t entity, float x, float y, float z, float width, float height, float depth)
{
	xBox box(xVector(x, y, z));
	box.Update(xVector(x + width, y + height, z + depth));
	((xEntity*)entity)->SetCollisionBox(box);
}

void xEntityType(size_t entity, int type, bool recurse)
{
	if(type < 0 || type > 999) return;
	if(recurse)
	{
		for(int i = 0; i < ((xEntity*)entity)->CountChilds(); i++) xEntityType((size_t)((xEntity*)entity)->GetChild(i), type, true);
	}
	((xEntity*)entity)->SetCollisionType(type);
	((xEntity*)entity)->Reset();
}

size_t xEntityCollided(size_t entity, int type)
{
	std::vector<xEntityCollision*>::const_iterator it;
	const std::vector<xEntityCollision*> &c = ((xEntity*)entity)->GetCollisions();
	for(it = c.begin(); it != c.end(); ++it)
	{
		const xEntityCollision * c = *it;
		if(c->with->GetCollisionType() == type) return (size_t)c->with;
	}
	return 0;
}

int xCountCollisions(size_t entity)
{
	return ((xEntity*)entity)->GetCollisions().size();
}

float xCollisionX(size_t entity, int index)
{
	if(index < 0 || index >= ((xEntity*)entity)->GetCollisions().size()) return 0.0f;
	return ((xEntity*)entity)->GetCollisions()[index - 1]->coords.x;
}

float xCollisionY(size_t entity, int index)
{
	if(index < 0 || index >= ((xEntity*)entity)->GetCollisions().size()) return 0.0f;
	return ((xEntity*)entity)->GetCollisions()[index - 1]->coords.y;
}

float xCollisionZ(size_t entity, int index)
{
	if(index < 0 || index >= ((xEntity*)entity)->GetCollisions().size()) return 0.0f;
	return ((xEntity*)entity)->GetCollisions()[index - 1]->coords.z;
}

float xCollisionNX(size_t entity, int index)
{
	if(index < 0 || index >= ((xEntity*)entity)->GetCollisions().size()) return 0.0f;
	return ((xEntity*)entity)->GetCollisions()[index - 1]->collision.normal.x;
}

float xCollisionNY(size_t entity, int index)
{
	if(index < 0 || index >= ((xEntity*)entity)->GetCollisions().size()) return 0.0f;
	return ((xEntity*)entity)->GetCollisions()[index - 1]->collision.normal.y;
}

float xCollisionNZ(size_t entity, int index)
{
	if(index < 0 || index >= ((xEntity*)entity)->GetCollisions().size()) return 0.0f;
	return ((xEntity*)entity)->GetCollisions()[index - 1]->collision.normal.z;
}

float xCollisionTime(size_t entity, int index)
{
	if(index < 0 || index >= ((xEntity*)entity)->GetCollisions().size()) return 0.0f;
	return ((xEntity*)entity)->GetCollisions()[index - 1]->collision.time;
}

size_t xCollisionEntity(size_t entity, int index)
{
	if(index < 0 || index >= ((xEntity*)entity)->GetCollisions().size()) return 0;
	return (size_t)((xEntity*)entity)->GetCollisions()[index - 1]->with;
}

size_t xCollisionSurface(size_t entity, int index)
{
	if(index < 0 || index >= ((xEntity*)entity)->GetCollisions().size()) return 0;
	return (size_t)((xEntity*)entity)->GetCollisions()[index - 1]->collision.surface;
}

int xCollisionTriangle(size_t entity, int index)
{
	if(index < 0 || index >= ((xEntity*)entity)->GetCollisions().size()) return 0;
	return ((xEntity*)entity)->GetCollisions()[index - 1]->collision.index;
}

int xGetEntityType(size_t entity)
{
	return ((xEntity*)entity)->GetCollisionType();
}

size_t xCreateTerrain(int size, size_t parent)
{
	xTerrain * newTerrain = new xTerrain();
	newTerrain->Create(size);
	if(parent != 0) newTerrain->SetParent((xEntity*)parent);
	return (size_t)newTerrain;
}

size_t xLoadTerrain(const char * path, size_t parent)
{
	xTerrain * newTerrain = new xTerrain();
	if(!newTerrain->Load(path)) return 0;
	if(parent != 0) newTerrain->SetParent((xEntity*)parent);
	return (size_t)newTerrain;
}

int xTerrainSize(size_t terrain)
{
	return ((xTerrain*)terrain)->GetSize();
}

void xTerrainShading(size_t terrain, bool state)
{
	((xTerrain*)terrain)->SetShading(state);
}

void xTerrainDetail(size_t terrain, int detail)
{
	((xTerrain*)terrain)->SetTerrainDetail(float(detail) / 16.0f);
}

float xTerrainHeight(size_t terrain, int x, int y)
{
	return ((xTerrain*)terrain)->GetHeight(x, y);
}

void xModifyTerrain(size_t terrain, int x, int y, float height)
{
	((xTerrain*)terrain)->Modify(x, y, height);
}

float xTerrainX(size_t terrain, float x, float y, float z)
{
	return ((xTerrain*)terrain)->GetPoint(xVector(x, y, z)).x;
}

float xTerrainY(size_t terrain, float x, float y, float z)
{
	return ((xTerrain*)terrain)->GetPoint(xVector(x, y, z)).y;
}

float xTerrainZ(size_t terrain, float x, float y, float z)
{
	return ((xTerrain*)terrain)->GetPoint(xVector(x, y, z)).z;
}

bool xIsiPodPlaying()
{
	return xAudioManager::Instance()->iPodPlaying();
}

void xEnableiPodMusic()
{
	xAudioManager::Instance()->EnableiPodMusic();
}

void xDisableiPodMusic()
{
	xAudioManager::Instance()->DisableiPodMusic();
}

void xMediaPlayerNextItem()
{
	xAudioManager::Instance()->MediaPlayerNextItem();
}

void xMediaPlayerPrevItem()
{
	xAudioManager::Instance()->MediaPlayerPrevItem();
}

void xMediaPlayerToItem(uint itemID)
{
	xAudioManager::Instance()->MediaPlayerToItem(itemID);
}

void xMediaPlayerPlay()
{
	xAudioManager::Instance()->MediaPlayerPlay();
}

void xMediaPlayerStop()
{
	xAudioManager::Instance()->MediaPlayerStop();
}

void xMediaPlayerPause()
{
	xAudioManager::Instance()->MediaPlayerPause();
}

int xMediaPlayerState()
{
	return xAudioManager::Instance()->MediaPlayerState();
}

void xMediaPlayerRepeatMode(int mode)
{
	xAudioManager::Instance()->SetMediaPlayerRepeatMode(mode);
}

int xMediaPlayerCurrentRepeatMode()
{
	return xAudioManager::Instance()->GetMediaPlayerRepeatMode();
}

void xMediaPlayerShuffleMode(int mode)
{
	xAudioManager::Instance()->SetMediaPlayerShuffleMode(mode);
}

int xMediaPlayerCurrentShuffleMode()
{
	return xAudioManager::Instance()->GetMediaPlayerShuffleMode();
}

void xMediaPlayerTime(float newTime)
{
	xAudioManager::Instance()->SetMediaPlayerTime(newTime);
}

float xMediaPlayerCurrentTime()
{
	return xAudioManager::Instance()->GetMediaPlayerTime();
}

uint xMediaPlayerItemID()
{
	return xAudioManager::Instance()->MediaPlayerItemID();
}

int xMediaPlayerItemType()
{
	return xAudioManager::Instance()->MediaPlayerItemType();
}

const char * xMediaPlayerItemTitle()
{
	return xAudioManager::Instance()->MediaPlayerItemTitle();
}

const char * xMediaPlayerItemAlbum()
{
	return xAudioManager::Instance()->MediaPlayerItemAlbum();
}

const char * xMediaPlayerItemArtist()
{
	return xAudioManager::Instance()->MediaPlayerItemArtist();
}

const char * xMediaPlayerItemGenre()
{
	return xAudioManager::Instance()->MediaPlayerItemGenre();
}

const char * xMediaPlayerItemComposer()
{
	return xAudioManager::Instance()->MediaPlayerItemComposer();
}

int xMediaPlayerItemAlbumTrackNumber()
{
	return xAudioManager::Instance()->MediaPlayerItemAlbumTrackNumber();
}

int xMediaPlayerItemDiscNumber()
{
	return xAudioManager::Instance()->MediaPlayerItemDiscNumber();
}

int xMediaPlayerItemCoverToImage(int width, int height)
{
	return (size_t)xAudioManager::Instance()->MediaPlayerItemCoverToImage(width, height);
}

int xMediaPlayerItemCoverToTexture(int width, int height)
{
	return (size_t)xAudioManager::Instance()->MediaPlayerItemCoverToTexture(width, height);
}

const char * xMediaPlayerItemLyrics()
{
	return xAudioManager::Instance()->MediaPlayerItemLyrics();
}

size_t xLoadSound(const char * path)
{
	xSound * newSound = new xSound();
	if(!newSound->LoadSound(path)) return 0;
	return (size_t)newSound;
}

void xFreeSound(size_t sound)
{
	((xSound*)sound)->Release();
	delete ((xSound*)sound);
}

void xLoopSound(size_t sound)
{
	((xSound*)sound)->Loop(true);
}

void xSoundPitch(size_t sound, int pitch)
{
	((xSound*)sound)->SetPitch(pitch);
}

void xSoundVolume(size_t sound, float volume)
{
	((xSound*)sound)->SetVolume(volume);
}

void xSoundPan(size_t sound, float panoram)
{
	((xSound*)sound)->SetPanoram(panoram);
}

size_t xPlayMusic(const char * path, bool looped)
{
	return (size_t)xAudioManager::Instance()->PlayMusic(path, looped);
}

size_t xPlaySound(size_t sound)
{
	return (size_t)((xSound*)sound)->Play();
}

void xUpdateAudio()
{
	xChannel::Update();
}

void xStopChannel(size_t channel)
{
	if(channel == MUSIC_CHANNEL)
	{
		xAudioManager::Instance()->StopMusic();
		return;
	}
	((xChannel*)channel)->Stop();
}

void xPauseChannel(size_t channel)
{
	if(channel == MUSIC_CHANNEL)
	{
		xAudioManager::Instance()->PauseMusic();
		return;
	}
	((xChannel*)channel)->Pause();
}

void xResumeChannel(size_t channel)
{
	if(channel == MUSIC_CHANNEL)
	{
		xAudioManager::Instance()->ResumeMusic();
		return;
	}
	((xChannel*)channel)->Resume();
}

void xChannelPitch(size_t channel, int pitch)
{
	if(channel == MUSIC_CHANNEL) return;
	((xChannel*)channel)->SetPitch(pitch);
}

void xChannelVolume(size_t channel, float volume)
{
	if(channel == MUSIC_CHANNEL)
	{
		xAudioManager::Instance()->MusicVolume(volume);
		return;
	}
	((xChannel*)channel)->SetVolume(volume);
}

void xChannelPan(size_t channel, float panoram)
{
	if(channel == MUSIC_CHANNEL) return;
	((xChannel*)channel)->SetPanoram(panoram);
}

bool xChannelPlaying(size_t channel)
{
	if(channel == MUSIC_CHANNEL) return xAudioManager::Instance()->MusicPlaying();
	return ((xChannel*)channel)->Playing();
}

size_t xCreateListener(size_t parent, float rolloffFactor, float dopplerFactor, float distanceFactor)
{
	xAudioManager::Instance()->GetListener()->SetPosition(0.0f, 0.0f, 0.0, false);
	xAudioManager::Instance()->GetListener()->SetParent((xEntity*)parent);
	xAudioManager::Instance()->SetRolloffFactor(rolloffFactor);
	xAudioManager::Instance()->SetDopplerFactor(dopplerFactor);
	xAudioManager::Instance()->SetSpeedFactor(distanceFactor);
	return (size_t)xAudioManager::Instance()->GetListener();
}

size_t xLoad3DSound(const char * path)
{
	xSound * newSound = new xSound();
	if(!newSound->Load3DSound(path)) return 0;
	return (size_t)newSound;
}

size_t xEmitSound(size_t sound, size_t entity)
{
	return (size_t)((xSound*)sound)->Emit((xEntity*)entity);
}

void xImageColor(size_t image, int red, int green, int blue)
{
	red   = Clamp(red,   0, 255);
	green = Clamp(green, 0, 255);
	blue  = Clamp(blue,  0, 255);
	((xImage*)image)->SetColor(red, green, blue);
}

void xImageAlpha(size_t image, float alpha)
{
	alpha = Clamp(alpha, 0.0f, 1.0f);
	((xImage*)image)->SetAlpha(alpha);
}

void xImageBlend(size_t image, int mode)
{
	mode = Clamp(mode, 1, 5);
	((xImage*)image)->SetBlend(mode);
}

void xSetGlobalColor(int red, int green, int blue)
{
	red   = Clamp(red,   0, 255);
	green = Clamp(green, 0, 255);
	blue  = Clamp(blue,  0, 255);
	xRender::Instance()->SetGlobalColor(red, green, blue);
}

void xSetGlobalAlpha(float alpha)
{
	alpha = Clamp(alpha, 0.0f, 1.0f);
	xRender::Instance()->SetGlobalAlpha(alpha);
}

void xSetGlobalBlend(int mode)
{
	mode = Clamp(mode, 0, 5);
	xRender::Instance()->SetGlobalBlend(mode);
}

void xSetGlobalRotate(float angle)
{
	xRender::Instance()->SetGlobalRotate(angle);
}

void xSetGlobalHandle(int x, int y)
{
	xRender::Instance()->SetGlobalHandle(x, y);
}

void xSetGlobalScale(float x, float y)
{
	xRender::Instance()->SetGlobalScale(x, y);
}

size_t xCreateSprite(size_t parent)
{
	xSprite * newSprite = new xSprite();
	if(parent != 0) newSprite->SetParent((xEntity*)parent);
	return (size_t)newSprite;
}

size_t xLoadSprite(const char * path, int flags, size_t parent)
{
	xSprite * newSprite = new xSprite();
	if(parent != 0) newSprite->SetParent((xEntity*)parent);
	int texture = xLoadTexture(path, flags);
	newSprite->SetTexture(0, (xTexture*)texture, 0);
	xFreeTexture(texture);
	return (size_t)newSprite;
}

void xRotateSprite(size_t sprite, float angle)
{
	((xSprite*)sprite)->SetRotation(angle);
}

void xScaleSprite(size_t sprite, float x, float y)
{
	((xSprite*)sprite)->SetScale(x, y);
}

void xHandleSprite(size_t sprite, float x, float y)
{
	((xSprite*)sprite)->SetOffset(x, y);
}

void xSpriteViewMode(size_t sprite, int mode)
{
	mode = Clamp(mode, 1, 4);
	((xSprite*)sprite)->SetViewMode(mode);
}

size_t xReadDir(const char * path)
{
	return xFileSystem::Instance()->ReadDirectory(path);
}

void xCloseDir(size_t directory)
{
	xFileSystem::Instance()->CloseDirectory(directory);
}

const char * xNextFile(size_t directory)
{
	return xFileSystem::Instance()->NextFile(directory);
}

const char * xCurrentDir(bool appDirectory)
{
	return xFileSystem::Instance()->GetCurrentDirectory(appDirectory);
}

void xChangeDir(const char * path)
{
	xFileSystem::Instance()->SetDirectory(path);
}

bool xCreateDir(const char * path)
{
	return xFileSystem::Instance()->CreateDirectory(path);
}

bool xDeleteDir(const char * path)
{
	return xFileSystem::Instance()->DeleteDirectory(path);
}

size_t xOpenFile(const char * path)
{
	return xFileSystem::Instance()->OpenFile(path);
}

size_t xReadFile(const char * path)
{
	return xFileSystem::Instance()->ReadFile(path);
}

size_t xWriteFile(const char * path)
{
	return xFileSystem::Instance()->WriteFile(path);
}

void xCloseFile(size_t fileHandle)
{
	xFileSystem::Instance()->CloseFile(fileHandle);
}

unsigned int xFilePos(size_t fileHandle)
{
	return xFileSystem::Instance()->GetFilePosition(fileHandle);
}

void xSeekFile(size_t fileHandle, unsigned int offset)
{
	xFileSystem::Instance()->SeekFile(fileHandle, offset);
}

int xFileType(const char * path)
{
	return xFileSystem::Instance()->GetFileType(path);
}

unsigned int xFileSize(const char * path)
{
	return xFileSystem::Instance()->GetFileSize(path);
}

bool xCopyFile(const char * pathFrom, const char * pathTo)
{
	return xFileSystem::Instance()->CopyFile(pathFrom, pathTo);
}

bool xDeleteFile(const char * path)
{
	return xFileSystem::Instance()->DeleteFile(path);
}

bool xEof(size_t fileHandle)
{
	return xFileSystem::Instance()->IsEndOfFile(fileHandle);
}

unsigned char xReadByte(size_t fileHandle)
{
	return xFileSystem::Instance()->ReadByte(fileHandle);
}

short xReadShort(size_t fileHandle)
{
	return xFileSystem::Instance()->ReadShort(fileHandle);
}

int xReadInt(size_t fileHandle)
{
	return xFileSystem::Instance()->ReadInt(fileHandle);
}

float xReadFloat(size_t fileHandle)
{
	return xFileSystem::Instance()->ReadFloat(fileHandle);
}

const char * xReadString(size_t fileHandle)
{
	return xFileSystem::Instance()->ReadString(fileHandle);
}

const char * xReadLine(size_t fileHandle)
{
	return xFileSystem::Instance()->ReadLine(fileHandle);
}

void * xReadBytes(size_t fileHandle, unsigned int size)
{
	return xFileSystem::Instance()->ReadBytes(fileHandle, size);
}

void xWriteByte(size_t fileHandle, unsigned char value)
{
	xFileSystem::Instance()->WriteByte(fileHandle, value);
}

void xWriteShort(size_t fileHandle, short value)
{
	xFileSystem::Instance()->WriteShort(fileHandle, value);
}

void xWriteInt(size_t fileHandle, int value)
{
	xFileSystem::Instance()->WriteInt(fileHandle, value);
}

void xWriteFloat(size_t fileHandle, float value)
{
	xFileSystem::Instance()->WriteFloat(fileHandle, value);
}

void xWriteString(size_t fileHandle, const char * value)
{
	xFileSystem::Instance()->WriteString(fileHandle, value);
}

void xWriteLine(size_t fileHandle, const char * value)
{
	xFileSystem::Instance()->WriteLine(fileHandle, value);
}

void xWriteBytes(size_t fileHandle, void * value, int size)
{
	xFileSystem::Instance()->WriteBytes(fileHandle, value, size);
}

#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
int xOpenMovie(const char * path)
{
	xMovie * movie = new xMovie();
	if(!movie->OpenFile(path))
	{
		delete movie;
		return 0;
	}
	return (int)movie;
}

void xPlayMovie(int movie)
{
	if(movie == 0) return;
	((xMovie*)movie)->Play();
}

void xStopMovie(int movie)
{
	if(movie == 0) return;
	((xMovie*)movie)->Stop();
}

void xCloseMovie(int movie)
{
	if(movie == 0) return;
	((xMovie*)movie)->Release();
}

bool xMoviePlaying(int movie)
{
	if(movie == 0) return false;
	return ((xMovie*)movie)->Playing();
}
#endif

size_t xCreateHTTPRequest(const char * url, int timeout, bool cacheble)
{
	xHTTPRequest * newRequest = new xHTTPRequest();
	newRequest->Create(url, timeout, cacheble);
	return (size_t)newRequest;
}

void xSetRequestTimeoutInterval(size_t request, int timeout)
{
	((xHTTPRequest*)request)->SetTimeoutInterval(timeout);
}

int xGetRequestTimeoutInterval(size_t request)
{
	return ((xHTTPRequest*)request)->GetTimeoutInterval();
}

void xEnableRequestCaching(size_t request)
{
	((xHTTPRequest*)request)->EnableCaching();
}

void xDisableRequestCaching(size_t request)
{
	((xHTTPRequest*)request)->DisableCaching();
}

bool xIsRequestCachable(size_t request)
{
	return ((xHTTPRequest*)request)->IsCachable();
}

const char * GetRequestURL(size_t request)
{
	return ((xHTTPRequest*)request)->GetURL();
}

void xSetRequestMethod(size_t request, int method)
{
	((xHTTPRequest*)request)->SetMethod((xRequestMethod)method);
}

int xGetRequestMethod(size_t request)
{
	return ((xHTTPRequest*)request)->GetMethod();
}

void xEnableRequestCookies(size_t request)
{
	((xHTTPRequest*)request)->EnableCookies();
}

void xDisableRequestCookies(size_t request)
{
	((xHTTPRequest*)request)->DisableCookies();
}

bool xIsRequestHandleCookies(size_t request)
{
	return ((xHTTPRequest*)request)->IsHandleCookies();
}

void xSetRequestAuthenticationData(size_t request, const char * userName, const char * password)
{
	((xHTTPRequest*)request)->SetAuthenticationData(userName, password);
}

void xSetRequestReferer(size_t request, const char * referer)
{
	((xHTTPRequest*)request)->SetReferer(referer);
}

void xSetRequestUserAgent(size_t request, const char * userAgent)
{
	((xHTTPRequest*)request)->SetUserAgent(userAgent);
}

size_t xSendHTTPRequest(size_t request, bool async)
{
	return (size_t)xNetworkManager::Instance()->SendHTTPRequest((xHTTPRequest*)request, async);
}

int xGetResponseState(size_t response)
{
	return ((xHTTPResponse*)response)->state;
}

void * xGetResponseData(size_t response)
{
	return ((xHTTPResponse*)response)->data;
}

uint xGetResponseDataLength(size_t response)
{
	return ((xHTTPResponse*)response)->lenght;
}

const char * xGetResponseMIMEType(size_t response)
{
	return ((xHTTPResponse*)response)->mimeType.c_str();
}

int xGetResponseErrorCode(size_t response)
{
	return ((xHTTPResponse*)response)->errorCode;
}

const char * xGetResponseErrorText(size_t response)
{
	return ((xHTTPResponse*)response)->errorText.c_str();
}

void xDeleteResponse(size_t response)
{
	xNetworkManager::Instance()->DeleteResponse((xHTTPResponse*)response);
}

void xAddRequestCookie(size_t request, const char * name, const char * value)
{
	((xHTTPRequest*)request)->AddCookie(name, value);
}

void xDeleteRequestCookie(size_t request, const char * name)
{
	((xHTTPRequest*)request)->DeleteCookie(name);
}

void xClearRequestCookies(size_t request)
{
	((xHTTPRequest*)request)->ClearCookies();
}

void xAddRequestFormField(size_t request, const char * name, const char * value)
{
	((xHTTPRequest*)request)->AddFromField(name, value);
}

void xDeleteRequestFormField(size_t request, const char * name)
{
	((xHTTPRequest*)request)->DeleteFormField(name);
}

void xClearRequestFormFields(size_t request)
{
	((xHTTPRequest*)request)->ClearFormFields();
}

// physics commands
void xEntityAddDummyShape(size_t entity)
{
	((xEntity*)entity)->AddDummyShape();
}

void xEntityAddBoxShape(size_t entity, float mass, float width, float height, float depth)
{
	((xEntity*)entity)->AddBoxShape(mass, width, height, depth);
}

void xEntityAddSphereShape(size_t entity, float mass, float radius)
{
	((xEntity*)entity)->AddSphereShape(mass, radius);
}

void xEntityAddCapsuleShape(size_t entity, float mass, float radius, float height)
{
	((xEntity*)entity)->AddCapsuleShape(mass, radius, height);
}

void xEntityAddConeShape(size_t entity, float mass, float radius, float height)
{
	((xEntity*)entity)->AddConeShape(mass, radius, height);
}

void xEntityAddCylinderShape(size_t entity, float mass, float width, float height, float depth)
{
	((xEntity*)entity)->AddCylinderShape(mass, width, height, depth);
}

void xEntityAddTriMeshShape(size_t entity, float mass)
{
	((xEntity*)entity)->AddTriMeshShape(mass);
}

void xEntityAddHullShape(size_t entity, float mass)
{
	((xEntity*)entity)->AddHullShape(mass);
}

void xWorldGravity(float x, float y, float z)
{
	IWorld * phyWorld = xRender::Instance()->GetPhysWorld();
	if(phyWorld != NULL) phyWorld->SetGravity(x, y, z);
}

void xEntityApplyCentralForce(size_t entity, float x, float y, float z)
{
	((xEntity*)entity)->ApplyCentralForce(x, y, z);
}

void xEntityApplyCentralImpulse(size_t entity, float x, float y, float z)
{
	((xEntity*)entity)->ApplyCentralImpulse(x, y, z);
}

void xEntityReleaseForces(size_t entity)
{
	((xEntity*)entity)->ReleaseForces();
}

void xEntityApplyTorque(size_t entity, float x, float y, float z)
{
	((xEntity*)entity)->ApplyTorque(x, y, z);
}

void xEntityApplyTorqueImpulse(size_t entity, float x, float y, float z)
{
	((xEntity*)entity)->ApplyTorqueImpulse(x, y, z);
}

void xEntityApplyForce(size_t entity, float x, float y, float z, float pointx, float pointy, float pointz)
{
	((xEntity*)entity)->ApplyForce(x, y, z, pointx, pointy, pointz);
}

void xEntityApplyImpulse(size_t entity, float x, float y, float z, float pointx, float pointy, float pointz)
{
	((xEntity*)entity)->ApplyImpulse(x, y, z, pointx, pointy, pointz);
}

void xEntityDamping(size_t entity, float linear, float angular)
{
	((xEntity*)entity)->SetDamping(linear, angular);
}

float xGetEntityLinearDamping(size_t entity)
{
	return ((xEntity*)entity)->GetLinearDamping();
}

float xGetEntityAngularDamping(size_t entity)
{
	return ((xEntity*)entity)->GetAngularDamping();
}

void xEntityFriction(size_t entity, float friction)
{
	((xEntity*)entity)->SetFriction(friction);
}

float xGetEntityFriction(size_t entity)
{
	return ((xEntity*)entity)->GetFriction();
}

void xEntityRestitution(size_t entity, float restitution)
{
	((xEntity*)entity)->SetRestitution(restitution);
}

float xGetEntityRestitution(size_t entity)
{
	return ((xEntity*)entity)->GetRestitution();
}

float xEntityForceX(size_t entity)
{
	return ((xEntity*)entity)->GetForce().x;
}

float xEntityForceY(size_t entity)
{
	return ((xEntity*)entity)->GetForce().y;
}

float xEntityForceZ(size_t entity)
{
	return ((xEntity*)entity)->GetForce().z;
}

float xEntityTorqueX(size_t entity)
{
	return ((xEntity*)entity)->GetTorque().x;
}

float xEntityTorqueY(size_t entity)
{
	return ((xEntity*)entity)->GetTorque().y;
}

float xEntityTorqueZ(size_t entity)
{
	return ((xEntity*)entity)->GetTorque().z;
}

void xFreeEntityShapes(size_t entity)
{
	((xEntity*)entity)->FreeShapes();
}

int xCountContacts(size_t entity)
{
	return ((xEntity*)entity)->GetContactsNumber();
}

float xEntityContactX(size_t entity, int index)
{
	return ((xEntity*)entity)->GetContactPoint(index).x;
}

float xEntityContactY(size_t entity, int index)
{
	return ((xEntity*)entity)->GetContactPoint(index).y;
}

float xEntityContactZ(size_t entity, int index)
{
	return ((xEntity*)entity)->GetContactPoint(index).z;
}

float xEntityContactNX(size_t entity, int index)
{
	return ((xEntity*)entity)->GetContactNormal(index).x;
}

float xEntityContactNY(size_t entity, int index)
{
	return ((xEntity*)entity)->GetContactNormal(index).y;
}

float xEntityContactNZ(size_t entity, int index)
{
	return ((xEntity*)entity)->GetContactNormal(index).z;
}

float xEntityContactDistance(size_t entity, int index)
{
	return ((xEntity*)entity)->GetContactDistance(index);
}

size_t xCreateJoint(int type, size_t firstBody, size_t secondBody)
{
	IWorld * world = xRender::Instance()->GetPhysWorld();
	if(world == NULL) return 0;
	if(type < 0) type = 0;
	if(type > 3) type = 3;
	((xEntity*)firstBody)->SyncBodyTransform();
	((xEntity*)secondBody)->SyncBodyTransform();
	return (size_t)world->CreateJoint((pxJointType)type, ((xEntity*)firstBody)->GetPhysBody(), ((xEntity*)secondBody)->GetPhysBody());
}

void xFreeJoint(size_t joint)
{
	if(joint == 0) return;
	IWorld * world = xRender::Instance()->GetPhysWorld();
	if(world == NULL) return;
	world->DeleteJoint((IJoint*)joint);
}

void xJointPivotA(size_t joint, float x, float y, float z)
{
	if(joint == 0) return;
	((IJoint*)joint)->SetPivotA(x, y, z);
}

void xJointPivotB(size_t joint, float x, float y, float z)
{
	if(joint == 0) return;
	((IJoint*)joint)->SetPivotB(x, y, z);
}

float xJointPivotAX(size_t joint)
{
	if(joint == 0) return 0.0f;
	return ((IJoint*)joint)->GetPivotAX();
}

float xJointPivotAY(size_t joint)
{
	if(joint == 0) return 0.0f;
	return ((IJoint*)joint)->GetPivotAY();
}

float xJointPivotAZ(size_t joint)
{
	if(joint == 0) return 0.0f;
	return ((IJoint*)joint)->GetPivotAZ();
}

float xJointPivotBX(size_t joint)
{
	if(joint == 0) return 0.0f;
	return ((IJoint*)joint)->GetPivotBX();
}

float xJointPivotBY(size_t joint)
{
	if(joint == 0) return 0.0f;
	return ((IJoint*)joint)->GetPivotBY();
}

float xJointPivotBZ(size_t joint)
{
	if(joint == 0) return 0.0f;
	return ((IJoint*)joint)->GetPivotBZ();
}

void xJointLinearLimits(size_t joint, float lowerX, float lowerY, float lowerZ, float upperX, float upperY, float upperZ)
{
	if(joint == 0) return;
	((IJoint*)joint)->SetLinearLimits(lowerX, lowerY, lowerZ, upperX, upperY, upperZ);
}

void xJointAngularLimits(size_t joint, float lowerX, float lowerY, float lowerZ, float upperX, float upperY, float upperZ)
{
	if(joint == 0) return;
	const float deg2rad = 180.0f / 3.141592f;
	((IJoint*)joint)->SetAngularLimits(lowerX / deg2rad, lowerY / deg2rad, lowerZ / deg2rad,
									   upperX / deg2rad, upperY / deg2rad, upperZ / deg2rad);
}

void xJointSpringParam(size_t joint, int index, bool enabled, float damping, float stiffness)
{
	if(joint == 0) return;
	if(index < 0 || index > 5) return;
	((IJoint*)joint)->SetSpringData(index, enabled, damping, stiffness);
}

void xJointHingeAxis(size_t joint, float x, float y, float z)
{
	if(joint == 0) return;
	((IJoint*)joint)->SetHingeAxis(x, y, z);
}

void xJointHingeLimit(size_t joint, float lower, float upper, float softness, float biasFactor, float relaxationFactor)
{
	if(joint == 0) return;
	const float deg2rad = 180.0f / 3.141592f;
	if(lower < -180.0f) lower = -180.0f;
	if(upper < -180.0f) upper = -180.0f;
	if(lower >  180.0f) lower =  180.0f;
	if(upper >  180.0f) upper =  180.0f;
	((IJoint*)joint)->SetHingeLimit(lower / deg2rad, upper / deg2rad, softness, biasFactor, relaxationFactor);
}

float xJointLinearLowerX(size_t joint)
{
	if(joint == 0) return 0.0f;
	return ((IJoint*)joint)->GetLinearLowerX();
}

float xJointLinearLowerY(size_t joint)
{
	if(joint == 0) return 0.0f;
	return ((IJoint*)joint)->GetLinearLowerY();
}

float xJointLinearLowerZ(size_t joint)
{
	if(joint == 0) return 0.0f;
	return ((IJoint*)joint)->GetLinearLowerZ();
}

float xJointLinearUpperX(size_t joint)
{
	if(joint == 0) return 0.0f;
	return ((IJoint*)joint)->GetLinearUpperX();
}

float xJointLinearUpperY(size_t joint)
{
	if(joint == 0) return 0.0f;
	return ((IJoint*)joint)->GetLinearUpperY();
}

float xJointLinearUpperZ(size_t joint)
{
	if(joint == 0) return 0.0f;
	return ((IJoint*)joint)->GetLinearUpperZ();
}

float xJointAngularLowerX(size_t joint)
{
	if(joint == 0) return 0.0f;
	return ((IJoint*)joint)->GetAngularLowerX();
}

float xJointAngularLowerY(size_t joint)
{
	if(joint == 0) return 0.0f;
	return ((IJoint*)joint)->GetAngularLowerY();
}

float xJointAngularLowerZ(size_t joint)
{
	if(joint == 0) return 0.0f;
	return ((IJoint*)joint)->GetAngularLowerZ();
}

float xJointAngularUpperX(size_t joint)
{
	if(joint == 0) return 0.0f;
	return ((IJoint*)joint)->GetAngularUpperX();
}

float xJointAngularUpperY(size_t joint)
{
	if(joint == 0) return 0.0f;
	return ((IJoint*)joint)->GetAngularUpperY();
}

float xJointAngularUpperZ(size_t joint)
{
	if(joint == 0) return 0.0f;
	return ((IJoint*)joint)->GetAngularUpperZ();
}

float xJointHingeLowerLimit(size_t joint)
{
	if(joint == 0) return 0.0f;
	return ((IJoint*)joint)->GetHingeLowerLimit();
}

float xJointHingeUpperLimit(size_t joint)
{
	if(joint == 0) return 0.0f;
	return ((IJoint*)joint)->GetHingeUpperLimit();
}

void xJointEnableMotor(size_t joint, int dof, bool enabled, float targetVelocity, float maxForce)
{
	if(joint == 0) return;
	if(dof < 0) dof = 0;
	if(dof > 5) dof = 5;
	((IJoint*)joint)->EnableMotor(dof, enabled, targetVelocity, maxForce);
}

void xJointHingeMotorTarget(size_t joint, float angle, float delta)
{
	if(joint == 0) return;
	const float deg2rad = 180.0f / 3.141592f;
	((IJoint*)joint)->SetHingeMotorTarget(angle / deg2rad, delta);
}

size_t xCreateSingleSurface()
{
	xEntity * newEntity = new xEntity();
	newEntity->MakeSingleSurface();
	return (size_t)newEntity;
}

void xSetSingleSurfaceFlags(size_t singleSurface, int flags)
{
	((xEntity*)singleSurface)->SetAtlasFlags(flags);
}

void xAddSingleSurfaceInstance(size_t singleSurface, size_t entity)
{
	((xEntity*)singleSurface)->AddInstance((xEntity*)entity);
}

void xRemoveSingleSurfaceInstance(size_t singleSurface, size_t entity)
{
	((xEntity*)singleSurface)->RemoveInstance((xEntity*)entity);
}

void xEnableAtlasesDebug(bool flag)
{
	xTextureAtlas::EnableDebug(flag);
}

size_t xCreateDummy2DShape()
{
	IWorld2D * world = xRender::Instance()->GetPhysWorld2D();
	if(world == NULL) return 0;
	return (size_t)world->CreateDummyBody();
}

size_t xCreateBox2DShape(float width, float height, float mass)
{
	IWorld2D * world = xRender::Instance()->GetPhysWorld2D();
	if(world == NULL) return 0;
	return (size_t)world->CreateBoxBody(width, height, mass);
}

size_t xCreateCircle2DShape(float radii, float mass)
{
	IWorld2D * world = xRender::Instance()->GetPhysWorld2D();
	if(world == NULL) return 0;
	return (size_t)world->CreateCircleBody(radii, mass);
}

size_t xCreatePolygon2DShape(float * points, int count, float mass)
{
	IWorld2D * world = xRender::Instance()->GetPhysWorld2D();
	if(world == NULL) return 0;
	return (size_t)world->CreatePolygonBody(points, count, mass);
}

void xSet2DShapeMass(size_t shape, float mass)
{
	if(shape == 0) return;
	((IBody2D*)shape)->SetMass(mass);
}

float xGet2DShapeMass(size_t shape)
{
	if(shape == 0) return 0.0f;
	return ((IBody2D*)shape)->GetMass();
}

void xPosition2DShape(size_t shape, float x, float y)
{
	if(shape == 0) return;
	((IBody2D*)shape)->SetPosition(x, y);
}

void xRotate2DShape(size_t shape, float angle)
{
	if(shape == 0) return;
	((IBody2D*)shape)->SetRotation(angle);
}

float x2DShapePositionX(size_t shape)
{
	if(shape == 0) return 0.0f;
	return ((IBody2D*)shape)->GetPositionX();
}

float x2DShapePositionY(size_t shape)
{
	if(shape == 0) return 0.0f;
	return ((IBody2D*)shape)->GetPositionY();
}

float x2DShapeRotation(size_t shape)
{
	if(shape == 0) return 0.0f;
	return ((IBody2D*)shape)->GetRotation();
}

void x2DWorldGravity(float x, float y)
{
	IWorld2D * world = xRender::Instance()->GetPhysWorld2D();
	if(world == NULL) return;
	world->SetGravity(x, y);
}

void x2DWorldIterations(int velocity, int position)
{
	IWorld2D * world = xRender::Instance()->GetPhysWorld2D();
	if(world == NULL) return;
	world->SetIterations(velocity, position);
}

void xDelete2DShape(size_t shape)
{
	IWorld2D * world = xRender::Instance()->GetPhysWorld2D();
	if(world == NULL) return;
	if(shape == 0) return;
	world->DeleteBody((IBody2D*)shape);
	x2DWorld::Instance()->DeleteBody((IBody2D*)shape);
}

void xLock2DShapeRotation(size_t shape, bool flag)
{
	if(shape == 0) return;
	((IBody2D*)shape)->LockRotation(flag);
}

bool x2DShapeRotationLocked(size_t shape)
{
	if(shape == 0) return false;
	return ((IBody2D*)shape)->RotationLocked();
}

void xSet2DShapeBullet(size_t shape, bool flag)
{
	if(shape == 0) return;
	((IBody2D*)shape)->SetBullet(flag);
}

bool xIs2DShapeBullet(size_t shape)
{
	if(shape == 0) return false;
	return ((IBody2D*)shape)->IsBullet();
}

void xSet2DShapeSensor(size_t shape, bool flag)
{
	if(shape == 0) return;
	((IBody2D*)shape)->SetSensor(flag);
}

bool xIs2DShapeSensor(size_t shape)
{
	if(shape == 0) return false;
	return ((IBody2D*)shape)->IsSensor();
}

void xSet2DShapeActive(size_t shape, bool flag)
{
	if(shape == 0) return;
	((IBody2D*)shape)->Activate(flag);
}

bool xIs2DShapeActive(size_t shape)
{
	if(shape == 0) return false;
	return ((IBody2D*)shape)->IsActive();
}

void xAllow2DShapeSleeping(size_t shape, bool flag)
{
	if(shape == 0) return;
	((IBody2D*)shape)->AllowSleep(flag);
}

bool xIs2DShapeSleepingAllowed(size_t shape)
{
	if(shape == 0) return false;
	return ((IBody2D*)shape)->IsAllowedSleep();
}

void x2DShapeApplyCentralForce(size_t shape, float x, float y)
{
	if(shape == 0) return;
	((IBody2D*)shape)->ApplyCentralForce(x, y);
}

void x2DShapeApplyCentralImpulse(size_t shape, float x, float y)
{
	if(shape == 0) return;
	((IBody2D*)shape)->ApplyCentralImpulse(x, y);
}

void x2DShapeApplyTorque(size_t shape, float omega)
{
	if(shape == 0) return;
	((IBody2D*)shape)->ApplyTorque(omega);
}

void x2DShapeApplyTorqueImpulse(size_t shape, float omega)
{
	if(shape == 0) return;
	((IBody2D*)shape)->ApplyTorqueImpulse(omega);
}

void x2DShapeApplyForce(size_t shape, float x, float y, float pointx, float pointy)
{
	if(shape == 0) return;
	((IBody2D*)shape)->ApplyForce(x, y, pointx, pointy);
}

void x2DShapeApplyImpulse(size_t shape, float x, float y, float pointx, float pointy)
{
	if(shape == 0) return;
	((IBody2D*)shape)->ApplyImpulse(x, y, pointx, pointy);
}

void x2DShapeReleaseForces(size_t shape)
{
	if(shape == 0) return;
	((IBody2D*)shape)->ReleaseForces();
}

void x2DShapeDamping(size_t shape, float linear, float angular)
{
	if(shape == 0) return;
	((IBody2D*)shape)->SetDamping(linear, angular);
}

float xGet2DShapeLinearDamping(size_t shape)
{
	if(shape == 0) return 0.0f;
	return ((IBody2D*)shape)->GetLinearDamping();
}

float xGet2DShapeAngularDamping(size_t shape)
{
	if(shape == 0) return 0.0f;
	return ((IBody2D*)shape)->GetAngularDamping();
}

void x2DShapeFriction(size_t shape, float friction)
{
	if(shape == 0) return;
	((IBody2D*)shape)->SetFriction(friction);
}

float xGet2DShapeFriction(size_t shape)
{
	if(shape == 0) return 0.0f;
	return ((IBody2D*)shape)->GetFriction();
}

void x2DShapeDensity(size_t shape, float density)
{
	if(shape == 0) return;
	((IBody2D*)shape)->SetDensity(density);
}

float xGet2DShapeDensity(size_t shape)
{
	if(shape == 0) return 0.0f;
	return ((IBody2D*)shape)->GetDensity();
}

void x2DShapeRestitution(size_t shape, float restitution)
{
	if(shape == 0) return;
	((IBody2D*)shape)->SetRestitution(restitution);
}

float xGet2DShapeRestitution(size_t shape)
{
	if(shape == 0) return 0.0f;
	return ((IBody2D*)shape)->GetRestitution();
}

int xCount2DShapeTouches(size_t shape)
{
	if(shape == 0) return 0;
	return ((IBody2D*)shape)->CountTouches();
}

size_t xGet2DShapeTouchingShape(size_t shape, int index)
{
	if(shape == 0) return 0;
	return (size_t)((IBody2D*)shape)->GetTouchingShape(index);
}

int xCount2DShapeCountacts(size_t shape)
{
	if(shape == 0) return 0;
	return ((IBody2D*)shape)->CountContacts();
}

float x2DShapeContactX(size_t shape, int index)
{
	if(shape == 0) return 0;
	return ((IBody2D*)shape)->GetContactX(index);
}

float x2DShapeContactY(size_t shape, int index)
{
	if(shape == 0) return 0;
	return ((IBody2D*)shape)->GetContactY(index);
}

float x2DShapeContactNX(size_t shape, int index)
{
	if(shape == 0) return 0;
	return ((IBody2D*)shape)->GetContactNX(index);
}

float x2DShapeContactNY(size_t shape, int index)
{
	if(shape == 0) return 0;
	return ((IBody2D*)shape)->GetContactNY(index);
}

size_t x2DShapeContactSecondShape(size_t shape, int index)
{
	if(shape == 0) return 0;
	return (size_t)((IBody2D*)shape)->GetContactSecondBody(index);
}

void xUpdate2DWorld(float speed)
{
	if(xRender::Instance()->GetPhysWorld2D() != NULL)
	{
		xRender::Instance()->GetPhysWorld2D()->Update(speed);
	}
}

void xRender2DWorld()
{
	x2DWorld::Instance()->Render();
}

void xPosition2DCamera(int x, int y)
{
	x2DWorld::Instance()->SetCameraPosition(x, y);
}

int x2DCameraX()
{
	return x2DWorld::Instance()->GetCameraX();
}

int x2DCameraY()
{
	return x2DWorld::Instance()->GetCameraY();
}

void xClear2DWorld()
{
	x2DWorld::Instance()->Clear();
	if(xRender::Instance()->GetPhysWorld2D() != NULL)
	{
		xRender::Instance()->GetPhysWorld2D()->Clear();
	}
}

void x2DShapeAssignImage(size_t shape, size_t image, int frame)
{
	if(shape == 0) return;
	x2DWorld::Instance()->AssignImage((IBody2D*)shape, (xImage*)image, frame);
}

void x2DShapeImageFrame(size_t shape, int frame)
{
	if(shape == 0) return;
	x2DWorld::Instance()->SetImageFrame((IBody2D*)shape, frame);
}

void x2DShapeImageOrder(size_t shape, int order)
{
	if(shape == 0) return;
	x2DWorld::Instance()->SetImageOrder((IBody2D*)shape, order);
}

void xFree2DJoint(size_t joint)
{
	IWorld2D * world = xRender::Instance()->GetPhysWorld2D();
	if(world == NULL) return;
	if(joint == 0) return;
	world->DeleteJoint((IJoint2D*)joint);
}

size_t xCreateDistance2DJoint(size_t bodyA, size_t bodyB, bool collide)
{
	IWorld2D * world = xRender::Instance()->GetPhysWorld2D();
	if(world == NULL) return 0;
	return (size_t)world->CreateDistanceJoint((IBody2D*)bodyA, (IBody2D*)bodyB, collide);
}

size_t xCreateDistance2DJointWithPivots(size_t bodyA, size_t bodyB, float pivotAX, float pivotAY, float pivotBX, float pivotBY, bool collide)
{
	IWorld2D * world = xRender::Instance()->GetPhysWorld2D();
	if(world == NULL) return 0;
	return (size_t)world->CreateDistanceJoint((IBody2D*)bodyA, (IBody2D*)bodyB, 
										   pivotAX, pivotAY, pivotBX, pivotBY, collide);
}

float x2DJointPivotAX(size_t joint)
{
	if(joint == 0) return 0.0f;
	return ((IJoint2D*)joint)->GetPivotAX();
}

float x2DJointPivotAY(size_t joint)
{
	if(joint == 0) return 0.0f;
	return ((IJoint2D*)joint)->GetPivotAY();
}

float x2DJointPivotBX(size_t joint)
{
	if(joint == 0) return 0.0f;
	return ((IJoint2D*)joint)->GetPivotBX();
}

float x2DJointPivotBY(size_t joint)
{
	if(joint == 0) return 0.0f;
	return ((IJoint2D*)joint)->GetPivotBY();
}

void xSet2DJointDistance(size_t joint, float distance)
{
	if(joint == 0) return;
	((IJoint2D*)joint)->SetLength(distance);
}

void xSet2DJointFrequency(size_t joint, float frequency)
{
	if(joint == 0) return;
	((IJoint2D*)joint)->SetFrequency(frequency);
}

void xSet2DJointDampingRatio(size_t joint, float ratio)
{
	if(joint == 0) return;
	((IJoint2D*)joint)->SetDampingRatio(ratio);
}

float xGet2DJointDistance(size_t joint)
{
	if(joint == 0) return 0.0f;
	return ((IJoint2D*)joint)->GetLength();
}

float xGet2DJointFrequency(size_t joint)
{
	if(joint == 0) return 0.0f;
	return ((IJoint2D*)joint)->GetFrequency();
}

float xGet2DJointDampingRatio(size_t joint)
{
	if(joint == 0) return 0.0f;
	return ((IJoint2D*)joint)->GetDampingRatio();
}

size_t xCreateRevolute2DJoint(size_t bodyA, size_t bodyB, bool collide)
{
	IWorld2D * world = xRender::Instance()->GetPhysWorld2D();
	if(world == NULL) return 0;
	return (size_t)world->CreateRevoluteJoint((IBody2D*)bodyA, (IBody2D*)bodyB, collide);
}

size_t xCreateRevolute2DJointWithAxis(size_t bodyA, size_t bodyB, float axisX, float axisY, bool collide)
{
	IWorld2D * world = xRender::Instance()->GetPhysWorld2D();
	if(world == NULL) return 0;
	return (size_t)world->CreateRevoluteJoint((IBody2D*)bodyA, (IBody2D*)bodyB, axisX, axisY, collide);
}

void xSet2DJointHingeLimit(size_t joint, bool enabled, float lower, float upper)
{
	if(joint == 0) return;
	((IJoint2D*)joint)->SetHingeLimit(enabled, lower, upper);
}

float xGet2DJointLowerHingeLimit(size_t joint)
{
	if(joint == 0) return 0.0f;
	return ((IJoint2D*)joint)->GetHingeLowerLimit();
}

float xGet2DJointUpperHingeLimit(size_t joint)
{
	if(joint == 0) return 0.0f;
	return ((IJoint2D*)joint)->GetHingeUpperLimit();
}

bool xGet2DJointHingeLimitEnabled(size_t joint)
{
	if(joint == 0) return false;
	return ((IJoint2D*)joint)->GetHingeLimitEnabled();
}

void xSet2DJointHingeMotor(size_t joint, bool enabled, float speed, float maxTorque)
{
	if(joint == 0) return;
	((IJoint2D*)joint)->SetHingeMotor(enabled, speed, maxTorque);
}

float xGet2DJointHingeMotorSpeed(size_t joint)
{
	if(joint == 0) return 0.0f;
	return ((IJoint2D*)joint)->GetHingeMotorSpeed();
}

float xGet2DJointHingeMotorTorque(size_t joint)
{
	if(joint == 0) return 0.0f;
	return ((IJoint2D*)joint)->GetHingeMotorTorque();
}

bool xGet2DJointHingeMotorEnabled(size_t joint)
{
	if(joint == 0) return false;
	return ((IJoint2D*)joint)->GetHingeMotorEnabled();
}

size_t xCreatePrismatic2DJoint(size_t bodyA, size_t bodyB, float axisX, float axisY, bool collide)
{
	IWorld2D * world = xRender::Instance()->GetPhysWorld2D();
	if(world == NULL) return 0;
	return (size_t)world->CreatePrismaticJoint((IBody2D*)bodyA, (IBody2D*)bodyB, axisX, axisY, collide);
}

size_t xCreatePrismatic2DJointWithPivot(size_t bodyA, size_t bodyB, float pivotX, float pivotY, float axisX, float axisY, bool collide)
{
	IWorld2D * world = xRender::Instance()->GetPhysWorld2D();
	if(world == NULL) return 0;
	return (size_t)world->CreatePrismaticJoint((IBody2D*)bodyA, (IBody2D*)bodyB, pivotX, pivotY, axisX, axisY, collide);
}

void xSet2DJointLinearLimit(size_t joint, bool enabled, float lower, float upper)
{
	if(joint == 0) return;
	((IJoint2D*)joint)->SetLinearLimit(enabled, lower, upper);
}

float xGet2DJointLowerLinearLimit(size_t joint)
{
	if(joint == 0) return 0.0f;
	return ((IJoint2D*)joint)->GetLinearLowerLimit();
}

float xGet2DJointUpperLinearLimit(size_t joint)
{
	if(joint == 0) return 0.0f;
	return ((IJoint2D*)joint)->GetLinearUpperLimit();
}

bool xGet2DJointLinearLimitEnabled(size_t joint)
{
	if(joint == 0) return false;
	return ((IJoint2D*)joint)->GetLinearLimitEnabled();
}

void xSet2DJointLinearMotor(size_t joint, bool enabled, float speed, float maxForce)
{
	if(joint == 0) return;
	((IJoint2D*)joint)->SetLinearMotor(enabled, speed, maxForce);
}

float xGet2DJointLinearMotorSpeed(size_t joint)
{
	if(joint == 0) return 0.0f;
	return ((IJoint2D*)joint)->GetLinearMotorSpeed();
}

float xGet2DJointLinearMotorForce(size_t joint)
{
	if(joint == 0) return 0.0f;
	return ((IJoint2D*)joint)->GetLinearMotorForce();
}

bool xGet2DJointLinearMotorEnabled(size_t joint)
{
	if(joint == 0) return false;
	return ((IJoint2D*)joint)->GetLinearMotorEnabled();
}

size_t xCreatePulley2DJoint(size_t bodyA, size_t bodyB, float anchorAX, float anchorAY, float anchorBX, float anchorBY, bool collide)
{
	IWorld2D * world = xRender::Instance()->GetPhysWorld2D();
	if(world == NULL) return 0;
	return (size_t)world->CreatePulleyJoint((IBody2D*)bodyA, (IBody2D*)bodyB, anchorAX, anchorAY,
										 anchorBX, anchorBY, collide);
}

size_t xCreatePulley2DJointWithPivots(size_t bodyA, size_t bodyB, float anchorAX, float anchorAY, float anchorBX, float anchorBY, float pivotAX, float pivotAY, float pivotBX, float pivotBY, bool collide)
{
	IWorld2D * world = xRender::Instance()->GetPhysWorld2D();
	if(world == NULL) return 0;
	return (size_t)world->CreatePulleyJoint((IBody2D*)bodyA, (IBody2D*)bodyB, anchorAX, anchorAY,
										 anchorBX, anchorBY, pivotAX, pivotAY, pivotBX, pivotBY, collide);
}

float xGet2DJointPulleyLengthA(size_t joint)
{
	if(joint == 0) return 0.0f;
	return ((IJoint2D*)joint)->GetPulleyLengthA();
}

float xGet2DJointPulleyLengthB(size_t joint)
{
	if(joint == 0) return 0.0f;
	return ((IJoint2D*)joint)->GetPulleyLengthB();
}

size_t xCreateGear2DJoint(size_t jointA, size_t jointB)
{
	IWorld2D * world = xRender::Instance()->GetPhysWorld2D();
	if(world == NULL) return 0;
	return (size_t)world->CreateGearJoint(((IJoint2D*)jointA), ((IJoint2D*)jointB));
}

void xSet2DJointGearRatio(size_t joint, float ratio)
{
	if(joint == 0) return;
	((IJoint2D*)joint)->SetGearRatio(ratio);
}

float xGet2DJointGearRatio(size_t joint)
{
	if(joint == 0) return 0.0f;
	return ((IJoint2D*)joint)->GetGearRatio();
}

unsigned int xMillisecs()
{
	uint timeGetTime();
	return timeGetTime();
}

bool xMeshesIntersect(size_t firstMesh, size_t secondMesh)
{
	if(firstMesh == 0 || secondMesh == 0) return false;
	return ((xEntity*)firstMesh)->MeshesIntersect((xEntity*)secondMesh);
}

size_t xCreateAtlas()
{
	x2DAtlas * newAtlas = new x2DAtlas();
	return (size_t)newAtlas;
}

size_t xLoadAtlas(const char * path)
{
	x2DAtlas * newAtlas = new x2DAtlas();
	if(!newAtlas->Load(path))
	{
		delete newAtlas;
		return NULL;
	}
	return (size_t)newAtlas;
}

void xFreeAtlas(size_t atlas)
{
	((x2DAtlas*)atlas)->Release();
	delete ((x2DAtlas*)atlas);
}

bool xAtlasAddImage(size_t atlas, size_t image)
{
	return ((x2DAtlas*)atlas)->AddImage((xImage*)image, "");
}

bool xAtlasAddNamedImage(size_t atlas, size_t image, const char * name)
{
	return ((x2DAtlas*)atlas)->AddImage((xImage*)image, name);
}

int xCountAtlasImages(size_t atlas)
{
	return ((x2DAtlas*)atlas)->CountImages();
}

size_t xGetAtlasImage(size_t atlas, int index)
{
	return (size_t)((x2DAtlas*)atlas)->GetImage(index);
}

size_t xFindAtlasImage(size_t atlas, const char * name)
{
	return (size_t)((x2DAtlas*)atlas)->FindImage(name);
}

void xBuildAtlas(size_t atlas)
{
	((x2DAtlas*)atlas)->GenerateTexture();
}

float xGetTotalPhysMem()
{
	return xSysInfo::Instance()->GetTotalMemory();
}

float xGetAvailPhysMem()
{
	return xSysInfo::Instance()->GetFreeMemory();
}

float xGetUsedPhysMem()
{
	return xSysInfo::Instance()->GetUsedMemory();
}

float xGetInactivePhysMem()
{
	return xSysInfo::Instance()->GetInactiveMemory();
}

float xGetCPUUserTime()
{
	return xSysInfo::Instance()->GetCPUUserTime();
}

float xGetCPUSysTime()
{
	return xSysInfo::Instance()->GetCPUSysTime();
}

float xGetCPUIdleTime()
{
	return xSysInfo::Instance()->GetCPUIdleTime();
}

void xAutoDeletePixels(bool flag)
{
	xRender::Instance()->SetAutoDeletePixels(flag);
}

void xDeleteTexturePixels(size_t texture)
{
	if(texture == 0) return;
	((xTexture*)texture)->DeletePixels();
}

void xDeleteImagePixels(size_t image)
{
	if(image == 0) return;
	((xImage*)image)->DeletePixels();
}

xVector _x3d_projected = xVector();
int xCameraProject(size_t camera, float x, float y, float z)
{
	xVector  vector  = ((xCamera*)camera)->GetWorldTransform().Inversed() * xVector(x, y, z);
	if(((xCamera*)camera)->GetProjMode() == PROJ_ORTHO)
	{
		float projection[16];
		int vp_x, vp_y, vp_w, vp_h;
		float nr, fr;
		((xCamera*)camera)->GetRange(&nr, &fr);
		((xCamera*)camera)->GetViewport(&vp_x, &vp_y, &vp_w, &vp_h);
		((xCamera*)camera)->GetProjectionMatrix(projection);
		float w = 1.0f / (projection[0 * 4 + 3] * vector.x + projection[1 * 4 + 3] * vector.y + projection[2 * 4 + 3] * vector.z + projection[3 * 4 + 3]);
		_x3d_projected =  xVector((projection[0 * 4 + 0] * vector.x + projection[1 * 4 + 0] * vector.y + projection[2 * 4 + 0] * vector.z + projection[3 * 4 + 0]) * w,
								  (projection[0 * 4 + 1] * vector.x + projection[1 * 4 + 1] * vector.y + projection[2 * 4 + 1] * vector.z + projection[3 * 4 + 1]) * w,
								  nr);
		_x3d_projected.x = (_x3d_projected.x + 0.5f) * vp_w;
		_x3d_projected.y = (0.5f - _x3d_projected.y) * vp_h;
		return 1;
	}
	if(vector.z <= 0.0f)
	{
#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
		float devider   = 3.2f;
		int orientation = xRender::Instance()->GetDeviceOrientation();
		if(orientation == 1 || orientation == 3) devider = 1.6f;
		int viewPortX, viewPortY, viewPortWidth, viewPortHeight;
		float nearRange, farRange;
		((xCamera*)camera)->GetViewport(&viewPortX, &viewPortY, &viewPortWidth, &viewPortHeight);
		((xCamera*)camera)->GetRange(&nearRange, &farRange);
		float zoom       = ((xCamera*)camera)->GetZoom();
		float aspect     = float(viewPortHeight) / float(viewPortWidth);
		float nearWidth  = 2.0f * nearRange * atan(1.0f / devider / zoom);
		float nearHeight = 2.0f * nearRange * atan(1.0f / devider / zoom) * aspect;
#else
		int viewPortX, viewPortY, viewPortWidth, viewPortHeight;
		float nearRange, farRange;
		((xCamera*)camera)->GetViewport(&viewPortX, &viewPortY, &viewPortWidth, &viewPortHeight);
		((xCamera*)camera)->GetRange(&nearRange, &farRange);
		float zoom       = ((xCamera*)camera)->GetZoom();
		float aspect     = float(viewPortHeight) / float(viewPortWidth);
		float nearWidth  = 2.0f * nearRange * atan(0.5f / zoom) / aspect;
		float nearHeight = 2.0f * nearRange * atan(0.5f / zoom);
#endif
		_x3d_projected = xVector((vector.x * nearRange / (-vector.z) / nearWidth + 0.5f) * viewPortWidth, (0.5f - vector.y * nearRange / (-vector.z) / nearHeight) * viewPortHeight, nearRange);
		return 1;
	}
	_x3d_projected = xVector();
	return 0;
}

float xProjectedX()
{
	return _x3d_projected.x;
}

float xProjectedY()
{
	return _x3d_projected.y;
}

float xProjectedZ()
{
	return _x3d_projected.z;
}

#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR

bool xIsGCSupported()
{
	return xPlayerManager::Instance()->IsGCSupported();
}

bool xGCAuthenticate()
{
	return xPlayerManager::Instance()->Authenticate();
}

bool xIsGCPlayerLogedIn()
{
	return xPlayerManager::Instance()->IsLogedIn();
}

const char * xGetGCPlayerName()
{
	return xPlayerManager::Instance()->GetPlayerInfo().name.c_str();
}

const char * xGetGCPlayerID()
{
	return xPlayerManager::Instance()->GetPlayerInfo().playerID.c_str();
}

int xGetGCFriendsCount()
{
	return xPlayerManager::Instance()->GetFriendsCount();
}

const char * xGetGCFriendName(int index)
{
	return xPlayerManager::Instance()->GetFriendInfo(index).name.c_str();
}

const char * xGetGCFriendID(int index)
{
	return xPlayerManager::Instance()->GetFriendInfo(index).playerID.c_str();
}

#endif