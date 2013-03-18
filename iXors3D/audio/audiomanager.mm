//
//  audiomanager.mm
//  iXors3D
//
//  Created by Knightmare on 17.09.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import "audiomanager.h"
#import "channel.h"
#import <pthread.h>
#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
#import <MediaPlayer/MediaPlayer.h>
#import <OpenAL/oalStaticBufferExtension.h>
#endif

#define min(a, b) (a < b ? a : b)

xAudioManager * xAudioManager::_instance = NULL;
static pthread_mutex_t musicMutex;

std::string currentItemTitle    = "";
std::string currentItemAlbum    = "";
std::string currentItemArtist   = "";
std::string currentItemGenre    = "";
std::string currentItemComposer = "";
std::string currentItemLyrics   = "";

void xInterruptionListener(void * clientData, UInt32 interruptionState)
{
    if (interruptionState == kAudioSessionBeginInterruption)
	{
		alcMakeContextCurrent (NULL);
	}
	else if (interruptionState == kAudioSessionEndInterruption)
	{
        ALCcontext * context = xAudioManager::Instance()->GetALContext();
		if (context != NULL)
		{
			alcMakeContextCurrent (context);
		}
		else
		{
			printf("ERROR(%s:%i): Tried to restore OpenGL context, but it appears to be NULL.\n", __FILE__, __LINE__);
		}
	}
}

void * UpdateMusicThread(void * data)
{
	for(;;)
	{
		pthread_mutex_lock(&musicMutex);
		xAudioManager::Instance()->UpdateMusic();
		pthread_mutex_unlock(&musicMutex);
		usleep(100000);
	}
	return NULL;
}

xAudioManager::xAudioManager()
{
	// initialize audio session
#if !TARGET_IPHONE_SIMULATOR && TARGET_OS_EMBEDDED
	OSStatus result = AudioSessionInitialize(NULL, NULL, xInterruptionListener, NULL);
	if (result)
	{
		printf("ERROR(%s:%i): Unable to initialize audio session (error #%i).\n", __FILE__, __LINE__, (int)result);
	}
	else
	{
		// check if iPod music played
		UInt32 size = sizeof(_iPodPlaying);
		result      = AudioSessionGetProperty(kAudioSessionProperty_OtherAudioIsPlaying, &size, &_iPodPlaying);
		if(result)
		{
			printf("ERROR(%s:%i): Unable to get audio session property ('kAudioSessionProperty_OtherAudioIsPlaying', error #%i).\n", __FILE__, __LINE__, (int)result);
		}
		// set category for session
		UInt32 category = (_iPodPlaying) ? kAudioSessionCategory_AmbientSound : kAudioSessionCategory_SoloAmbientSound;
		result          = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
		if(result)
		{
			printf("ERROR(%s:%i): Unable to set audio session category (error #%i).\n", __FILE__, __LINE__, (int)result);
		}
		// set session as active
		result = AudioSessionSetActive(true);
		if(result)
		{
			printf("ERROR(%s:%i): Unable to set audio session as active (error #%i).\n", __FILE__, __LINE__, (int)result);
		}
	}
#endif
	// listener entity
	_listener = new xEntity();
	// destroy old OpenAL if avaliable
	ALCcontext * oldContext = alcGetCurrentContext();
	if(oldContext != NULL)
	{
		ALCdevice * oldDevice = alcGetContextsDevice(oldContext);
		alcMakeContextCurrent(NULL);
		alcDestroyContext(oldContext);
		alcCloseDevice(oldDevice);
	}
	// initialize OpenAL
	// get device
	_device = alcOpenDevice(NULL);
	if(_device == NULL)
	{
		printf("ERROR(%s:%i): Unable to initialize OpenAL.\n", __FILE__, __LINE__);
		return;
	}
	// create context
	_context = alcCreateContext(_device, NULL);
	if(_context == NULL)
	{
		printf("ERROR(%s:%i): Unable to create OpenAL cotext.\n", __FILE__, __LINE__);
		return;
	}
	// seet context as active
	alcMakeContextCurrent(_context);
	if(alGetError() != AL_NO_ERROR) printf("alcMakeContextCurrent() error.\n");
	// clear any errors
	alGetError();
	// set factors
	_rolloffFactor   = 1.0f;
	_speedFactor     = 1.0f;
	_dopplerFactor   = 1.0f;
	_musicID         = -1;
	_musicFile       = NULL;
	_musicBuffers[0] = -1;
	_musicBuffers[1] = -1;
	_loopedMusic     = false;
	//
#if !TARGET_IPHONE_SIMULATOR && TARGET_OS_EMBEDDED
	MPMediaQuery * songs = [[MPMediaQuery alloc] init];
	[[MPMusicPlayerController applicationMusicPlayer] setQueueWithQuery: songs];
	[[MPMusicPlayerController applicationMusicPlayer] skipToBeginning];
#endif
	// update listener
	Update();
}

