//
//  image.h
//  iXors3D
//
//  Created by Knightmare on 27.08.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "texture.h"
#import "render.h"

class x2DAtlas;

class xImage
{
private:
	xTexture       * _texture;
	int              _width, _height;
	int              _offsetx, _offsety;
	float            _scalex, _scaley;
	float              _angle;
	float    		 _red, _green, _blue;
	float            _alpha;
	int              _blend;
	int				src_blend;
	int				dsc_blend;
	int              _frames;
	x2DAtlas       * _atlas;
	static bool      _midHandle;
private:
	void DrawFrame(float x, float y, int frame, int rectX, int rectY, int rectWidth, int rectHeight, bool alpha);
public:
	xImage();
	~xImage();
	void CreateForAtlas(xTexture * texture, x2DAtlas * atlas, int width, int height, int frames);
#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
	bool CreateWithUIImage(UIImage * image);
#endif
	bool Load(const char * path);
	bool LoadAnimated(const char * path, int frameWidth, int frameHeight, int firstFrame, int frames);
	bool Create(int frameWidth, int frameHeight, int frames);
	void Draw(float x, float y, int frame);
	void DrawRect(int x, int y, int frame, int rectX, int rectY, int rectWidth, int rectHeight);
	void DrawBlock(int x, int y, int frame);
	void DrawBlockRect(int x, int y, int frame, int rectX, int rectY, int rectWidth, int rectHeight);
	void SetHandle(int x, int y);
	void SetRotate(float angle);
	void SetScale(float x, float y);
	void Resize(int width, int height);
	int GetWidth();
	int GetHeight();
	int GetXHandle();
	int GetYHandle();
	float GetAngle();
	float GetScaleX();
	float GetScaleY();
	float GetColorRed();
	float GetColorGreen();
	float GetColorBlue();
	float GetColorAlpha();
	void MidHandle();
	static void AutoMidHandle(bool state);
	void Release();
	void Lock(int frame);
	void Unlock(int frame);
	GLuint ReadPixel(int x, int y, int frame);
	void WritePixel(int x, int y, GLuint color, int frame);
	bool Collide(int x1, int y1, int frame1, xImage * img2, int x2, int y2, int frame2);
	bool CollideRect(int x, int y, int frame, int rx, int ry, int rw, int rh);
	bool CollideBoxRect(int x, int y, int rx, int ry, int rw, int rh);
	bool CollideBox(int x1, int y1, xImage * img2, int x2, int y2);
	void Mask(int red, int green, int blue);
	xImage * Clone();
	bool Picked(int x, int y, int frame, int px, int py);
	bool BoxPicked(int x, int y, int px, int py);
	void SetBlend(int blend);
	void SetCustomBlend(int src, int desc);
	void SetColor(int red, int green, int blue);
	void SetAlpha(float alpha);
	void SetTarget(int frame);
	xTexture * GetTexture();
	int CountFrames();
	void DeleteBuffers(x2DAtlas * atlas);
	x2DAtlas * GetAtlas();
	void DeletePixels();
	bool IsLocked(int frame);
};