//
//  box.mm
//  iXors3D
//
//  Created by Knightmare on 02.09.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import "box.h"

xBox::xBox()
{
	min = xVector( FLT_MAX,  FLT_MAX,  FLT_MAX);
	max = xVector(-FLT_MAX, -FLT_MAX, -FLT_MAX);
}

xBox::xBox(const xVector &vector)
{
	min = vector;
	max = vector;
}

xBox::xBox(const xVector &_min, const xVector &_max)
{
	min = _min;
	max = _max;
}

xBox::xBox(const x3DLine &line)
{
	min = line.origin;
	max = line.origin;
	Update(line.origin + line.direction);
}

void xBox::Clear()
{
	min = xVector( FLT_MAX,  FLT_MAX,  FLT_MAX);
	max = xVector(-FLT_MAX, -FLT_MAX, -FLT_MAX);
}

bool xBox::Empty() const
{
	return max.x < min.x || max.y < min.y || max.z < min.z;
}

xVector xBox::Centre() const
{
	return xVector((min.x + max.x) * 0.5f, (min.y + max.y) * 0.5f, (min.z + max.z) * 0.5f);
}

xVector xBox::Corner(int mask) const
{
	return xVector(((mask & 1) ? max : min).x, ((mask & 2) ? max : min).y, ((mask & 4) ? max : min).z);
}

void xBox::Update(const xVector &vector)
{
	if(vector.x < min.x) min.x = vector.x;
	if(vector.y < min.y) min.y = vector.y;
	if(vector.z < min.z) min.z = vector.z;
	if(vector.x > max.x) max.x = vector.x;
	if(vector.y > max.y) max.y = vector.y;
	if(vector.z > max.z) max.z = vector.z;
}

void xBox::Update(const xBox &other)
{
	if(other.min.x < min.x) min.x = other.min.x;
	if(other.min.y < min.y) min.y = other.min.y;
	if(other.min.z < min.z) min.z = other.min.z;
	if(other.max.x > max.x) max.x = other.max.x;
	if(other.max.y > max.y) max.y = other.max.y;
	if(other.max.z > max.z) max.z = other.max.z;
}

bool xBox::Overlaps(const xBox &other) const
{
	return (max.x < other.max.x ? max.x : other.max.x) >= (min.x > other.min.x ? min.x : other.min.x) &&
		   (max.y < other.max.y ? max.y : other.max.y) >= (min.y > other.min.y ? min.y : other.min.y) &&
		   (max.z < other.max.z ? max.z : other.max.z) >= (min.z > other.min.z ? min.z : other.min.z);
}

void xBox::Expand(float scale)
{
	min.x -= scale;
	min.y -= scale;
	min.z -= scale;
	max.x += scale;
	max.y += scale;
	max.z += scale;
}

float xBox::Width() const
{
	return max.x - min.x;
}

float xBox::Height() const
{
	return max.y - min.y;
}

float xBox::Depth() const
{
	return max.z - min.z;
}

bool xBox::Contains(const xVector &vector)
{
	return vector.x >= min.x && vector.x <= max.x && vector.y >= min.y && vector.y <= max.y && vector.z >= min.z && vector.z <= max.z;
}