ALCcontext * xAudioManager::GetALContext()
{
    return _context;
}

void xAudioManager::StartMusicThread()
{
	// start music thread
	pthread_mutexattr_t mutexattr;
	pthread_mutexattr_init(&mutexattr);
	int mutexError = pthread_mutex_init(&musicMutex, &mutexattr);
	if(mutexError != 0)
	{
		printf("ERROR(%s:%i): Error of creating music thread mutex.\n", __FILE__, __LINE__);
	}
	pthread_mutexattr_destroy(&mutexattr);
	pthread_attr_t attr;
    pthread_t      posixThreadID;
	pthread_attr_init(&attr);
	pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
    int threadError = pthread_create(&posixThreadID, &attr, &UpdateMusicThread, NULL);
    pthread_attr_destroy(&attr);
	if(threadError != 0)
	{
		printf("ERROR(%s:%i): Error of creating thread for music proccesing.\n", __FILE__, __LINE__);
	}
}

xAudioManager::xAudioManager(const xAudioManager & other)
{
}

xAudioManager & xAudioManager::operator=(const xAudioManager & other)
{
	return *this;
}

xAudioManager::~xAudioManager()
{
}

xAudioManager * xAudioManager::Instance()
{
	if(_instance == NULL)
	{
		_instance = new xAudioManager();
		_instance->StartMusicThread();
	}
	return _instance;
}

bool xAudioManager::iPodPlaying()
{
	return _iPodPlaying;
}

void xAudioManager::MediaPlayerNextItem()
{
	//iPodMusicPlayer
#if !TARGET_IPHONE_SIMULATOR && TARGET_OS_EMBEDDED
	MPMusicPlayerController * iPod = [MPMusicPlayerController applicationMusicPlayer];
	[iPod skipToNextItem];
#endif
}

void xAudioManager::MediaPlayerPrevItem()
{
#if !TARGET_IPHONE_SIMULATOR && TARGET_OS_EMBEDDED
	MPMusicPlayerController * iPod = [MPMusicPlayerController applicationMusicPlayer];
	[iPod skipToPreviousItem];
#endif
}

void xAudioManager::MediaPlayerPlay()
{
#if !TARGET_IPHONE_SIMULATOR && TARGET_OS_EMBEDDED
	MPMusicPlayerController * iPod = [MPMusicPlayerController applicationMusicPlayer];
	[iPod play];
#endif
}

void xAudioManager::MediaPlayerStop()
{
#if !TARGET_IPHONE_SIMULATOR && TARGET_OS_EMBEDDED
	MPMusicPlayerController * iPod = [MPMusicPlayerController applicationMusicPlayer];
	[iPod stop];
#endif
}

void xAudioManager::MediaPlayerPause()
{
#if !TARGET_IPHONE_SIMULATOR && TARGET_OS_EMBEDDED
	MPMusicPlayerController * iPod = [MPMusicPlayerController applicationMusicPlayer];
	[iPod pause];
#endif
}

