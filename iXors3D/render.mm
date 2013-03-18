//
//  render.m
//  iXors3D
//
//  Created by Knightmare on 01.09.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import "render.h"
#import "light.h"
#import <sys/time.h>
#import "pxWorld.h"
#import "pxWorld2D.h"
#import "camera.h"
#import "2datlas.h"

xRender * xRender::_instance = NULL;

uint timeGetTime()
{
	timeval time;
	gettimeofday(&time, NULL);
	return (time.tv_sec * 1000) + (time.tv_usec / 1000);
}

xRender::xRender()
{ 
	_width            = 0;
	_height           = 0;
	_context          = NULL;
#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
	_layer            = NULL;
#else
	_appTitle         = "Render window";
	_fullScreen       = false;
#endif
	_renderBuffer     = 0;
	_frameBuffer      = 0;
	_depthBuffer      = 0;
	_cred             = 0;
	_cgreen           = 0;
	_cblue            = 0;
	_red              = 255;
	_green            = 255;
	_blue             = 255;
	_bbPixels         = NULL;
	_textureLayer     = 0;
	_lastTime         = 0;
	_lastTris         = 0;
	_lastFPS          = 0;
	_tempFPS          = 0;
	_tempTris         = 0;
	_activeCamera     = NULL;
	_tansprentStage   = false;
	_orderedStage     = false;
	_globalScalex     = 1.0f;
	_globalScaley     = 1.0f;
	_globalOffsetx    = 0;
	_globalOffsety    = 0;
	_globalAngle      = 0;
	_globalRed        = 1.0f;
	_globalGreen      = 1.0f;
	_globalBlue       = 1.0f;
	_globalAlpha      = 1.0f;
	_globalBlend      = 0;
	_orientationMask  = 0;
	_pickedPosition   = xVector();
	_pickedNormal     = xVector();
	_pickDistance     = 0.0f;
	_pickTime         = 0.0f;
	_pickedTriangle   = 0;
	_pickedSurfce     = NULL;
	_pickedEntity     = NULL;
	_renderWindow     = nil;
	_physWorld        = NULL;
	_physWorld2D      = NULL;
	_activeFB         = 0;
	_orientation      = 0;
	_lastAtlas        = NULL;
	_autoDeletePixels = false;
	_scaleFactor      = 1.0f;
}

xRender::xRender(const xRender & other)
{
}

xRender & xRender::operator=(const xRender & other)
{
	return *this;
}

xRender::~xRender()
{
	_width        = 0;
	_height       = 0;
	_context      = NULL;
#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
	_layer        = NULL;
#endif
	_renderBuffer = 0;
	_frameBuffer  = 0;
	_depthBuffer  = 0;
	_cred         = 0.0f;
	_cgreen       = 0.0f;
	_cblue        = 0.0f;
	_red          = 255;
	_green        = 255;
	_blue         = 255;
	_lastTime     = 0;
	_lastTris     = 0;
	_lastFPS      = 0;
	_tempFPS      = 0;
	_tempTris     = 0;
	_bbPixels     = NULL;
	_dips         = 0;
	_windowWidth  = 0;
	_windowHeight = 0;
	if(_physWorld != NULL) delete _physWorld;
	if(_physWorld2D != NULL) delete _physWorld2D;
}

xRender * xRender::Instance()
{
	if(_instance == NULL) _instance = new xRender();
	return _instance;
}

void xRender::SetActiveCamera(xCamera * camera)
{
	_activeCamera = camera;
}

xCamera * xRender::GetActiveCamera()
{
	return _activeCamera;
}

void xRender::SetOrientationMask(int mask)
{
	_orientationMask = mask;
}

int xRender::GetOrientationMask()
{
	return _orientationMask;
}

#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
void xRender::SetWindow(UIWindow * window)
{
	_renderWindow = window;
}
#else
void xRender::SetWindow(NSWindow * window)
{
	_renderWindow = window;
}
#endif

pthread_mutex_t * xRender::GetMutex()
{
	return &_renderMutex;
}

#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
UIWindow * xRender::GetWindow()
{
	return _renderWindow;
}
#else
NSWindow * xRender::GetWindow()
{
	return _renderWindow;
}
#endif

void xRender::ComputeMatrices(int orientation)
{
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	if(orientation == 2)
	{
		glTranslatef(_windowWidth / 2, _windowHeight / 2, 0);
		glRotatef(180, 0, 0, 1);
		glTranslatef(-_windowWidth / 2, -_windowHeight / 2, 0);
	}
	else if(orientation == 3)
	{
		glTranslatef(_windowWidth / 2, _windowHeight / 2, 0);
		glRotatef(-90, 0, 0, 1);
		glTranslatef(-_windowHeight / 2, -_windowWidth / 2, 0);
	}
	else if(orientation == 1)
	{
		glTranslatef(_windowWidth / 2, _windowHeight / 2, 0);
		glRotatef(90, 0, 0, 1);
		glTranslatef(-_windowHeight / 2, -_windowWidth / 2, 0);
	}
	glGetFloatv(GL_MODELVIEW_MATRIX, &_screenRotateMatrix[0]);
	glLoadIdentity();
	if(orientation == 2)
	{
		glRotatef(180, 0, 0, 1);
	}
	else if(orientation == 3)
	{
		glRotatef(90, 0, 0, 1);
	}
	else if(orientation == 1)
	{
		glRotatef(-90, 0, 0, 1);
	}
	glGetFloatv(GL_MODELVIEW_MATRIX, &_screenRotateMatrix3D[0]);
}

void xRender::SetDeviceOrientation(int orientation)
{
	_orientation = orientation;
	ComputeMatrices(_orientation);
}

float * xRender::GetScreenRotateMatrix()
{
	return &_screenRotateMatrix3D[0];
}

int xRender::GetDeviceOrientation()
{
	return _orientation;
}

