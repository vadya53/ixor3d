//
//  xMusicAppDelegate.m
//  xMusic
//
//  Created by Knightmare on 07.02.10.
//  Copyright XorsTeam 2010. All rights reserved.
//

#import "xMusicAppDelegate.h"
#import <vector>
#import <string>

// returns time in milliseconds
uint timeGetTime();

// cube entity
int musicCube       = 0;
int mainCamera      = 0;
int logo            = 0;
int backGround      = 0;
float accelerationX = 0.0f;
float accelerationY = 0.0f;
float accelerationZ = 0.0f;
bool accelerated    = false;
int initialized     = 0;

// covers & songs
struct Song
{
	uint        itemID;
	int         cover;
	std::string artist;
	std::string title;
	int         surface;
	Song(uint _itemID, int _cover, const char * _artist, const char * _title)
	{
		itemID  = _itemID;
		cover   = _cover;
		artist  = _artist;
		title   = _title;
		surface = 0;
	}
};
std::vector<Song> covers;

// current playing sound
int currentSong = -1;

@implementation xMusicAppDelegate

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
	xPositionEntity(mainCamera, 0, 0, 5, false);
	xCameraClsMode(mainCamera, false, true);
	// getting 6 random covers from iPod music
	xEnableiPodMusic();
	xMediaPlayerPlay();
	xMediaPlayerPause();
	xMediaPlayerShuffleMode(SHUFFLE_SONGS);
	xMediaPlayerRepeatMode(REPEAT_ALL);
	while(covers.size() < 6)
	{
		int cover = xMediaPlayerItemCoverToTexture(128, 128);
		if(cover != 0)
		{
			covers.push_back(Song(xMediaPlayerItemID(), cover, xMediaPlayerItemArtist(), xMediaPlayerItemTitle()));
		}
		xMediaPlayerNextItem();
		xMediaPlayerPause();
	}
	// create scene
	musicCube = xCreateMesh(0);
	// back
	int brush   = xCreateBrush(255, 255, 255);
	xBrushTexture(brush, covers[0].cover, 0, 0);
	int surface = xCreateSurface(musicCube, brush);
	xAddVertex(surface, -1.0f,  1.0f, -1.0f, 1.0f, 0.0f);
	xAddVertex(surface,  1.0f,  1.0f, -1.0f, 0.0f, 0.0f);
	xAddVertex(surface,  1.0f, -1.0f, -1.0f, 0.0f, 1.0f);
	xAddVertex(surface, -1.0f, -1.0f, -1.0f, 1.0f, 1.0f);
	xAddTriangle(surface, 0, 1, 2);
	xAddTriangle(surface, 2, 3, 0);
	covers[0].surface = surface;
	// left
	xBrushTexture(brush, covers[1].cover, 0, 0);
	surface = xCreateSurface(musicCube, brush);
	xAddVertex(surface, -1.0f,  1.0f,  1.0f, 1.0f, 0.0f);
	xAddVertex(surface, -1.0f,  1.0f, -1.0f, 0.0f, 0.0f);
	xAddVertex(surface, -1.0f, -1.0f, -1.0f, 0.0f, 1.0f);
	xAddVertex(surface, -1.0f, -1.0f,  1.0f, 1.0f, 1.0f);
	xAddTriangle(surface, 0, 1, 2);
	xAddTriangle(surface, 2, 3, 0);
	covers[1].surface = surface;
	// right
	xBrushTexture(brush, covers[2].cover, 0, 0);
	surface = xCreateSurface(musicCube, brush);
	xAddVertex(surface,  1.0f,  1.0f,  1.0f, 0.0f, 0.0f);
	xAddVertex(surface,  1.0f,  1.0f, -1.0f, 1.0f, 0.0f);
	xAddVertex(surface,  1.0f, -1.0f, -1.0f, 1.0f, 1.0f);
	xAddVertex(surface,  1.0f, -1.0f,  1.0f, 0.0f, 1.0f);
	xAddTriangle(surface, 2, 1, 0);
	xAddTriangle(surface, 0, 3, 2);
	covers[2].surface = surface;
	// front
	xBrushTexture(brush, covers[3].cover, 0, 0);
	surface = xCreateSurface(musicCube, brush);
	xAddVertex(surface, -1.0f,  1.0f,  1.0f, 0.0f, 0.0f);
	xAddVertex(surface,  1.0f,  1.0f,  1.0f, 1.0f, 0.0f);
	xAddVertex(surface,  1.0f, -1.0f,  1.0f, 1.0f, 1.0f);
	xAddVertex(surface, -1.0f, -1.0f,  1.0f, 0.0f, 1.0f);
	xAddTriangle(surface, 2, 1, 0);
	xAddTriangle(surface, 0, 3, 2);
	covers[3].surface = surface;
	// up
	xBrushTexture(brush, covers[4].cover, 0, 0);
	surface = xCreateSurface(musicCube, brush);
	xAddVertex(surface, -1.0f,  1.0f, -1.0f, 0.0f, 0.0f);
	xAddVertex(surface,  1.0f,  1.0f, -1.0f, 1.0f, 0.0f);
	xAddVertex(surface,  1.0f,  1.0f,  1.0f, 1.0f, 1.0f);
	xAddVertex(surface, -1.0f,  1.0f,  1.0f, 0.0f, 1.0f);
	xAddTriangle(surface, 2, 1, 0);
	xAddTriangle(surface, 0, 3, 2);
	covers[4].surface = surface;
	// down
	xBrushTexture(brush, covers[5].cover, 0, 0);
	surface = xCreateSurface(musicCube, brush);
	xAddVertex(surface, -1.0f, -1.0f, -1.0f, 0.0f, 1.0f);
	xAddVertex(surface,  1.0f, -1.0f, -1.0f, 1.0f, 1.0f);
	xAddVertex(surface,  1.0f, -1.0f,  1.0f, 1.0f, 0.0f);
	xAddVertex(surface, -1.0f, -1.0f,  1.0f, 0.0f, 0.0f);
	xAddTriangle(surface, 0, 1, 2);
	xAddTriangle(surface, 2, 3, 0);
	covers[5].surface = surface;
	// make mesh pickable
	xEntityPickMode(musicCube, 2);
	// update mesh normals
	xUpdateNormals(musicCube);
	// create light
	xCreateLight(0, 0);
	// load font
	int font = xLoadFont("media/Tahoma22");
	xSetFont(font);
	// start music playing
	xMediaPlayerRepeatMode(REPEAT_ONE);
	currentSong = 3;
	xMediaPlayerToItem(covers[3].itemID);
	xMediaPlayerPlay();
	// load logo
	logo = xLoadImage("media/logo.png");
	// load backgorund image
	backGround = xLoadImage("media/background.png");
	xMidHandle(backGround);
	// activate acceleromter
	xEnableAccelerometer(true);
	initialized = timeGetTime();
	// launch animation
	animationInterval = 1.0 / 60.0;
	[self startAnimation];
}