int xAudioManager::MediaPlayerState()
{
#if !TARGET_IPHONE_SIMULATOR && TARGET_OS_EMBEDDED
	MPMusicPlayerController * iPod = [MPMusicPlayerController applicationMusicPlayer];
	switch([iPod playbackState])
	{
		case MPMusicPlaybackStateStopped:     return 0;
		case MPMusicPlaybackStatePlaying:     return 1;
		case MPMusicPlaybackStatePaused:      return 2;
		case MPMusicPlaybackStateInterrupted: return 3;
	}
#endif
	return 0;
}

void xAudioManager::SetMediaPlayerTime(float newTime)
{
#if !TARGET_IPHONE_SIMULATOR && TARGET_OS_EMBEDDED
	MPMusicPlayerController * iPod = [MPMusicPlayerController applicationMusicPlayer];
	iPod.currentPlaybackTime = newTime;
#endif
}

float xAudioManager::GetMediaPlayerTime()
{
#if !TARGET_IPHONE_SIMULATOR && TARGET_OS_EMBEDDED
	MPMusicPlayerController * iPod = [MPMusicPlayerController applicationMusicPlayer];
	return (float)iPod.currentPlaybackTime;
#endif
	return 0.0f;
}

void xAudioManager::MediaPlayerToItem(uint itemID)
{
#if !TARGET_IPHONE_SIMULATOR && TARGET_OS_EMBEDDED
	MPMediaQuery * songs = [[MPMediaQuery alloc] init];
	for(MPMediaItem * item in songs.items)
	{
		uint ID = [[item valueForProperty: MPMediaItemPropertyPersistentID] unsignedIntegerValue];
		if(ID == itemID)
		{
			[MPMusicPlayerController applicationMusicPlayer].nowPlayingItem = item;
			return;
		}
	}
#endif
}

void xAudioManager::SetMediaPlayerRepeatMode(int mode)
{
#if !TARGET_IPHONE_SIMULATOR && TARGET_OS_EMBEDDED
	MPMusicPlayerController * iPod = [MPMusicPlayerController applicationMusicPlayer];
	switch(mode)
	{
		case 0:  iPod.repeatMode = MPMusicRepeatModeDefault; break;
		case 1:  iPod.repeatMode = MPMusicRepeatModeNone;    break;
		case 2:  iPod.repeatMode = MPMusicRepeatModeOne;     break;
		case 3:  iPod.repeatMode = MPMusicRepeatModeAll;     break;	
		default: iPod.repeatMode = MPMusicRepeatModeDefault;
	}
#endif
}

int xAudioManager::GetMediaPlayerRepeatMode()
{
#if !TARGET_IPHONE_SIMULATOR && TARGET_OS_EMBEDDED
	MPMusicPlayerController * iPod = [MPMusicPlayerController applicationMusicPlayer];
	switch([iPod repeatMode])
	{
		case MPMusicRepeatModeDefault: return 0;
		case MPMusicRepeatModeNone:    return 1;
		case MPMusicRepeatModeOne:     return 2;
		case MPMusicRepeatModeAll:     return 3;			
	}
#endif
	return 0;
}

void xAudioManager::SetMediaPlayerShuffleMode(int mode)
{
#if !TARGET_IPHONE_SIMULATOR && TARGET_OS_EMBEDDED
	MPMusicPlayerController * iPod = [MPMusicPlayerController applicationMusicPlayer];
	switch(mode)
	{
		case 0:  iPod.shuffleMode = MPMusicShuffleModeDefault; break;
		case 1:  iPod.shuffleMode = MPMusicShuffleModeOff;     break;
		case 2:  iPod.shuffleMode = MPMusicShuffleModeSongs;   break;
		case 3:  iPod.shuffleMode = MPMusicShuffleModeAlbums;  break;
		default: iPod.shuffleMode = MPMusicShuffleModeDefault; break;
	}
#endif
}

