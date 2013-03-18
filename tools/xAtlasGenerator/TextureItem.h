//
//  TextureItem.h
//  xAtlasGenerator
//
//  Created by Fadeev 'Knightmare' Dmitry on 9/8/10.
//  Copyright 2010 XorsTeam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <vector>

@interface TextureItem : NSObject
{
	NSString                * fileName;
	NSString                * imageName;
	int                       frameWidth;
	int                       frameHeight;
	int                       frames;
	std::vector<CGImageRef>   images;
}

- (id)init;
- (NSString*)fileName;
- (void)setFileName:(NSString*)value;
- (NSString*)imageName;
- (void)setImageName:(NSString*)value;
- (int)frameWidth;
- (void)setFrameWidth:(int)value;
- (int)frameHeight;
- (void)setFrameHeight:(int)value;
- (int)frames;
- (void)setFrames:(int)value;
- (void)addImage:(CGImageRef)value;
- (CGImageRef)getImage:(int)imageIndex;
- (int)countImages;
- (void)clearImages;

@end
