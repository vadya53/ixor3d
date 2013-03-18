#ifndef _NODES_H_
#define _NODES_H_

#import <vector>
#import <string>
#import "x3dmath.h"
#import "surfaces.h"
#import "bones.h"
#import "animkeys.h"
#import "animations.h"

struct LoaderNode
{
	LoaderNode()
	{
		_brushID  = -1;
		_name     = "";
		_position = xVector(0.0f, 0.0f, 0.0f);
		_scale    = xVector(1.0f, 1.0f, 1.0f);
		_rotation = xQuaternion(0.0f, 0.0f, 0.0f, 1.0f);
		_surfaces.resize(0);
		_animKeys.resize(0);
		_bones.resize(0);
		_animations.resize(0);
	}
	void Release()
	{
		for(int i = 0; i < _surfaces.size(); i++)
		{
			_surfaces[i].Release(i);
		}
		_surfaces.clear();
		for(int i = 0; i < _subNodes.size(); i++)
		{
			_subNodes[i]->Release();
			delete _subNodes[i];
		}
		_subNodes.clear();
	}
	std::string              _name;
	xVector                  _position;
	xVector                  _scale;
	xQuaternion              _rotation;
	std::vector<LoaderNode*> _subNodes;
	SurfacesArray            _surfaces;
	AnimKeysArray            _animKeys;
	BonesArray               _bones;
	AnimationsArray          _animations;
	int                      _boneID;
	int                      _brushID;
};

typedef std::vector<LoaderNode> NodesArray;

#endif