int xAudioManager::GetMediaPlayerShuffleMode()
{
#if !TARGET_IPHONE_SIMULATOR && TARGET_OS_EMBEDDED
	MPMusicPlayerController * iPod = [MPMusicPlayerController applicationMusicPlayer];
	switch([iPod shuffleMode])
	{
		case MPMusicShuffleModeDefault: return 0;
		case MPMusicShuffleModeOff:     return 1;
		case MPMusicShuffleModeSongs:   return 2;
		case MPMusicShuffleModeAlbums:  return 3;
	}
#endif
	return 0;
}

uint xAudioManager::MediaPlayerItemID()
{
#if !TARGET_IPHONE_SIMULATOR && TARGET_OS_EMBEDDED
	MPMusicPlayerController * iPod = [MPMusicPlayerController applicationMusicPlayer];
	MPMediaItem * item             = [iPod nowPlayingItem];
	if(item == nil) return 0;
	return [[item valueForProperty: MPMediaItemPropertyPersistentID] unsignedIntValue];
#else
	return 0;
#endif
}

int xAudioManager::MediaPlayerItemType()
{
#if !TARGET_IPHONE_SIMULATOR && TARGET_OS_EMBEDDED
	MPMusicPlayerController * iPod = [MPMusicPlayerController applicationMusicPlayer];
	MPMediaItem * item             = [iPod nowPlayingItem];
	if(item == nil) return -1;
	switch([[item valueForProperty: MPMediaItemPropertyMediaType] integerValue])
	{
		case MPMediaTypeMusic:     return 0;
		case MPMediaTypePodcast:   return 1;
		case MPMediaTypeAudioBook: return 2;
		case MPMediaTypeAnyAudio:  return 3;
	}
#endif
	return -1;
}

const char * xAudioManager::MediaPlayerItemTitle()
{
#if !TARGET_IPHONE_SIMULATOR && TARGET_OS_EMBEDDED
	MPMusicPlayerController * iPod = [MPMusicPlayerController applicationMusicPlayer];
	MPMediaItem * item             = [iPod nowPlayingItem];
	if(item == nil) return NULL;
	currentItemTitle = [[item valueForProperty: MPMediaItemPropertyTitle] UTF8String];
#endif
	return currentItemTitle.c_str();
}

const char * xAudioManager::MediaPlayerItemAlbum()
{
#if !TARGET_IPHONE_SIMULATOR && TARGET_OS_EMBEDDED
	MPMusicPlayerController * iPod = [MPMusicPlayerController applicationMusicPlayer];
	MPMediaItem * item             = [iPod nowPlayingItem];
	if(item == nil) return NULL;
	currentItemAlbum = [[item valueForProperty: MPMediaItemPropertyAlbumTitle] UTF8String];
#endif
	return currentItemAlbum.c_str();
}

const char * xAudioManager::MediaPlayerItemArtist()
{
#if !TARGET_IPHONE_SIMULATOR && TARGET_OS_EMBEDDED
	MPMusicPlayerController * iPod = [MPMusicPlayerController applicationMusicPlayer];
	MPMediaItem * item             = [iPod nowPlayingItem];
	if(item == nil) return NULL;
	currentItemArtist = [[item valueForProperty: MPMediaItemPropertyArtist] UTF8String];
#endif
	return currentItemArtist.c_str();
}

const char * xAudioManager::MediaPlayerItemGenre()
{
#if !TARGET_IPHONE_SIMULATOR && TARGET_OS_EMBEDDED
	MPMusicPlayerController * iPod = [MPMusicPlayerController applicationMusicPlayer];
	MPMediaItem * item             = [iPod nowPlayingItem];
	if(item == nil) return NULL;
	currentItemGenre = [[item valueForProperty: MPMediaItemPropertyGenre] UTF8String];
#endif
	return currentItemGenre.c_str();
}

const char * xAudioManager::MediaPlayerItemComposer()
{
#if !TARGET_IPHONE_SIMULATOR && TARGET_OS_EMBEDDED
	MPMusicPlayerController * iPod = [MPMusicPlayerController applicationMusicPlayer];
	MPMediaItem * item             = [iPod nowPlayingItem];
	if(item == nil) return NULL;
	currentItemComposer = [[item valueForProperty: MPMediaItemPropertyComposer] UTF8String];
#endif
	return currentItemComposer.c_str();
}

