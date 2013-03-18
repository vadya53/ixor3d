//
//  bullet.h
//  Invaders
//
//  Created by Knightmare on 08.10.09.
//  Copyright 2009 XorsTeam. All rights reserved.
//

class Bullet
{
private:
	int _x, _y; // bullet position
	int _image; // bullet sprite
	int _owner; // bullet owner. 0 - player, 1 - enemy
	int _time;  // bullet movement time
public:
	void Create(int x, int y, int owner, int image);
	bool IsAlive();
	void Render();
	int GetOwner();
	void Release();
	int GetX();
	int GetY();
};