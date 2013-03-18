//
//  channel.h
//  iXors3D
//
//  Created by Knightmare on 17.09.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenAL/al.h>
//#import <OpenAL/alc.h>
#import <vector>

class xChannel
{
	friend class xSound;
private:
	ALuint                        _channelID;
	ALuint                        _bufferID;
	bool                          _is3D;
	int                           _pitch;
	float                         _panoram;
	static std::vector<xChannel*> _channels;
private:
	xChannel();
	~xChannel();
public:
	void SetPitch(int value);
	void SetVolume(float value);
	void SetPanoram(float value);
	bool Playing();
	void Stop();
	void Pause();
	void Resume();
	void SetPosition(float x, float y, float z);
	static void Update();
	static bool Validate(xChannel * channel);
	static int GetCount();
};

