//
//  animtrack.h
//  iXors3D
//
//  Created by Knightmare on 10.09.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "animset.h"

class xAnimTrack
{
private:
	struct xEventKey
	{
		int   _keyType;
		float _keyValue;
		float _keyTime;
		float _startValue;
		float _startTime;
		bool  _keyInterpolate;
	};
	std::vector<xEventKey>   _events;
	float                    _time;
	float                    _localTime;
	bool                     _enabled;
	int                      _mode;
	float                    _lenght;
	int                      _destination;
	float                    _weight;
	float                    _speed;
	xAnimSet               * _animSet;
	bool                     _ended;
private:
	void ActivateEvents();
	void DeleteEvents();
public:
	xAnimTrack();
	void AddKeyDisableTrack(float keyTime);
	bool IsEnded();
	void EndTrack();
	void AddKeySetWeight(float weight, float keyTime, bool interpolate);
	void AddKeySetSpeed(float speed, float keyTime, bool interpolate);
	void SetAnimationSet(xAnimSet * newAnimSet);
	xAnimSet * GetAnimationSet();
	void DeleteAllEvents();
	float GetTime();
	void SetTime(float newTime);
	void Update(float deltaTime);
	void EnableTrack(bool state);
	void SetSpeed(float speed);
	float GetSpeed();
	bool IsEnabled();
	void ResetTime();
	void SetTrackMode(int newMode);
	int GetTrackMode();
	void SetTrackLength(float newLenght);
	float GetTrackLength();
	void SetWeight(float newWeight);
	float GetWeight();
};