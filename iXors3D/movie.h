//
//  movie.h
//  iXors3D
//
//  Created by Knightmare on 07.12.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import <TargetConditionals.h>
#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR

#import <MediaPlayer/MediaPlayer.h>

@interface MoviePlaying : NSObject
{
	BOOL playing;
}

@property BOOL playing;

-(void)movePlaybackFinished: (NSNotification*)notification;

@end


class xMovie
{
private:
	MPMoviePlayerController * _player;
	MoviePlaying            * _playing;
public:
	xMovie();
	bool OpenFile(const char * path);
	void Play();
	void Stop();
	void Release();
	bool Playing();
};

#else

#import <AppKit/AppKit.h>
#import <QTKit/QTKit.h>
#import <QuickTime/QuickTime.h>

class xMovie
{
private:
public:
	xMovie();
	bool OpenFile(const char * path);
};

#endif