#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
void xRender::SetOrientation(UIDeviceOrientation orientation)
{
	UIDeviceOrientation currentOrientation;
	switch(_orientation)
	{
		case 0:  currentOrientation = UIDeviceOrientationPortrait;           break;
		case 1:  currentOrientation = UIDeviceOrientationLandscapeLeft;      break;
		case 2:  currentOrientation = UIDeviceOrientationPortraitUpsideDown; break;
		case 3:  currentOrientation = UIDeviceOrientationLandscapeRight;     break;
		default: currentOrientation = UIDeviceOrientationPortrait;           break;
	}
	if(currentOrientation == orientation) return;
	pthread_mutex_lock(&_renderMutex);
	switch(orientation)
	{
		case UIDeviceOrientationPortrait:
		{
			if(_orientationMask & 1)
			{
				SetDeviceOrientation(0);
				ResetViewports();
				[[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationPortrait animated: NO];
			}
		}
		break;
		case UIDeviceOrientationLandscapeLeft:
		{
			if(_orientationMask & 2)
			{
				SetDeviceOrientation(1);
				ResetViewports();
				[[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationLandscapeRight animated: NO];
			}
		}
		break;
		case UIDeviceOrientationPortraitUpsideDown:
		{
			if(_orientationMask & 4)
			{
				SetDeviceOrientation(2);
				ResetViewports();
				[[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationPortraitUpsideDown animated: NO];
			}
		}
		break;
		case UIDeviceOrientationLandscapeRight:
		{
			if(_orientationMask & 8)
			{
				SetDeviceOrientation(3);
				ResetViewports();
				[[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationLandscapeLeft animated: NO];
			}
		}
		break;
	}
	pthread_mutex_unlock(&_renderMutex);
}
#endif

#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
bool xRender::Initialize(CAEAGLLayer * eaglLayer)
#else
bool xRender::Initialize(int width, int height, int depth, bool fullscreen, NSView * view)
#endif
{
	// create OGL context
#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
	_layer                    = eaglLayer;
	_layer.opaque             = YES;
	_layer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
								 [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
	_context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
	if(!_context || ![EAGLContext setCurrentContext:_context])
	{
		printf("ERROR(%s:%i): Failed to create OpenGL ES context.\n", __FILE__, __LINE__);
		return false;
	}
#else
	NSOpenGLPixelFormatAttribute attributes[] =
	{
		NSOpenGLPFADoubleBuffer, 
		NSOpenGLPFAColorSize, 24,
		NSOpenGLPFADepthSize, 24,
		NSOpenGLPFAWindow,
		0
	};
	NSOpenGLPixelFormat * pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes: attributes];
	if(pixelFormat == nil)
	{
		printf("ERROR(%s:%i): Failed to choose pixel format.\n", __FILE__, __LINE__);
		return false;
	}
	_context = [[NSOpenGLContext alloc] initWithFormat: pixelFormat shareContext: nil];
	if(_context == nil)
	{
		printf("ERROR(%s:%i): Failed to create OpenGL context.\n", __FILE__, __LINE__);
		return false;
	}
	[_context setView: view];
	[_context makeCurrentContext];
	_width      = width;
	_height     = height;
	_fullScreen = fullscreen;
#endif
	// create frame buffer
	CreateFrameBuffer();
	// print information to log
	printf("iXors3D Engine initialized successfully.\n");
	printf("Vendor: %s\n", glGetString(GL_VENDOR));
	printf("Renderer: %s\n", glGetString(GL_RENDERER));
	printf("Version: %s\n", glGetString(GL_VERSION));
	printf("Extensions: %s\n", glGetString(GL_EXTENSIONS));
	glGetIntegerv(GL_MAX_TEXTURE_UNITS, &_maxTextureUnits);
	printf("Max texture units: %i\n", _maxTextureUnits);
	glGetIntegerv(GL_MAX_TEXTURE_SIZE, &_maxTextureSize);
	printf("Max texture size: %ix%i\n", _maxTextureSize, _maxTextureSize);
	glGetIntegerv(GL_MAX_LIGHTS, &_maxLights);
	printf("Max lights: %i\n", _maxLights);
	// reset lights
	_lightsGroup.resize(_maxLights);
	for(int i = 0; i < _lightsGroup.size(); i++) _lightsGroup[i] = NULL;
	// states
	glEnable(GL_RESCALE_NORMAL);
	GLfloat ambient[] = { 0.5f, 0.5f, 0.5f, 1.0f };
	glLightModelfv(GL_LIGHT_MODEL_AMBIENT, ambient);
	// capture last time
	_lastTime       = timeGetTime();
	_viewPortX      = 0;
	_viewPortY      = 0;
	_viewPortWidth  = _width;
	_viewPortHeight = _height;
	// create physics world
	_physWorld = (IWorld*)new pxWorld();
	if(_physWorld != NULL)
	{
		printf("Bullet physics intialized!\n");
	}
	_physWorld2D = (IWorld2D*)new pxWorld2D();
	if(_physWorld2D != NULL)
	{
		printf("Box2D physics intialized!\n");
	}
	SetDeviceOrientation(_orientation);
	// all done
    return true;
}

void xRender::SetWindowSize(int width, int height)
{
	_windowWidth  = width;
	_windowHeight = height;
}

int xRender::GetWindowWidth()
{
	return _windowWidth;
}

int xRender::GetWindowHeight()
{
	return _windowHeight;
}

void xRender::ResetViewports()
{
	_viewPortX      = 0;
	_viewPortY      = 0;
	_viewPortWidth  = GraphicsWidth();
	_viewPortHeight = GraphicsHeight();
	for(int i = 0; i < _camerasGroup.size(); i++)
	{
		if(_camerasGroup[i]->UsedDefaultVP())
		{
			_camerasGroup[i]->SetViewport(0, 0, GraphicsWidth(), GraphicsHeight());
		}
	}
}

IWorld * xRender::GetPhysWorld()
{
	return _physWorld;
}

void xRender::AddPhysNode(xEntity * entity)
{
	std::vector<xEntity*>::iterator itr = std::find(_physNodes.begin(), _physNodes.end(), entity);
	if(itr == _physNodes.end()) _physNodes.push_back(entity);
}

void xRender::DeletePhysNode(xEntity * entity)
{
	std::vector<xEntity*>::iterator itr = std::find(_physNodes.begin(), _physNodes.end(), entity);
	if(itr != _physNodes.end()) _physNodes.erase(itr);
}

std::vector<xEntity*>::iterator xRender::PhysNodesBegin()
{
	return _physNodes.begin();
}

std::vector<xEntity*>::iterator xRender::PhysNodesEnd()
{
	return _physNodes.end();
}

void xRender::AddDIP()
{
	_dips++;
}

int xRender::GetDIPCount()
{
	return _dips;
}

#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
xGLView * xRender::GetView()
{
	return _view;
}

void xRender::SetLayer(CAEAGLLayer * eaglLayer)
{
	_layer = eaglLayer;
}

void xRender::SetView(xGLView * view)
{
	_view = view;
}
#else
void xRender::SetAppTitle(const char * title)
{
	_appTitle = title;
	if(_renderWindow != nil)
	{
		[_renderWindow setTitle: [NSString stringWithUTF8String: title]];
	}
}

const char * xRender::GetAppTitle()
{
	return _appTitle.c_str();
}

NSView * xRender::GetView()
{
	return _view;
}

void xRender::SetView(NSView * view)
{
	_view = view;
}

void xRender::ShowWindow()
{
	if(_fullScreen) [_renderWindow setLevel: CGShieldingWindowLevel()];
	[_renderWindow deminiaturize: nil];
}

void xRender::HideWindow()
{
	if(_fullScreen) [_renderWindow setLevel: 0];
	[_renderWindow miniaturize: nil];
}
#endif

int xRender::GetMaxTextureUnits()
{
	return _maxTextureUnits;
}

int xRender::GetMaxTextureSize()
{
	return _maxTextureSize;
}

int xRender::GetMaxLights()
{
	return _maxLights;
}

bool xRender::TransparentStage()
{
	return _tansprentStage;
}

void xRender::CreateFrameBuffer()
{
#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
	[EAGLContext setCurrentContext:_context];
	// create frame and render buffers
	glGenFramebuffersOES(1, &_frameBuffer);
    glGenRenderbuffersOES(1, &_renderBuffer);
    // bind buffers
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, _frameBuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, _renderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:_layer];
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, _renderBuffer);
    // getting backbuffer size
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &_width);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &_height);
    // create dpth buffer
	glGenRenderbuffersOES(1, &_depthBuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, _depthBuffer);
	glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, _width, _height);
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, _depthBuffer);
	if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES)
	{
        printf("ERROR(%s:%i): Failed to make framebuffer object %x.\n", __FILE__, __LINE__, glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return;
    }
#else
	[_context makeCurrentContext];
	// create frame and render buffers
	_frameBuffer = 0;
    glGenRenderbuffersEXT(1, &_renderBuffer);
    // bind buffers
    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, _frameBuffer);
    glBindRenderbufferEXT(GL_RENDERBUFFER_EXT, _renderBuffer);
    glRenderbufferStorageEXT(GL_RENDERBUFFER_EXT, GL_RGB, _width, _height);
    glFramebufferRenderbufferEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_RENDERBUFFER_EXT, _renderBuffer);
    // create dpth buffer
	glGenRenderbuffersEXT(1, &_depthBuffer);
	glBindRenderbufferEXT(GL_RENDERBUFFER_EXT, _depthBuffer);
	glRenderbufferStorageEXT(GL_RENDERBUFFER_EXT, GL_DEPTH_COMPONENT24, _width, _height);
	glFramebufferRenderbufferEXT(GL_FRAMEBUFFER_EXT, GL_DEPTH_ATTACHMENT_EXT, GL_RENDERBUFFER_EXT, _depthBuffer);
	if(glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT) != GL_FRAMEBUFFER_COMPLETE_EXT)
	{
        printf("ERROR(%s:%i): Failed to make framebuffer object %x.\n", __FILE__, __LINE__, glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT));
        return;
    }
