//
//  line.mm
//  iXors3D
//
//  Created by Knightmare on 02.09.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import "line.h"

x3DLine::x3DLine()
{
}

x3DLine::x3DLine(const xVector &_origin, const xVector &_direction)
{
	origin    = _origin;
	direction = _direction;
}

x3DLine x3DLine::operator+(const xVector &vector) const
{
	return x3DLine(origin + vector, direction);
}

x3DLine x3DLine::operator-(const xVector &vector) const
{
	return x3DLine(origin - vector, direction);
}

xVector x3DLine::operator*(float scale) const
{
	return origin + direction * scale;
}

xVector x3DLine::Nearest(const xVector &vector) const
{
	return origin + direction * (direction.Dot(vector - origin) / direction.Dot(direction));
}