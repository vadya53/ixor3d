//
//  splash.mm
//  Invaders
//
//  Created by Knightmare on 4/24/10.
//  Copyright 2010 XorsTeam. All rights reserved.
//

#import "splash.h"
#import "game.h"

uint timeGetTime();

void SplashStage::Load()
{
	xCls();
	_splashImage = xLoadImage("iXors3d.png");
	_startTime   = timeGetTime();
	// set stage as active
	MakeActive();
}

void SplashStage::Update()
{
	float alpha = float(timeGetTime() - _startTime) / 2500.0f;
	xImageAlpha(_splashImage, alpha);
	xFlip();
}

void SplashStage::Render()
{
	xCls();
	xDrawImage(_splashImage, 0, 0, 0);
	if(timeGetTime() - _startTime > 5000)
	{
		GameStage * gameStage = new GameStage();
		gameStage->Load();
	}
}

void SplashStage::Unload()
{
	xFreeImage(_splashImage);
}
