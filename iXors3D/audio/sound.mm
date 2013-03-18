//
//  sound.mm
//  iXors3D
//
//  Created by Knightmare on 17.09.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import "sound.h"
#import "audiomanager.h"
#import "audiofile.h"

xSound::xSound()
{
	_bufferID       = 0;
	_pitch          = 0;
	_pitchMultipler = 1.0f;
	_volume         = 1.0f;
	_panoram        = 0.0f;
	_is3D           = false;
	_looped         = false;
	alGenBuffers(1, &_bufferID);
	if(alGetError() != AL_NO_ERROR) printf("alGenBuffers() error.\n");
}

void xSound::Release()
{
	if(_bufferID != 0)
	{
		std::vector<xChannel*>::iterator itr = xChannel::_channels.begin();
		while(itr != xChannel::_channels.end())
		{
			if((*itr)->_bufferID == _bufferID)
			{
				delete *itr;
				itr = xChannel::_channels.erase(itr);
			}
			else
			{
				itr++;
			}
		}
		alDeleteBuffers(1, &_bufferID);
		if(alGetError() != AL_NO_ERROR) printf("alDeleteBuffers() error.\n");
	}
}

xChannel * xSound::Play()
{
	xChannel * newChannel = new xChannel();
	newChannel->_bufferID = _bufferID;
	newChannel->_is3D     = _is3D;
	newChannel->_pitch    = _pitch;
	newChannel->_panoram  = _panoram;
	alSourcei(newChannel->_channelID, AL_BUFFER, _bufferID);
	if(alGetError() != AL_NO_ERROR) printf("alSourcei(AL_BUFFER) error.\n");
	alSourcei(newChannel->_channelID, AL_LOOPING, _looped);
	if(alGetError() != AL_NO_ERROR) printf("alSourcei(AL_LOOPING) error.\n");
	alSourcei(newChannel->_channelID, AL_SOURCE_RELATIVE, !_is3D);
	if(alGetError() != AL_NO_ERROR) printf("alSourcei(AL_SOURCE_RELATIVE) error.\n");
	alSourcef(newChannel->_channelID, AL_PITCH, _pitchMultipler);
	if(alGetError() != AL_NO_ERROR) printf("alSourcef(AL_PITCH) error.\n");
	alSourcef(newChannel->_channelID, AL_GAIN, _volume);
	if(alGetError() != AL_NO_ERROR) printf("alSourcef(AL_GAIN) error.\n");
	alSourcef(newChannel->_channelID, AL_ROLLOFF_FACTOR, xAudioManager::Instance()->GetRolloffFactor());
	if(alGetError() != AL_NO_ERROR) printf("alSourcef(AL_ROLLOFF_FACTOR) error.\n");
	if(_is3D)
	{
		ALfloat position[] = { 0.0f, 0.0f, 0.0f };
		alSourcefv(newChannel->_channelID, AL_POSITION, position);
		if(alGetError() != AL_NO_ERROR) printf("alSourcefv(AL_POSITION) error.\n");
	}
	else
	{
		xVector panoram = xAudioManager::Instance()->GetListener()->GetQuaternion(true) * xVector(_panoram, 0.0f, 0.0f);
		alSourcefv(newChannel->_channelID, AL_POSITION, (ALfloat*)&panoram);
		if(alGetError() != AL_NO_ERROR) printf("alSourcefv(AL_POSITION) error.\n");
	}
	alSourcePlay(newChannel->_channelID);
	if(alGetError() != AL_NO_ERROR) printf("alSourcePlay() error.\n");
	return newChannel;
}

xChannel * xSound::Emit(xEntity * entity)
{
	xChannel * newChannel = Play();
	xVector postion = entity->GetPosition(true);
	newChannel->SetPosition(postion.x, postion.y, postion.z);
	entity->AddChannel(newChannel);
	return newChannel;
}

bool xSound::LoadSound(const char * path)
{
	ALsizei dataSize;
	ALenum  dataFormat;
	xAudioFile * file = new xAudioFile();
	if(!file->Open(path))
	{
		delete file;
		return false;
	}
	void * data = file->Read(&dataSize, &dataFormat, &_pitch);
	if(data == NULL)
	{
		file->Close();
		delete file;
		return false;
	}
	alBufferData(_bufferID, dataFormat, data, dataSize, _pitch);
	if(alGetError() != AL_NO_ERROR) printf("alBufferData() error.\n");
	free(data);
	file->Close();
	delete file;
	return true;
}

bool xSound::Load3DSound(const char * path)
{
	_is3D = true;
	return LoadSound(path);
}

void xSound::SetPitch(int value)
{
	_pitchMultipler = float(value) / float(_pitch);
}

void xSound::SetVolume(float value)
{
	_volume = value;
}

void xSound::SetPanoram(float value)
{
	if(value < -1.0f) value = -1.0f;
	if(value >  1.0f) value =  1.0f;
	_panoram = value;
}

int xSound::GetPitch()
{
	return _pitch * _pitchMultipler;
}

float xSound::GetVolume()
{
	return _volume;
}

float xSound::GetPanoram()
{
	return _panoram;
}

void xSound::Loop(bool state)
{
	_looped = state;
}
