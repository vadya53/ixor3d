//
//  plane.mm
//  iXors3D
//
//  Created by Knightmare on 02.09.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import "plane.h"

xPlane::xPlane()
{
	d = 0.0f;
}

xPlane::xPlane(const xVector &_normal, float _d)
{
	normal = _normal;
	d      = _d;
}

xPlane::xPlane(const xVector &_point, const xVector &_normal)
{
	normal = _normal;
	d      = -_normal.Dot(_point);
}

xPlane::xPlane(const xVector &v0, const xVector &v1, const xVector &v2)
{
	normal = (v1 - v0).Cross(v2 - v0).Normalized();
	d      = -normal.Dot(v0);
}

xPlane xPlane::operator-() const
{
	return xPlane(-normal, -d);
}

float xPlane::IntersectTime(const x3DLine &line) const
{
	return -Distance(line.origin) / normal.Dot(line.direction);
}

xVector xPlane::Intersect(const x3DLine &line) const
{
	return line * IntersectTime(line);
}

x3DLine xPlane::Intersect(const xPlane &other) const
{
	xVector lv = normal.Cross(other.normal).Normalized();
	return x3DLine(other.Intersect(x3DLine(Nearest(normal * -d), normal.Cross(lv))), lv);
}

xVector xPlane::Nearest(const xVector &vector) const
{
	return vector - normal * Distance(vector);
}

void xPlane::Negate()
{
	normal = -normal;
	d      = -d;
}

float xPlane::Distance(const xVector &vector) const
{
	return normal.Dot(vector) + d;
}

void xPlane::Normalize()
{
	float temp = 1.0f / sqrtf((normal.x * normal.x) + (normal.y * normal.y) + (normal.z * normal.z));
	normal.x = normal.x * temp;
	normal.y = normal.y * temp;
	normal.z = normal.z * temp;
	d        = d * temp;
}

xPlane xPlane::Normalized()
{
	xPlane result = *this;
	result.Normalize();
	return result;
}