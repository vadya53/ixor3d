//
//  vector.mm
//  iXors3D
//
//  Created by Knightmare on 02.09.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import "vector.h"

xVector::xVector()
{
	x = 0.0f;
	y = 0.0f;
	z = 0.0f;
}

xVector::xVector(float _x, float _y, float _z)
{
	x = _x;
	y = _y;
	z = _z;
}

xVector xVector::operator-() const
{
	return xVector(-x, -y, -z); 
}

xVector xVector::operator*(float scale) const
{
	return xVector(x * scale, y * scale, z * scale);
}

xVector xVector::operator*(const xVector & other) const
{
	return xVector(x * other.x, y * other.y, z * other.z);
}

xVector xVector::operator/(float scale) const
{
	return xVector(x / scale, y / scale, z / scale);
}

xVector xVector::operator/(const xVector &other) const
{
	return xVector(x / other.x, y / other.y, z / other.z);
}

xVector xVector::operator+(const xVector &other) const
{
	return xVector(x + other.x, y + other.y, z + other.z);
}

xVector xVector::operator-(const xVector &other) const
{
	return xVector(x - other.x, y - other.y, z - other.z);
}

xVector &xVector::operator*=(float scale)
{
	x *= scale;
	y *= scale;
	z *= scale;
	return *this;
}

xVector &xVector::operator*=(const xVector &other)
{
	x *= other.x;
	y *= other.y;
	z *= other.z;
	return *this;
}

xVector &xVector::operator/=(float scale)
{
	x /= scale;
	y /= scale;
	z /= scale;
	return *this;
}

xVector &xVector::operator/=(const xVector &other)
{
	x /= other.x;
	y /= other.y;
	z /= other.z;
	return *this;
}

xVector &xVector::operator+=(const xVector &other)
{
	x += other.x;
	y += other.y;
	z += other.z;
	return *this;
}

xVector &xVector::operator-=(const xVector &other)
{
	x -= other.x;
	y -= other.y;
	z -= other.z;
	return *this;
}

bool xVector::operator<(const xVector &other) const
{
	if(fabs(x - other.x) > X3DEPSILON) return x < other.x ? true : false;
	if(fabs(y - other.y) > X3DEPSILON) return y < other.y ? true : false;
	return fabs(z - other.z) > X3DEPSILON && z < other.z;
}

bool xVector::operator==(const xVector &other) const
{
	return fabs(x - other.x) <= X3DEPSILON && fabs(y - other.y) <= X3DEPSILON && fabs(z - other.z) <= X3DEPSILON;
}

bool xVector::operator!=(const xVector &other) const
{
	return fabs(x - other.x) > X3DEPSILON || fabs(y - other.y) > X3DEPSILON || fabs(z - other.z) > X3DEPSILON;
}

float xVector::Dot(const xVector &other) const
{
	return x * other.x + y * other.y + z * other.z;
}

xVector xVector::Cross(const xVector &other) const
{
	return xVector(y * other.z - z * other.y, z * other.x - x * other.z, x * other.y - y * other.x);
}

float xVector::Length() const
{
	return sqrtf(x * x + y * y + z * z);
}

float xVector::Distance(const xVector &other) const
{
	float dx = x - other.x;
	float dy = y - other.y;
	float dz = z - other.z;
	return sqrtf(dx * dx + dy * dy + dz * dz);
}

xVector xVector::Normalized() const
{
	float length = Length();
	return xVector(x / length, y / length, z / length);
}

void xVector::Normalize()
{
	float length = Length();
	x /= length;
	y /= length;
	z /= length;
}

float xVector::Yaw() const
{
	return RadToDeg(-atan2f(x, z));
}

float xVector::Pitch() const
{
	return RadToDeg(-atan2f(y, sqrtf(x * x + z * z)));
}

void xVector::Clear()
{
	x = 0.0f;
	y = 0.0f;
	z = 0.0f;
}

xVector xVector::Lerp(const xVector &other, float factor) const
{
	return *this + (other - *this) * factor;
}