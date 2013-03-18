//
//  explosion.mm
//  Invaders
//
//  Created by Knightmare on 08.10.09.
//  Copyright 2009 XorsTeam. All rights reserved.
//

#import "explosion.h"
#import "xors3d.h"

uint timeGetTime();

void Explosion::Create(int x, int y, int image)
{
	_x     = x;
	_y     = y;
	_image = image;
	_frame = 0;
	_time  = timeGetTime();
}

bool Explosion::IsAlive()
{
	return (_frame < 16);
}

void Explosion::Render()
{
	// check frame
	if(_frame > 15) return;
	// draw image
	xDrawImage(_image, _x, _y, _frame);
	// animate explosion
	if(timeGetTime() > _time + 10)
	{
		_frame++;
		_time = timeGetTime();
	}
}