//
//  texture.h
//  iXors3D
//
//  Created by Knightmare on 26.08.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ogles.h"
#import "x3dmath.h"
#import <string>

class xTexture
{
friend class xTextureManager;
friend class xImage;
friend class xFont;
friend class xTextureAtlas;
friend class x2DAtlas;
friend class xAudioManager;
private:
	struct TextureBuffer
	{
		GLuint       * _textureID;
		GLsizei        _width, _height;
		GLsizei        _origWidth, _origHeight;
		int            _flags;
		int            _frames;
		std::string    _path;
		GLuint      ** _pixels;
		GLuint      ** _lockedPixels;
		int            _counter;
		bool           _created;
		GLuint       * _renderTargets;
		TextureBuffer();
		~TextureBuffer();
		void Retain();
		void Release();
	};
private:
	TextureBuffer * _buffer;
	float           _uscale, _vscale, _angle, _uoffset, _voffset;
	GLfloat         _matrix[16];
	bool            _needMatrix;
	int             _blendMode;
	int             _textureCoordsSet;
	int             _counter;
private:
	void Mask(uint32_t * pixels, int red, int green, int blue);
	void ComputeAlpha(uint32_t * pixels);
	void FixRGBA(uint32_t * pixels, int width, int height);
	void UpdateMatrix();
	bool Load(const char * path, int flags);
#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
	bool CreateWithUIImage(UIImage * image);
	bool CheckPVR(const char * path);
	bool LoadPVR(const char * path, int loadFlags);
#endif
	bool LoadAnimated(const char * path, int flags, int frameWidth, int frameHeight, int firstFrame, int frames);
	bool Create(int flags, int frameWidth, int frameHeight, int frames);
	bool CreateWithBytes(void * data, unsigned int length);
	xTexture();
	xTexture(TextureBuffer * buffer);
	~xTexture();
	void Release();
	void ForceRelease();
	TextureBuffer * GetBufferObject();
public:
	bool CreatedTexture();
	bool AnimatedTexture();
	int GetWidth();
	int GetHeight();
	GLuint GetTextureID(int frame);
	xTexture * Clone();
	void Lock(int frame);
	uint * GetPixels(int frame);
	void Unlock(int frame);
	GLuint ReadPixel(int x, int y, int frame);
	void WritePixel(int x, int y, GLuint color, int frame);
	int GetCounter();
	void Retain();
	int GetFlags();
	void SetFlags(int flags);
	void SetScale(float u, float v);
	void SetOffset(float u, float v);
	void SetRotation(float angle);
	void SetMatrix(int layer);
	int GetBlendMode();
	void SetBlendMode(int mode);
	void SetCoordsSet(int setNum);
	int GetCoordsSet();
	const char * GetPath();
	int FramesCount();
	bool IsLocked(int frame);
	void ApplyMask(int red, int green, int blue);
	void SetTarget(int frame);
	void DeletePixels();
};