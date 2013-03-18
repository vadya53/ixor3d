//
//  splash.h
//  Ragdoll
//
//  Created by Knightmare on 11.08.10.
//  Copyright 2010 XorsTeam. All rights reserved.
//

#import "stage.h"

class SplashStage : public Stage
{
private:
	int  _splashImage;
	uint _startTime;
public:
	void Load();
	void Update();
	void Render();
	void Unload();
};