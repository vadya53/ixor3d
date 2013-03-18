//
//  explosion.h
//  Invaders
//
//  Created by Knightmare on 08.10.09.
//  Copyright 2009 XorsTeam. All rights reserved.
//

class Explosion
{
private:
	int _x, _y; // explosion position
	int _frame; // current frame
	int _time;  // current time
	int _image; // explosion image
public:
	void Create(int x, int y, int image);
	bool IsAlive();
	void Render();
};