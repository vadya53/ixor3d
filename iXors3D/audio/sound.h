//
//  sound.h
//  iXors3D
//
//  Created by Knightmare on 17.09.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenAL/al.h>
#import <OpenAL/alc.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/ExtendedAudioFile.h>
#import "channel.h"
#import "entity.h"

class xSound
{
private:
	ALuint _bufferID;
	int    _pitch;
	float  _pitchMultipler, _volume, _panoram;
	bool   _is3D, _looped;
private:
	void * GetAudioData(const char * path, ALsizei * dataSize, ALenum * dataFormat, ALsizei * sampleRate);
public:
	xSound();
	void Release();
	bool LoadSound(const char * path);
	bool Load3DSound(const char * path);
	void SetPitch(int value);
	void SetVolume(float value);
	void SetPanoram(float value);
	int GetPitch();
	float GetVolume();
	float GetPanoram();
	void Loop(bool state);
	xChannel * Play();
	xChannel * Emit(xEntity * entity);
};