#endif
	_activeFB = _frameBuffer;
}

void xRender::DeleteFrameBuffer()
{
#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
	glDeleteFramebuffersOES(1, &_frameBuffer);
    _frameBuffer = 0;
    glDeleteRenderbuffersOES(1, &_renderBuffer);
    _renderBuffer = 0;
	glDeleteRenderbuffersOES(1, &_depthBuffer);
	_depthBuffer = 0;
#else
    _frameBuffer = 0;
    glDeleteRenderbuffersEXT(1, &_renderBuffer);
    _renderBuffer = 0;
	glDeleteRenderbuffersEXT(1, &_depthBuffer);
	_depthBuffer = 0;
#endif
	_activeFB = 0;
}

void xRender::Cls()
{
	pthread_mutex_lock(&_renderMutex);
#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
	// set context
	[EAGLContext setCurrentContext:_context];
    // bind buffer
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, _activeFB);
#else
	[_context makeCurrentContext];
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, _activeFB);
#endif
	// set viewport
    glViewport(0, 0, _width, _height);
    // set clear color
    glClearColor(_cred, _cgreen, _cblue, 1.0f);
	// set z-buffer clear value
#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
	glClearDepthf(1.0f);
#else
	glClearDepth(1.0f);
#endif
	// clear
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	pthread_mutex_unlock(&_renderMutex);
}

void xRender::SetContext()
{
	pthread_mutex_lock(&_renderMutex);
#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
	[EAGLContext setCurrentContext:_context];
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, _activeFB);
#else
	[_context makeCurrentContext];
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, _activeFB);
#endif
	pthread_mutex_unlock(&_renderMutex);
}

void xRender::SetFrameBuffer()
{
	_activeFB = _frameBuffer;
#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, _activeFB);
#else
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, _activeFB);
#endif
	ComputeMatrices(_orientation);
}

void xRender::SetActiveBuffer(GLuint buffer)
{
	_activeFB = buffer;
#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, _activeFB);
#else
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, _activeFB);
#endif
	ComputeMatrices(0);
}

void xRender::Flip()
{
	DrawQueue();
	// capture statistics
	_tempFPS++;
    if(_lastTime < timeGetTime() - 1000)
	{
		_lastFPS  = _tempFPS;
		_tempFPS  = 0;
		_lastTime = timeGetTime();
	}
	_lastTris = _tempTris;
	_tempTris = 0;	
	_dips     = 0;
	pthread_mutex_lock(&_renderMutex);
#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
	[EAGLContext setCurrentContext:_context];
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, _renderBuffer);
    [_context presentRenderbuffer:GL_RENDERBUFFER_OES];
#else
	[_context makeCurrentContext];
	glBindFramebufferEXT(GL_READ_FRAMEBUFFER_EXT, _frameBuffer);
	[_context flushBuffer];
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, _activeFB);
#endif
	pthread_mutex_unlock(&_renderMutex);
}

void xRender::AddTriangles(int count)
{
	_tempTris += count;
}

int xRender::GetTrianglesCount()
{
	return _lastTris;
}

int xRender::GetFPSCount()
{
	return _lastFPS;
}

void xRender::ClsColor(int red, int green, int blue)
{
	_cred   = (float)red   / 255.0f;
	_cgreen = (float)green / 255.0f;
	_cblue  = (float)blue  / 255.0f;
}

void xRender::Color(int red, int green, int blue)
{
	_red   = red;
	_green = green;
	_blue  = blue;
}

void xRender::SetScaleFactor(float value)
{
	_scaleFactor = value;
}

float xRender::GetScaleFactor()
{
	return _scaleFactor;
}

int xRender::GraphicsWidth()
{
	if(_orientation == 1 || _orientation == 3) return _height;
	return _width;
}

int xRender::GraphicsHeight()
{
	if(_orientation == 1 || _orientation == 3) return _width;
	return _height;
}

xPoint xRender::RotatePoint(const xPoint & point, const xPoint & size)
{
	if(_orientation == 3 || _frameBuffer != _activeFB) return point;
	xPoint realPoint = RotateSize(point);
	xPoint realSize  = RotateSize(size);
	switch(_orientation)
	{
		case 0: return xPoint(realPoint.x,                             _windowHeight - realSize.y - realPoint.y);
		case 1: return xPoint(_windowWidth - realSize.x - realPoint.x, _windowHeight - realSize.y - realPoint.y);
		case 2: return xPoint(_windowWidth - realSize.x - realPoint.x, realPoint.y);
	}
	return point;
}

xPoint xRender::RotateSize(const xPoint & point)
{
	if(_frameBuffer != _activeFB) return point;
	if(_orientation == 1 || _orientation == 3) return xPoint(point.y, point.x);
	return point;
}

void xRender::DrawLine(int x, int y, int dx, int dy)
{
	// prepare 2D rendering
	Prepare2D();
	// line arrays
	const GLfloat lineVertices[] = { x, y, dx, dy };
    const GLubyte lineColors[]   = { _red, _green, _blue, 255,
									 _red, _green, _blue, 255 };
	// set pointer to vertices
    glVertexPointer(2, GL_FLOAT, 0, lineVertices);
    glEnableClientState(GL_VERTEX_ARRAY);
	// set pointer to colors
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, lineColors);
    glEnableClientState(GL_COLOR_ARRAY);
	// disable texture coords
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	// disable texture
	glActiveTexture(GL_TEXTURE0);
	glDisable(GL_TEXTURE_2D);
	// draw line
    glDrawArrays(GL_LINES, 0, 2);
}

