//
//  render.h
//  iXors3D
//
//  Created by Knightmare on 01.09.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ogles.h"
#import "texture.h"
#import <vector>
#import <algorithm>
#import "glview.h"
#import "IWorld.h"
#import "IWorld2D.h"
#import <pthread.h>


#define PI 3.141592653589f

class x2DAtlas;
class xImage;
class xEntity;
class xCamera;
class xLight;
class xBone;
class xSurface;

typedef std::pair<float, xEntity*> TransprentPair;
typedef std::pair<int, xEntity*>   OrderedPair;

struct xPoint
{
	int x, y;
	xPoint()
	{
		x = 0;
		y = 0;
	}
	xPoint(int _x, int _y)
	{
		x = _x;
		y = _y;
	}
};

class xRender
{
private:
	struct xAtlasVertex
	{
		GLfloat x, y, tu, tv;
		GLubyte red, green, blue, alpha;
	};
private:
#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
	xGLView                     * _view;
	EAGLContext                 * _context;
	CAEAGLLayer                 * _layer;
	UIWindow                    * _renderWindow;
#else
	NSView          * _view;
	NSOpenGLContext * _context;
	NSWindow        * _renderWindow;
	std::string       _appTitle;
	bool              _fullScreen;
#endif
	GLint                         _width;
	GLint                         _height;
	GLuint                        _renderBuffer;
	GLuint                        _frameBuffer;
	GLuint                        _depthBuffer;
	GLfloat                       _cred, _cgreen, _cblue;
	GLubyte                       _red, _green, _blue;
	GLuint                      * _bbPixels;
	static xRender              * _instance;
	int                           _maxTextureUnits;
	int                           _maxTextureSize;
	int                           _maxLights;
	int                           _textureLayer;
	xCamera                     * _activeCamera;
	std::vector<xEntity*>         _mainEntityGroup;
	std::vector<xBone*>           _animatedGroup;
	std::vector<TransprentPair>   _transparentGroup;
	std::vector<xCamera*>         _camerasGroup;
	std::vector<xLight*>          _lightsGroup;
	std::vector<xEntity*>         _md2Group;
	bool                          _tansprentStage;
	bool                          _orderedStage;
	std::vector<OrderedPair>      _preOrderGroup;
	std::vector<OrderedPair>      _postOrderGroup;
	float                         _screenRotateMatrix[16];
	float                         _screenRotateMatrix3D[16];
	//picking info
	xVector                       _pickedPosition;
	xVector                       _pickedNormal;
	float                         _pickDistance;
	float                         _pickTime;
	int                           _pickedTriangle;
	xSurface                    * _pickedSurfce;
	xEntity                     * _pickedEntity;
	std::vector<xEntity*>         _pickedGroup;
	int                           _lastTris;
	int                           _tempTris;
	int                           _lastFPS;
	int                           _tempFPS;
	uint                          _lastTime;
	int                           _viewPortX, _viewPortY, _viewPortWidth, _viewPortHeight;
	int                           _dips;
	int                           _windowWidth, _windowHeight;
	int                           _orientationMask;
	pthread_mutex_t               _renderMutex;
	int                           _orientation;
	GLuint                        _activeFB;
	//
	float                         _globalScalex, _globalScaley;
	int                           _globalOffsetx, _globalOffsety;
	float                           _globalAngle;
	float                         _globalRed, _globalGreen, _globalBlue;
	float                         _globalAlpha;
	int                           _globalBlend;
	bool                          _autoDeletePixels;
	// physics
	IWorld                      * _physWorld;
	std::vector<xEntity*>         _physNodes;
	IWorld2D                    * _physWorld2D;
	// atlas queue
	x2DAtlas                    * _lastAtlas;
	std::vector<xAtlasVertex>     _queueVertices;
	// retina support
	float                         _scaleFactor;
private:
	xRender();
	xRender(const xRender & other);
	xRender & operator=(const xRender & other);
	~xRender();
	void AlphaSort(int lo, int hi);
	void DeleteOrdered(xEntity * entity);
	void DeletePicked(xEntity * entity);
	void ComputeMatrices(int orientation);
public:
	static xRender * Instance();
#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
	xGLView * GetView();
	void SetView(xGLView * view);
	bool Initialize(CAEAGLLayer * eaglLayer);
	void SetLayer(CAEAGLLayer * eaglLayer);
	void SetWindow(UIWindow * window);
	UIWindow * GetWindow();
	void SetOrientation(UIDeviceOrientation orientation);
#else
	void SetAppTitle(const char * title);
	const char * GetAppTitle();
	NSView * GetView();
	void SetView(NSView * view);
	bool Initialize(int width, int height, int depth, bool fullscreen, NSView * view);
	void SetWindow(NSWindow * window);
	NSWindow * GetWindow();
	void ShowWindow();
	void HideWindow();
#endif
	void SetScaleFactor(float value);
	float GetScaleFactor();
	void SetOrientationMask(int mask);
	void SetDeviceOrientation(int orientation);
	int GetDeviceOrientation();
	int GetOrientationMask();
	pthread_mutex_t * GetMutex();
	xPoint RotatePoint(const xPoint & point, const xPoint & size);
	xPoint RotateSize(const xPoint & point);
	float * GetScreenRotateMatrix();
	void CreateFrameBuffer();
	void DeleteFrameBuffer();
	void SetFrameBuffer();
	void SetActiveBuffer(GLuint buffer);
	void Cls();
	void Flip();
	void ClsColor(int red, int green, int blue);
	void Color(int red, int green, int blue);
	int GraphicsWidth();
	int GraphicsHeight();
	void DrawLine(int x, int y, int dx, int dy);
	void Prepare2D();
	void DrawRect(int x, int y, int width, int height, bool solid);
	void DrawOval(int x, int y, int width, int height, bool solid);
	void DrawPoint(int x, int y);
	void LockBB();
	void UnlockBB();
	GLuint ReadPixelBB(int x, int y);
	void WritePixelBB(int x, int y, GLuint color);
	void SetBlend(int mode);
	void ResetTextureLayers();
	void SetTexture(xTexture * texture, int frame);
	int GetMaxTextureUnits();
	int GetMaxTextureSize();
	int GetMaxLights();
	void SetActiveCamera(xCamera * camera);
	xCamera * GetActiveCamera();
	void AddEntity(xEntity * entity);
	void DeleteEntity(xEntity * entity);
	void AddCamera(xCamera * camera);
	void DeleteCamera(xCamera * camera);
	std::vector<xEntity*> * GetEntitiesArray();
	std::vector<xCamera*> * GetCamerasArray();
	void AddMD2Mesh(xEntity * entity);
	void DeleteMD2Mesh(xEntity * entity);
	std::vector<xEntity*> * GetMD2Array();
	void SetContext();
	void AddLight(xLight * light);
	void DeleteLight(xLight * light);
	void ResetLights();
	bool TransparentStage();
	void AddTransparent(xEntity * entity);
	void RenderTransparent();
	void RenderPreOrder();
	void RenderPostOrder();
	bool OrderedStage();
	void SetOrderedEntity(xEntity * entity);
	void AddAnimated(xBone * bone);
	void DeleteAnimated(xBone * bone);
	std::vector<xBone*> * GetAnimatedArray();
	void ResetPicks();
	void SetPickPosition(xVector position);
	xVector GetPickPosition();
	void SetPickNormal(xVector position);
	xVector GetPickNormal();
	void SetPickDistance(float value);
	float GetPickDistance();
	void SetPickTime(float value);
	float GetPickTime();
	void SetPickTriangle(int value);
	int GetPickTriangle();
	void SetPickSurface(xSurface * surface);
	xSurface * GetPickSurface();
	void SetPickEntity(xEntity * entity);
	xEntity * GetPickEntity();
	void SetPickedEntity(xEntity * entity);
	xEntity * LinePick(xVector position, xVector direction, float distance);
	xVector GetColor();
	void AddTriangles(int count);
	int GetTrianglesCount();
	int GetFPSCount();
	void SetViewport(int x, int y, int width, int height);
	void AddDIP();
	int GetDIPCount();
	void SetGlobalBlend(int blend);
	void SetGlobalColor(int red, int green, int blue);
	void SetGlobalAlpha(float alpha);
	void SetGlobalHandle(int x, int y);
	void SetGlobalRotate(float angle);
	void SetGlobalScale(float x, float y);
	int GetGlobalBlend();
	xVector GetGlobalColor();
	float GetGlobalAlpha();
	xVector GetGlobalHandle();
	float GetGlobalRotate();
	xVector GetGlobalScale();
	void SetWindowSize(int width, int height);
	int GetWindowWidth();
	int GetWindowHeight();
	void ResetViewports();
	// physics
	IWorld * GetPhysWorld();
	void AddPhysNode(xEntity * entity);
	void DeletePhysNode(xEntity * entity);
	std::vector<xEntity*>::iterator PhysNodesBegin();
	std::vector<xEntity*>::iterator PhysNodesEnd();
	IWorld2D * GetPhysWorld2D();
	// atlas queue
	void AddToQueue(xImage * image, float x, float y, int frame, int rectX, int rectY, int rectWidth, int rectHeight);
	void DrawQueue();
	void SetAutoDeletePixels(bool flag);
	bool GetAutoDeletePixels();
};