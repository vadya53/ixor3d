//
//  channel.mm
//  iXors3D
//
//  Created by Knightmare on 17.09.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import "channel.h"
#import "audiomanager.h"
#import "x3dmath.h"

std::vector<xChannel*> xChannel::_channels;

xChannel::xChannel()
{
	alGenSources(1, &_channelID);
	_channels.push_back(this);
}

xChannel::~xChannel()
{
	alDeleteSources(1, &_channelID);
}

void xChannel::SetPitch(int value)
{
	if(_channelID == 0) return;
	alSourcef(_channelID, AL_PITCH, float(value) / float(_pitch));
}

void xChannel::SetVolume(float value)
{
	if(_channelID == 0) return;
	if(value < 0.0f) value = 0.0f;
	if(value > 1.0f) value = 1.0f;
	alSourcef(_channelID, AL_GAIN, value);
}

void xChannel::SetPanoram(float value)
{
	if(_channelID == 0) return;
	if(value < -1.0f) value = -1.0f;
	if(value >  1.0f) value =  1.0f;
	_panoram = value;
}

bool xChannel::Playing()
{
	if(_channelID == 0) return false;
	ALint result;
	alGetSourcei(_channelID, AL_SOURCE_STATE, &result);
	return (result == AL_PLAYING || result == AL_PAUSED);
}

void xChannel::Stop()
{
	if(_channelID == 0) return;
	alSourceStop(_channelID);
}

void xChannel::Pause()
{
	if(_channelID == 0) return;
	alSourcePause(_channelID);
}

void xChannel::Resume()
{
	if(_channelID == 0) return;
	ALint result;
	alGetSourcei(_channelID, AL_SOURCE_STATE, &result);
	if(result == AL_PAUSED) alSourcePlay(_channelID);
}

void xChannel::SetPosition(float x, float y, float z)
{
	if(!_is3D) return;
	ALfloat position[] = { x, y, z };
	alSourcefv(_channelID, AL_POSITION, position);
}

bool xChannel::Validate(xChannel * channel)
{
	std::vector<xChannel*>::iterator itr = _channels.begin();
	while(itr != _channels.end())
	{
		if((*itr) == channel) return true;
		itr++;
	}
	return false;
}

void xChannel::Update()
{
	std::vector<xChannel*>::iterator itr = _channels.begin();
	while(itr != _channels.end())
	{
		if((*itr)->Playing())
		{
			if(!(*itr)->_is3D)
			{
				xVector panoram = xAudioManager::Instance()->GetListener()->GetQuaternion(true) * xVector((*itr)->_panoram, 0.0f, 0.0f);
				alSourcefv((*itr)->_channelID, AL_POSITION, (ALfloat*)&panoram);
			}
			itr++;
		}
		else
		{
			delete (*itr);
			itr = _channels.erase(itr);
		}
	}
}

int xChannel::GetCount()
{
	return _channels.size();
	
}


