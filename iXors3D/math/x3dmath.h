//
//  x3dmath.h
//  iXors3D
//
//  Created by Knightmare on 26.08.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import <math.h>
#import "vector.h"
#import "quaternion.h"
#import "line.h"
#import "box.h"
#import "transform.h"
#import "plane.h"

inline xQuaternion PitchQuaternion(float pitch)
{
	pitch = DegToRad(pitch);
	return xQuaternion(sinf(pitch / -2.0f), 0.0f, 0.0f, cosf(pitch / -2.0f));
}

inline xQuaternion YawQuaternion(float yaw)
{
	yaw = DegToRad(yaw);
	return xQuaternion(0.0f, sinf(yaw / 2.0f), 0.0f, cosf(yaw / 2.0f));
}

inline xQuaternion RollQuaternion(float roll)
{
	roll = DegToRad(roll);
	return xQuaternion(0.0f, 0.0f, sinf(roll / -2.0f), cosf(roll / -2.0f));
}

inline xQuaternion RotationQuaternion(float pitch, float yaw, float roll)
{
	return YawQuaternion(yaw) * PitchQuaternion(pitch) * RollQuaternion(roll);
}

inline float QuaternionPitch(const xQuaternion &quat)
{
	return quat.k().Pitch();
}

inline float QuaternionYaw(const xQuaternion &quat)
{
	return quat.k().Yaw();
}

inline float QuaternionRoll(const xQuaternion &quat)
{
	return RadToDeg(atan2f(quat.i().y, quat.j().y));
}

inline xQuaternion MatrixToQuaternion(const xMatrix &matrix)
{
	xMatrix temp = matrix;
	temp.Orthogonalize();
	float t = temp.i.x + temp.j.y + temp.k.z;
	float w, x, y, z;
	if(t > X3DEPSILON)
	{
		t = sqrtf(t + 1.0f) * 2.0f;
		x = (temp.k.y - temp.j.z) / t;
		y = (temp.i.z - temp.k.x) / t;
		z = (temp.j.x - temp.i.y) / t;
		w = t / 4.0f;
	}
	else if(temp.i.x > temp.j.y && temp.i.x > temp.k.z)
	{
		t = sqrtf(temp.i.x - temp.j.y - temp.k.z + 1.0f) * 2.0f;
		x = t / 4.0f;
		y = (temp.j.x + temp.i.y) / t;
		z = (temp.i.z + temp.k.x) / t;
		w = (temp.k.y - temp.j.z) / t;
	}
	else if(temp.j.y > temp.k.z)
	{
		t = sqrtf(temp.j.y - temp.k.z - temp.i.x + 1.0f) * 2.0f;
		x = (temp.j.x + temp.i.y) / t;
		y = t / 4.0f;
		z = (temp.k.y + temp.j.z) / t;
		w = (temp.i.z - temp.k.x) / t;
	}
	else
	{
		t = sqrtf(temp.k.z - temp.j.y - temp.i.x + 1.0f) * 2.0f;
		x = (temp.i.z + temp.k.x) / t;
		y = (temp.k.y + temp.j.z) / t;
		z = t / 4.0f;
		w = (temp.j.x - temp.i.y) / t;
	}
	return xQuaternion(x, y, z, w);
}

inline float TransformRadius(float radius, const xMatrix &matrix)
{
	static const float sq_3 = sqrtf(1.0f / 3.0f);
	return (matrix * xVector(sq_3, sq_3, sq_3)).Length() * radius;
}

inline xMatrix PitchMatrix(float pitch)
{
	pitch = DegToRad(pitch);
	return xMatrix(xVector(1.0f, 0.0f, 0.0f), xVector(0.0f, cosf(pitch), sinf(pitch)), xVector(0.0f, -sinf(pitch), cosf(pitch)));
}

inline xMatrix YawMatrix(float yaw)
{
	yaw = DegToRad(yaw);
	return xMatrix(xVector(cosf(yaw), 0.0f, sinf(yaw)), xVector(0.0f, 1.0f, 0.0f), xVector(-sinf(yaw), 0.0f, cosf(yaw)));
}

inline xMatrix RollMatrix(float roll)
{
	roll = DegToRad(roll);
	return xMatrix(xVector(cosf(roll), sinf(roll), 0.0f), xVector(-sinf(roll), cosf(roll), 0.0f), xVector(0.0f, 0.0f, 1.0f));
}

inline float MatrixPitch(const xMatrix &matrix)
{
	return matrix.k.Pitch();
}

inline float MatrixYaw(const xMatrix &matrix)
{
	return matrix.k.Yaw();
}

inline float MatrixRoll(const xMatrix &matrix)
{
	return RadToDeg(atan2f(matrix.i.y, matrix.j.y));
}

inline xMatrix ScaleMatrix(float x, float y, float z)
{
	return xMatrix(xVector(x, 0.0f, 0.0f), xVector(0.0f, y, 0.0f), xVector(0.0f, 0.0f, z));
}

inline xMatrix ScaleMatrix(const xVector &scale)
{
	return xMatrix(xVector(scale.x, 0.0f, 0.0f), xVector(0.0f, scale.y, 0.0f), xVector(0.0f, 0.0f, scale.z));
}

inline xMatrix RotationMatrix(float pitch, float yaw, float roll)
{
	return YawMatrix(yaw) * PitchMatrix(pitch) * RollMatrix(roll);
}

inline xMatrix RotationMatrix(const xVector &rotation)
{
	return YawMatrix(rotation.y) * PitchMatrix(rotation.x) * RollMatrix(rotation.z);
}