//
//  terrain.mm
//  iXors3D
//
//  Created by Knightmare on 15.09.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import "terrain.h"
#import "filesystem.h"

const int gridsInPatch = 8;
const float gridSize   = 8.0f;

xVertex              * xTerrain::_vertices = NULL;
xTerrain::TerrainLOD * xTerrain::_indices  = NULL;

bool xTerrain::ValidateTerrainSize(int size)
{
	for(int i = 6; i < 15; i++)
	{
		int pot = 1 << i;
		if(size == pot) return true;
		if(size <  pot) return false;
	}
	return false;
}

void xTerrain::CalculateNormal(xVector & n, xVector p0, xVector p1, xVector p2)
{
	xVector s = p1 - p0;
	xVector t = p2 - p0;
	n = s.Cross(t);
}

xTerrain::xTerrain()
{
	// create vertex buffer
	if(_vertices == NULL)
	{
		_vertices = new xVertex[33 * 33];
		int counter = 0;
		for(int y = 0; y < 33; y++)
		{
			for(int x = 0; x < 33; x++)
			{
				_vertices[counter++] = InitializeVertex();
			}
		}
	}
	// create indices buffers
	if(_indices == NULL)
	{
		_indices = new TerrainLOD[5];
		// create indices presets
		int counter = 0;
		for(int i = 0; i < 5; i++)
		{
			_indices[i]._presets    = new ushort*[9];
			_indices[i]._triangles  = new int[9];
			_indices[i]._primitives = new int[9];
			int size = 32 / (1 << i);
			// #1 - none
			// create buffer
			_indices[i]._presets[0] = new ushort[(size * size * 2) * 3];
			if(_indices[i]._presets[0] == NULL)
			{
				printf("ERROR(%s:%i): Unable to create new index buffer for terrain LODs.", __FILE__, __LINE__);
			}
			// lock buffer
			ushort * indices = _indices[i]._presets[0];
			counter = 0;
			// write indices
			_indices[i]._triangles[0] = 0;
			for(int y = 0; y < size; y++)
			{
				indices[counter++] = (y + 0) * (size + 1);
				indices[counter++] = (y + 1) * (size + 1);
				for(int x = 0; x < size; x++)
				{
					indices[counter++] = (y + 0) * (size + 1) + x + 1;
					indices[counter++] = (y + 1) * (size + 1) + x + 1;
					_indices[i]._triangles[0] += 2;
				}
				if(y != size - 1)
				{
					indices[counter++] = (y + 1) * (size + 1) + size;
					indices[counter++] = (y + 1) * (size + 1);
				}
			}
			_indices[i]._primitives[0] = counter;
			// #2 - down
			// create buffer
			_indices[i]._presets[1] = new ushort[((size * size * 2) - (1 << (4 - i))) * 3];
			if(_indices[i]._presets[1] == NULL)
			{
				printf("ERROR(%s:%i): Unable to create new index buffer for terrain LODs.", __FILE__, __LINE__);
			}
			indices = _indices[i]._presets[1];
			// write indices
			counter = 0;
			_indices[i]._triangles[1] = 0;
			for(int y = 0; y < size - 1; y++)
			{
				indices[counter++] = (y + 0) * (size + 1);
				indices[counter++] = (y + 1) * (size + 1);
				for(int x = 0; x < size; x++)
				{
					indices[counter++] = (y + 0) * (size + 1) + x + 1;
					indices[counter++] = (y + 1) * (size + 1) + x + 1;
					_indices[i]._triangles[1] += 2;
				}
				if(y != size - 1)
				{
					indices[counter++] = (y + 1) * (size + 1) + size;
					indices[counter++] = (y + 1) * (size + 1);
				}
			}
			for(int x = 0; x < size; x += 2)
			{
				indices[counter++] = (size - 1) * (size + 1) + x;
				indices[counter++] = (size + 0) * (size + 1) + x;
				indices[counter++] = (size - 1) * (size + 1) + x + 1;
				indices[counter++] = (size + 0) * (size + 1) + x + 2;
				indices[counter++] = (size - 1) * (size + 1) + x + 2;
				if(x != size - 2) indices[counter++] = (size + 0) * (size + 1) + x + 2;
				_indices[i]._triangles[2] += 3;
			}
			_indices[i]._primitives[1] = counter;
			// #3 - left
			// create buffer
			_indices[i]._presets[2] = new ushort[(size * size * 2 - (1 << (4 - i))) * 3];
			if(_indices[i]._presets[2] == NULL)
			{
				printf("ERROR(%s:%i): Unable to create new index buffer for terrain LODs.", __FILE__, __LINE__);
			}
			// lock buffer
			indices = _indices[i]._presets[2];
			counter = 0;
			// write indices
			_indices[i]._triangles[2] = 0;
			for(int y = 0; y < size; y++)
			{
				indices[counter++] = (y + 0) * (size + 1) + 1;
				indices[counter++] = (y + 1) * (size + 1) + 1;
				for(int x = 1; x < size; x++)
				{
					indices[counter++] = (y + 0) * (size + 1) + x + 1;
					indices[counter++] = (y + 1) * (size + 1) + x + 1;
					_indices[i]._triangles[2] += 2;
				}
				if(y != size - 1)
				{
					indices[counter++] = (y + 1) * (size + 1) + size;
					indices[counter++] = (y + 1) * (size + 1) + 1;
				}
			}
			indices[counter++] = size * (size + 1) + size;
			indices[counter++] = 1;
			for(int y = 0; y < size; y += 2)
			{
				indices[counter++] = (y + 0) * (size + 1) + 1;
				indices[counter++] = (y + 0) * (size + 1) + 0;
				indices[counter++] = (y + 1) * (size + 1) + 1;
				indices[counter++] = (y + 2) * (size + 1) + 0;
				indices[counter++] = (y + 2) * (size + 1) + 1;
				if(y != size - 2) indices[counter++] = (y + 2) * (size + 1) + 0;
				_indices[i]._triangles[3] += 3;
			}
			_indices[i]._primitives[2] = counter;
			// #4 - up
			// create buffer
			_indices[i]._presets[3] = new ushort[(size * size * 2 - (1 << (4 - i))) * 3];
			if(_indices[i]._presets[3] == NULL)
			{
				printf("ERROR(%s:%i): Unable to create new index buffer for terrain LODs.", __FILE__, __LINE__);
			}
			// lock buffer
			indices = _indices[i]._presets[3];
			counter = 0;
			// write indices
			_indices[i]._triangles[3] = 0;
			for(int y = 1; y < size; y++)
			{
				indices[counter++] = (y + 0) * (size + 1);
				indices[counter++] = (y + 1) * (size + 1);
				for(int x = 0; x < size; x++)
				{
					indices[counter++] = (y + 0) * (size + 1) + x + 1;
					indices[counter++] = (y + 1) * (size + 1) + x + 1;
					_indices[i]._triangles[3] += 2;
				}
				if(y != size - 1)
				{
					indices[counter++] = (y + 1) * (size + 1) + size;
					indices[counter++] = (y + 1) * (size + 1);
				}
			}
			indices[counter++] = size * (size + 1) + size;
			indices[counter++] = size + 1;
			indices[counter++] = size + 1;
			for(int x = 0; x < size; x += 2)
			{
				indices[counter++] = 1 * (size + 1) + x + 0;
				indices[counter++] = 0 * (size + 1) + x + 0;
				indices[counter++] = 1 * (size + 1) + x + 1;
				indices[counter++] = 0 * (size + 1) + x + 2;
				indices[counter++] = 1 * (size + 1) + x + 2;
				if(x != size - 2) indices[counter++] = 1 * (size + 1) + x + 2;
				_indices[i]._triangles[3] += 3;
			}
			_indices[i]._primitives[3] = counter;
			// #5 - right
			// create buffer
			_indices[i]._presets[4] = new ushort[(size * size * 2 - (1 << (4 - i))) * 3];
			if(_indices[i]._presets[4] == NULL)
			{
				printf("ERROR(%s:%i): Unable to create new index buffer for terrain LODs.", __FILE__, __LINE__);
			}
			// lock buffer
			indices = _indices[i]._presets[4];
			counter = 0;
			// write indices
			_indices[i]._triangles[4] = 0;
			for(int y = 0; y < size; y++)
			{
				indices[counter++] = (y + 0) * (size + 1);
				indices[counter++] = (y + 1) * (size + 1);
				for(int x = 0; x < size - 1; x++)
				{
					indices[counter++] = (y + 0) * (size + 1) + x + 1;
					indices[counter++] = (y + 1) * (size + 1) + x + 1;
					_indices[i]._triangles[4] += 2;
				}
				if(y != size - 1)
				{
					indices[counter++] = (y + 1) * (size + 1) + size - 1;
					indices[counter++] = (y + 1) * (size + 1);
				}
			}
			indices[counter++] = size * (size + 1) + size - 1;
			indices[counter++] = size - 1;
			indices[counter++] = size - 1;
			for(int y = 0; y < size; y += 2)
			{
				indices[counter++] = (y + 0) * (size + 1) + size - 1;
				indices[counter++] = (y + 0) * (size + 1) + size - 0;
				indices[counter++] = (y + 1) * (size + 1) + size - 1;
				indices[counter++] = (y + 2) * (size + 1) + size - 0;
				indices[counter++] = (y + 2) * (size + 1) + size - 1;
				if(y != size - 2) indices[counter++] = (y + 2) * (size + 1) + size - 1;
				_indices[i]._triangles[4] += 3;
			}
			_indices[i]._primitives[4] = counter;
			// #6 - left-down
			// create buffer
			_indices[i]._presets[5] = new ushort[(size * size * 2 - (1 << (4 - i)) * 2) * 3];
			if(_indices[i]._presets[5] == NULL)
			{
				printf("ERROR(%s:%i): Unable to create new index buffer for terrain LODs.", __FILE__, __LINE__);
			}
			// lock buffer
			indices = _indices[i]._presets[5];
			counter = 0;
			// write indices
			_indices[i]._triangles[5] = 0;
			for(int y = 0; y < size - 1; y++)
			{
				indices[counter++] = (y + 0) * (size + 1) + 1;
				indices[counter++] = (y + 1) * (size + 1) + 1;
				for(int x = 1; x < size; x++)
				{
					indices[counter++] = (y + 0) * (size + 1) + x + 1;
					indices[counter++] = (y + 1) * (size + 1) + x + 1;
					_indices[i]._triangles[5] += 2;
				}
				if(y != size - 2)
				{
					indices[counter++] = (y + 1) * (size + 1) + size;
					indices[counter++] = (y + 1) * (size + 1) + 1;
				}
			}
			indices[counter++] = (size - 1) * (size + 1) + size;
			indices[counter++] = (size - 0) * (size + 1) + 0;
			indices[counter++] = (size - 0) * (size + 1) + 0;
			indices[counter++] = (size - 0) * (size + 1) + 0;
			indices[counter++] = (size - 1) * (size + 1) + 1;
			indices[counter++] = (size - 0) * (size + 1) + 2;
			indices[counter++] = (size - 1) * (size + 1) + 2;
			indices[counter++] = (size - 1) * (size + 1) + 2;
			_indices[i]._triangles[5] += 2;
			for(int x = 2; x < size; x += 2)
			{
				indices[counter++] = (size - 1) * (size + 1) + x + 0;
				indices[counter++] = (size - 0) * (size + 1) + x + 0;
				indices[counter++] = (size - 1) * (size + 1) + x + 1;
				indices[counter++] = (size - 0) * (size + 1) + x + 2;
				indices[counter++] = (size - 1) * (size + 1) + x + 2;
				if(x != size - 2) indices[counter++] = (size - 1) * (size + 1) + x + 2;
				_indices[i]._triangles[5] += 3;
			}
			indices[counter++] = (size - 1) * (size + 1) + size;
			indices[counter++] = 1;
			indices[counter++] = 1;
			for(int y = 0; y < size - 2; y += 2)
			{
				indices[counter++] = (y + 0) * (size + 1) + 1;
				indices[counter++] = (y + 0) * (size + 1) + 0;
				indices[counter++] = (y + 1) * (size + 1) + 1;
				indices[counter++] = (y + 2) * (size + 1) + 0;
				indices[counter++] = (y + 2) * (size + 1) + 1;
				if(y != size - 2) indices[counter++] = (y + 2) * (size + 1) + 1;
				_indices[i]._triangles[5] += 3;
			}
			if(size > 2) indices[counter++] = (size - 2) * (size + 1) + 1;
			indices[counter++] = (size - 2) * (size + 1) + 0;
			indices[counter++] = (size - 1) * (size + 1) + 1;
			indices[counter++] = (size - 0) * (size + 1) + 0;
			_indices[i]._triangles[5] += 2;
			_indices[i]._primitives[5] = counter;
			// #7 - left-down
			// create buffer
			_indices[i]._presets[6] = new ushort[(size * size * 2 - (1 << (4 - i)) * 2) * 3];
			if(_indices[i]._presets[6] == NULL)
			{
				printf("ERROR(%s:%i): Unable to create new index buffer for terrain LODs.", __FILE__, __LINE__);
			}
			// lock buffer
			indices = _indices[i]._presets[6];
			counter = 0;
			// write indices
			_indices[i]._triangles[6] = 0;
			for(int y = 1; y < size; y++)
			{
				indices[counter++] = (y + 0) * (size + 1) + 1;
				indices[counter++] = (y + 1) * (size + 1) + 1;
				for(int x = 1; x < size; x++)
				{
					indices[counter++] = (y + 0) * (size + 1) + x + 1;
					indices[counter++] = (y + 1) * (size + 1) + x + 1;
					_indices[i]._triangles[6] += 2;
				}
				if(y != size - 1)
				{
					indices[counter++] = (y + 1) * (size + 1) + size;
					indices[counter++] = (y + 1) * (size + 1) + 1;
				}
			}
			indices[counter++] = size * (size + 1) + size;
			indices[counter++] = 0;
			indices[counter++] = 0;
			indices[counter++] = 1 * (size + 1) + 1;
			indices[counter++] = 0 * (size + 1) + 2;
			indices[counter++] = 1 * (size + 1) + 2;
			indices[counter++] = 1 * (size + 1) + 2;
			_indices[i]._triangles[6] += 2;
			for(int x = 2; x < size; x += 2)
			{
				indices[counter++] = 1 * (size + 1) + x + 0;
				indices[counter++] = 0 * (size + 1) + x + 0;
				indices[counter++] = 1 * (size + 1) + x + 1;
				indices[counter++] = 0 * (size + 1) + x + 2;
				indices[counter++] = 1 * (size + 1) + x + 2;
				if(x != size - 2) indices[counter++] = 1 * (size + 1) + x + 2;
				_indices[i]._triangles[6] += 3;
			}
			indices[counter++] = 0 * (size + 1) + size;
			indices[counter++] = 0 * (size + 1) + size;
			if(size != 2) indices[counter++] = 0;
			indices[counter++] = 0;
			indices[counter++] = 1 * (size + 1) + 1;
			indices[counter++] = 2 * (size + 1) + 0;
			indices[counter++] = 2 * (size + 1) + 1;
			_indices[i]._triangles[6] += 2;
			for(int y = 2; y < size; y += 2)
			{
				indices[counter++] = (y + 0) * (size + 1) + 1;
				indices[counter++] = (y + 0) * (size + 1) + 1;
				indices[counter++] = (y + 0) * (size + 1) + 0;
				indices[counter++] = (y + 1) * (size + 1) + 1;
				indices[counter++] = (y + 2) * (size + 1) + 0;
				indices[counter++] = (y + 2) * (size + 1) + 1;
				_indices[i]._triangles[6] += 3;
			}
			_indices[i]._primitives[6] = counter;
			// #8 - up-right
			// create buffer
			_indices[i]._presets[7] = new ushort[(size * size * 2 - (1 << (4 - i)) * 2) * 3];
			if(_indices[i]._presets[7] == NULL)
			{
				printf("ERROR(%s:%i): Unable to create new index buffer for terrain LODs.", __FILE__, __LINE__);
			}
			// lock buffer
			indices = _indices[i]._presets[7];
			counter = 0;
			// write indices
			_indices[i]._triangles[7] = 0;
			for(int y = 1; y < size; y++)
			{
				indices[counter++] = (y + 0) * (size + 1);
				indices[counter++] = (y + 1) * (size + 1);
				for(int x = 0; x < size - 1; x++)
				{
					indices[counter++] = (y + 0) * (size + 1) + x + 1;
					indices[counter++] = (y + 1) * (size + 1) + x + 1;
					_indices[i]._triangles[7] += 2;
				}
				if(y != size - 1)
				{
					indices[counter++] = (y + 1) * (size + 1) + size - 1;
					indices[counter++] = (y + 1) * (size + 1);
				}
			}
			indices[counter++] = size * (size + 1) + size - 1;
			indices[counter++] = size + 1;
			indices[counter++] = size + 1;
			for(int x = 0; x < size - 2; x += 2)
			{
				indices[counter++] = 1 * (size + 1) + x + 0;
				indices[counter++] = 0 * (size + 1) + x + 0;
				indices[counter++] = 1 * (size + 1) + x + 1;
				indices[counter++] = 0 * (size + 1) + x + 2;
				indices[counter++] = 1 * (size + 1) + x + 2;
				indices[counter++] = 1 * (size + 1) + x + 2;
				_indices[i]._triangles[7] += 3;
			}
			indices[counter++] = 1 * (size + 1) + (size - 2);
			indices[counter++] = 0 * (size + 1) + (size - 2);
			indices[counter++] = 1 * (size + 1) + (size - 1);
			indices[counter++] = 0 * (size + 1) + (size - 0);
			indices[counter++] = 2 * (size + 1) + (size - 0);
			indices[counter++] = 2 * (size + 1) + (size - 0);
			indices[counter++] = 1 * (size + 1) + (size - 1);
			indices[counter++] = 2 * (size + 1) + (size - 0);
			indices[counter++] = 2 * (size + 1) + (size - 1);
			_indices[i]._triangles[7] += 4;
			for(int y = 2; y < size; y += 2)
			{
				indices[counter++] = (y + 0) * (size + 1) + (size - 0);
				indices[counter++] = (y + 0) * (size + 1) + (size - 1);
				indices[counter++] = (y + 0) * (size + 1) + (size - 0);
				indices[counter++] = (y + 1) * (size + 1) + (size - 1);
				indices[counter++] = (y + 2) * (size + 1) + (size - 0);
				indices[counter++] = (y + 2) * (size + 1) + (size - 1);
				_indices[i]._triangles[7] += 3;
			}
			_indices[i]._primitives[7] = counter;
			// #9 - down-right
			// create buffer
			_indices[i]._presets[8] = new ushort[(size * size * 2 - (1 << (4 - i)) * 2) * 3];
			if(_indices[i]._presets[8] == NULL)
			{
				printf("ERROR(%s:%i): Unable to create new index buffer for terrain LODs.", __FILE__, __LINE__);
			}
			// lock buffer
			indices = _indices[i]._presets[8];
			counter = 0;
			// write indices
			_indices[i]._triangles[8] = 0;
			for(int y = 0; y < size - 1; y++)
			{
				indices[counter++] = (y + 0) * (size + 1);
				indices[counter++] = (y + 1) * (size + 1);
				for(int x = 0; x < size - 1; x++)
				{
					indices[counter++] = (y + 0) * (size + 1) + x + 1;
					indices[counter++] = (y + 1) * (size + 1) + x + 1;
					_indices[i]._triangles[8] += 2;
				}
				if(y != size - 1)
				{
					indices[counter++] = (y + 1) * (size + 1) + size - 1;
					indices[counter++] = (y + 1) * (size + 1);
				}
			}
			for(int x = 0; x < size - 2; x += 2)
			{
				indices[counter++] = (size - 1) * (size + 1) + x + 0;
				indices[counter++] = (size - 0) * (size + 1) + x + 0;
				indices[counter++] = (size - 1) * (size + 1) + x + 1;
				indices[counter++] = (size - 0) * (size + 1) + x + 2;
				indices[counter++] = (size - 1) * (size + 1) + x + 2;
				indices[counter++] = (size - 1) * (size + 1) + x + 2;
				_indices[i]._triangles[8] += 3;
			}
			indices[counter++] = (size - 1) * (size + 1) + (size - 2);
			indices[counter++] = (size - 0) * (size + 1) + (size - 2);
			indices[counter++] = (size - 1) * (size + 1) + (size - 1);
			indices[counter++] = (size - 0) * (size + 1) + (size - 0);
			indices[counter++] = (size - 2) * (size + 1) + (size - 0);
			indices[counter++] = (size - 2) * (size + 1) + (size - 0);
			indices[counter++] = (size - 1) * (size + 1) + (size - 1);
			indices[counter++] = (size - 2) * (size + 1) + (size - 1);
			_indices[i]._triangles[8] += 4;
			for(int y = size - 2; y > 0; y -= 2)
			{
				indices[counter++] = (y - 0) * (size + 1) + (size - 1);
				indices[counter++] = (y - 0) * (size + 1) + (size - 0);
				indices[counter++] = (y - 1) * (size + 1) + (size - 1);
				indices[counter++] = (y - 2) * (size + 1) + (size - 0);
				indices[counter++] = (y - 2) * (size + 1) + (size - 1);
				if(y != 2) indices[counter++] = (y - 2) * (size + 1) + (size - 1);
				_indices[i]._triangles[8] += 3;
			}
			_indices[i]._primitives[8] = counter;
		}
	}
	//
	_heightMap   = NULL;
	_terrainTree = NULL;
	_size        = 0;
	_patches     = NULL;
	_detail      = 128.0f;
	_shade       = false;
	_shading     = false;
	_flipped     = false;
	_type        = ENTITY_TERRAIN;
}

