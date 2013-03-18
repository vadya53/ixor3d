//
//  texturemanager.h
//  iXors3D
//
//  Created by Fadeev 'Knightmare' Dmitry on 10/26/10.
//  Copyright 2010 XorsTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "texture.h"
#import <vector>
#import <string>

class xTextureManager
{
private:
	class TextureData
	{
	public:
		std::string               filePath;
		int                       flags;
		int                       width;
		int                       height;
		int                       startFrame;
		int                       totalFrames;
		xTexture::TextureBuffer * buffer;
	};
private:
	static xTextureManager     * _instance;
	std::vector<TextureData*>    _loaded;
	std::vector<TextureData*>    _loadedAnimated;
	std::vector<xTexture*>       _created;
	std::string                  _texturePath;
	typedef std::vector<TextureData*>::iterator LoadedTextureIterator;
	typedef std::vector<xTexture*>::iterator TextureIterator;
private:
	xTextureManager();
	xTextureManager(const xTextureManager & other);
	const xTextureManager & operator=(const xTextureManager & other);
	~xTextureManager();
	LoadedTextureIterator FindTexture(const char * path, int flags);
	LoadedTextureIterator FindTexture(xTexture::TextureBuffer * texture);
	LoadedTextureIterator FindAnimatedTexture(const char * path, int flags, int frameWidth, int frameHeight, int firstFrame, int frameCount);
	LoadedTextureIterator FindAnimatedTexture(xTexture::TextureBuffer * texture);
	TextureIterator FindCreatedTexture(xTexture * texture);
public:
	static xTextureManager * Instance();
	xTexture * LoadTexture(const char * path, int flags);
	xTexture * LoadAnimTexture(const char * path, int flags, int frameWidth, int frameHeight, int firstFrame, int frameCount);
	xTexture * CreateTexture(int width, int height, int flags, int frames);
	void ReleaseTexture(xTexture * texture);
	void ReleaseBuffer(void * buffer);
	void Clear();
	void SetTexturePath(const char * path);
	const char * GetTexturePath();
};