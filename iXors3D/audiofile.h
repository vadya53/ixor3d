//
//  audiofile.h
//  iXors3D
//
//  Created by Knightmare on 20.12.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import <Foundation/Foundation.h>
// OpenAL
#import <OpenAL/al.h>
#import <OpenAL/alc.h>
// iPhone toolbox
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/ExtendedAudioFile.h>
// OGG Vorbis
#import "ivorbiscodec.h"
#import "ivorbisfile.h"

class xAudioFile
{
private:
	ExtAudioFileRef               _extFile;
	FILE                        * _oggFile;
	OggVorbis_File                _oggStream;
	vorbis_info                 * _vorbisInfo;
	AudioStreamBasicDescription   _outputFormat;
	AudioStreamBasicDescription   _fileFormat;
	SInt64                        _fileLength;
	bool                          _proceedMusic;
public:
	xAudioFile();
	bool Open(const char * path);
	void * Read(ALsizei * dataSize, ALenum * dataFormat, ALsizei * sampleRate, bool stream = false, bool looped = false);
	bool ProccedMusic();
	void Close();
};