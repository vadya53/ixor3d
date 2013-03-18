//
//  game.h
//  Ragdoll
//
//  Created by Knightmare on 11.08.10.
//  Copyright 2010 XorsTeam. All rights reserved.
//

#import "stage.h"
#import "ragdoll.h"
#import <vector>

class GameStage : public Stage
{
private:
	// images
	int                   _boxImage, _backGround, _buttonImage;
	// shapes
	int                   _leftWall, _rightWall, _downWall, _upWall;
	// fonts
	int                   _mainFont;
	// ragdolls array
	std::vector<Ragdoll*> _ragdolls;
	// boxes array
	std::vector<int>      _boxShapes;
	// active ragdoll
	int                   _activeRagdoll;
private:
	public:
	void Load();
	void Update();
	void Render();
	void Unload();
};