void xTerrain::Create(int size)
{
	// validate size
	if(!ValidateTerrainSize(size))
	{
		printf("ERROR(%s:%i): Unable to create terrain with size %i", __FILE__, __LINE__, size);
		return;
	}
	// create height map
	_heightMap = new float*[size + 1];
	for(int i = 0; i < size + 1; i++)
	{
		_heightMap[i] = new float[size + 1];
	}
	// fill height map
	for(int x = 0; x < size + 1; x++)
	{
		for(int y = 0; y < size + 1; y++)
		{
			_heightMap[x][y] = 0.0f;
		}
	}
	// create patches map
	_patches = new TerrainPatch*[size / 32];
	for(int i = 0; i < size / 32; i++)
	{
		_patches[i] = new TerrainPatch[size / 32];
	}
	// create quadtree
	_size        = size;
	_terrainTree = new xQuadTree();
	_terrainTree->Build(0, 0, size);
}

bool xTerrain::Load(const char * path)
{
	// load CG image from file
	NSString * realPath = [NSString stringWithUTF8String: xFileSystem::Instance()->GetRealPath(path).c_str()];
#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
	CGImageRef cgImage = [UIImage imageWithContentsOfFile: realPath].CGImage;
#else
	NSImage          * image   = [[NSImage alloc] initWithContentsOfFile: realPath];
	CGImageSourceRef   source  = CGImageSourceCreateWithData((CFDataRef)[image TIFFRepresentation], NULL);
	CGImageRef         cgImage = CGImageSourceCreateImageAtIndex(source, 0, NULL);
	[image release];
#endif
	if(!cgImage)
	{
		printf("ERROR(%s:%i): Unable to load texture from file '%s'. Unable to read file.\n", __FILE__, __LINE__, path);
		return false;
	}
	// get image size
	_size = CGImageGetWidth(cgImage);
	// remap image
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	uint * pixels        = (uint*)malloc(_size * _size * 4);
	CGContextRef context = CGBitmapContextCreate(pixels, _size, _size, 8, 4 * _size, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	CGColorSpaceRelease(colorSpace);
	CGContextDrawImage(context, CGRectMake(0, 0, _size, _size), cgImage);
	// create heightmap
	_heightMap = new float*[_size + 1];
	for(int i = 0; i < _size + 1; i++)
	{
		_heightMap[i] = new float[_size + 1];
	}
	// copy height values
	for(int y = 0; y < _size; y++)
	{
		for(int x = 0; x < _size; x++)
		{
			_heightMap[x][y] = ((float)((pixels[y * _size + x] >> 16) & 0xff)) / 255.0f;
		}
	}
	for(int i = 0; i < _size + 1; i++)
	{
		_heightMap[i][_size] = _heightMap[i][_size - 1];
		_heightMap[_size][i] = _heightMap[_size - 1][i];
	}
	// create patches map
	_patches = new TerrainPatch*[_size / 32];
	for(int i = 0; i < _size / 32; i++)
	{
		_patches[i] = new TerrainPatch[_size / 32];
	}
	// create quadtree
	_terrainTree = new xQuadTree();
	_terrainTree->Build(0, 0, _size);
	// create floating texture for heightmap
	return true;
}

void xTerrain::Release()
{
	for(int i = 0; i < _size + 1; i++)
	{
		delete [] _heightMap[i];
	}
	delete [] _heightMap;
}

void xTerrain::SetTerrainDetail(float detail)
{
	_detail = detail;
}

int xTerrain::GetSize()
{
	return _size;
}

float xTerrain::GetHeight(int x, int y)
{
	if(x < 0 || x >= _size || y < 0 || y >= _size) return 0.0f;
	return _heightMap[x][y];
}

void xTerrain::Modify(int x, int y, float height)
{
	if(x < 0 || x >= _size || y < 0 || y >= _size) return;
	_heightMap[x][y] = height;
}

void xTerrain::SetShading(bool state)
{
	_shade = state;
}

float Lerp(float a, float b, float t)
{
	return a - (a * t) + (b * t);
}

xVector xTerrain::GetPoint(xVector coords)
{
	coords = GetWorldTransform().Inversed() * coords;
	float x = coords.x / gridSize; 
    float z = coords.z / gridSize;
	float col = floorf(z);
	float row = floorf(x);
	float A = GetHeight(row + 0, col + 0);
	float B = GetHeight(row + 0, col + 1);
	float C = GetHeight(row + 1, col + 0);
	float D = GetHeight(row + 1, col + 1);
	float dx = z - col;
	float dz = x - row;
	coords.y = 0.0f;
	if(dz < 1.0f - dx)
	{
		float uy = B - A;
		float vy = C - A;
		coords.y = A + Lerp(0.0f, uy, dx) + Lerp(0.0f, vy, dz);
	}
	else
	{
		float uy = C - D;
		float vy = B - D;
		coords.y = D + Lerp(0.0f, uy, 1.0f - dx) + Lerp(0.0f, vy, 1.0f - dz);
	}
	return GetWorldTransform() * coords;
}

void xTerrain::Draw()
{
	// check quadtree
	if(_terrainTree == NULL) return;
	// check ordered rendering
	if(GetOrder() != 0 && !xRender::Instance()->OrderedStage()) return;
	// check transparent rendering
	if(GetOrder() == 0 || !xRender::Instance()->OrderedStage())
	{
		if(_masterBrush.alpha < 1.0f || _masterBrush.blendMode != 1 || HasAlphaTextures())
		{
			if(!xRender::Instance()->TransparentStage())
			{
				xRender::Instance()->AddTransparent(this);
				return;
			}
		}
		else if(xRender::Instance()->TransparentStage()) return;
	}
	// getting world matrix
	xTransform worldMatrix = GetWorldTransform();
	// getting active camera
	xCamera * activeCamera = xRender::Instance()->GetActiveCamera();
	// compute visible leaves
	LeavesArray leaves;
	_terrainTree->ComputeVisibleLeaves(&leaves, activeCamera, worldMatrix);
	if(leaves.size() == 0) return;
	// setting vertex buffer
	// set vertex pointer
	glVertexPointer(3, GL_FLOAT, sizeof(xVertex), &_vertices[0].x);
	// set normals pointer
	glNormalPointer(GL_FLOAT, sizeof(xVertex), &_vertices[0].nx);
	// set colors pointer
	glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(xVertex), &_vertices[0].color);
	// set texture coords pointer
	int textureLayer = 0;
	for(int i = 0; i < xRender::Instance()->GetMaxTextureUnits(); i++)
	{
		if(_masterBrush.textures[i].texture != NULL)
		{
			glClientActiveTexture(GL_TEXTURE0 + textureLayer);
			glEnableClientState(GL_TEXTURE_COORD_ARRAY);
			if(_masterBrush.textures[i].texture->GetCoordsSet() == 0)
			{
				glTexCoordPointer(2, GL_FLOAT, sizeof(xVertex), &_vertices[0].tu1);
			}
			else
			{
				glTexCoordPointer(2, GL_FLOAT, sizeof(xVertex), &_vertices[0].tu2);
			}
			textureLayer++;
		}
	}
	// enable states
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_NORMAL_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);	
	// disable alphablending
	glDisable(GL_BLEND);
	// getting camera poisition
	xVector cameraPosition = activeCamera->GetPosition(true);
	// capture device states
	bool fogEnabled = glIsEnabled(GL_FOG);
	// setting textures
	xRender::Instance()->ResetTextureLayers();
	bool needAlphaTest  = false;
	bool needAlphaBlend = false;
	for(int i = 0; i < xRender::Instance()->GetMaxTextureUnits(); i++)
	{
		if(_masterBrush.textures[i].texture != NULL)
		{
			needAlphaBlend |= _masterBrush.textures[i].texture->GetFlags() & 2;
			needAlphaTest  |= _masterBrush.textures[i].texture->GetFlags() & 4;
			xRender::Instance()->SetTexture(_masterBrush.textures[i].texture, _masterBrush.textures[i].frame);
		}
	}
	// fullbright flag
	bool * lightStates = new bool[xRender::Instance()->GetMaxLights()];
	GLfloat ambient[4];
	glEnable(GL_CULL_FACE);
	if(_masterBrush.FX & 1)
	{
		for(int i = 0; i < xRender::Instance()->GetMaxLights(); i++)
		{
			lightStates[i] = glIsEnabled(GL_LIGHT0 + i);
			glDisable(GL_LIGHT0 + i);
		}
		glGetFloatv(GL_LIGHT_MODEL_AMBIENT, ambient);
		GLfloat fullBright[] = { 1.0f, 1.0f, 1.0f, 1.0f };
		glLightModelfv(GL_LIGHT_MODEL_AMBIENT, fullBright);
	}
	else if(!_shading)
	{
		for(int i = 0; i < xRender::Instance()->GetMaxLights(); i++)
		{
			lightStates[i] = glIsEnabled(GL_LIGHT0 + i);
			glDisable(GL_LIGHT0 + i);
		}
	}
	// vertex color flag
	if(_masterBrush.FX & 2)
	{
		glEnable(GL_COLOR_MATERIAL);
	}
	else
	{
		glDisable(GL_COLOR_MATERIAL);
		xVector color = xVector(float(_masterBrush.red) / 255.0f, 
								float(_masterBrush.green) / 255.0f, 
								float(_masterBrush.blue) / 255.0f);
		glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE, &color.x);
		glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, &xVector(1.0f, 1.0f, 1.0f).x);
		glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, _masterBrush.shininess);
	}
	// flat shaded flag
	if(_masterBrush.FX & 4) glShadeModel(GL_FLAT);
	// fog disable flag
	if(_masterBrush.FX & 8) glDisable(GL_FOG);
	// culling disable flag
	if(_masterBrush.FX & 16)
	{
		glDisable(GL_CULL_FACE);
	}
	else if(_flipped)
	{
		glCullFace(GL_CW);
	}
	glDisable(GL_CULL_FACE);
	// setting blend mode
	needAlphaBlend |= _masterBrush.alpha < 1.0f || _masterBrush.blendMode > 1;
	if(needAlphaBlend)
	{
		xRender::Instance()->SetBlend(_masterBrush.blendMode);
	}
	// clear patches map
	for(int x = 0; x < _size / 32; x++)
	{
		for(int y = 0; y < _size / 32; y++)
		{
			_patches[x][y]._patch = NULL;
		}
	}
	// fill patches map
	xTransform worldInverse = worldMatrix.Inversed();
	xVector cameraInTerrain = worldInverse * cameraPosition;
	LeavesArray::iterator itr = leaves.begin();
	while(itr != leaves.end())
	{
		float centerx  = (*itr)->GetX() + 16.5f;
		float centerz  = (*itr)->GetY() + 16.5f;
		float distance = sqrt((centerx - cameraInTerrain.x) * (centerx - cameraInTerrain.x) +
							  (0.0f    - cameraInTerrain.y) * (0.0f    - cameraInTerrain.y) +
							  (centerz - cameraInTerrain.z) * (centerz - cameraInTerrain.z));
		int LODLevel   = int(distance / _detail * 5);
		if(LODLevel < 0) LODLevel = 0;
		if(LODLevel > 4) LODLevel = 4;
		_patches[(*itr)->GetX() / 32][(*itr)->GetY() / 32]._patch = *itr;
		_patches[(*itr)->GetX() / 32][(*itr)->GetY() / 32]._lod   = LODLevel;
		itr++;
	}
	// render all patches
	for(int px = 0; px < _size / 32; px++)
	{
		for(int py = 0; py < _size / 32; py++)
		{
			if(_patches[px][py]._patch != NULL)
			{
				// compute preset for patch
				int lod1   = GetLODForPatch(px - 1, py + 0);
				int lod2   = GetLODForPatch(px + 1, py + 0);
				int lod3   = GetLODForPatch(px + 0, py - 1);
				int lod4   = GetLODForPatch(px + 0, py + 1);
				int preset = ComputePresetID(_patches[px][py]._lod, lod1, lod2, lod3, lod4);
				int counter = 0;
				// write vertices data
				int patchSize = 32 / (1 << _patches[px][py]._lod) + 1;
				for(int y = 0; y < patchSize; y++)
				{
					for(int x = 0; x < patchSize; x++)
					{
						int vx = _patches[px][py]._patch->GetX() + x * (1 << _patches[px][py]._lod);
						int vz = _patches[px][py]._patch->GetY() + y * (1 << _patches[px][py]._lod);
						_vertices[counter].x   = vx;
						_vertices[counter].y   = _heightMap[vx][vz];
						_vertices[counter].z   = vz;
						_vertices[counter].tu1 = float(vx) / float(_size);
						_vertices[counter].tv1 = float(vz) / float(_size);
						_vertices[counter].tu2 = float(x)  / float(patchSize);
						_vertices[counter].tv2 = float(y)  / float(patchSize);
						if(_shading)
						{
							_vertices[counter].nx = 0.0f;
							_vertices[counter].ny = 0.0f;
							_vertices[counter].nz = 0.0f;
						}
						counter++;
					}
				}
				// if shading enable - compute normals
				if(_shading)
				{
					for(int y = 0; y < patchSize - 1; y++)
					{
						for(int x = 0; x < patchSize - 1; x++)
						{
							ushort index1 = (y + 1) * patchSize + x + 0;
							ushort index2 = (y + 0) * patchSize + x + 1;
							ushort index3 = (y + 0) * patchSize + x + 0;
							ushort index4 = (y + 1) * patchSize + x + 1;
							// compute normals
							xVector normal;
							CalculateNormal(normal,
											xVector(_vertices[index1].x, _vertices[index1].y, _vertices[index1].z), 
											xVector(_vertices[index2].x, _vertices[index2].y, _vertices[index2].z), 
											xVector(_vertices[index3].x, _vertices[index3].y, _vertices[index3].z));
							normal.Normalize();
							_vertices[index1].nx += normal.x;
							_vertices[index2].nx += normal.x;
							_vertices[index3].nx += normal.x;
							_vertices[index1].ny += normal.y;
							_vertices[index2].ny += normal.y;
							_vertices[index3].ny += normal.y;
							_vertices[index1].nz += normal.z;
							_vertices[index2].nz += normal.z;
							_vertices[index3].nz += normal.z;
							CalculateNormal(normal,
											xVector(_vertices[index2].x, _vertices[index2].y, _vertices[index2].z), 
											xVector(_vertices[index1].x, _vertices[index1].y, _vertices[index1].z), 
											xVector(_vertices[index4].x, _vertices[index4].y, _vertices[index4].z));
							normal.Normalize();
							_vertices[index2].nx += normal.x;
							_vertices[index1].nx += normal.x;
							_vertices[index4].nx += normal.x;
							_vertices[index2].ny += normal.y;
							_vertices[index1].ny += normal.y;
							_vertices[index4].ny += normal.y;
							_vertices[index2].nz += normal.z;
							_vertices[index1].nz += normal.z;
							_vertices[index4].nz += normal.z;
						}
					}
					// normalize values
					for(int i = 0; i < counter; i++)
					{
						xVector normal;
						normal.x = _vertices[i].nx;
						normal.y = _vertices[i].ny;
						normal.z = _vertices[i].nz;
						normal.Normalize();
						_vertices[i].nx = normal.x;
						_vertices[i].ny = normal.y;
						_vertices[i].nz = normal.z;
					}
				}
				// draw patch
				glDrawElements(GL_TRIANGLE_STRIP, _indices[_patches[px][py]._lod]._primitives[preset], GL_UNSIGNED_SHORT, _indices[_patches[px][py]._lod]._presets[preset]);
				xRender::Instance()->AddTriangles(_indices[_patches[px][py]._lod]._triangles[preset]);
				xRender::Instance()->AddDIP();
			}
		}
	}
	// restore render states
	// restore states
	for(int i = 1; i < xRender::Instance()->GetMaxTextureUnits(); i++)
	{
		glClientActiveTexture(GL_TEXTURE0 + i);
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	}
	glClientActiveTexture(GL_TEXTURE0);
	if(_masterBrush.FX & 1 || !_shading)
	{
		for(int i = 0; i < xRender::Instance()->GetMaxLights(); i++)
		{
			if(lightStates[i]) glEnable(GL_LIGHT0 + i);
		}
		if(_masterBrush.FX & 1) glLightModelfv(GL_LIGHT_MODEL_AMBIENT, ambient);
	}
	if(_masterBrush.FX & 4) glShadeModel(GL_SMOOTH);
	if(_masterBrush.FX & 8 && fogEnabled) glEnable(GL_FOG);
	if(needAlphaTest) glEnable(GL_ALPHA_TEST);
	if(needAlphaBlend)
	{
		glDisable(GL_BLEND);
		glDepthMask(GL_TRUE);
	}
	if(_masterBrush.FX & 16)
	{
		glEnable(GL_CULL_FACE);
	}
	else if(_flipped)
	{
		glCullFace(GL_CCW);
	}
	delete [] lightStates;
}

bool xTerrain::HasAlphaTextures()
{
	for(int i = 0; i < xRender::Instance()->GetMaxTextureUnits(); i++)
	{
		if(_masterBrush.textures[i].texture != NULL && _masterBrush.textures[i].texture->GetFlags() & 2)
		{
			return true;
		}
	}
	return false;
}

int xTerrain::ComputePresetID(int lod, int lod1, int lod2, int lod3, int lod4)
{
	if(lod1 > lod && lod4 > lod) return 5;
	if(lod1 > lod && lod3 > lod) return 6;
	if(lod2 > lod && lod3 > lod) return 7;
	if(lod2 > lod && lod4 > lod) return 8;
	if(lod4 > lod)               return 1;
	if(lod1 > lod)               return 2;
	if(lod3 > lod)               return 3;
	if(lod2 > lod)               return 4;
	return 0;
}

int xTerrain::GetLODForPatch(int x, int y)
{
	if(x < 0 || y < 0 || x >= _size / 32 || y >= _size / 32) return -1;
	if(_patches[x][y]._patch == NULL) return -1;
	return _patches[x][y]._lod;
}