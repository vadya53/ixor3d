//
//  quadtree.mm
//  iXors3D
//
//  Created by Fadeev 'Knightmare' Dmitry on 9/29/10.
//  Copyright 2010 XorsTeam. All rights reserved.
//

#import "quadtree.h"

xQuadTree::xQuadTree()
{
	_x    = 0;
	_y    = 0;
	_size = 0;
}

void xQuadTree::AddLeav(xQuadTree * leav)
{
	_leaves.push_back(leav);
}

void xQuadTree::Build(int x, int y, int size)
{
	_x    = x;
	_y    = y;
	_size = size;
	if(size > 32)
	{
		int newSize = size / 2;
		xQuadTree * newLeav = NULL;
		// [x][0]
		// [0][0]
		newLeav        = new xQuadTree();
		newLeav->_x    = x;
		newLeav->_y    = y;
		newLeav->_size = newSize;
		newLeav->Build(newLeav->_x, newLeav->_y, newSize);
		_leaves.push_back(newLeav);
		// [0][x]
		// [0][0]
		newLeav        = new xQuadTree();
		newLeav->_x    = x + newSize;
		newLeav->_y    = y;
		newLeav->_size = newSize;
		newLeav->Build(newLeav->_x, newLeav->_y, newSize);
		_leaves.push_back(newLeav);
		// [0][0]
		// [x][0]
		newLeav        = new xQuadTree();
		newLeav->_x    = x;
		newLeav->_y    = y + newSize;
		newLeav->_size = newSize;
		newLeav->Build(newLeav->_x, newLeav->_y, newSize);
		_leaves.push_back(newLeav);
		// [0][0]
		// [0][x]
		newLeav        = new xQuadTree();
		newLeav->_x    = x + newSize;
		newLeav->_y    = y + newSize;
		newLeav->_size = newSize;
		newLeav->Build(newLeav->_x, newLeav->_y, newSize);
		_leaves.push_back(newLeav);
	}
}

int xQuadTree::GetX()
{
	return _x;
}

int xQuadTree::GetY()
{
	return _y;
}

int xQuadTree::GetSize()
{
	return _size;
}

bool xQuadTree::InView(xCamera * camera, xTransform & world)
{
	return camera->GetFrustum()->BoxInFrustum(world * xBox(xVector(_x, 0.0f, _y), xVector(_x + _size, 1.0f, _y + _size)));
}

xQuadTree * xQuadTree::Clone()
{
	xQuadTree * newLeave      = new xQuadTree();
	newLeave->_x              = _x;
	newLeave->_y              = _y;
	newLeave->_size           = _size;
	LeavesArray::iterator itr = _leaves.begin();
	while(itr != _leaves.end())
	{
		newLeave->_leaves.push_back((*itr)->Clone());
		itr++;
	}
	return newLeave;
}

void xQuadTree::Release()
{
	LeavesArray::iterator itr = _leaves.begin();
	while(itr != _leaves.end())
	{
		(*itr)->Release();
		delete (*itr);
		itr++;
	}
	_leaves.clear();
}

void xQuadTree::GetAllLeaves(LeavesArray * leaves)
{
	LeavesArray::iterator itr = _leaves.begin();
	while(itr != _leaves.end())
	{
		if((*itr)->_leaves.size() == 0)
		{
			leaves->push_back(*itr);
		}
		else
		{
			(*itr)->GetAllLeaves(leaves);
		}
		itr++;
	}
}

void xQuadTree::ComputeVisibleLeaves(LeavesArray * leaves, xCamera * camera, xTransform & world)
{
	LeavesArray::iterator itr = _leaves.begin();
	while(itr != _leaves.end())
	{
		if((*itr)->InView(camera, world))
		{
			if((*itr)->_leaves.size() == 0)
			{
				leaves->push_back(*itr);
			}
			else
			{
				(*itr)->ComputeVisibleLeaves(leaves, camera, world);
			}
		}
		itr++;
	}
}