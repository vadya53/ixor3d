//
//  quaternion.mm
//  iXors3D
//
//  Created by Knightmare on 02.09.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import "quaternion.h"

xQuaternion::xQuaternion()
{
	x = 0.0f;
	y = 0.0f;
	z = 0.0f;
	w = 1.0f;
}

xQuaternion::xQuaternion(float _x, float _y, float _z, float _w)
{
	x = _x;
	y = _y;
	z = _z;
	w = _w;
}

xQuaternion xQuaternion::operator-() const
{
	return xQuaternion(-x, -y, -z, w);
}

xQuaternion xQuaternion::operator+(const xQuaternion &other) const
{
	return xQuaternion(x + other.x, y + other.y, z + other.z, w + other.w);
}

xQuaternion xQuaternion::operator-(const xQuaternion &other) const
{
	return xQuaternion(x - other.x, y - other.y, z - other.z, w - other.w);
}

xQuaternion xQuaternion::operator*(const xQuaternion &other) const
{
	xVector vector = xVector(other.x, other.y, other.z).Cross(xVector(x, y, z)) + xVector(other.x, other.y, other.z) * w + xVector(x, y, z) * other.w;
	return xQuaternion(vector.x, vector.y, vector.z, w * other.w - xVector(x, y, z).Dot(xVector(other.x, other.y, other.z)));
}

xVector xQuaternion::operator*(const xVector &vector) const
{
	xQuaternion temp = *this * xQuaternion(vector.x, vector.y, vector.z, 0.0f) * -*this;
	return xVector(temp.x, temp.y, temp.z);
}

xQuaternion xQuaternion::operator*(float scale) const
{
	return xQuaternion(x * scale, y * scale, z * scale, w * scale);
}

xQuaternion xQuaternion::operator/(float scale) const
{
	return xQuaternion(x / scale, y / scale, z / scale, w / scale);
}

float xQuaternion::Dot(const xQuaternion &other) const
{
	return x * other.x + y * other.y + z * other.z + w * other.w;
}

float xQuaternion::Length() const
{
	return sqrtf(w * w + x * x + y * y + z * z);
}

void xQuaternion::Normalize()
{
	*this = *this / Length();
}

xQuaternion xQuaternion::Normalized() const
{
	return *this / Length();
}

xQuaternion xQuaternion::Slerp(const xQuaternion &other, float factor) const
{
	xQuaternion temp;
	float omega, cosOmega, sinOmega, scale0, scale1;
	cosOmega = x * other.x + y * other.y + z * other.z + w * other.w;
	if(cosOmega < 0.0f)
	{
		cosOmega = -cosOmega;
		temp.x   = -other.x;
		temp.y   = -other.y;
		temp.z   = -other.z;
		temp.w   = -other.w;
	}
	else
	{
		temp.x = other.x;
		temp.y = other.y;
		temp.z = other.z;
		temp.w = other.w;
	}
	if((1.0f - cosOmega) > X3DEPSILON)
	{
		omega    = acos(cosOmega);
		sinOmega = sin(omega);
		scale0   = sin((1.0f - factor) * omega) / sinOmega;
		scale1   = sin(factor * omega) / sinOmega;
	}
	else
	{        
		scale0 = 1.0f - factor;
		scale1 = factor;
	}
	return xQuaternion(scale0 * x + scale1 * temp.x,
					   scale0 * y + scale1 * temp.y,
					   scale0 * z + scale1 * temp.z,
					   scale0 * w + scale1 * temp.w);
}

xVector xQuaternion::i() const
{
	float xz = x * z;
	float wy = w * y;
	float xy = x * y;
	float wz = w * z;
	float yy = y * y;
	float zz = z * z;
	return xVector(1.0f - 2.0f * (yy + zz), 2.0f * (xy - wz), 2.0f * (xz + wy));
}

xVector xQuaternion::j() const
{
	float yz = y * z;
	float wx = w * x;
	float xy = x * y;
	float wz = w * z;
	float xx = x * x;
	float zz = z * z;
	return xVector(2.0f * (xy + wz), 1.0f - 2.0f * (xx + zz), 2.0f * (yz - wx));
}

xVector xQuaternion::k() const
{
	float xz = x * z;
	float wy = w * y;
	float yz = y * z;
	float wx = w * x;
	float xx = x * x;
	float yy = y * y;
	return xVector(2.0f * (xz - wy), 2.0f * (yz + wx), 1.0f - 2.0f * (xx + yy));
}

void xQuaternion::ShortestArc(const xVector & from, const xVector & to)
{
	xVector c = from.Cross(to);
    x = c.x;
	y = c.y;
	z = c.z;
	w = from.Dot(to);
    Normalize();
    w += 1.0f;
    if(w <= 0.0001f)
    {
		if((from.z * from.z) > (from.x * from.x))
		{
			x =  0.0f;
			y =  from.z;
			z = -from.y;
		}
        else
		{
			x =  from.y;
			y = -from.x;
			z =  0.0f;
		}
    }
    Normalize();
}