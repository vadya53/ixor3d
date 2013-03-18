//
//  game.h
//  Invaders
//
//  Created by Knightmare on 08.10.09.
//  Copyright 2009 XorsTeam. All rights reserved.
//

#import "stage.h"
#import <vector>

// classes definition
class Bullet;
class Enemy;
class Explosion;

class GameStage : public Stage
{
private:
	// images
	int                     _backgroundImage;
	int                     _playerImage;
	int                     _enemyImage;
	int                     _arrowLeftImage;
	int                     _arrowRightImage;
	int                     _fireImage;
	int                     _playerAfterburnImage;
	int                     _explosionImage;
	int                     _playerBulletImage;
	int                     _enemyBulletImage;
	int                     _enemyAfterburnImage;
	// fonts
	int                     _mainFont;
	// player ship position
	int                     _playerPosition;
	// ships flame animation data
	int                     _flameFrame;
	int                     _flameTime;
	// explosions array
	std::vector<Explosion*> _explosions;
	// bullets array
	std::vector<Bullet*>    _bullets;
	// last player shoting time
	int                     _lastShot;
	// enemies array
	std::vector<Enemy*>     _enemies;
	int                     _lastCreate;
	// game score
	int                     _score;
	int                     _lives;
	int                     _immortalTime;
private:
	bool InButton(int x, int y, int cx, int cy, int radii);
	void RenderBullets();
	void RenderExplosions();
	void RenderEnemies();
	void UpdateBullets();
	void UpdateEnemies();
	void CreateExplosion(int x, int y);
	void DestroyPlayer();
	void GenerateEnemies();
public:
	void Load();
	void Update();
	void Render();
	void Unload();
	void CreateBullet(int x, int y, int owner);
	int GetPlayerPosition();
};