int xAudioManager::MediaPlayerItemAlbumTrackNumber()
{
#if !TARGET_IPHONE_SIMULATOR && TARGET_OS_EMBEDDED
	MPMusicPlayerController * iPod = [MPMusicPlayerController applicationMusicPlayer];
	MPMediaItem * item             = [iPod nowPlayingItem];
	if(item == nil) return -1;
	return [[item valueForProperty: MPMediaItemPropertyAlbumTrackNumber] intValue];
#else
	return -1;
#endif
}

int xAudioManager::MediaPlayerItemDiscNumber()
{
#if !TARGET_IPHONE_SIMULATOR && TARGET_OS_EMBEDDED
	MPMusicPlayerController * iPod = [MPMusicPlayerController applicationMusicPlayer];
	MPMediaItem * item             = [iPod nowPlayingItem];
	if(item == nil) return -1;
	return [[item valueForProperty: MPMediaItemPropertyDiscNumber] intValue];
#else
	return -1;
#endif
}

xImage * xAudioManager::MediaPlayerItemCoverToImage(int width, int height)
{
#if !TARGET_IPHONE_SIMULATOR && TARGET_OS_EMBEDDED
	MPMusicPlayerController * iPod = [MPMusicPlayerController applicationMusicPlayer];
	MPMediaItem * item             = [iPod nowPlayingItem];
	if(item == nil) return NULL;
	MPMediaItemArtwork * artwork = [item valueForProperty: MPMediaItemPropertyArtwork];
	if(artwork == nil)
	{
		printf("ERROR(%s:%i): Unable to convert current item cover to image. No cover avaliable.\n", __FILE__, __LINE__);
		return NULL;
	}
	UIImage * uiImage = [artwork imageWithSize: CGSizeMake(width, height)];
	if(uiImage == nil)
	{
		printf("ERROR(%s:%i): Unable to convert current item cover to image. Unable to create UIImage.\n", __FILE__, __LINE__);
		return NULL;
	}
	xImage * newImage = new xImage();
	if(!newImage->CreateWithUIImage(uiImage)) return NULL;
	return newImage;
#else
	return NULL;
#endif
}

xTexture * xAudioManager::MediaPlayerItemCoverToTexture(int width, int height)
{
#if !TARGET_IPHONE_SIMULATOR && TARGET_OS_EMBEDDED
	MPMusicPlayerController * iPod = [MPMusicPlayerController applicationMusicPlayer];
	MPMediaItem * item             = [iPod nowPlayingItem];
	if(item == nil) return NULL;
	MPMediaItemArtwork * artwork = [item valueForProperty: MPMediaItemPropertyArtwork];
	if(artwork == nil)
	{
		printf("ERROR(%s:%i): Unable to convert current item cover to texture. No cover avaliable.\n", __FILE__, __LINE__);
		return NULL;
	}
	UIImage * uiImage = [artwork imageWithSize: CGSizeMake(width, height)];
	if(uiImage == nil)
	{
		printf("ERROR(%s:%i): Unable to convert current item cover to texture. Unable to create UIImage.\n", __FILE__, __LINE__);
		return NULL;
	}
	xTexture * newTexture = new xTexture();
	if(!newTexture->CreateWithUIImage(uiImage)) return NULL;
	return newTexture;
#else
	return NULL;
#endif
}

const char * xAudioManager::MediaPlayerItemLyrics()
{
#if !TARGET_IPHONE_SIMULATOR && TARGET_OS_EMBEDDED
	MPMusicPlayerController * iPod = [MPMusicPlayerController applicationMusicPlayer];
	MPMediaItem * item             = [iPod nowPlayingItem];
	currentItemLyrics = [[item valueForProperty: MPMediaItemPropertyLyrics] UTF8String];
#endif
	return currentItemLyrics.c_str();
}