void xRender::SetViewport(int x, int y, int width, int height)
{
    DrawQueue();
	_viewPortX      = x;
	_viewPortY      = y;
	_viewPortWidth  = width;
	_viewPortHeight = height;
}

void xRender::Prepare2D()
{
	DrawQueue();
}

void xRender::AddToQueue(xImage * image, float x, float y, int frame, int rectX, int rectY, int rectWidth, int rectHeight)
{
	if(_lastAtlas != NULL && _lastAtlas != image->GetAtlas()) DrawQueue();
	_lastAtlas = image->GetAtlas();
	xAtlasVertex vertices[6];
	// create vertex buffer
	float scalex   = image->GetScaleX();
	float scaley   = image->GetScaleY();
	float offsetx  = image->GetXHandle();
	float offsety  = image->GetYHandle();
	float red      = image->GetColorRed();
	float green    = image->GetColorGreen();
	float blue     = image->GetColorBlue();
	float alpha    = image->GetColorAlpha();
	GLfloat osx    = 0.0f - (offsetx + _globalOffsetx) * scalex * _globalScalex;
	GLfloat osy    = 0.0f - (offsety + _globalOffsety) * scaley * _globalScaley;
	GLfloat odx    = rectWidth  * scalex * _globalScalex - (offsetx + _globalOffsetx) * scalex * _globalScalex;
	GLfloat ody    = rectHeight * scaley * _globalScaley - (offsety + _globalOffsety) * scaley * _globalScaley;
	// rotate corners
	float radAngle = (image->GetAngle() + _globalAngle) * (PI / 180.f);
	float sina     = sin(radAngle);
	float cosa     = cos(radAngle);
	GLfloat c1x    = osx * cosa - osy * sina;
	GLfloat c1y    = osx * sina + osy * cosa;
	GLfloat c2x    = odx * cosa - osy * sina;
	GLfloat c2y    = odx * sina + osy * cosa;
	GLfloat c3x    = osx * cosa - ody * sina;
	GLfloat c3y    = osx * sina + ody * cosa;
	GLfloat c4x    = odx * cosa - ody * sina;
	GLfloat c4y    = odx * sina + ody * cosa;
	xTextureAtlas::xAtlasRegion region = _lastAtlas->GetTextureRegion(image->GetTexture(), frame);
	float minX = float(region.x + rectX)              / float(_lastAtlas->GetWidth());
	float minY = float(region.y + rectY)              / float(_lastAtlas->GetHeight());
	float maxX = float(region.x + rectX + rectWidth)  / float(_lastAtlas->GetWidth());
	float maxY = float(region.y + rectY + rectHeight) / float(_lastAtlas->GetHeight());
	//
	vertices[0].x     = x + c1x;
	vertices[0].y     = y + c1y;
	vertices[0].tu    = minX;
	vertices[0].tv    = minY;
	vertices[0].red   = red   * _globalRed   * 255;
	vertices[0].green = green * _globalGreen * 255;
	vertices[0].blue  = blue  * _globalBlue  * 255;
	vertices[0].alpha = alpha * _globalAlpha * 255;
	//
	vertices[1].x     = x + c2x;
	vertices[1].y     = y + c2y,
	vertices[1].tu    = maxX;
	vertices[1].tv    = minY;
	vertices[1].red   = red   * _globalRed   * 255;
	vertices[1].green = green * _globalGreen * 255;
	vertices[1].blue  = blue  * _globalBlue  * 255;
	vertices[1].alpha = alpha * _globalAlpha * 255;
	//
	vertices[2].x     = x + c3x;
	vertices[2].y     = y + c3y;
	vertices[2].tu    = minX;
	vertices[2].tv    = maxY;
	vertices[2].red   = red   * _globalRed   * 255;
	vertices[2].green = green * _globalGreen * 255;
	vertices[2].blue  = blue  * _globalBlue  * 255;
	vertices[2].alpha = alpha * _globalAlpha * 255;
	//
	vertices[3].x     = x + c2x;
	vertices[3].y     = y + c2y,
	vertices[3].tu    = maxX;
	vertices[3].tv    = minY;
	vertices[3].red   = red   * _globalRed   * 255;
	vertices[3].green = green * _globalGreen * 255;
	vertices[3].blue  = blue  * _globalBlue  * 255;
	vertices[3].alpha = alpha * _globalAlpha * 255;	
	//
	vertices[4].x     = x + c4x;
	vertices[4].y     = y + c4y;
	vertices[4].tu    = maxX;
	vertices[4].tv    = maxY;
	vertices[4].red   = red   * _globalRed   * 255;
	vertices[4].green = green * _globalGreen * 255;
	vertices[4].blue  = blue  * _globalBlue  * 255;
	vertices[4].alpha = alpha * _globalAlpha * 255;
	//
	vertices[5].x     = x + c3x;
	vertices[5].y     = y + c3y;
	vertices[5].tu    = minX;
	vertices[5].tv    = maxY;
	vertices[5].red   = red   * _globalRed   * 255;
	vertices[5].green = green * _globalGreen * 255;
	vertices[5].blue  = blue  * _globalBlue  * 255;
	vertices[5].alpha = alpha * _globalAlpha * 255;
	//
	_queueVertices.push_back(vertices[0]);
	_queueVertices.push_back(vertices[1]);
	_queueVertices.push_back(vertices[2]);
	_queueVertices.push_back(vertices[3]);
	_queueVertices.push_back(vertices[4]);
	_queueVertices.push_back(vertices[5]);
}

