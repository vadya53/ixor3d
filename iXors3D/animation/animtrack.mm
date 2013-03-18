//
//  animtrack.mm
//  iXors3D
//
//  Created by Knightmare on 10.09.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import "animtrack.h"
#import <iostream>

xAnimTrack::xAnimTrack()
{
	_time           = 0.0f;
	_localTime      = 0.0f;
	_enabled        = false;
	_mode           = 0;
	_lenght         = 0.0f;
	_destination    = 1;
	_weight         = 1.0f;
	_speed          = 1.0f;
	_animSet        = NULL;
	_ended          = false;
}

void xAnimTrack::AddKeyDisableTrack(float keyTime)
{
	xEventKey newEvent;
	newEvent._keyInterpolate = false;
	newEvent._keyType        = 1;
	newEvent._keyTime        = _time + (_destination * keyTime);
	newEvent._keyValue       = 0.0f;
	newEvent._startTime      = 0.0f;
	newEvent._startValue     = 0.0f;
	_events.push_back(newEvent);
}

bool xAnimTrack::IsEnded()
{
	return _ended;
}

void xAnimTrack::EndTrack()
{
	_ended = true;
}

void xAnimTrack::AddKeySetWeight(float weight, float keyTime, bool interpolate)
{
	xEventKey newEvent;
	newEvent._keyInterpolate = interpolate;
	newEvent._keyType        = 2;
	newEvent._keyTime        = _time + (_destination * keyTime);
	newEvent._keyValue       = weight;
	newEvent._startTime      = _time;
	newEvent._startValue     = _weight;
	_events.push_back(newEvent);
}

void xAnimTrack::AddKeySetSpeed(float speed, float keyTime, bool interpolate)
{
	xEventKey newEvent;
	newEvent._keyInterpolate = interpolate;
	newEvent._keyType        = 3;
	newEvent._keyTime        = _time + (_destination * keyTime);
	newEvent._keyValue       = speed;
	newEvent._startTime      = _time;
	newEvent._startValue     = _speed;
	_events.push_back(newEvent);
}

void xAnimTrack::SetAnimationSet(xAnimSet * newAnimSet)
{
	_animSet = newAnimSet;
}

xAnimSet * xAnimTrack::GetAnimationSet()
{
	return _animSet;
}

void xAnimTrack::DeleteAllEvents()
{
	_events.clear();
}

float xAnimTrack::GetTime()
{
	return _localTime;
}

void xAnimTrack::SetTime(float newTime)
{
	_time = newTime;
}

void xAnimTrack::Update(float deltaTime)
{
	if(_enabled)
	{
		_time += deltaTime * _speed;
		ActivateEvents();
		DeleteEvents();
		if(_ended) return;
		if(_mode == 2)
		{
			int loopNum  = _time / _lenght;
			_destination = (loopNum + 1) % 2;
		}
		else if(_mode == 3)
		{
			if(_time > _lenght || _time < 0.0f)
			{
				_localTime = _speed >= 0.0f ? _lenght : 0.0f;
				_ended = true;
				return;
			}
		}
		if(_destination == 0)
		{
			_localTime = _lenght - fmodf(_time, _lenght);
		}
		else
		{
			_localTime = fmodf(_time, _lenght);
		}
	}
}

void xAnimTrack::EnableTrack(bool state)
{
	_enabled = state;
}

void xAnimTrack::SetSpeed(float speed)
{
	_speed = speed;
}

float xAnimTrack::GetSpeed()
{
	return _speed;
}

bool xAnimTrack::IsEnabled()
{
	return _enabled;
}

void xAnimTrack::ResetTime()
{
	_time      = 0.0f;
	_localTime = 0.0f;
}

void xAnimTrack::SetTrackMode(int newMode)
{
	_mode        = newMode;
	_destination = 1;
}

int xAnimTrack::GetTrackMode()
{
	return _mode;
}

void xAnimTrack::SetTrackLength(float newLenght)
{
	_lenght = newLenght;
}

float xAnimTrack::GetTrackLength()
{
	return _lenght;
}

void xAnimTrack::SetWeight(float newWeight)
{
	if(newWeight < 0.0f) newWeight = 0.0f;
	if(newWeight > 1.0f) newWeight = 1.0f;
	_weight = newWeight;
}

float xAnimTrack::GetWeight()
{
	return _weight;
}

void xAnimTrack::ActivateEvents()
{
	for(int i = 0; i < _events.size(); i++)
	{
		if(_events[i]._keyInterpolate)
		{
			if(_time >= _events[i]._keyTime)
			{
				switch(_events[i]._keyType)
				{
					case 2: _weight = _events[i]._keyValue; break;
					case 3: _speed  = _events[i]._keyValue; break;
				}
			}
			else
			{
				float s = (_time - _events[i]._startTime) / (_events[i]._keyTime - _events[i]._startTime);
				float value = _events[i]._startValue + s * (_events[i]._keyValue - _events[i]._startValue);
				switch(_events[i]._keyType)
				{		
					case 2: _weight = value; break;
					case 3: _speed  = value; break;
				}
			}
		}
		else
		{
			if(_time >= _events[i]._keyTime)
			{
				switch(_events[i]._keyType)
				{
					case 1: _enabled = false;                break;
					case 2: _weight  = _events[i]._keyValue; break;
					case 3:	_speed   = _events[i]._keyValue; break;
				}
			}
		}
	}
}

void xAnimTrack::DeleteEvents()
{
	std::vector<xEventKey>::iterator i = _events.begin();
	while(i != _events.end())
	{
		if(_time >= (*i)._keyTime)
		{
			i = _events.erase(i);
		}
		else
		{
			i++;
		}
	}
}