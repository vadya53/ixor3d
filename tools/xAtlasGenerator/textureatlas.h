//
//  textureatlas.h
//  iXors3D
//
//  Created by Knightmare on 7/3/10.
//  Copyright 2010 XorsTeam. All rights reserved.
//

#ifndef _TEXTUREATLAS_H_
#define _TEXTUREATLAS_H_

#import <vector>
#import <Cocoa/Cocoa.h>

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
		CGImageRef texture;
		int        frame;
		int        counter;
	public:
		xAtlasRegion();
		xAtlasRegion(int _x, int _y, int _w, int _h, CGImageRef _texture, int _frame);
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
	CGImageRef                    _atlasTexture;
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
	bool AddTexture(CGImageRef texture, int frame);
	void DeleteTexture(CGImageRef texture, int frame);
	xAtlasRegion GetTextureRegion(CGImageRef texture, int frame);
	CGImageRef GetTexture();
	void RebuildTexture();
};

#endif