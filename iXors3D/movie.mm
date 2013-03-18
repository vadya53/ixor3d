//
//  movie.mm
//  iXors3D
//
//  Created by Knightmare on 07.12.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import <TargetConditionals.h>
#import "movie.h"

#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR

#import <string>

xMovie::xMovie()
{
	_player  = NULL;
	_playing = NULL;
}

bool xMovie::OpenFile(const char * path)
{
	// get file url
	std::string filePath = "";
	std::string fileName = path;
	int slashPos = fileName.find_last_of('/');
	if(slashPos != fileName.npos)
	{
		filePath = fileName.substr(0, slashPos);
		fileName = fileName.substr(slashPos + 1);
	}
	NSString * realPath      = [[NSBundle mainBundle] pathForResource: [NSString stringWithUTF8String: fileName.c_str()] ofType: nil inDirectory: (filePath.length() == 0 ? nil : [NSString stringWithUTF8String: filePath.c_str()])];
	NSURL    * fileURL       = [NSURL fileURLWithPath: realPath];
	// open file
	_playing                 = [[MoviePlaying alloc] init];
	_playing.playing         = false;
	_player                  = [[MPMoviePlayerController alloc] initWithContentURL: fileURL];
	if(!_player)
	{
		printf("ERROR(%s:%i): Unable to load movie from file '%s'\n", __FILE__, __LINE__, path);
		return false;
	}
	_player.scalingMode      = MPMovieScalingModeAspectFit;
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 30200
	_player.movieControlMode = MPMovieControlModeHidden;
#else
	_player.controlStyle = MPMovieControlStyleNone;
#endif
	return true;
}

void xMovie::Play()
{
	[_player play];
	// add observer
    [[NSNotificationCenter defaultCenter] addObserver: _playing
											 selector: @selector(movePlaybackFinished:)
												 name: MPMoviePlayerPlaybackDidFinishNotification
											   object: _player];
	_playing.playing = true;
}

void xMovie::Stop()
{
	[_player stop];
	[[NSNotificationCenter defaultCenter] removeObserver: _playing
													name: MPMoviePlayerPlaybackDidFinishNotification
												  object: _player];
	_playing.playing = false;
}

void xMovie::Release()
{
	if(_playing)
	{
		[[NSNotificationCenter defaultCenter] removeObserver: _playing
														name: MPMoviePlayerPlaybackDidFinishNotification
													  object: _player];
		[_playing release];
	}
	if(_player) [_player release];
}

bool xMovie::Playing()
{
	if(_playing == NULL) return false;
	return _playing.playing;
}

@implementation MoviePlaying

@synthesize playing;

-(void)movePlaybackFinished: (NSNotification*)notification
{
	MPMoviePlayerController * player = [notification object];
    [[NSNotificationCenter defaultCenter] removeObserver: self
													name: MPMoviePlayerPlaybackDidFinishNotification
												  object: player];
	playing = false;
}

@end

#else

#import <string>

xMovie::xMovie()
{
}

bool xMovie::OpenFile(const char * path)
{
		return true;
}

#endif