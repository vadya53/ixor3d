//
//  audiofile.mm
//  iXors3D
//
//  Created by Knightmare on 20.12.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import "audiofile.h"
#import <string>
#import "filesystem.h"

//#define MUSIC_BATCH_SIZE 131072 //16384 //32768
const int BUFFER_SIZE = 512 * 1024;
#define min(a, b) (a < b ? a : b)

xAudioFile::xAudioFile()
{
	_extFile      = NULL;
	_oggFile      = NULL;
	_vorbisInfo   = NULL;
	_proceedMusic = true;
	_fileLength   = 0;
}

bool xAudioFile::Open(const char * path)
{
	std::string fullPath = xFileSystem::Instance()->GetRealPath(path);
	NSString * realPath  = [NSString stringWithUTF8String: fullPath.c_str()];
	CFURLRef fileURL     = (CFURLRef)[NSURL fileURLWithPath: realPath];
	// use OGG Vorbis codec
	std::string extension = "blah";
	int dotPos = fullPath.find_last_of('.');
	if(dotPos != fullPath.npos) extension = fullPath.substr(dotPos + 1);
	if(extension.length() == 3)
	{
		if(tolower(extension[0]) == 'o' && tolower(extension[1]) == 'g' && tolower(extension[2]) == 'g')
		{
			int result;
			// open ogg
			if(!(_oggFile = fopen([realPath UTF8String], "rb")))
			{
				printf("ERROR(%s:%i): Unable to open OGG file '%s'\n", __FILE__, __LINE__, [realPath UTF8String]);
				return false;
			}
			if((result = ov_open(_oggFile, &_oggStream, NULL, 0)) < 0)
			{
				fclose(_oggFile);
				printf("ERROR(%s:%i): File '%s' is not OGG\n", __FILE__, __LINE__, [realPath UTF8String]);
				return false;
			}
			_vorbisInfo = ov_info(&_oggStream, -1);
			return true;
		}
	}
	// use iPhone codec
	UInt32 propertySize = sizeof(_fileFormat);
	OSStatus error      = ExtAudioFileOpenURL(fileURL, &_extFile);
	if(error)
	{
		printf("ERROR(%s:%i): ExtAudioFileOpenURL() failed with error %ld\n", __FILE__, __LINE__, (long int)error);
		return false;
	}
	// get format
	error = ExtAudioFileGetProperty(_extFile, kExtAudioFileProperty_FileDataFormat, &propertySize, &_fileFormat);
	if(error)
	{
		printf("ERROR(%s:%i): ExtAudioFileGetProperty() failed with error %ld\n", __FILE__, __LINE__, (long int)error);
		ExtAudioFileDispose(_extFile);
		_extFile = NULL;
		return false;
	}
	// check channels count
	if(_fileFormat.mChannelsPerFrame > 2)
	{
		printf("ERROR(%s:%i): Unsupported Format, channel count is greater than stereo.\n", __FILE__, __LINE__);
		ExtAudioFileDispose(_extFile);
		_extFile = NULL;
		return false;
	}
	// set the client format to 16 bit signed integer (native-endian) data
	_outputFormat.mSampleRate       = _fileFormat.mSampleRate;
	_outputFormat.mChannelsPerFrame = _fileFormat.mChannelsPerFrame;
	_outputFormat.mFormatID         = kAudioFormatLinearPCM;
	_outputFormat.mBytesPerPacket   = 2 * _outputFormat.mChannelsPerFrame;
	_outputFormat.mFramesPerPacket  = 1;
	_outputFormat.mBytesPerFrame    = 2 * _outputFormat.mChannelsPerFrame;
	_outputFormat.mBitsPerChannel   = 16;
	_outputFormat.mFormatFlags      = kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger;
	// set the desired client (output) data format
	error = ExtAudioFileSetProperty(_extFile, kExtAudioFileProperty_ClientDataFormat, sizeof(_outputFormat), &_outputFormat);
	if(error)
	{
		printf("ERROR(%s:%i): ExtAudioFileSetProperty() failed with error %ld\n", __FILE__, __LINE__, (long int)error);
		ExtAudioFileDispose(_extFile);
		_extFile = NULL;
		return false;
	}
	propertySize = sizeof(_fileLength);
	error = ExtAudioFileGetProperty(_extFile, kExtAudioFileProperty_FileLengthFrames, &propertySize, &_fileLength);
	if(error)
	{
		printf("ERROR(%s:%i): ExtAudioFileGetProperty() failed with error %ld\n", __FILE__, __LINE__, (long int)error);
		ExtAudioFileDispose(_extFile);
		_extFile = NULL;
		return false;
	}
	return true;
}

