//
//  sprite.h
//  iXors3D
//
//  Created by Knightmare on 15.10.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import "entity.h"

class xSprite : public xEntity
{
private:
	float _angle;
	float _scalex, _scaley;
	float _offsetx, _offsety;
	int   _viewMode;
public:
	xSprite();
	void SetOffset(float x, float y);
	void SetScale(float x, float y);
	void SetRotation(float angle);
	void SetViewMode(int mode);
	xEntity * Clone(xEntity * parent, bool cloneGeom);
	void UpdateSurface();
};