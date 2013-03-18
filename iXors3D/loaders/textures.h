#ifndef _TEXTURES_H_
#define _TEXTURES_H_

#import "texture.h"

struct LoaderTexture
{
	LoaderTexture()
	{
		_filename = "";
		_flags    = 1;
		_blend    = 2;
		_posX     = 0.0f;
		_posY     = 0.0f;
		_scaleX   = 1.0f;
		_scaleY   = 1.0f;
		_rotation = 0.0f;
		_texture  = NULL;
	}
	std::string   _filename;
	int           _flags;
	int           _blend;
	float         _posX;
	float         _posY;
	float         _scaleX;
	float         _scaleY;
	float         _rotation;
	xTexture    * _texture;
};

typedef std::vector<LoaderTexture> TexturesArray;

#endif