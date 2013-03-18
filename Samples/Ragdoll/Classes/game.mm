//
//  game.mm
//  Ragdoll
//
//  Created by Knightmare on 11.08.10.
//  Copyright 2010 XorsTeam. All rights reserved.
//

#import "game.h"
#import <iostream>

void GameStage::Load()
{
	_activeRagdoll = 0;
	// create ground
	_downWall  = xCreateBox2DShape(480, 10, 0.0f);
	xPosition2DShape(_downWall, 240, 325);
	_leftWall  = xCreateBox2DShape(10, 320, 0.0f);
	xPosition2DShape(_leftWall, 485, 160);
	_rightWall = xCreateBox2DShape(10, 320, 0.0f);
	xPosition2DShape(_rightWall, -5, 160);
	_upWall    = xCreateBox2DShape(480, 10, 0.0f);
	xPosition2DShape(_upWall, 240, -5);
	// create ragdolls
	Ragdoll * ragdoll;
	ragdoll = new Ragdoll();
	ragdoll->Create("node.png", "head.png", 100, 150, 190, 0,   0);
	_ragdolls.push_back(ragdoll);
	ragdoll = new Ragdoll();
	ragdoll->Create("node.png", "head.png", 380, 150, 0,   190, 0);
	_ragdolls.push_back(ragdoll);
	// create boxes
	_boxImage = xLoadImage("box.png");
	for(int i = 0; i < 5; i++)
	{
		int box = xCreateBox2DShape(xImageWidth(_boxImage), xImageHeight(_boxImage), 1.0f);
		xPosition2DShape(box, 240, 296 - i * 48);
		x2DShapeAssignImage(box, _boxImage, 0);
		_boxShapes.push_back(box);
	}
	// load background
	_backGround = xLoadImage("forest.png");
	// load switch image
	_buttonImage = xLoadAnimImage("button.png", 64, 32, 0, 2);
	xMidHandle(_buttonImage);
	// load font
	_mainFont = xLoadFont("mainfont");
	xSetFont(_mainFont);
	// set stage as active
	MakeActive();
}

void GameStage::Update()
{
	// proceed touches
	for(int i = 0; i < xCountTouches(); i++)
	{
		if(xTouchPhase(i) == TOUCH_BEGAN)
		{
			if(xTouchX(i) >= 208 && xTouchX(i) <= 272
			   && xTouchY(i) >= 288 && xTouchY(i) <= 320)
			{
				_activeRagdoll = 1 - _activeRagdoll;
			}
			else
			{
				float x   = xTouchX(i) - x2DShapePositionX(_ragdolls[_activeRagdoll]->GetNode(Ragdoll::BodyUp));
				float y   = xTouchY(i) - x2DShapePositionY(_ragdolls[_activeRagdoll]->GetNode(Ragdoll::BodyUp));
				float len = sqrtf(x * x + y * y);
				float nx  = x / len;
				float ny  = y / len;
				x2DShapeApplyImpulse(_ragdolls[_activeRagdoll]->GetNode(Ragdoll::BodyUp), nx * 500, ny * 500, x, y);
			}
		}
	}
	// update world
	xUpdate2DWorld(1.0f);
}

void GameStage::Render()
{
	// clear scene
	xCls();
	// draw background
	xDrawImage(_backGround, 0, -40, 0);
	// render world
	xRender2DWorld();
	// draw switch button
	xDrawImage(_buttonImage, 240, 304, _activeRagdoll);
	// draw text
	xColor(0, 0, 0);
	char buff[128];
	sprintf(buff, "FPS: %i", xFPSCounter());
	xText(10, 10, buff, false, false);
	// present scene
    xFlip();	
}

void GameStage::Unload()
{
	// free images
	xFreeImage(_backGround);
	xFreeImage(_boxImage);
	// free font
	xFreeFont(_mainFont);
	// delete reagdolls
	for(int i = 0; i < _ragdolls.size(); i++)
	{
		delete _ragdolls[i];
	}
	_ragdolls.clear();
	// delete ground
	xDelete2DShape(_downWall);
	xDelete2DShape(_leftWall);
	xDelete2DShape(_rightWall);
	xDelete2DShape(_upWall);
	// delete boxes
	for(int i = 0; i < _boxShapes.size(); i++)
	{
		xDelete2DShape(_boxShapes[i]);
	}
	_boxShapes.clear();
}