void xAudioManager::DisableiPodMusic()
{
#if !TARGET_IPHONE_SIMULATOR && TARGET_OS_EMBEDDED
	UInt32 category = kAudioSessionCategory_SoloAmbientSound;
	OSStatus result = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
	if(result)
	{
		printf("ERROR(%s:%i): Unable to set audio session category (error #%i).\n", __FILE__, __LINE__, (int)result);
	}
#endif
}

void xAudioManager::EnableiPodMusic()
{
#if !TARGET_IPHONE_SIMULATOR && TARGET_OS_EMBEDDED
	UInt32 category = kAudioSessionCategory_AmbientSound;
	OSStatus result = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
	if(result)
	{
		printf("ERROR(%s:%i): Unable to set audio session category (error #%i).\n", __FILE__, __LINE__, (int)result);
	}
#endif
}

void xAudioManager::Update()
{
	if(_context == NULL) return;
	// set position and orientation
	xVector position      = _listener->GetPosition(true);
	xVector direction     = _listener->GetQuaternion(true) * xVector(0.0f, 0.0f, -1.0f);
	ALfloat listenerOri[] = { direction.x, direction.y, direction.z, 0.0, 1.0, 0.0 };
	ALfloat listenerPos[] = { position.x, position.y, position.z };
	alListenerfv(AL_POSITION, listenerPos);
	if(alGetError() != AL_NO_ERROR) printf("alListenerfv(AL_POSITION) error.\n");
	alListenerfv(AL_ORIENTATION, listenerOri);
	if(alGetError() != AL_NO_ERROR) printf("alListenerfv(AL_ORIENTATION) error.\n");
	// set factors
	alDopplerFactor(_dopplerFactor);
	if(alGetError() != AL_NO_ERROR) printf("alDopplerFactor() error.\n");
	alSpeedOfSound(343.3f * _speedFactor);
	if(alGetError() != AL_NO_ERROR) printf("alSpeedOfSound() error.\n");
	// update channels
	xChannel::Update();
}

xEntity * xAudioManager::GetListener()
{
	return _listener;
}

void xAudioManager::FreeListener()
{
	_listener = new xEntity();
}

void xAudioManager::SetRolloffFactor(float value)
{
	_rolloffFactor = value;
}

void xAudioManager::SetDopplerFactor(float value)
{
	_dopplerFactor = value;
}

void xAudioManager::SetSpeedFactor(float value)
{
	_speedFactor = value;
}

float xAudioManager::GetRolloffFactor()
{
	return _rolloffFactor;
}

float xAudioManager::GetDopplerFactor()
{
	return _dopplerFactor;
}

float xAudioManager::GetSpeedFactor()
{
	return _speedFactor;
}

void xAudioManager::UpdateMusic()
{
	if(_musicID == -1 || _musicFile == NULL) return;
	int processed = 0;
	alGetSourcei(_musicID, AL_BUFFERS_QUEUED, &processed);
	if(alGetError() != AL_NO_ERROR) printf("alGetSourcei(AL_BUFFERS_QUEUED) error.\n");
	if(processed == 0)
	{
		StopMusicSync();
		return;
	}
	int state = 0;
	alGetSourcei(_musicID, AL_SOURCE_STATE, &state);
	if(state == 0x1014) alSourcePlay(_musicID);
	if(alGetError() != AL_NO_ERROR) printf("alSourcePlay() error.\n");
    alGetSourcei(_musicID, AL_BUFFERS_PROCESSED, &processed);
	if(alGetError() != AL_NO_ERROR) printf("alGetSourcei(AL_BUFFERS_PROCESSED) error.\n");
    while(processed--)
    {
        ALuint buffer;
        alSourceUnqueueBuffers(_musicID, 1, &buffer);
		if(alGetError() != AL_NO_ERROR) printf("alSourceUnqueueBuffers() error.\n");
		if(_musicFile->ProccedMusic())
		{
			if(!StreamBuffer(buffer)) return;
			alSourceQueueBuffers(_musicID, 1, &buffer);
			if(alGetError() != AL_NO_ERROR) printf("alSourceQueueBuffers() error.\n");
		}
    }
}

