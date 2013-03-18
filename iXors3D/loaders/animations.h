#ifndef _ANIMATIONS_H_
#define _ANIMATIONS_H_

struct LoaderAnimation
{
	LoaderAnimation()
	{
		_flag       = 0;
		_startFrame = 0;
		_endFrame   = 0;
		_fps        = 0.0f;
	}
	int   _flag;
	int   _startFrame;
	int   _endFrame;
	float _fps;
};

typedef std::vector<LoaderAnimation> AnimationsArray;

#endif