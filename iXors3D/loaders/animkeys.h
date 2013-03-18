#ifndef _ANIMKEYS_H_
#define _ANIMKEYS_H_

#import "x3dmath.h"

struct LoaderAnimKey
{
	LoaderAnimKey()
	{
		_flag     = 0;
		_animSet  = 0;
		_frame    = 0;
		_position = xVector(0.0f, 0.0f, 0.0f);
		_scale    = xVector(1.0f, 1.0f, 1.0f);
		_rotation = xQuaternion(0.0f, 0.0f, 0.0f, 1.0f);
	}
	int         _flag;
	int         _animSet;
	int         _frame;
	xVector     _position;
	xVector     _scale;
	xQuaternion _rotation;
};

typedef std::vector<LoaderAnimKey> AnimKeysArray;

#endif