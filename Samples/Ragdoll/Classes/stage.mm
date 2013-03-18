//
//  stage.mm
//  Ragdoll
//
//  Created by Knightmare on 11.08.10.
//  Copyright 2010 XorsTeam. All rights reserved.
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