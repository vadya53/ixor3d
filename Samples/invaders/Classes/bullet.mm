//
//  bullet.mm
//  Invaders
//
//  Created by Knightmare on 08.10.09.
//  Copyright 2009 XorsTeam. All rights reserved.
//

#import "bullet.h"
#import "xors3d.h"
#import <iostream>

uint timeGetTime();

void Bullet::Create(int x, int y, int owner, int image)
{
	_x     = x;
	_y     = y;
	_owner = owner;
	_image = image;
	_time  = timeGetTime();
}

bool Bullet::IsAlive()
{
	if(_owner == 0)
	{
		return _y > 0;
	}
	else
	{
		return _y < 320;
	}
}

void Bullet::Release()
{
	if(_owner == 0)
	{
		_y = -30;
	}
	else
	{
		_y = 350;
	}
}

void Bullet::Render()
{
	// move bullet
	if(timeGetTime() > _time + 10)
	{
		if(_owner == 0)
		{
			_y -= 5;
		}
		else
		{
			_y += 5;
		}
		_time = timeGetTime();
	}
	// draw image
	xDrawImage(_image, _x, _y, 0);
}

int Bullet::GetOwner()
{
	return _owner;
}

int Bullet::GetX()
{
	return _x;
}

int Bullet::GetY()
{
	return _y;
}