//
//  iXors3DAppDelegate.m
//  iXors3D
//
//  Created by Knightmare on 01.09.09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "iXors3DAppDelegate.h"
#import <vector>
#import <algorithm>
#import <string>

uint timeGetTime();

float Rnd(float fMin, float fMax)
{
	float fRandNum = (float)rand () / RAND_MAX;
	return fMin + (fMax - fMin) * fRandNum;
}

BOOL InButton(int x, int y, int cx, int cy, int radii)
{
	x -= cx;
	y -= cy;
	return (fabs(sqrtf(x * x + y * y)) <= radii ? true : false);
}

@implementation iXors3DAppDelegate

@synthesize window;
@synthesize animationTimer;
@synthesize animationInterval;

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    [application setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
	xGraphics3D(1, 0, window);
	xEnableOrientations(DEVICE_LANDSCAPE_LEFT | DEVICE_LANDSCAPE_RIGHT);
	xEnableMultiTouch();
	// draw splash
	image = xLoadImage("media/iX3d.png");
	xMidHandle(image);
	xCls();
	xDrawImage(image, xGraphicsWidth() / 2, xGraphicsHeight() / 2, 0);
	xFlip();
	// controll image
	control = xLoadImage("media/control.png");
	// create camera
	camera = xCreateCamera(0);
	xPositionEntity(camera, 0, 0, 10, false);
	xCameraClsColor(camera, 0, 105, 105);
	// create light
	int light = xCreateLight(0, 0);
	xRotateEntity(light, -45, 0, 0, false);
	entity = xLoadAnimMesh("media/kuznec.b3d", 0);
	xRotateEntity(entity, 0, 180, 0, false);
	xAnimate(entity, 1, 1, 0, 0);
	//
	int font = xLoadFont("media/Tahoma22");
	xSetFont(font);
	image = xLoadImage("media/ctest.jpg");
	xScaleImage(image, 0.5f, 0.5f);
	/*
	int terrain = xLoadTerrain("terrain.png", 0);
	xScaleEntity(terrain, 1, 50, 1, 0);
	int tex = xLoadTexture("MossyGround.png", 1 + 8);
	xEntityTexture(terrain, tex, 0, 0);
	*/
	/*
	int t1 = xLoadTexture("media/iX3d.png", 9);
	int t2 = xLoadTexture("media/iX3d.pvr", 11);
	xScaleTexture(t1, 0.5f, 1.0f);
	int c = xCreateCube(0);
	xPositionEntity(c, -2, 0, 0, false);
	xEntityTexture(c, t1, 0, 0);
	c = xCreateCube(0);
	xPositionEntity(c, 2, 0, 0, false);
	xEntityTexture(c, t2, 0, 0);
	xRotateTexture(t2, 45.0f);
	xFreeTexture(t1);
	xFreeTexture(t2);
	//
	int level = xLoadAnimMesh("media/level1.b3d", nil);
	int detail = xLoadTexture("media/detail.pvr", 1);
	xScaleTexture(detail,0.125,0.125);
	
	int outerground = xFindChild(level, "outerground");
	int outergroundtex = xLoadTexture("media/outerground.pvr", 8);
	xEntityTexture(outerground, outergroundtex, 0, 1);
	xEntityTexture(outerground, detail, 0, 0);
	
	
	int fence = xFindChild(level, "fence");
	int fencetex = xLoadTexture("media/fence.png", 8);
	xEntityTexture(fence, fencetex, 0, 0);
	
	int road = xFindChild(level, "road");
	int roadtex = xLoadTexture("media/road.png", 8);
	xEntityTexture(road, roadtex, 0, 0);
	
	int outertrees = xFindChild(level, "outertrees");
	int outertreestex = xLoadTexture("media/pines2.png", 10);
	xEntityTexture(outertrees, outertreestex, 0, 0);
	xEntityFX(outertrees, 1);
	
	int leaves = xFindChild(level, "leaves1");
	xEntityFX(leaves,1);
	int leavestex = xLoadTexture("media/leaves.pvr", 2);
	xEntityTexture(leaves, leavestex, 0, 0);
	
	leaves = xFindChild(level, "leaves2");
	xEntityFX(leaves,1);
	xEntityTexture(leaves, leavestex, 0, 0);
	
	leaves = xFindChild(level, "leaves3");
	xEntityFX(leaves,1);
	xEntityTexture(leaves, leavestex, 0, 0);
	
	leaves = xFindChild(level, "leaves4");
	xEntityFX(leaves,1);
	xEntityTexture(leaves, leavestex, 0, 0);
	
	leaves = xFindChild(level, "leaves5");
	xEntityFX(leaves,1);
	xEntityTexture(leaves, leavestex, 0, 0);
	
	
	int barks = xFindChild(level, "barks");
	int barkstex = xLoadTexture("media/bark.pvr", 0);
	xEntityTexture(barks, barkstex, 0, 0);
	
	int ground = xFindChild(level, "innerground");
	
	int groundtex = xLoadTexture("media/ground.png", 8);
	xEntityTexture(ground, groundtex, 0, 1);
	xEntityTexture(ground, detail, 0, 0);
	*/
	// start drawing
	animationInterval = 1.0 / 60.0;
	/*
	int cube = xCreateCube(0);
	image = xLoadTexture("media/frost.png", 1 + 4 + 8 + 16 + 32);
	xEntityTexture(cube, image, 0, 0);
	xEntityBlend(cube, BLEND_ADD);
	xTextureBlend(image, TEXBLEND_MULTIPLY);
	xScaleTexture(image, 1.0f / 4.0f, 1.0f / 4.4f);
	xEntityColor(cube, 0, 255, 0);
	int select = xLoadAnimMesh("media/selection.b3d", 0);
	xAnimate(select, 1, 1, 0, 0);
	*/
	//
	printf("Game Center available - %i\n", xIsGCSupported());
	if(xGCAuthenticate())
	{
		printf("Connected to Game Center\n");
		printf("Player: %s (%s)\n", xGetGCPlayerName(), xGetGCPlayerID());
		printf("Player have %i friends:\n", xGetGCFriendsCount());
		for(int i = 0; i < xGetGCFriendsCount(); i++)
		{
			printf("\tFriend #%i: %s (%s)\n", i + 1, xGetGCFriendName(i), xGetGCFriendID(i));
		}
	}
	else
	{
		printf("Unable to connect to Game Center\n");
	}
	[self startAnimation];
}

