//
//  enemy.h
//  Invaders
//
//  Created by Knightmare on 08.10.09.
//  Copyright 2009 XorsTeam. All rights reserved.
//

class Enemy
{
private:
	int _x, _y;    // ship position
	int _image;    // ship image
	int _flame;    // flame image
	int _health;   // ship health
	int _lastShot; // last enemy shot time
public:
	void Create(int x, int y, int health, int shipImage, int flameImage);
	bool IsAlive();
	void Update();
	void Render(int flameFrame);
	int GetX();
	int GetY();
	void AddDamage(int value);
};