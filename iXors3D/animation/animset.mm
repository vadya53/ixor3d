//
//  animset.mm
//  iXors3D
//
//  Created by Knightmare on 10.09.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import "animset.h"

xAnimSet::xAnimSet()
{
	_lenght = 0.0f;
	_frames = 0;
	_fps    = 0.0f;
}

bool xAnimSet::GetBoneTransform(float time, xVector & position, xVector & scale, xQuaternion & rotation)
{
	if(_animKeys.size() == 0) return false;
	xKeysArray::iterator iteratorKeyframe = GetUpperBound(time);
	if(iteratorKeyframe == _animKeys.end())
	{
		--iteratorKeyframe;
		position = (*iteratorKeyframe).position;
		rotation = (*iteratorKeyframe).rotation;
		scale    = (*iteratorKeyframe).scale;
		return true;
	}
	if(iteratorKeyframe == _animKeys.begin())
	{
		position = (*iteratorKeyframe).position;
		rotation = (*iteratorKeyframe).rotation;
		scale    = (*iteratorKeyframe).scale;
		return true;
	}
	xAnimKey * pKeyframeBefore = &(*(iteratorKeyframe - 1));
	xAnimKey * pKeyframeAfter  = &(*iteratorKeyframe);
	float blendFactor = (time - pKeyframeBefore->time) / (pKeyframeAfter->time - pKeyframeBefore->time);
	position = pKeyframeBefore->position.Lerp(pKeyframeAfter->position, blendFactor);
	scale    = pKeyframeBefore->scale.Lerp(pKeyframeAfter->scale, blendFactor);
	rotation = pKeyframeBefore->rotation.Slerp(pKeyframeAfter->rotation, blendFactor);
	return true;
}

float xAnimSet::GetLenght()
{
	return _lenght;
}

void xAnimSet::SetLenght(float newLen)
{
	_lenght = newLen;
}

xKeysArray * xAnimSet::GetKeys()
{
	return &_animKeys;
}

void xAnimSet::AddAnimationKey(float time, int frame, xVector position, xVector scale, xQuaternion rotation, int type)
{
	xKeysArray::iterator itr = _animKeys.begin();
	while(itr != _animKeys.end())
	{
		if(itr->frame == frame)
		{
			itr->type |= type;
			if(type & 1) itr->position = position;
			if(type & 2) itr->rotation = rotation;
			if(type & 4) itr->scale    = scale;
			return;
		}
		itr++;
	}
	xAnimKey newKey;
	newKey.frame    = frame;
	newKey.time     = time;
	newKey.type     = type;
	newKey.position = position;
	newKey.rotation = rotation;
	newKey.scale    = scale;
	_animKeys.push_back(newKey);
	int i = _animKeys.size() - 1;
	while(i > 0 && _animKeys[i].time < _animKeys[i - 1].time)
	{
		std::swap(_animKeys[i], _animKeys[i - 1]);
		--i;
	}
}

void xAnimSet::ClearKeys()
{
	_animKeys.clear();
}

int xAnimSet::FramesCount()
{
	return _frames;
}

void xAnimSet::SetFramesCount(int newFrames)
{
	_frames = newFrames;
}

void xAnimSet::SetFPS(float fps)
{
	_fps = fps;
}

float xAnimSet::GetFPS()
{
	return _fps;
}

xAnimSet * xAnimSet::Clone()
{
	xAnimSet * newSet = new xAnimSet();
	newSet->_lenght   = _lenght;
	newSet->_frames   = _frames;
	newSet->_fps      = _fps;
	newSet->_animKeys = _animKeys;
	return newSet;
}

xKeysArray::iterator xAnimSet::GetUpperBound(float time)
{
	xKeysArray::iterator i = _animKeys.begin();
	while(i != _animKeys.end() && time >= (*i).time) ++i;
	return i;
}