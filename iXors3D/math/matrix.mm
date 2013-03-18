//
//  matrix.mm
//  iXors3D
//
//  Created by Knightmare on 02.09.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import "matrix.h"
#import "x3dmath.h"

xMatrix::xMatrix()
{
	i = xVector(1.0f, 0.0f, 0.0f);
	j = xVector(0.0f, 1.0f, 0.0f);
	k = xVector(0.0f, 0.0f, 1.0f);
}

xMatrix::xMatrix(const xVector &_i, const xVector &_j, const xVector &_k)
{
	i = _i;
	j = _j;
	k = _k;
}

xMatrix::xMatrix(const xQuaternion &quat)
{
	float xx = quat.x * quat.x;
	float yy = quat.y * quat.y;
	float zz = quat.z * quat.z;
	float xy = quat.x * quat.y;
	float xz = quat.x * quat.z;
	float yz = quat.y * quat.z;
	float wx = quat.w * quat.x;
	float wy = quat.w * quat.y;
	float wz = quat.w * quat.z;
	i = xVector(1.0f - 2.0f * (yy + zz), 2.0f * (xy - wz), 2.0f * (xz + wy));
	j = xVector(2.0f * (xy + wz), 1.0f - 2.0f * (xx + zz), 2.0f * (yz - wx));
	k = xVector(2.0f * (xz - wy), 2.0f * (yz + wx), 1.0f - 2.0f * (xx + yy));
}

xMatrix::xMatrix(const xVector &axis, float angle)
{
	float c  = cosf(angle);
	float s  = sinf(angle);
	float x2 = axis.x * axis.x;
	float y2 = axis.y * axis.y;
	float z2 = axis.z * axis.z;
	i = xVector(x2 + c * (1.0f - x2), axis.x * axis.y * (1.0f - c) - axis.z * s, axis.z * axis.x * (1.0f - c) + axis.y * s);
	j = xVector(axis.x * axis.y * (1.0f - c) + axis.z * s, y2 + c * (1.0f - y2), axis.y * axis.z * (1.0f - c) - axis.x * s);
	k = xVector(axis.z * axis.x * (1.0f - c) - axis.y * s, axis.y * axis.z * (1.0f - c) + axis.x * s, z2 + c * (1.0f - z2));
}

xMatrix xMatrix::Transposed() const
{
	xMatrix matrix;
	matrix.i.x = i.x;
	matrix.i.y = j.x;
	matrix.i.z = k.x;
	matrix.j.x = i.y;
	matrix.j.y = j.y;
	matrix.j.z = k.y;
	matrix.k.x = i.z;
	matrix.k.y = j.z;
	matrix.k.z = k.z;
	return matrix;
}

void xMatrix::Transpose()
{
	float temp = 0.0f;
	i.x  = i.x;
	temp = i.y;
	i.y  = j.x;
	j.x  = temp;
	temp = i.z;
	i.z  = k.x;
	k.x  = temp;
	j.y  = j.y;
	temp = j.z;
	j.z  = k.y;
	k.y  = temp;
	k.z  = k.z;
}

float xMatrix::Determinant() const
{
	return i.x * (j.y * k.z - j.z * k.y) - i.y * (j.x * k.z - j.z * k.x) + i.z * (j.x * k.y - j.y * k.x);
}

xMatrix xMatrix::Inversed() const
{
	xMatrix matrix;
	float d    = 1.0f / Determinant();
	matrix.i.x =  d * (j.y * k.z - j.z * k.y);
	matrix.i.y = -d * (i.y * k.z - i.z * k.y);
	matrix.i.z =  d * (i.y * j.z - i.z * j.y);
	matrix.j.x = -d * (j.x * k.z - j.z * k.x);
	matrix.j.y =  d * (i.x * k.z - i.z * k.x);
	matrix.j.z = -d * (i.x * j.z - i.z * j.x);
	matrix.k.x =  d * (j.x * k.y - j.y * k.x);
	matrix.k.y = -d * (i.x * k.y - i.y * k.x);
	matrix.k.z =  d * (i.x * j.y - i.y * j.x);
	return matrix;
}

void xMatrix::Inverse()
{
	float ix = i.x;
	float iy = i.y;
	float iz = i.z;
	float jx = j.x;
	float jy = j.y;
	float jz = j.z;
	float kx = k.x;
	float ky = k.y;
	float kz = k.z;
	float d  = 1.0f / Determinant();
	i.x      =  d * (jy * kz - jz * ky);
	i.y      = -d * (iy * kz - iz * ky);
	i.z      =  d * (iy * jz - iz * jy);
	j.x      = -d * (jx * kz - jz * kx);
	j.y      =  d * (ix * kz - iz * kx);
	j.z      = -d * (ix * jz - iz * jx);
	k.x      =  d * (jx * ky - jy * kx);
	k.y      = -d * (ix * ky - iy * kx);
	k.z      =  d * (ix * jy - iy * jx);
}

xMatrix xMatrix::Cofactor() const
{
	xMatrix matrix;
	matrix.i.x =  (j.y * k.z - j.z * k.y);
	matrix.i.y = -(j.x * k.z - j.z * k.x);
	matrix.i.z =  (j.x * k.y - j.y * k.x);
	matrix.j.x = -(i.y * k.z - i.z * k.y);
	matrix.j.y =  (i.x * k.z - i.z * k.x);
	matrix.j.z = -(i.x * k.y - i.y * k.x);
	matrix.k.x =  (i.y * j.z - i.z * j.y);
	matrix.k.y = -(i.x * j.z - i.z * j.x);
	matrix.k.z =  (i.x * j.y - i.y * j.x);
	return matrix;
}

bool xMatrix::operator==(const xMatrix &other) const
{
	return i == other.i && j == other.j && k == other.k;
}

bool xMatrix::operator!=(const xMatrix &other) const
{
	return i != other.i || j != other.j || k != other.k;
}

xVector xMatrix::operator*(const xVector &vector) const
{
	return xVector(i.x * vector.x + j.x * vector.y + k.x * vector.z, i.y * vector.x + j.y * vector.y + k.y * vector.z, i.z * vector.x + j.z * vector.y + k.z * vector.z);
}

xMatrix xMatrix::operator*(const xMatrix &other) const
{
	xMatrix matrix;
	matrix.i.x = i.x * other.i.x + j.x * other.i.y + k.x * other.i.z;
	matrix.i.y = i.y * other.i.x + j.y * other.i.y + k.y * other.i.z;
	matrix.i.z = i.z * other.i.x + j.z * other.i.y + k.z * other.i.z;
	matrix.j.x = i.x * other.j.x + j.x * other.j.y + k.x * other.j.z;
	matrix.j.y = i.y * other.j.x + j.y * other.j.y + k.y * other.j.z;
	matrix.j.z = i.z * other.j.x + j.z * other.j.y + k.z * other.j.z;
	matrix.k.x = i.x * other.k.x + j.x * other.k.y + k.x * other.k.z;
	matrix.k.y = i.y * other.k.x + j.y * other.k.y + k.y * other.k.z;
	matrix.k.z = i.z * other.k.x + j.z * other.k.y + k.z * other.k.z;
	return matrix;
}

void xMatrix::Orthogonalize()
{
	k.Normalize();
	i = j.Cross(k).Normalized();
	j = k.Cross(i);
}

xMatrix xMatrix::Orthogonalized() const
{
	xMatrix matrix;
	matrix = *this;
	matrix.Orthogonalize();
	return matrix;
}