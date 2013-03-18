//
//  TextureItem.m
//  xAtlasGenerator
//
//  Created by Fadeev 'Knightmare' Dmitry on 9/8/10.
//  Copyright 2010 XorsTeam. All rights reserved.
//

#import "TextureItem.h"


@implementation TextureItem

- (id)init
{
	[super init];
	fileName    = @"";
	imageName   = @"";
	frameWidth  = 1;
	frameHeight = 1;
	frames      = 1;
	return self;
}

- (NSString*)fileName
{
	return fileName;
}

- (void)setFileName:(NSString*)value
{
	fileName = value;
	[fileName retain];
}

- (NSString*)imageName
{
	return imageName;
}

- (void)setImageName:(NSString*)value
{
	imageName = value;
	[imageName retain];
}

- (int)frameWidth
{
	return frameWidth;
}

- (void)setFrameWidth:(int)value
{
	frameWidth = value;
}

- (int)frameHeight
{
	return frameHeight;
}

- (void)setFrameHeight:(int)value
{
	frameHeight = value;
}

- (int)frames
{
	return frames;
}

- (void)setFrames:(int)value
{
	frames = value;
}

- (void)addImage:(CGImageRef)value
{
	images.push_back(value);
}

- (CGImageRef)getImage:(int)imageIndex
{
	return images[imageIndex];
}

- (int)countImages
{
	return images.size();
}

- (void)clearImages
{
	images.clear();
}

@end
