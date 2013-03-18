//
//  stage.h
//  Ragdoll
//
//  Created by Knightmare on 11.08.10.
//  Copyright 2010 XorsTeam. All rights reserved.
//

#import "xors3d.h"

class Stage
{
private:
	static Stage * _active;
protected:
	void MakeActive();
public:
	virtual void Load()   = 0;
	virtual void Update() = 0;
	virtual void Render() = 0;
	virtual void Unload() = 0;
	static Stage * GetActive();
};