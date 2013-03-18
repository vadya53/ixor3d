#ifndef _BONES_H_
#define _BONES_H_

struct LoaderBone
{
	LoaderBone()
	{
		_vertexID = 0;
		_weight   = 1.0f;
	}
	int   _vertexID;
	float _weight;
};

typedef std::vector<LoaderBone> BonesArray;

#endif