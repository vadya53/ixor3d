//
//  font.h
//  iXors3D
//
//  Created by Knightmare on 18.09.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <map>
#import <vector>
#import "texture.h"

class xFont
{
private:
	struct xCharacter
	{
		float x, y, dx, dy;
		int   width;
	};
	struct TextVertex
	{
		GLfloat x, y, tu, tv;
		GLubyte red, green, blue, alpha;
	};
private:
	xTexture                  * _fontTexture;
	std::map<int, xCharacter>   _chars;
	int                         _width;
	int                         _height;
	int                         _symbols;
	unsigned char               _red, _green, _blue;
	bool                        _colorFont;
	int                         _offsetx, _offsety;
	float                       _scalex, _scaley;
	float                         _angle;
	float                       _alpha;
	int                         _blend;
	std::vector<TextVertex>     _textWords;
private:
	int GetLineWidth(const char * text);
	void AddWord(const char * text, int x, int y);
public:
	xFont();
	void Release();
	bool Load(const char * path);
	void DrawText(const char * text, int x, int y, bool centerx, bool centery);
	void DrawTextEx(const char * text, int x, int y, int width);
	int GetFontHeight();
	int GetFontWidth();
	int GetStringHeight(const char * text);
	int GetStringWidth(const char * text);
	void EnableTextureColor(bool state);
	void SetBlend(int blend);
	void SetAlpha(float alpha);
	void SetHandle(int x, int y);
	void SetRotate(float angle);
	void SetScale(float x, float y);
	void SetColor(int r, int g, int b);
};