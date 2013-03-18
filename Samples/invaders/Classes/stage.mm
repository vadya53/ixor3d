//
//  stage.mm
//  Invaders
//
//  Created by Knightmare on 08.10.09.
//  Copyright 2009 XorsTeam. All rights reserved.
//

#import "stage.h"

Stage * Stage::_active = NULL;

void Stage::MakeActive()
{
	if(_active != NULL)
	{
		_active->Unload();
		delete _active;
	}
	_active = this;
}

Stage * Stage::GetActive()
{
	return _active;
}