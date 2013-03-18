#import <iostream>
#import "xors3d.h"

// for camera mouse look
float CurveValue(float newvalue, float oldvalue, float increments)
{
	if(increments >  1.0f) oldvalue = oldvalue - (oldvalue - newvalue) / increments;
	if(increments <= 1.0f) oldvalue = newvalue; 
	return oldvalue;
}
float mousespeed       = 0.5;
float camerasmoothness = 4.5;
float mxs   = 0.0f;
float mys   = 0.0f;
float camxa = 0.0f;
float camya = 0.0f;

@interface TestApp : NSObject<NSApplicationDelegate>
{
	size_t cube, camera, image;
	NSTimer * timer;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification;

@end

int frames = 0;

@implementation TestApp

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	xAppTitle("Testing application");
	xGraphics3D(800, 600, 32, 0);
	//xGraphics3D(1920, 1080, 32, 1);
	camera = xCreateCamera(0);
	xPositionEntity(camera, 0.0f, 0.0f, 10.0f, false);
	xCameraClsColor(camera, 192, 192, 192);
	//cube = xCreateCube(0);
	//size_t texture = xLoadTexture("media/iX3d.png", 1 + 8);
	//xEntityTexture(cube, texture, 0, 0);
	xSetFont(xLoadFont("media/Tahoma22"));
	size_t m = xLoadMesh("media/kuznec.b3d", 0);
	xEntityPickMode(m, 2);
	image = xLoadImage("media/iX3d.png");
	cube = xCreateSphere(16, 0);
	xEntityFX(cube, 16);
	xEntityAlpha(cube, 0.5f);
	size_t t = xLoadTexture("media/iX3d.png", 1 + 8 + 64);
	xEntityTexture(cube, t, 0, 0);
	//
	//xMoveMouse(xGraphicsWidth() / 2, xGraphicsHeight() / 2);
	timer = [NSTimer scheduledTimerWithTimeInterval:(1.0 / 60.0) target:self selector:@selector(draw) userInfo:nil repeats:YES];
}

- (void)draw
{
	if(xKeyDown(KEY_SPACE)) xMoveMouse(400, 300);
	if(xKeyDown(KEY_ESCAPE)) exit(0);
	// camera control
	if(xKeyDown(KEY_W)) xMoveEntity(camera,  0,  0, -1, false);
	if(xKeyDown(KEY_S)) xMoveEntity(camera,  0,  0,  1, false);
	if(xKeyDown(KEY_A)) xMoveEntity(camera, -1,  0,  0, false);
	if(xKeyDown(KEY_D)) xMoveEntity(camera,  1,  0,  0, false);
	mxs   = CurveValue(xMouseXSpeed() * mousespeed, mxs, camerasmoothness);
	mys   = CurveValue(xMouseYSpeed() * mousespeed, mys, camerasmoothness);
	camxa = fmodf(camxa - mxs, 360.0f);
	camya = camya + mys;
	if(camya < -89.0f) camya = -89.0f;
	if(camya >  89.0f) camya =  89.0f;
	//xMoveMouse(xGraphicsWidth() / 2, xGraphicsHeight() / 2);
	xRotateEntity(camera, -camya, -camxa, 0.0, false);
	//
	xTurnEntity(cube, 0.0f, 1.0f, 0.0f, false);
	xRenderWorld(1.0f);
	xDrawImage(image, 0, 0, 0);
	char buffer[256];
	xCameraProject(camera, xEntityX(cube, true), xEntityY(cube, true), xEntityZ(cube, true));
	if(xMouseDown(MOUSE_LEFT)) xCameraPick(camera, xMouseX(), xMouseY());
	sprintf(buffer, "FPS: %i\nTriangles rendered: %i\nMouse: %ix%i\nPicked: 0x%X", xFPSCounter(), xTrisRendered(), xMouseX(), xMouseY(), (unsigned int)xPickedEntity());
	xText(10, 10, buffer, false, false);
	xLine(xProjectedX() - 5, xProjectedY(), xProjectedX() + 5, xProjectedY());
	xLine(xProjectedX(), xProjectedY() - 5, xProjectedX(), xProjectedY() + 5);
	xFlip();
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	return YES;
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
	xShowWindow();
}

- (void)applicationDidResignActive:(NSNotification *)notification
{
	xHideWindow();
}

@end

int main(int argc, char * const argv[])
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	[[NSApplication sharedApplication] setDelegate: [[TestApp alloc] init]];
	[[NSApplication sharedApplication] run];
	[pool release];
    return 0;
}
