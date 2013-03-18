//
//  audiomanager.h
//  iXors3D
//
//  Created by Knightmare on 17.09.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "entity.h"
#import <OpenAL/al.h>
#import <OpenAL/alc.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/ExtendedAudioFile.h>
#import "audiofile.h"
#import "image.h"

#define MUSIC_CHANNEL    0x000fade1

class xAudioManager
{
private:
	xEntity                     * _listener;
	static xAudioManager        * _instance;
	ALCcontext                  * _context;
	ALCdevice                   * _device;
	float                         _rolloffFactor;
	float                         _dopplerFactor;
	float                         _speedFactor;
	ALuint                        _musicID;
	ALuint                        _musicBuffers[2];
	xAudioFile                  * _musicFile;
	bool                          _loopedMusic;
	UInt32                        _iPodPlaying;
private:
	xAudioManager();
	xAudioManager(const xAudioManager & other);
	xAudioManager & operator=(const xAudioManager & other);
	~xAudioManager();
	bool OpenMusicFile(const char * path);
	void * GetAudioData(ALsizei * dataSize, ALenum * dataFormat, ALsizei * sampleRate);
	bool StreamBuffer(ALuint bufferID);
	void StopMusicSync();
	bool MusicPlayingSync();
	void StartMusicThread();
public:
	static xAudioManager * Instance();
    ALCcontext * GetALContext();
	void Update();
	xEntity * GetListener();
	void FreeListener();
	void SetRolloffFactor(float value);
	void SetDopplerFactor(float value);
	void SetSpeedFactor(float value);
	float GetRolloffFactor();
	float GetDopplerFactor();
	float GetSpeedFactor();
	xChannel * PlayMusic(const char * path, bool looped);
	void UpdateMusic();
	void StopMusic();
	void PauseMusic();
	void ResumeMusic();
	void MusicVolume(float volume);
	bool MusicPlaying();
	bool iPodPlaying();
	void EnableiPodMusic();
	void DisableiPodMusic();
	void MediaPlayerNextItem();
	void MediaPlayerPrevItem();
	void MediaPlayerToItem(uint itemID);
	void MediaPlayerPlay();
	void MediaPlayerStop();
	void MediaPlayerPause();
	int MediaPlayerState();
	void SetMediaPlayerRepeatMode(int mode);
	int GetMediaPlayerRepeatMode();
	void SetMediaPlayerShuffleMode(int mode);
	int GetMediaPlayerShuffleMode();
	void SetMediaPlayerTime(float newTime);
	float GetMediaPlayerTime();
	uint MediaPlayerItemID();
	int MediaPlayerItemType();
	const char * MediaPlayerItemTitle();
	const char * MediaPlayerItemAlbum();
	const char * MediaPlayerItemArtist();
	const char * MediaPlayerItemGenre();
	const char * MediaPlayerItemComposer();
	int MediaPlayerItemAlbumTrackNumber();
	int MediaPlayerItemDiscNumber();
	xImage * MediaPlayerItemCoverToImage(int width, int height);
	xTexture * MediaPlayerItemCoverToTexture(int width, int height);
	const char * MediaPlayerItemLyrics();
};