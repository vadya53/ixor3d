//
//  quadtree.h
//  iXors3D
//
//  Created by Fadeev 'Knightmare' Dmitry on 9/29/10.
//  Copyright 2010 XorsTeam. All rights reserved.
//

#import <vector>
#import "camera.h"

class xQuadTree;
typedef std::vector<xQuadTree*> LeavesArray;

class xQuadTree
{
private:
	LeavesArray _leaves;
	int         _x, _y, _size;
private:
	void AddLeav(xQuadTree * leav);
	bool InView(xCamera * camera, xTransform & world);
public:
	xQuadTree();
	void Build(int x, int y, int size);
	int GetX();
	int GetY();
	int GetSize();
	void ComputeVisibleLeaves(LeavesArray * leaves, xCamera * camera, xTransform & world);
	void GetAllLeaves(LeavesArray * leaves);
	void Release();
	xQuadTree * Clone();
};