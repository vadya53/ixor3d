//
//  transform.mm
//  iXors3D
//
//  Created by Knightmare on 02.09.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import "transform.h"

xTransform::xTransform()
{
}

xTransform::xTransform(const xMatrix &_matrix)
{
	matrix = _matrix;
}

xTransform::xTransform(const xVector &_position)
{
	position = _position;
}

xTransform::xTransform(const xMatrix &_matrix, const xVector &_position)
{
	matrix   = _matrix;
	position = _position;
}

xTransform xTransform::Inversed() const
{
	xTransform transform;
	transform.matrix   = matrix.Inversed();
	transform.position = transform.matrix * -position;
	return transform;
}

void xTransform::Inverse()
{
	matrix.Inverse();
	position = matrix * -position;
}

xTransform xTransform::Transposed() const
{
	xTransform transform;
	transform.matrix   = matrix.Transposed();
	transform.position = transform.matrix * -position;
	return transform;
}

void xTransform::Transpose()
{
	matrix.Transpose();
	position = matrix * -position;
}

xVector xTransform::operator*(const xVector &vector) const
{
	return matrix * vector + position;
}

x3DLine xTransform::operator*(const x3DLine &line) const
{
	xVector temp = (*this) * line.origin;
	return x3DLine(temp, (*this) * (line.origin + line.direction) - temp);
}

xBox xTransform::operator*(const xBox &box) const
{
	xBox temp(*this * box.Corner(0));
	for(int k = 1; k < 8; ++k) temp.Update(*this * box.Corner(k));
	return temp;
}

xTransform xTransform::operator*(const xTransform &other) const
{
	xTransform transform;
	transform.matrix   = matrix * other.matrix;
	transform.position = matrix * other.position + position;
	return transform;
}

bool xTransform::operator==(const xTransform &other) const
{
	return matrix == other.matrix && position == other.position;
}

bool xTransform::operator!=(const xTransform &other) const
{
	return matrix != other.matrix || position != other.position;
}
