//
//  enemy.mm
//  Invaders
//
//  Created by Knightmare on 08.10.09.
//  Copyright 2009 XorsTeam. All rights reserved.
//

#import "enemy.h"
#import "xors3d.h"
#import "game.h"

uint timeGetTime();

void Enemy::Create(int x, int y, int health, int shipImage, int flameImage)
{
	_x        = x;
	_y        = y;
	_health   = health;
	_image    = shipImage;
	_flame    = flameImage;
	_lastShot = timeGetTime();
}

bool Enemy::IsAlive()
{
	return _health > 0 && _y < 320;
}

void Enemy::Update()
{
	// if player in range - attack
	GameStage * gameStage = (GameStage*)Stage::GetActive();
	if(gameStage->GetPlayerPosition() + 64 > _x && gameStage->GetPlayerPosition() < _x + 64)
	{
		if(timeGetTime() > _lastShot + 1000)
		{
			gameStage->CreateBullet(_x + 22, _y + 72, 1);
			_lastShot = timeGetTime();
		}
	}
	_y++;
}

void Enemy::Render(int flameFrame)
{
	// draw ship image
	xDrawImage(_image, _x, _y, _x / 28);
	xDrawImage(_flame, _x + 20, _y - 10, flameFrame);
}

void Enemy::AddDamage(int value)
{
	_health -= value;
}

int Enemy::GetX()
{
	return _x;
}

int Enemy::GetY()
{
	return _y;
}