- (void)drawView
{
	int radii = 24;
	int fcx   = 70 + 190;
	int fcy   = 28 + 190;
	int bcx   = 70 + 190;
	int bcy   = 98 + 190;
	int lcx   = 35 + 190;
	int lcy   = 62 + 190;
	int rcx   = 104 + 190;
	int rcy   = 62 + 190;
	int tlcx  = 182 + 190;
	int tlcy  = 62 + 190;
	int trcx  = 252 + 190;
	int trcy  = 62 + 190;
	int tucx  = 218 + 190;
	int tucy  = 28 + 190;
	int tdcx  = 218 + 190;
	int tdcy  = 98 + 190;
	int phase = 0;
	static float p = 0;
	//xPositionTexture(image, p, p);
	p-=0.001;
	for(int i = 0; i < xCountTouches(); i++)
	{
		//printf("Touch #%i: (%ix%i)->(%ix%i), phase: %i\n", i, xTouchPrevX(i), xTouchPrevY(i), xTouchX(i), xTouchY(i), xTouchPhase(i));
		phase = xTouchPhase(i);
		if(xTouchPhase(i) > 0)
		{
			//xCameraPick(camera, xTouchX(i), xTouchY(i));
			// forward
			if(InButton(xTouchX(i), xTouchY(i), fcx, fcy, radii)) xMoveEntity(camera, 0, 0, -0.1, false);
			// backward
			if(InButton(xTouchX(i), xTouchY(i), bcx, bcy, radii)) xMoveEntity(camera, 0, 0, 0.1, false);
			// left
			if(InButton(xTouchX(i), xTouchY(i), lcx, lcy, radii)) xMoveEntity(camera, -0.1, 0, 0, false);
			// right
			if(InButton(xTouchX(i), xTouchY(i), rcx, rcy, radii)) xMoveEntity(camera, 0.1, 0, 0, false);
			// turn left
			if(InButton(xTouchX(i), xTouchY(i), tlcx, tlcy, radii)) xTurnEntity(camera, 0, -0.1, 0, true);
			// turn right
			if(InButton(xTouchX(i), xTouchY(i), trcx, trcy, radii)) xTurnEntity(camera, 0, 0.1, 0, true);
			// turn up
			if(InButton(xTouchX(i), xTouchY(i), tucx, tucy, radii)) xTurnEntity(camera, 0.1, 0, 0, true);
			// turn down
			if(InButton(xTouchX(i), xTouchY(i), tdcx, tdcy, radii)) xTurnEntity(camera, -0.1, 0, 0, true);
		}
	}
	// render world
	xUpdateWorld(1.0f);
	xRenderWorld(1.0f);
	xDrawImage(control, 190, 190, 0);
	xCameraProject(camera, xEntityX(entity, 1), xEntityX(entity, 1), xEntityX(entity, 1));
	/*
	xDrawImage(image1, 0, 0, 0);
	xDrawImage(image2, 100, 0, 0);
	xDrawImage(image3, 200, 0, 0);
	*/
	xDrawImage(image, 0, 0, 0);
	// draw statistic
	char statisticBuff[512];
	sprintf(statisticBuff, "FPS: %i\nTriangles: %i\nDIP calls: %i\nAnimated: %i\nProjected: %fx%f", xFPSCounter(), xTrisRendered(), xDIPCalls(), xAnimating(entity), xProjectedX(), xProjectedY());
	xText(0, 0, statisticBuff, false, false);
	//xSetGlobalRotate(20);
	//xTextEx(0, 100, 300, "<color=255, 0, 0>red, <color=0, 255, 0>green, <color=0, 0, 255>blue\nsecond line that width more that text area with and it'll break to several lines\nthird line");
    //xSetGlobalRotate(0);
	xFlip();
}

- (void)layoutSubviews
{
    xResetGraphics();
    [self drawView];
}

- (void)startAnimation
{
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval target:self selector:@selector(drawView) userInfo:nil repeats:YES];
}

- (void)stopAnimation
{
    self.animationTimer = nil;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	//animationInterval = 1.0 / 5.0;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	//animationInterval = 1.0 / 60.0;
}

- (void)dealloc
{
	[window release];
	[super dealloc];
}

@end
