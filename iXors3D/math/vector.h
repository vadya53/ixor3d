//
//  vector.h
//  iXors3D
//
//  Created by Knightmare on 02.09.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import <Foundation/Foundation.h>

#define X3DEPSILON 0.00001f
#define X3DPI 3.1415f
#define DegToRad(a) (a * (X3DPI / 180.0f))
#define RadToDeg(a) (a * (180.0f / X3DPI))

class xVector
{
public:
	float x, y, z;
public:
	xVector();
	xVector(float _x, float _y, float _z);
	xVector operator-() const;
	xVector operator*(float scale) const;
	xVector operator*(const xVector & other) const;
	xVector operator/(float scale) const;
	xVector operator/(const xVector &other) const;
	xVector operator+(const xVector &other) const;
	xVector operator-(const xVector &other) const;
	xVector &operator*=(float scale);
	xVector &operator*=(const xVector &other);
	xVector &operator/=(float scale);
	xVector &operator/=(const xVector &other);
	xVector &operator+=(const xVector &other);
	xVector &operator-=(const xVector &other);
	bool operator<(const xVector &other) const;
	bool operator==(const xVector &other) const;
	bool operator!=(const xVector &other) const;
	float Dot(const xVector &other) const;
	xVector Cross(const xVector &other) const;
	float Length() const;
	float Distance(const xVector &other) const;
	xVector Normalized() const;
	void Normalize();
	float Yaw() const;
	float Pitch() const;
	void Clear();
	xVector Lerp(const xVector &other, float factor) const;
};