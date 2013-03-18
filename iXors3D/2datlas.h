//
//  2datlas.h
//  iXors3D
//
//  Created by Fadeev 'Knightmare' Dmitry on 9/6/10.
//  Copyright 2010 XorsTeam. All rights reserved.
//

#import "textureatlas.h"
#import "image.h"
#import <vector>
#import <map>
#import <string>

class x2DAtlas
{
private:
	xTextureAtlas              * _atlas;
	std::vector<xImage*>         _images;
	std::map<std::string, int>   _indexMap;
	bool                         _generated;
public:
	x2DAtlas();
	~x2DAtlas();
	bool Load(const char * path);
	bool AddImage(xImage * image, const char * name);
	int CountImages();
	xImage * GetImage(int index);
	xImage * FindImage(const char * name);
	void GenerateTexture();
	xTexture * GetTexture();
	xTextureAtlas::xAtlasRegion GetTextureRegion(xTexture * texture, int frame);
	void DeleteTexture(xImage * image);
	int GetWidth();
	int GetHeight();
	void Release();
};