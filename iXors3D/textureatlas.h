//
//  textureatlas.h
//  iXors3D
//
//  Created by Knightmare on 7/3/10.
//  Copyright 2010 XorsTeam. All rights reserved.
//

#ifndef _TEXTUREATLAS_H_
#define _TEXTUREATLAS_H_

#import "texture.h"
#import <vector>

#define MAX_ATLAS_SIZE 4096

class xTextureAtlas
{
public:
    struct xAtlasPosition
    {
	public:
		int x, y;
	public:
		xAtlasPosition();
		xAtlasPosition(int _x, int _y);
		bool operator ==(const xAtlasPosition & position) const;
    };
    struct xAtlasRegion : public xAtlasPosition
    {
	public:
		int        width, height;
		xTexture * texture;
		int        frame;
		int        counter;
	public:
		xAtlasRegion();
		xAtlasRegion(int _x, int _y, int _w, int _h, xTexture * _texture, int _frame);
		bool Contains(const xAtlasPosition & position) const;
		bool Contains(const xAtlasRegion & region) const;
		bool Intersects(const xAtlasRegion & region) const;
		static bool Greater(const xAtlasRegion & first, const xAtlasRegion & second);
    };
private:
	xAtlasRegion                  _size;
	std::vector<xAtlasRegion>     _regions;
	std::vector<xAtlasPosition>   _positions;
	bool                          _updated;
	xTexture                    * _atlasTexture;
private:
	bool IsFree(const xAtlasRegion & region) const;
	void AddPosition(const xAtlasPosition & position);
	void AddRegion(const xAtlasRegion & region);
	bool AddAtEmptySpot(xAtlasRegion & region);
	bool AddAtEmptySpotAutoGrow(xAtlasRegion * region, int maxWidth, int maxHeight);
public:
	xTextureAtlas();
	~xTextureAtlas();
    void Initialize(int width = 1, int height = 1);
    void Release();
	bool Validate() const;
	int GetWidth() const;
	int GetHeight() const;
	bool AddTexture(xTexture * texture, int frame, int maxSize = MAX_ATLAS_SIZE);
	void DeleteTexture(xTexture * texture, int frame, int maxSize = MAX_ATLAS_SIZE);
	xAtlasRegion GetTextureRegion(xTexture * texture, int frame);
	xTexture * GetTexture();
	void RebuildTexture();
	static void EnableDebug(bool flag);
	void SetTexture(xTexture * texture);
	void AddRegion(xTexture * texture, int frame, int x, int y, int width, int height);
};

#endif