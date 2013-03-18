//
//  game.mm
//  Invaders
//
//  Created by Knightmare on 08.10.09.
//  Copyright 2009 XorsTeam. All rights reserved.
//

#import "game.h"
#import "explosion.h"
#import "bullet.h"
#import "enemy.h"
#import <iostream>

//#define SIMULATOR_DEBUG

uint timeGetTime();

void GameStage::Load()
{
	// load images
	_backgroundImage      = xLoadImage("back.png");
	_playerImage          = xLoadAnimImage("player.png", 64, 64, 0, 15);
	_arrowLeftImage       = xLoadImage("arrow_left.png");
	_arrowRightImage      = xLoadImage("arrow_right.png");
	_fireImage            = xLoadImage("fire.png");
	_playerAfterburnImage = xLoadAnimImage("afterburn_down.png", 24, 24, 0, 2);
	_enemyAfterburnImage  = xLoadAnimImage("afterburn_up.png", 24, 24, 0, 2);
	_explosionImage       = xLoadAnimImage("explosion.png", 64, 64, 0, 16);
	_playerBulletImage    = xLoadImage("shot_player.png");
	_enemyBulletImage     = xLoadImage("shot_enemy.png");
	_enemyImage           = xLoadAnimImage("enemy.png", 64, 64, 0, 15);
	// load fonts
	_mainFont             = xLoadFont("mainfont");
	// set values
	_playerPosition       = 208;
	_flameFrame           = 0;
	_score                = 0;
	_lives                = 5;
	_immortalTime         = 0;
	_flameTime            = timeGetTime();
	_lastShot             = timeGetTime();
	_lastCreate           = timeGetTime();
	// set stage as active
	MakeActive();
}

void GameStage::Update()
{
	if(_lives < 1) return;
	// player ship control
	for(int i = 0; i < xCountTouches(); i++)
	{
		// if pressed phase
		if(xTouchPhase(i) == TOUCH_PRESSED)
		{
			// move left
			if(xTouchX(i) > 10 && xTouchX(i) < 45 && xTouchY(i) > 275 && xTouchY(i) < 315)
			{
				_playerPosition -= 4;
				if(_playerPosition < 0) _playerPosition = 0;
			}
			// move right
			else if(xTouchX(i) > 55 && xTouchX(i) < 90 && xTouchY(i) > 275 && xTouchY(i) < 315)
			{
				_playerPosition += 4;
				if(_playerPosition > 416) _playerPosition = 416;
			}
			// fire button
			else if(InButton(xTouchX(i), xTouchY(i), 451, 294, 24))
			{
				if(timeGetTime() > _lastShot + 200)
				{
					CreateBullet(_playerPosition + 22, 243, 0);
					_lastShot = timeGetTime();
				}
			}
		}
	}
#ifdef SIMULATOR_DEBUG
	if(timeGetTime() > _lastShot + 200)
	{
		CreateBullet(_playerPosition + 22, 243, 0);
		_lastShot = timeGetTime();
	}
#endif
	// update flames
	if(timeGetTime() > _flameTime + 100)
	{
		_flameFrame++;
		if(_flameFrame == 2) _flameFrame = 0;
		_flameTime = timeGetTime();
	}
	// test all bullets
	UpdateBullets();
	// update all enemies
	UpdateEnemies();
	// generate new enemies
	GenerateEnemies();
}

void GameStage::Render()
{
	// clear scene
	xCls();
	// draw background
	xDrawImage(_backgroundImage, 0, 0, 0);
	// draw player ship
	xDrawImage(_playerImage, _playerPosition, 251, _playerPosition / 28);
	xDrawImage(_playerAfterburnImage, _playerPosition + 20, 305, _flameFrame);
	// draw enemies
	RenderEnemies();
	// render all bullets
	RenderBullets();
	// render all explodes
	RenderExplosions();
	// draw control sprites
	// movement
	xDrawImage(_arrowLeftImage, 5, 270, 0);
	xDrawImage(_arrowRightImage, 45, 270, 0);
	// fire
	xDrawImage(_fireImage, 427, 270, 0);
	// draw text information
	xSetFont(_mainFont);
	char buff[256];
	sprintf(buff, "Score: %i", _score);
	xText(5, 5, buff, false, false);
	sprintf(buff, "Ships: %i", _lives);
	xText(370, 5, buff, false, false);
	// "GAME OVER" message
	if(_lives < 1)
	{
		int width = xStringWidth("GAME OVER!");
		xText(240 - width / 2, 160, "GAME OVER!", true, true);
	}
	// present scene
    xFlip();	
}

void GameStage::Unload()
{
	xFreeImage(_backgroundImage);
	xFreeImage(_playerImage);
	xFreeImage(_arrowLeftImage);
	xFreeImage(_arrowRightImage);
	xFreeImage(_fireImage);
	xFreeImage(_playerAfterburnImage);
	xFreeImage(_explosionImage);
	xFreeImage(_playerBulletImage);
	xFreeImage(_enemyAfterburnImage);
	xFreeImage(_enemyBulletImage);
	xFreeImage(_enemyImage);
	xFreeFont(_mainFont);
}

bool GameStage::InButton(int x, int y, int cx, int cy, int radii)
{
	x -= cx;
	y -= cy;
	return (fabs(sqrtf(x * x + y * y)) <= radii ? true : false);
}

