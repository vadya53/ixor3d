//
//  terrain.h
//  iXors3D
//
//  Created by Knightmare on 15.09.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ogles.h"
#import "entity.h"
#import "quadtree.h"

class xTerrain : public xEntity
{
private:
	struct TerrainLOD
	{
		ushort                ** _presets;
		int                    * _triangles;
		int                    * _primitives;
	};
	struct TerrainPatch
	{
		xQuadTree * _patch;
		int         _lod;
	};
private:
	static xVertex                 *  _vertices;
	static TerrainLOD              *  _indices;
	xQuadTree                      *  _terrainTree;
	float                          ** _heightMap;
	TerrainPatch                   ** _patches;
	int                               _size;
	bool                              _shade;
	float                             _detail;
	bool                              _shading;
	bool                              _flipped;
private:
	bool ValidateTerrainSize(int size);
	void CalculateNormal(xVector & n, xVector p0, xVector p1, xVector p2);
	int GetLODForPatch(int x, int y);
	int ComputePresetID(int lod, int lod1, int lod2, int lod3, int lod4);
	bool HasAlphaTextures();
public:
	xTerrain();
	void Create(int size);
	bool Load(const char * path);
	void Release();
	int GetSize();
	float GetHeight(int x, int y);
	void Modify(int x, int y, float height);
	void SetShading(bool state);
	xVector GetPoint(xVector coords);
	void SetTerrainDetail(float detail);
	void Draw();
};