void xRender::DrawQueue()
{
	// set viewport
	glEnable(GL_SCISSOR_TEST);
    //glScissor(_viewPortX, _height - _viewPortHeight, _viewPortWidth, _height - _viewPortY);
	//glViewport(0, 0, _width, _height);
	xPoint viewPortPos  = RotatePoint(xPoint(_viewPortX, _viewPortY), xPoint(_viewPortWidth, _viewPortHeight));
	xPoint viewPortSize = RotateSize(xPoint(_viewPortWidth, _viewPortHeight));
	glViewport(viewPortPos.x, viewPortPos.y, viewPortSize.x, viewPortSize.y);
	glScissor(viewPortPos.x, viewPortPos.y, viewPortSize.x, viewPortSize.y);
	// set matrix
	glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    //glOrthof(0.0, _width, _height, 0.0, -1.0, 1.0);
#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
	glOrthof(viewPortPos.x, viewPortSize.x, viewPortSize.y, viewPortPos.y, -1.0, 1.0);
#else
	glOrtho(viewPortPos.x, viewPortSize.x, viewPortSize.y, viewPortPos.y, -1.0, 1.0);
#endif
    glMatrixMode(GL_MODELVIEW);
	glLoadMatrixf(_screenRotateMatrix);
	// disable z-buffer
	glDisable(GL_DEPTH_TEST);
	// disable lighting
	glDisable(GL_LIGHTING);
	// disable fog
	glDisable(GL_FOG);
	// get colors from vertex
	glEnable(GL_COLOR_MATERIAL);
	// disable culling
	glDisable(GL_CULL_FACE);
	// disable texture filtering
	glActiveTexture(GL_TEXTURE0);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glMatrixMode(GL_TEXTURE);
	glLoadIdentity();
	//
	if(_queueVertices.size() > 0)
	{
		xRender::Instance()->AddDIP();
		// set pointer to vertices
		glVertexPointer(2, GL_FLOAT, sizeof(xAtlasVertex), &_queueVertices[0].x);
		glEnableClientState(GL_VERTEX_ARRAY);
		// set pointer to texture coords
		glTexCoordPointer(2, GL_FLOAT, sizeof(xAtlasVertex), &_queueVertices[0].tu);
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		// set pointer to colors
		glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(xAtlasVertex), &_queueVertices[0].red);
		glEnableClientState(GL_COLOR_ARRAY);
		// disable normals
		glDisableClientState(GL_NORMAL_ARRAY);
		// bind texture
		glActiveTexture(GL_TEXTURE0);
		glBindTexture(GL_TEXTURE_2D, _lastAtlas->GetTexture()->GetTextureID(0));
		glEnable(GL_TEXTURE_2D);
		glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE);
		glTexEnvi(GL_TEXTURE_ENV, GL_SRC0_ALPHA, GL_PREVIOUS);
		glTexEnvi(GL_TEXTURE_ENV, GL_SRC1_ALPHA, GL_TEXTURE);
		glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_ALPHA, GL_SRC_ALPHA);
		glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND1_ALPHA, GL_SRC_ALPHA);
		glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_ALPHA, GL_MODULATE);
		glTexEnvi(GL_TEXTURE_ENV, GL_SRC0_RGB, GL_PREVIOUS);
		glTexEnvi(GL_TEXTURE_ENV, GL_SRC1_RGB, GL_TEXTURE);
		glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_RGB, GL_SRC_COLOR);
		glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND1_RGB, GL_SRC_COLOR);
		glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_MODULATE);
		//
		glActiveTexture(GL_TEXTURE1);
		glDisable(GL_TEXTURE_2D);
		// set blend mode
		glEnable(GL_BLEND);
		switch(_globalBlend)
		{
			case 1: // disable
			{
				glDisable(GL_BLEND);
				glDisable(GL_ALPHA_TEST);
			}
			break;
			case 2: // mesked
			{
				glDisable(GL_BLEND);
				glEnable(GL_ALPHA_TEST);
				glAlphaFunc(GL_GREATER, 0.0f);
			}
			break;
			case 3:  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); break; // alpha
			case 4:  glBlendFunc(GL_SRC_ALPHA, GL_ONE);                 break; // light
			case 5:  glBlendFunc(GL_ZERO, GL_ONE_MINUS_SRC_ALPHA);      break; // shader
			default: glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		}
		// draw rect
		glDrawArrays(GL_TRIANGLES, 0, _queueVertices.size());
		glDisable(GL_BLEND);
		glDisable(GL_ALPHA_TEST);
		_queueVertices.clear();
	}
}

xVector xRender::GetColor()
{
	return xVector(_red, _green, _blue);
}

void xRender::DrawRect(int x, int y, int width, int height, bool solid)
{
	// prepare 2D rendering
	Prepare2D();
	if(solid)
	{
		// rect arrays
		const GLfloat rectVertices[] = { x, y, x + width, y,
										 x, y + height, x + width, y + height };
		const GLubyte rectColors[]   = { _red, _green, _blue, 255,
										 _red, _green, _blue, 255,
										 _red, _green, _blue, 255,
										 _red, _green, _blue, 255 };
		// set pointer to vertices
		glVertexPointer(2, GL_FLOAT, 0, rectVertices);
		glEnableClientState(GL_VERTEX_ARRAY);
		// set pointer to colors
		glColorPointer(4, GL_UNSIGNED_BYTE, 0, rectColors);
		glEnableClientState(GL_COLOR_ARRAY);
		// disable texture coords
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
		// disable texture
		glActiveTexture(GL_TEXTURE0);
		glDisable(GL_TEXTURE_2D);
		// draw rect
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	}
	else
	{
		// rect arrays
		const GLfloat rectVertices[] = { x, y, x + width, y,
										 x + width, y, x + width, y + height,
										 x + width, y + height, x, y + height,
										 x, y + height, x, y};
		const GLubyte rectColors[]   = { _red, _green, _blue, 255,
										 _red, _green, _blue, 255,
										 _red, _green, _blue, 255,
										 _red, _green, _blue, 255,
										 _red, _green, _blue, 255,
										 _red, _green, _blue, 255,
										 _red, _green, _blue, 255,
										 _red, _green, _blue, 255 };
		// set pointer to vertices
		glVertexPointer(2, GL_FLOAT, 0, rectVertices);
		glEnableClientState(GL_VERTEX_ARRAY);
		// set pointer to colors
		glColorPointer(4, GL_UNSIGNED_BYTE, 0, rectColors);
		glEnableClientState(GL_COLOR_ARRAY);
		// disable texture coords
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
		// disable texture
		glActiveTexture(GL_TEXTURE0);
		glDisable(GL_TEXTURE_2D);
		// draw rect
		glDrawArrays(GL_LINES, 0, 8);
	}
}

