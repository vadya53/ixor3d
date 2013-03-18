//
//  animset.h
//  iXors3D
//
//  Created by Knightmare on 10.09.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "x3dmath.h"
#import <vector>
#import <map>

struct xAnimKey
{
	int          frame;
	xVector      position;
	xVector      scale;
	xQuaternion  rotation;
	float        time;
	int          type;
};

typedef std::vector<xAnimKey> xKeysArray;

class xAnimSet
{
private:
	float      _lenght;
	int        _frames;
	float      _fps;
	xKeysArray _animKeys;
private:
	xKeysArray::iterator GetUpperBound(float time);
public:
	xAnimSet();
	bool GetBoneTransform(float time, xVector & position, xVector & scale, xQuaternion & rotation);
	float GetLenght();
	void SetLenght(float newLen);
	void AddAnimationKey(float time, int frame, xVector position, xVector scale, xQuaternion rotation, int type);
	void ClearKeys();
	int FramesCount();
	void SetFramesCount(int newFrames);
	void SetFPS(float fps);
	float GetFPS();
	xAnimSet * Clone();
	xKeysArray * GetKeys();
};