void GameStage::CreateExplosion(int x, int y)
{
	Explosion * newExplosion = new Explosion();
	newExplosion->Create(x, y, _explosionImage);
	_explosions.push_back(newExplosion);
}

void GameStage::CreateBullet(int x, int y, int owner)
{
	Bullet * newBullet = new Bullet();
	newBullet->Create(x, y, owner, owner == 0 ? _playerBulletImage : _enemyBulletImage);
	_bullets.push_back(newBullet);
}

void GameStage::RenderBullets()
{
	std::vector<Bullet*>::iterator itr = _bullets.begin();
	while(itr != _bullets.end())
	{
		if((*itr)->IsAlive())
		{
			(*itr)->Render();
			itr++;
		}
		else
		{
			delete (*itr);
			itr = _bullets.erase(itr);
		}
	}
}

void GameStage::RenderExplosions()
{
	std::vector<Explosion*>::iterator itr = _explosions.begin();
	while(itr != _explosions.end())
	{
		if((*itr)->IsAlive())
		{
			(*itr)->Render();
			itr++;
		}
		else
		{
			delete (*itr);
			itr = _explosions.erase(itr);
		}
	}
}

void GameStage::GenerateEnemies()
{
	if(timeGetTime() > _lastCreate + 2000)
	{
		_lastCreate = timeGetTime();
		Enemy * newEnemy = new Enemy();
		newEnemy->Create(rand() % 416, -64, 2, _enemyImage, _enemyAfterburnImage);
		_enemies.push_back(newEnemy);
	}
}

void GameStage::DestroyPlayer()
{
	if(timeGetTime() < _immortalTime) return;
	// decrease score
	_score -= 50;
	if(_score < 0) _score = 0;
	// decrease lives
	_lives--;
	// reset ship position
	_playerPosition = _lives > 0 ? 208 : -300;
	// reset ship immortal time
	_immortalTime = timeGetTime() + 3000;
}

void GameStage::UpdateEnemies()
{
	std::vector<Enemy*>::iterator itr = _enemies.begin();
	while(itr != _enemies.end())
	{
		if((*itr)->IsAlive())
		{
			(*itr)->Update();
			// test for ships collision
			// check bounding box collisions first
			if(xImagesOverlap(_playerImage, _playerPosition, 251,
							  _enemyImage, (*itr)->GetX(), (*itr)->GetY()))
			{
				// now make pixel prefect collision test
				if(xImagesCollide(_playerImage, _playerPosition, 251, _playerPosition / 28,
								  _enemyImage, (*itr)->GetX(), (*itr)->GetY(), (*itr)->GetX() / 28))
				{
					// make damage
					(*itr)->AddDamage(1000);
					DestroyPlayer();
					// add explode
					CreateExplosion((*itr)->GetX() , (*itr)->GetY());
					CreateExplosion(_playerPosition, 251);
				}
			}
		}
		itr++;
	}
}

void GameStage::RenderEnemies()
{
	std::vector<Enemy*>::iterator itr = _enemies.begin();
	while(itr != _enemies.end())
	{
		if((*itr)->IsAlive())
		{
			(*itr)->Render(_flameFrame);
			itr++;
		}
		else
		{
			delete (*itr);
			itr = _enemies.erase(itr);
		}
	}
}

int GameStage::GetPlayerPosition()
{
	return _playerPosition;
}

void GameStage::UpdateBullets()
{
	std::vector<Bullet*>::iterator itr = _bullets.begin();
	while(itr != _bullets.end())
	{
		if((*itr)->GetOwner() == 0)
		{
			// if its player bullet test for collisions with all enemies
			std::vector<Enemy*>::iterator itr2 = _enemies.begin();
			while(itr2 != _enemies.end())
			{
				if((*itr2)->IsAlive())
				{
					// check bounding box collisions first
					if(xImagesOverlap(_playerBulletImage, (*itr)->GetX(), (*itr)->GetY(),
									  _enemyImage, (*itr2)->GetX(), (*itr2)->GetY()))
					{
						// now make pixel prefect collision test
						if(xImagesCollide(_playerBulletImage, (*itr)->GetX(), (*itr)->GetY(), 0,
										  _enemyImage, (*itr2)->GetX(), (*itr2)->GetY(), (*itr2)->GetX() / 28))
						{
							// make damage
							(*itr2)->AddDamage(1);
							// add explode it enemy destroied
							if(!(*itr2)->IsAlive())
							{
								CreateExplosion((*itr)->GetX() - 32, (*itr)->GetY() - 32);
								_score += 10;
							}
							// delete bullet
							(*itr)->Release();
						}
					}
				}
				itr2++;
			}
		}
		else
		{
			// check bounding box collisions first
			if(xImagesOverlap(_enemyBulletImage, (*itr)->GetX(), (*itr)->GetY(),
							  _playerImage, _playerPosition, 251))
			{
				// now make pixel prefect collision test
				if(xImagesCollide(_enemyBulletImage, (*itr)->GetX(), (*itr)->GetY(), 0,
								  _playerImage, _playerPosition, 251, _playerPosition / 28))
				{
					// destroy player
					CreateExplosion((*itr)->GetX() - 32, (*itr)->GetY() - 32);
					DestroyPlayer();
					// delete bullet
					(*itr)->Release();
				}
			}
		}
		itr++;
	}
}