void xRender::DrawOval(int x, int y, int width, int height, bool solid)
{
	const int segments = 36;
	// prepare 2D rendering
	Prepare2D();
	if(solid)
	{
		// craete arrays for vertex data
		GLfloat * rectVertices = (GLfloat*)malloc(segments * 3 * 2 * sizeof(GLfloat));
		GLubyte * rectColors   = (GLubyte*)malloc(segments * 3 * 4 * sizeof(GLubyte));
		if(!rectVertices || !rectColors)
		{
			printf("ERROR(%s:%i): Unble to allocate vertex buffer for 2D primitive rendering.\n", __FILE__, __LINE__);
			return;
		}
		float segmentAngle = 3.1415f * 2.0f / (float)segments;
		for(int i = 0; i < segments; i++)
		{
			float sx = cos((float)(i + 0) * segmentAngle) * (width  / 2);
			float sy = sin((float)(i + 0) * segmentAngle) * (height / 2);
			float dx = cos((float)(i + 1) * segmentAngle) * (width  / 2);
			float dy = sin((float)(i + 1) * segmentAngle) * (height / 2);
			rectVertices[i * 6 + 0] = x + sx + width  / 2;
			rectVertices[i * 6 + 1] = y + sy + height / 2;
			rectVertices[i * 6 + 2] = x + dx + width  / 2;
			rectVertices[i * 6 + 3] = y + dy + height / 2;
			rectVertices[i * 6 + 4] = x + width  / 2;
			rectVertices[i * 6 + 5] = y + height / 2;
			rectColors[i * 12 + 0]  = _red;
			rectColors[i * 12 + 1]  = _green;
			rectColors[i * 12 + 2]  = _blue;
			rectColors[i * 12 + 3]  = 255;
			rectColors[i * 12 + 4]  = _red;
			rectColors[i * 12 + 5]  = _green;
			rectColors[i * 12 + 6]  = _blue;
			rectColors[i * 12 + 7]  = 255;
			rectColors[i * 12 + 8]  = _red;
			rectColors[i * 12 + 9]  = _green;
			rectColors[i * 12 + 10] = _blue;
			rectColors[i * 12 + 11] = 255;
		}
		// set pointer to vertices
		glVertexPointer(2, GL_FLOAT, 0, rectVertices);
		glEnableClientState(GL_VERTEX_ARRAY);
		// set pointer to colors
		glColorPointer(4, GL_UNSIGNED_BYTE, 0, rectColors);
		glEnableClientState(GL_COLOR_ARRAY);
		// disable texture coords
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
		// disable texture
		glActiveTexture(GL_TEXTURE0);
		glDisable(GL_TEXTURE_2D);
		// draw rect
		glDrawArrays(GL_TRIANGLES, 0, segments * 3);
		// delete arrays
		free(rectVertices);
		free(rectColors);
	}
	else
	{
		// craete arrays for vertex data
		GLfloat * rectVertices = (GLfloat*)malloc(segments * 2 * 2 * sizeof(GLfloat));
		GLubyte * rectColors   = (GLubyte*)malloc(segments * 2 * 4 * sizeof(GLubyte));
		if(!rectVertices || !rectColors)
		{
			printf("ERROR(%s:%i): Unble to allocate vertex buffer for 2D primitive rendering.\n", __FILE__, __LINE__);
			return;
		}
		float segmentAngle     = 3.1415f * 2.0f / (float)segments;
		for(int i = 0; i < segments; i++)
		{
			float sx = cos((float)(i + 0) * segmentAngle) * (width  / 2);
			float sy = sin((float)(i + 0) * segmentAngle) * (height / 2);
			float dx = cos((float)(i + 1) * segmentAngle) * (width  / 2);
			float dy = sin((float)(i + 1) * segmentAngle) * (height / 2);
			rectVertices[i * 4 + 0] = x + sx + width  / 2;
			rectVertices[i * 4 + 1] = y + sy + height / 2;
			rectVertices[i * 4 + 2] = x + dx + width  / 2;
			rectVertices[i * 4 + 3] = y + dy + height / 2;
			rectColors[i * 8 + 0]   = _red;
			rectColors[i * 8 + 1]   = _green;
			rectColors[i * 8 + 2]   = _blue;
			rectColors[i * 8 + 3]   = 255;
			rectColors[i * 8 + 4]   = _red;
			rectColors[i * 8 + 5]   = _green;
			rectColors[i * 8 + 6]   = _blue;
			rectColors[i * 8 + 7]   = 255;
		}
		// set pointer to vertices
		glVertexPointer(2, GL_FLOAT, 0, rectVertices);
		glEnableClientState(GL_VERTEX_ARRAY);
		// set pointer to colors
		glColorPointer(4, GL_UNSIGNED_BYTE, 0, rectColors);
		glEnableClientState(GL_COLOR_ARRAY);
		// disable texture coords
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
		// disable texture
		glActiveTexture(GL_TEXTURE0);
		glDisable(GL_TEXTURE_2D);
		// draw rect
		glDrawArrays(GL_LINES, 0, segments * 2);
		// delete arrays
		free(rectVertices);
		free(rectColors);
	}
}

void xRender::DrawPoint(int x, int y)
{
	// prepare 2D rendering
	Prepare2D();
	// arrays for point
	const GLfloat pointVertex[] = { x, y };
	const GLubyte pointColor[]  = { _red, _green, _blue, 255 };
	// set pointer to vertices
	glVertexPointer(2, GL_FLOAT, 0, pointVertex);
	glEnableClientState(GL_VERTEX_ARRAY);
	// set pointer to colors
	glColorPointer(4, GL_UNSIGNED_BYTE, 0, pointColor);
	glEnableClientState(GL_COLOR_ARRAY);
	// disable texture coords
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	// disable texture
	glActiveTexture(GL_TEXTURE0);
	glDisable(GL_TEXTURE_2D);
	// draw rect
	glDrawArrays(GL_POINTS, 0, 1);
}

void xRender::LockBB()
{
	if(_bbPixels != NULL) return;
	_bbPixels = (GLuint*)malloc(_width * _height * 4);
	glReadPixels(0, 0, _width, _height, GL_RGBA, GL_UNSIGNED_BYTE, _bbPixels);
}

void xRender::UnlockBB()
{
	if(_bbPixels == NULL) return;
	free(_bbPixels);
	_bbPixels = NULL;
}

GLuint xRender::ReadPixelBB(int x, int y)
{
	if(x < 0 || y < 0 || x >= _width || y >= _height) return 0;
	bool locked = true;
	if(_bbPixels != NULL)
	{
		LockBB();
		locked = false;
	}
	GLuint color = _bbPixels[y * _width + x];
	if(!locked) UnlockBB();
	return color;
}

void xRender::WritePixelBB(int x, int y, GLuint color)
{
	if(x < 0 || y < 0 || x >= _width || y >= _height) return;
	bool locked = true;
	if(_bbPixels != NULL)
	{
		LockBB();
		locked = false;
	}
	_bbPixels[y * _width + x] = color;
	if(!locked) UnlockBB();
}

void xRender::SetBlend(int mode)
{
	glEnable(GL_BLEND);
	glDepthMask(GL_FALSE);
	if(mode == 1)
	{
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	}
	else if(mode == 2)
	{
		glBlendFunc(GL_DST_COLOR, GL_ZERO);
	}
	else if(mode == 3)
	{
		glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	}
}

void xRender::ResetTextureLayers()
{
	for(int i = 0; i < xRender::Instance()->GetMaxTextureUnits(); i++)
	{
		glActiveTexture(GL_TEXTURE0 + i);
		glDisable(GL_TEXTURE_2D);
	}
	_textureLayer = 0;
}