bool xAudioManager::StreamBuffer(ALuint bufferID)
{
	ALsizei dataSize;
	ALsizei pitch;
	ALenum  dataFormat;
	void * data = GetAudioData(&dataSize, &dataFormat, &pitch);
	if(data == NULL) return false;
	alBufferData(bufferID, dataFormat, data, dataSize, pitch);
	if(alGetError() != AL_NO_ERROR) printf("alBufferData() error.\n");
	free(data);
	return true;
}

xChannel * xAudioManager::PlayMusic(const char * path, bool looped)
{
	pthread_mutex_lock(&musicMutex);
	// check for played music
	if(_musicFile != NULL)
	{
		//ExtAudioFileDispose(_musicFile);
		_musicFile->Close();
		delete _musicFile;
		_musicFile = NULL;
	}
	if(MusicPlayingSync()) StopMusicSync();
	if(_musicID != -1)
	{
		alDeleteSources(1, &_musicID);
		_musicID = -1;
	}
	if(_musicBuffers[0] != -1)
	{
		alDeleteSources(1, &_musicBuffers[0]);
		_musicBuffers[0] = -1;
	}
	if(_musicBuffers[1] != -1)
	{
		alDeleteSources(1, &_musicBuffers[1]);
		_musicBuffers[1] = -1;
	}
	_loopedMusic = looped;
	// read file
	if(!OpenMusicFile(path))
	{
		pthread_mutex_unlock(&musicMutex);
		return NULL;
	}
	// creates buffers and source if needed
	//_proceedMusic = true;
	if(_musicID         == -1) alGenSources(1, &_musicID);
	if(_musicBuffers[0] == -1) alGenBuffers(1, &_musicBuffers[0]);
	if(_musicBuffers[1] == -1) alGenBuffers(1, &_musicBuffers[1]);
	// fill buffers and queue it to source
	if(!StreamBuffer(_musicBuffers[0]))
	{
		pthread_mutex_unlock(&musicMutex);
		return NULL;
	}
    if(!StreamBuffer(_musicBuffers[1]))
	{
		pthread_mutex_unlock(&musicMutex);
		return NULL;
	}
    alSourceQueueBuffers(_musicID, 2, _musicBuffers);
	if(alGetError() != AL_NO_ERROR) printf("alSourceQueueBuffers() error.\n");
	// play source
	alSourcei(_musicID, AL_LOOPING, false);
	if(alGetError() != AL_NO_ERROR) printf("alSourcei(AL_LOOPING) error.\n");
	alSourcei(_musicID, AL_SOURCE_RELATIVE, true);
	if(alGetError() != AL_NO_ERROR) printf("alSourcei(AL_SOURCE_RELATIVE) error.\n");
	alSourcef(_musicID, AL_GAIN, 1.0f);
	if(alGetError() != AL_NO_ERROR) printf("alSourcef(AL_GAIN) error.\n");
	alSource3f(_musicID, AL_POSITION, 0.0, 0.0, 0.0);
	if(alGetError() != AL_NO_ERROR) printf("alSource3f(AL_POSITION) error.\n");
	alSource3f(_musicID, AL_VELOCITY,   0.0, 0.0, 0.0);
	if(alGetError() != AL_NO_ERROR) printf("alSource3f(AL_VELOCITY) error.\n");
    alSource3f(_musicID, AL_DIRECTION,  0.0, 0.0, 0.0);
	if(alGetError() != AL_NO_ERROR) printf("alSource3f(AL_DIRECTION) error.\n");
	alSourcef(_musicID, AL_ROLLOFF_FACTOR,  0.0);
	if(alGetError() != AL_NO_ERROR) printf("alSourcef(AL_ROLLOFF_FACTOR) error.\n");
	alSourcePlay(_musicID);
	if(alGetError() != AL_NO_ERROR) printf("alSourcePlay() error.\n");
	// return pointer
	pthread_mutex_unlock(&musicMutex);
	return (xChannel*)MUSIC_CHANNEL;
}

