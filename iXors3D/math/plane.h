//
//  plane.h
//  iXors3D
//
//  Created by Knightmare on 02.09.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "line.h"

class xPlane
{
public:
	xVector normal;
	float   d;
public:
	xPlane();
	xPlane(const xVector &_normal, float _d);
	xPlane(const xVector &_point, const xVector &_normal);
	xPlane(const xVector &v0, const xVector &v1, const xVector &v2);
	xPlane operator-() const;
	float IntersectTime(const x3DLine &line) const;
	xVector Intersect(const x3DLine &line) const;
	x3DLine Intersect(const xPlane &other) const;
	xVector Nearest(const xVector &vector) const;
	void Negate();
	float Distance(const xVector &vector) const;
	void Normalize();
	xPlane Normalized();
};
