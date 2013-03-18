#ifndef _SURFACES_H_
#define _SURFACES_H_

#import "surface.h"

struct LoaderSurface
{
	struct Triangle
	{
		ushort _v0;
		ushort _v1;
		ushort _v2;
		Triangle()
		{
			_v0 = 0;
			_v1 = 0;
			_v2 = 0;
		}
		Triangle(ushort v0, ushort v1, ushort v2)
		{
			_v0 = v0;
			_v1 = v1;
			_v2 = v2;
		}
	};
	LoaderSurface()
	{
		_triangles = new std::vector<Triangle>();
		_vertices  = NULL;
		_materialID = -1;
		//_vertices.resize(0);
		_triangles->resize(0);
		_cntAlphaVertex = 0;
	}
	void Release(int index)
	{
		if(index == 0)
		{
			if(_vertices != NULL)
			{
				_vertices->clear();
				delete _vertices;
			}
		}
		if(_triangles != NULL)
		{
			_triangles->clear();
			delete _triangles;
		}
	}
	int                       _materialID;
	int						  _cntAlphaVertex;
	int                       _flags;
	std::vector<xVertex> *    _vertices;
	std::vector<Triangle>   * _triangles;
};

typedef std::vector<LoaderSurface> SurfacesArray;

#endif