void xRender::SetTexture(xTexture * texture, int frame)
{
	if(texture != NULL)
	{
		// bind texture
		glActiveTexture(GL_TEXTURE0 + _textureLayer);
		glEnable(GL_TEXTURE_2D);
		glBindTexture(GL_TEXTURE_2D, texture->GetTextureID(frame));
#if !TARGET_OS_EMBEDDED && !TARGET_IPHONE_SIMULATOR
		if(texture->GetFlags() & 64)
		{
			glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
			glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
			glEnable(GL_TEXTURE_GEN_S);
			glEnable(GL_TEXTURE_GEN_T);
		}
		else
		{
			glDisable(GL_TEXTURE_GEN_S);
			glDisable(GL_TEXTURE_GEN_T);
		}
#endif
		// set texture matrix
#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
		texture->SetMatrix(_textureLayer);
#else
		static float * sphereMapMatrix = NULL;
		if(sphereMapMatrix == NULL)
		{
			sphereMapMatrix = new float[16];
			for(int i = 0; i < 16; i++) sphereMapMatrix[i] = 0.0f;
			sphereMapMatrix[0]  =  1.0f;
			sphereMapMatrix[5]  = -1.0f;
			sphereMapMatrix[10] =  1.0f;
			sphereMapMatrix[12] =  0.0f;
			sphereMapMatrix[13] =  1.0f;
			sphereMapMatrix[14] =  0.0f;
			sphereMapMatrix[15] =  1.0f;
		}
		if(texture->GetFlags() & 64)
		{
			glMatrixMode(GL_TEXTURE);
			glLoadMatrixf(sphereMapMatrix);
		}
		else
		{
			texture->SetMatrix(_textureLayer);
		}
#endif
		//
		// set filtering
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, (texture->GetFlags() & 8 ? GL_LINEAR_MIPMAP_LINEAR : GL_LINEAR));
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, (texture->GetFlags() & 8 ? GL_LINEAR_MIPMAP_LINEAR : GL_LINEAR));
		// set texture clamping
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, (texture->GetFlags() & 16 ? GL_CLAMP_TO_EDGE : GL_REPEAT));
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, (texture->GetFlags() & 32 ? GL_CLAMP_TO_EDGE : GL_REPEAT));
		// set blending params
		glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE);
		glTexEnvi(GL_TEXTURE_ENV, GL_SRC0_ALPHA, GL_PREVIOUS);
		glTexEnvi(GL_TEXTURE_ENV, GL_SRC1_ALPHA, GL_TEXTURE);
		glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_ALPHA, GL_SRC_ALPHA);
		glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND1_ALPHA, GL_SRC_ALPHA);
		glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_ALPHA, (texture->GetFlags() & 2 || texture->GetFlags() & 4) ? GL_MODULATE : GL_REPLACE);
		glTexEnvi(GL_TEXTURE_ENV, GL_SRC0_RGB, GL_PREVIOUS);
		glTexEnvi(GL_TEXTURE_ENV, GL_SRC1_RGB, GL_TEXTURE);
		glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_RGB, GL_SRC_COLOR);
		glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND1_RGB, GL_SRC_COLOR);
		switch(texture->GetBlendMode())
		{
			case 1:
				glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_INTERPOLATE); // blend by texture alpha
				glTexEnvi(GL_TEXTURE_ENV, GL_SRC2_RGB, GL_TEXTURE);
				glTexEnvi(GL_TEXTURE_ENV, GL_SRC2_ALPHA, GL_TEXTURE);
				glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND2_RGB, GL_ONE_MINUS_SRC_ALPHA);
				break;
			case 2:
				glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_MODULATE); // modulate
				break;
			case 3:
				glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_ADD); // additive
				break;
			case 4:
				glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_DOT3_RGB); // dot3 bump-mapping
				break;
			case 5:
				glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_MODULATE); // GL_MODULATE2X
				break;
			default:
				glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_REPLACE); // dont blend
		}
		// increase layer
		_textureLayer++;
	}
}

void xRender::AddEntity(xEntity * entity)
{
	_mainEntityGroup.push_back(entity);
}

void xRender::DeleteEntity(xEntity * entity)
{
	std::vector<xEntity*>::iterator i = std::find(_mainEntityGroup.begin(), _mainEntityGroup.end(), entity);
	if(i == _mainEntityGroup.end()) return;
	_mainEntityGroup.erase(i);
}

void xRender::AddMD2Mesh(xEntity * entity)
{
	_md2Group.push_back(entity);
}

void xRender::DeleteMD2Mesh(xEntity * entity)
{
	std::vector<xEntity*>::iterator i = std::find(_md2Group.begin(), _md2Group.end(), entity);
	if(i == _md2Group.end()) return;
	_md2Group.erase(i);
}

std::vector<xEntity*> * xRender::GetMD2Array()
{
	return &_md2Group;
}

void xRender::AddCamera(xCamera * camera)
{
	_camerasGroup.push_back(camera);
}

void xRender::DeleteCamera(xCamera * camera)
{
	std::vector<xCamera*>::iterator i = std::find(_camerasGroup.begin(), _camerasGroup.end(), camera);
	if(i == _camerasGroup.end()) return;
	_camerasGroup.erase(i);
}

void xRender::AddAnimated(xBone * bone)
{
	_animatedGroup.push_back(bone);
}

void xRender::DeleteAnimated(xBone * bone)
{
	std::vector<xBone*>::iterator i = std::find(_animatedGroup.begin(), _animatedGroup.end(), bone);
	if(i == _animatedGroup.end()) return;
	_animatedGroup.erase(i);
}

std::vector<xBone*> * xRender::GetAnimatedArray()
{
	return &_animatedGroup;
}

void xRender::AddLight(xLight * light)
{
	for(int i = 0; i < _maxLights; i++)
	{
		if(_lightsGroup[i] == NULL)
		{
			_lightsGroup[i] = light;
			_lightsGroup[i]->SetNumber(i);
			return;
		}
	}
}

void xRender::DeleteLight(xLight * light)
{
	for(int i = 0; i < _maxLights; i++)
	{
		if(_lightsGroup[i] == light) _lightsGroup[i] = NULL;
	}
}

void xRender::ResetLights()
{
	for(int i = 0; i < _maxLights; i++)
	{
		if(_lightsGroup[i] != NULL) _lightsGroup[i]->SetLight();
	}
}

std::vector<xEntity*> * xRender::GetEntitiesArray()
{
	return &_mainEntityGroup;
}

std::vector<xCamera*> * xRender::GetCamerasArray()
{
	return &_camerasGroup;
}

void xRender::AlphaSort(int lo, int hi)
{
	if(lo < hi)
	{
		int i = lo;
		int j = hi;
		TransprentPair x = _transparentGroup[(lo + hi) / 2];
		do
		{
	        while((_transparentGroup[i]).first > x.first) i++;
			while((_transparentGroup[j]).first < x.first) j--;
			if(i <= j)
			{
				TransprentPair tempPair = _transparentGroup[i];
				_transparentGroup[i]    = _transparentGroup[j];
				_transparentGroup[j]    = tempPair;
				i++;
				j--;
			}
		}
		while (i <= j);
	    if(lo < j)  AlphaSort(lo, j);
	    if(i  < hi) AlphaSort(i,  hi);
	}
}

void xRender::AddTransparent(xEntity * entity)
{
	TransprentPair newPair;
	if(_activeCamera != NULL)
	{
		newPair.first = entity->GetPosition(true).Distance(((xEntity*)_activeCamera)->GetPosition(true));
		//xBox bbox = entity->GetWorldTransform() * entity->GetBoundingBox();
		//newPair.first = bbox.Centre().Distance(((xEntity*)_activeCamera)->GetPosition(true));
	}
	else
	{
		newPair.first = entity->GetPosition(true).Length();
	}
	newPair.second = entity;
	_transparentGroup.push_back(newPair);
}

void xRender::RenderTransparent()
{
	AlphaSort(0, _transparentGroup.size() - 1);
	_tansprentStage = true;
	for(std::vector<TransprentPair>::iterator i = _transparentGroup.begin(); i != _transparentGroup.end(); i++)
	{
		i->second->Draw();
	}
	_tansprentStage = false;
	_transparentGroup.clear();
}

void xRender::RenderPreOrder()
{
	glDisable(GL_DEPTH_TEST);
	_orderedStage = true;
	for(std::vector<OrderedPair>::iterator i = _preOrderGroup.begin(); i != _preOrderGroup.end(); i++)
	{
		i->second->Draw();
	}
	_orderedStage = false;
	glEnable(GL_DEPTH_TEST);
}

