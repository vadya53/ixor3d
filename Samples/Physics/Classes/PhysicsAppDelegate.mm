//
//  PhysicsAppDelegate.m
//  Physics
//
//  Created by Knightmare on 07.02.10.
//  Copyright XorsTeam 2010. All rights reserved.
//

#import "PhysicsAppDelegate.h"

// camera entity
int mainCamera = 0;
// ground entity
int ground     = 0;
// control images
int control    = 0;
int fire       = 0;

// checks if button prssed
bool InButton(int x, int y, int cx, int cy, int radii)
{
	x -= cx;
	y -= cy;
	return (fabs(sqrtf(x * x + y * y)) <= radii ? true : false);
}


// shoot sphere to wall
void ShootSphere()
{
	int sphere = xCreateSphere(8, 0);
	xPositionEntity(sphere, xEntityX(mainCamera, true), xEntityY(mainCamera, true), xEntityZ(mainCamera, true), false);
	xTFormNormal(0.0f, 0.0f, -1.0f, mainCamera, 0);
	xEntityAddSphereShape(sphere, 1.0f, 0.0f);
	xEntityApplyCentralImpulse(sphere, xTFormedX() * 100.0f, xTFormedY() * 100.0f, xTFormedZ() * 100.0f);
	xEntityColor(sphere, 120, 0, 0);
}

@implementation PhysicsAppDelegate

@synthesize window;
@synthesize animationTimer;
@synthesize animationInterval;

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    [application setStatusBarHidden:YES animated:YES];
	// initialize engine
	xGraphics3D(1, false, window);
	// create camera
	mainCamera = xCreateCamera(0);
	xPositionEntity(mainCamera, 0.0f, 50.0f, 50.0f, false);
	xRotateEntity(mainCamera, -45.0f, 0.0f, 0.0f, false);
	// create ground
	ground = xCreateCube(0);
	xScaleEntity(ground, 100.0f, 0.1f, 100.0f, false);
	xEntityAddBoxShape(ground, 0.0f, 0.0f, 0.0f, 0.0f);
	int grass = xLoadTexture("media/grass.png", 1 + 8);
	xEntityTexture(ground, grass, 0, 0);
	xFreeTexture(grass);
	// create wall
	int wallTexture = xLoadTexture("media/logo.png", 1 + 8);
	int wallSize = 6;
	for(int y = 0; y < wallSize; y++)
	{
		for(int x = 0; x < wallSize; x++)
		{
			int cube = xCreateCube(0);
			xPositionEntity(cube, (x - wallSize / 2) * 2.0f, 1.1f + y * 2.0f, 0.0f, false);
			xEntityTexture(cube, wallTexture, 0, 0);
			xEntityAddBoxShape(cube, 1.0f, 0.0f, 0.0f, 0.0f);
		}
	}
	// load default font
	xSetFont(xLoadFont("media/Tahoma22"));
	// load control images
	control = xLoadImage("media/control.png");
	fire    = xLoadImage("media/fire.png");
	// launch animation
	animationInterval = 1.0f / 60.0f;
	[self startAnimation];
}

- (void)drawView
{
	// camera controll
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
	for(int i = 0; i < xCountTouches(); i++)
	{
		if(xTouchPhase(i) > 0)
		{
			// forward
			if(InButton(xTouchX(i), xTouchY(i), fcx,  fcy,  radii)) xMoveEntity(mainCamera,  0.0f,  0.0f, -1.0f, false);
			// backward
			if(InButton(xTouchX(i), xTouchY(i), bcx,  bcy,  radii)) xMoveEntity(mainCamera,  0.0f,  0.0f,  1.0f, false);
			// left
			if(InButton(xTouchX(i), xTouchY(i), lcx,  lcy,  radii)) xMoveEntity(mainCamera, -1.0f,  0.0f,  0.0f, false);
			// right 
			if(InButton(xTouchX(i), xTouchY(i), rcx,  rcy,  radii)) xMoveEntity(mainCamera,  1.0f,  0.0f,  0.0f, false);
			// turn left
			if(InButton(xTouchX(i), xTouchY(i), tlcx, tlcy, radii)) xTurnEntity(mainCamera,  0.0f, -1.0f,  0.0f, true);
			// turn right
			if(InButton(xTouchX(i), xTouchY(i), trcx, trcy, radii)) xTurnEntity(mainCamera,  0.0f,  1.0f,  0.0f, true);
			// turn up
			if(InButton(xTouchX(i), xTouchY(i), tucx, tucy, radii)) xTurnEntity(mainCamera,  1.0f,  0.0f,  0.0f, true);
			// turn down
			if(InButton(xTouchX(i), xTouchY(i), tdcx, tdcy, radii)) xTurnEntity(mainCamera, -1.0f,  0.0f,  0.0f, true);
			// fire button
			if(InButton(xTouchX(i), xTouchY(i), 29, 294, 24) && xTouchPhase(i) == TOUCH_BEGAN) ShootSphere();
		}
	}
	// update wold
	xUpdateWorld(1.0f);
	// render world
	xRenderWorld(1.0f);
	// draw controll images
	xDrawImage(control, 190, 190, 0);
	xDrawImage(fire, 5, 270, 0);
	// fps counter
	char buff[256];
	sprintf(buff, "FPS: %i\nTrisRendered: %i", xFPSCounter(), xTrisRendered());
	xText(10, 10, buff, false, false);
	// swap buffers
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
	animationInterval = 1.0 / 5.0;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	animationInterval = 1.0 / 60.0;
}

- (void)dealloc
{
	[window release];
	[super dealloc];
}

@end