void * xAudioFile::Read(ALsizei * dataSize, ALenum * dataFormat, ALsizei * sampleRate, bool stream, bool looped)
{
	void * data = NULL;
	// use OGG Vorbis codec
	if(_oggFile != NULL)
	{
		int size = 0;
		if(!stream)
		{
			const int buffSize = 64 * 1024;
			char * newData     = NULL;
			bool eof           = false;
			int currentSection = 0;
			char * tmpBuff     = new char[buffSize];
			while(!eof)
			{
				int returnValue = ov_read(&_oggStream, &tmpBuff[0], buffSize, &currentSection);
				if(returnValue == 0)
				{
					eof = true;
				}
				else if(returnValue < 0)
				{
					delete [] tmpBuff;
					if(newData) free(newData);
					printf("ERROR(%s:%i): Failed to read data from OGG stream.\n", __FILE__, __LINE__);
					return NULL;
				}
				else
				{
					size += returnValue;
					if(!data)
					{
						newData = (char*)malloc(returnValue);
					}
					else
					{
						newData = (char*)realloc(data, size);
					}
					if(!newData)
					{
						delete [] tmpBuff;
						printf("ERROR(%s:%i): Failed to read data from OGG stream. Not enougch memory.\n", __FILE__, __LINE__);
						return NULL;
					}
					data = newData;
					size_t dest = (size_t)data + (size - returnValue);
					memcpy((char*)dest, &tmpBuff[0], returnValue);
				}
			}
			delete [] tmpBuff;
		}
		else
		{
			data = new char[BUFFER_SIZE];
			int section = 0;
			int result  = 0;
			while(size < BUFFER_SIZE)
			{
				result = ov_read(&_oggStream, ((char*)data) + size, BUFFER_SIZE - size, &section);
				if(result > 0)
				{
					size += result;
				}
				else if(result < 0)
				{
					free(data);
					printf("ERROR(%s:%i): Failed to read data from OGG stream.\n", __FILE__, __LINE__);
					return NULL;
				}
				else
				{
					_proceedMusic = false;
					if(looped)
					{
						ov_raw_seek(&_oggStream, 0);
						_proceedMusic = true;
					}
					break;
				}
			}
			if(size == 0)
			{
				free(data);
				printf("ERROR(%s:%i): Failed to read data from OGG stream.\n", __FILE__, __LINE__);
				return NULL;
			}
		}
		// read ogg information
		*dataSize   = (ALsizei)size;
		*dataFormat = (_vorbisInfo->channels > 1) ? AL_FORMAT_STEREO16 : AL_FORMAT_MONO16;
		*sampleRate = (ALsizei)_vorbisInfo->rate;
	}
	// use iPhone codec
	else if(_extFile != NULL)
	{
		if(!stream)
		{
			// read all the data into memory
			UInt32 fileDataSize = _fileLength * _outputFormat.mBytesPerFrame;
			data                = malloc(fileDataSize);
			if(data)
			{
				AudioBufferList dataBuffer;
				dataBuffer.mNumberBuffers = 1;
				dataBuffer.mBuffers[0].mDataByteSize   = fileDataSize;
				dataBuffer.mBuffers[0].mNumberChannels = _outputFormat.mChannelsPerFrame;
				dataBuffer.mBuffers[0].mData           = data;
				// read the data into an AudioBufferList
				OSStatus error = ExtAudioFileRead(_extFile, (UInt32*)&_fileLength, &dataBuffer);
				if(error == noErr)
				{
					*dataSize   = (ALsizei)fileDataSize;
					*dataFormat = (_outputFormat.mChannelsPerFrame > 1) ? AL_FORMAT_STEREO16 : AL_FORMAT_MONO16;
					*sampleRate = (ALsizei)_outputFormat.mSampleRate;
				}
				else 
				{
					free(data);
					printf("ERROR(%s:%i): ExtAudioFileRead() failed with error %ld\n", __FILE__, __LINE__, (long int)error);
					return NULL;
				}
			}
		}
		else
		{
			// check data size to read
			SInt64 offset  = 0;
			OSStatus error = ExtAudioFileTell(_extFile, &offset);
			if(error)
			{
				printf("ERROR(%s:%i): ExtAudioFileTell() failed with error %ld\n", __FILE__, __LINE__, (long int)error);
				return NULL;
			}
			// read the data into memory
			int MUSIC_BATCH_SIZE   = BUFFER_SIZE / _outputFormat.mBytesPerFrame;
			SInt64 batchSize       = min(MUSIC_BATCH_SIZE, _fileLength - offset);
			UInt32 bufferDataSize  = batchSize * _outputFormat.mBytesPerFrame;
			data                   = malloc(bufferDataSize);
			if(batchSize < MUSIC_BATCH_SIZE) _proceedMusic = false;
			if(data)
			{
				AudioBufferList dataBuffer;
				dataBuffer.mNumberBuffers              = 1;
				dataBuffer.mBuffers[0].mDataByteSize   = bufferDataSize;
				dataBuffer.mBuffers[0].mNumberChannels = _outputFormat.mChannelsPerFrame;
				dataBuffer.mBuffers[0].mData           = data;
				// read the data into an AudioBufferList
				error = ExtAudioFileRead(_extFile, (UInt32*)&batchSize, &dataBuffer);
				if(batchSize == 0) _proceedMusic = false;
				if(error == noErr)
				{
					*dataSize   = (ALsizei)bufferDataSize;
					*dataFormat = (_outputFormat.mChannelsPerFrame > 1) ? AL_FORMAT_STEREO16 : AL_FORMAT_MONO16;
					*sampleRate = (ALsizei)_outputFormat.mSampleRate;
				}
				else
				{
					free(data);
					printf("ERROR(%s:%i): ExtAudioFileRead() failed with error %ld\n", __FILE__, __LINE__, (long int)error);
					return NULL;
				}
			}
			if(looped && !_proceedMusic)
			{
				ExtAudioFileSeek(_extFile, 0);
				_proceedMusic = true;
			}
		}
	}
	return data;
}

bool xAudioFile::ProccedMusic()
{
	return _proceedMusic;
}

void xAudioFile::Close()
{
	if(_extFile != NULL) ExtAudioFileDispose(_extFile);
	if(_oggFile != NULL) ov_clear(&_oggStream);
	_extFile      = NULL;
	_oggFile      = NULL;
	_proceedMusic = true;
	_vorbisInfo   = NULL;
	_fileLength   = 0;
}