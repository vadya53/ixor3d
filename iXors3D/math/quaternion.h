//
//  quaternion.h
//  iXors3D
//
//  Created by Knightmare on 02.09.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <math.h>
#import "vector.h"

class xQuaternion
{
public:
	float x, y, z, w;
public:
	xQuaternion();
	xQuaternion(float _x, float _y, float _z, float _w);
	xQuaternion operator-() const;
	xQuaternion operator+(const xQuaternion &other) const;
	xQuaternion operator-(const xQuaternion &other) const;
	xQuaternion operator*(const xQuaternion &other) const;
	xVector operator*(const xVector &vector) const;
	xQuaternion operator*(float scale) const;
	xQuaternion operator/(float scale) const;
	float Dot(const xQuaternion &other) const;
	float Length() const;
	void Normalize();
	xQuaternion Normalized() const;
	xQuaternion Slerp(const xQuaternion &other, float factor) const;
	xVector i() const;
	xVector j() const;
	xVector k() const;
	void ShortestArc(const xVector & from, const xVector & to);
};