- (void)drawView
{
	// accumulate acceleration
	if(timeGetTime() > initialized + 1000) // prevent acceleration on launch
	{
		if(fabs(xAccelerationX()) > 1.0f) accelerationX += xAccelerationX() * 100.0f;
		if(fabs(xAccelerationY()) > 1.0f) accelerationY += xAccelerationY() * 100.0f;
		if(fabs(xAccelerationZ()) > 1.0f) accelerationZ += xAccelerationZ() * 100.0f;
		accelerationX *= 0.9f;
		accelerationY *= 0.9f;
		accelerationZ *= 0.9f;
	}
	// turn cube by acceleration
	if(fabs(accelerationX) > 0.001 || fabs(accelerationY) > 0.001 || fabs(accelerationZ) > 0.001)
	{
		xTurnEntity(musicCube, accelerationZ, accelerationX, accelerationY, false);
		accelerated = true;
	}
	else if(accelerated)
	{
		accelerated = false;
		// pick music cude, and change songs by its surfaces
		int picked = xCameraPick(mainCamera, 240, 160);
		if(picked != 0)
		{
			int surface = xPickedSurface();
			for(int i = 0; i < 6; i++)
			{
				if(surface == covers[i].surface && i != currentSong)
				{
					xMediaPlayerToItem(covers[i].itemID);
					xMediaPlayerPlay();
					currentSong = i;
					break;
				}
			}
		}
	}
	// turn cube by touches
	for(int i = 0; i < xCountTouches(); i++)
	{
		if(xTouchPhase(i) == TOUCH_MOVE)
		{
			xTurnEntity(musicCube, xTouchY(i) - xTouchPrevY(i), xTouchPrevX(i) - xTouchX(i), 0, true);
		}
		else if(xTouchPhase(i) == TOUCH_RELEASED)
		{
			// pick music cude, and change songs by its surfaces
			int picked = xCameraPick(mainCamera, 240, 160);
			if(picked != 0)
			{
				int surface = xPickedSurface();
				for(int i = 0; i < 6; i++)
				{
					if(surface == covers[i].surface && i != currentSong)
					{
						xMediaPlayerToItem(covers[i].itemID);
						xMediaPlayerPlay();
						currentSong = i;
						break;
					}
				}
			}
		}
	}
	// draw background
	xDrawImage(backGround, 240, 160, 0);
	// render world
	xRenderWorld(1.0f);
	// now playing message
	char nowPlayingBuff[512];
	sprintf(nowPlayingBuff, "Now playing: %s - %s", covers[currentSong].artist.c_str(), covers[currentSong].title.c_str());
	xText(240, 290, nowPlayingBuff, true, false);
	// draw logo
	xDrawImage(logo, 401, 0, 0);
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