void xRender::RenderPostOrder()
{
	glDisable(GL_DEPTH_TEST);
	_orderedStage = true;
	for(std::vector<OrderedPair>::iterator i = _postOrderGroup.begin(); i != _postOrderGroup.end(); i++)
	{
		i->second->Draw();
	}
	_orderedStage = false;
	glEnable(GL_DEPTH_TEST);
}

bool xRender::OrderedStage()
{
	return _orderedStage;
}

void xRender::DeleteOrdered(xEntity * entity)
{
	for(std::vector<OrderedPair>::iterator i = _preOrderGroup.begin(); i != _preOrderGroup.end(); i++)
	{
		if(i->second == entity)
		{
			_preOrderGroup.erase(i);
			return;
		}
	}
	for(std::vector<OrderedPair>::iterator i = _postOrderGroup.begin(); i != _postOrderGroup.end(); i++)
	{
		if(i->second == entity)
		{
			_postOrderGroup.erase(i);
			return;
		}
	}
}

void xRender::SetOrderedEntity(xEntity * entity)
{
	DeleteOrdered(entity);
	if(entity->GetOrder() > 0)
	{
		OrderedPair newPair;
		newPair.first  = entity->GetOrder();
		newPair.second = entity;
		_preOrderGroup.push_back(newPair);
		int i = _preOrderGroup.size() - 1;
		while(i > 0 && _preOrderGroup[i].first > _preOrderGroup[i - 1].first)
		{
			std::swap(_preOrderGroup[i], _preOrderGroup[i - 1]);
			--i;
		}
	}
	else if(entity->GetOrder() < 0)
	{
		OrderedPair newPair;
		newPair.first  = entity->GetOrder();
		newPair.second = entity;
		_postOrderGroup.push_back(newPair);
		int i = _postOrderGroup.size() - 1;
		while(i > 0 && _postOrderGroup[i].first > _postOrderGroup[i - 1].first)
		{
			std::swap(_postOrderGroup[i], _postOrderGroup[i - 1]);
			--i;
		}
	}
}

void xRender::ResetPicks()
{
	_pickedPosition = xVector();
	_pickedNormal   = xVector(0.0f, 0.0f, 1.0f);
	_pickDistance   = FLT_MAX;
	_pickTime       = 1.0f;
	_pickedTriangle = 0;
	_pickedSurfce   = NULL;
	_pickedEntity   = NULL;
}

void xRender::SetPickPosition(xVector position)
{
	_pickedPosition = position;
}

xVector xRender::GetPickPosition()
{
	return _pickedPosition;
}

void xRender::SetPickNormal(xVector position)
{
	_pickedNormal = position;
}

xVector xRender::GetPickNormal()
{
	return _pickedNormal;
}

void xRender::SetPickDistance(float value)
{
	_pickDistance = value;
}

float xRender::GetPickDistance()
{
	return _pickDistance;
}

void xRender::SetPickTime(float value)
{
	_pickTime = value;
}

float xRender::GetPickTime()
{
	return _pickTime;
}

void xRender::SetPickTriangle(int value)
{
	_pickedTriangle = value;
}

int xRender::GetPickTriangle()
{
	return _pickedTriangle;
}

void xRender::SetPickSurface(xSurface * surface)
{
	_pickedSurfce = surface;
}

xSurface * xRender::GetPickSurface()
{
	return _pickedSurfce;
}

void xRender::SetPickEntity(xEntity * entity)
{
	_pickedEntity = entity;
}

xEntity * xRender::GetPickEntity()
{
	return _pickedEntity;
}

void xRender::DeletePicked(xEntity * entity)
{
	std::vector<xEntity*>::iterator itr = std::find(_pickedGroup.begin(), _pickedGroup.end(), entity);
	if(itr == _pickedGroup.end()) return;
	_pickedGroup.erase(itr);
}

void xRender::SetPickedEntity(xEntity * entity)
{
	if(entity->GetPickMode() == 0)
	{
		DeletePicked(entity);
		return;
	}
	if(std::find(_pickedGroup.begin(), _pickedGroup.end(), entity) != _pickedGroup.end()) return;
	_pickedGroup.push_back(entity);
}

xEntity * xRender::LinePick(xVector position, xVector direction, float distance)
{
	ResetPicks();
	if(distance == 0.0f) distance = position.Distance(position + direction);
	direction.Normalize();
	// test pre ordered objects
	for(int i = _postOrderGroup.size() - 1; i >= 0; i--)
	{
		if(_postOrderGroup[i].second->GetPickMode() > 0) _postOrderGroup[i].second->LinePick(position, direction);
		if(_pickedEntity != NULL) return _pickedEntity;
	}
	// test normal ordered objects
	for(int i = 0; i < _pickedGroup.size(); i++)
	{
		if(_pickedGroup[i]->GetPickMode() > 0 && _pickedGroup[i]->GetOrder() == 0) _pickedGroup[i]->LinePick(position, direction);
	}
	if(distance < _pickDistance) ResetPicks();
	if(_pickedEntity != NULL) return _pickedEntity;
	// test post ordered objects
	for(int i = _preOrderGroup.size() - 1; i >= 0; i--)
	{
		if(_preOrderGroup[i].second->GetPickMode() > 0) _preOrderGroup[i].second->LinePick(position, direction);
		if(_pickedEntity != NULL) return _pickedEntity;
	}
	return _pickedEntity;
}

void xRender::SetGlobalBlend(int blend)
{
	_globalBlend = blend;
}

void xRender::SetGlobalColor(int red, int green, int blue)
{
	_globalRed   = (float)red   / 255.0f;
	_globalGreen = (float)green / 255.0f;
	_globalBlue  = (float)blue  / 255.0f;
}

void xRender::SetGlobalAlpha(float alpha)
{
	_globalAlpha = alpha;
}

void xRender::SetGlobalHandle(int x, int y)
{
	_globalOffsetx = x;
	_globalOffsety = y;
}

void xRender::SetGlobalRotate(float angle)
{
	_globalAngle = angle;
}

void xRender::SetGlobalScale(float x, float y)
{
	_globalScalex = x;
	_globalScaley = y;
}

int xRender::GetGlobalBlend()
{
	return _globalBlend;
}

xVector xRender::GetGlobalColor()
{
	return xVector(_globalRed, _globalGreen, _globalBlue);
}

float xRender::GetGlobalAlpha()
{
	return _globalAlpha;
}

xVector xRender::GetGlobalHandle()
{
	return xVector(_globalOffsetx, _globalOffsety, 0.0f);
}

float xRender::GetGlobalRotate()
{
	return _globalAngle;
}

xVector xRender::GetGlobalScale()
{
	return xVector(_globalScalex, _globalScaley, 0.0f);
}

IWorld2D * xRender::GetPhysWorld2D()
{
	return _physWorld2D;
}

void xRender::SetAutoDeletePixels(bool flag)
{
	_autoDeletePixels = flag;
}

bool xRender::GetAutoDeletePixels()
{
	return _autoDeletePixels;
}