void xAudioManager::StopMusic()
{
	pthread_mutex_lock(&musicMutex);
	if(_musicID == -1)
	{
		pthread_mutex_unlock(&musicMutex);
		return;
	}
	alSourceStop(_musicID);
	if(alGetError() != AL_NO_ERROR) printf("alSourceStop() error.\n");
	alDeleteSources(1, &_musicID);
	if(alGetError() != AL_NO_ERROR) printf("alDeleteSources() error.\n");
	_musicID = -1;
	alDeleteBuffers(2, _musicBuffers);
	if(alGetError() != AL_NO_ERROR) printf("alDeleteBuffers() error.\n");
	_musicBuffers[0] = -1;
	_musicBuffers[1] = -1;
	pthread_mutex_unlock(&musicMutex);
}

void xAudioManager::StopMusicSync()
{
	if(_musicID == -1) return;
	alSourceStop(_musicID);
	if(alGetError() != AL_NO_ERROR) printf("alSourceStop() error.\n");
	alDeleteSources(1, &_musicID);
	if(alGetError() != AL_NO_ERROR) printf("alDeleteSources() error.\n");
	_musicID = -1;
	alDeleteBuffers(2, _musicBuffers);
	if(alGetError() != AL_NO_ERROR) printf("alDeleteBuffers() error.\n");
	_musicBuffers[0] = -1;
	_musicBuffers[1] = -1;
}

void xAudioManager::PauseMusic()
{
	pthread_mutex_lock(&musicMutex);
	if(_musicID == -1)
	{
		pthread_mutex_unlock(&musicMutex);
		return;
	}
	alSourcePause(_musicID);
	pthread_mutex_unlock(&musicMutex);
}

void xAudioManager::ResumeMusic()
{
	pthread_mutex_lock(&musicMutex);
	if(_musicID == -1)
	{
		pthread_mutex_unlock(&musicMutex);
		return;
	}
	ALint result;
	alGetSourcei(_musicID, AL_SOURCE_STATE, &result);
	if(result == AL_PAUSED) alSourcePlay(_musicID);
	pthread_mutex_unlock(&musicMutex);
}

void xAudioManager::MusicVolume(float volume)
{
	pthread_mutex_lock(&musicMutex);
	if(_musicID == -1)
	{
		pthread_mutex_unlock(&musicMutex);
		return;
	}
	alSourcef(_musicID, AL_GAIN, volume);
	if(alGetError() != AL_NO_ERROR) printf("alSourcef(AL_GAIN) error.\n");
	pthread_mutex_unlock(&musicMutex);
}

bool xAudioManager::MusicPlaying()
{
	pthread_mutex_lock(&musicMutex);
	if(_musicID == -1)
	{
		pthread_mutex_unlock(&musicMutex);
		return false;
	}
	ALint result;
	alGetSourcei(_musicID, AL_SOURCE_STATE, &result);
	pthread_mutex_unlock(&musicMutex);
	return (result == AL_PLAYING || result == AL_PAUSED);
}

bool xAudioManager::MusicPlayingSync()
{
	if(_musicID == -1) return false;
	ALint result;
	alGetSourcei(_musicID, AL_SOURCE_STATE, &result);
	return (result == AL_PLAYING || result == AL_PAUSED);
}

bool xAudioManager::OpenMusicFile(const char * path)
{
	_musicFile = new xAudioFile();
	return _musicFile->Open(path);
}

void * xAudioManager::GetAudioData(ALsizei * dataSize, ALenum * dataFormat, ALsizei * sampleRate)
{
	if(_musicFile == NULL) return NULL;
	return _musicFile->Read(dataSize, dataFormat, sampleRate, true, _loopedMusic);
}