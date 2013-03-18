//
//  IJoint2D.h
//  iXors3D
//
//  Created by Fadeev 'Knightmare' Dmitry on 8/5/10.
//  Copyright 2010 XorsTeam. All rights reserved.
//

#ifndef _IJOINT2D_H_
#define _IJOINT2D_H_

enum pxJoint2DType
{
	pxJOINT2D_DISTANCE  = 0,
	pxJOINT2D_REVOLUTE  = 1,
	pxJOINT2D_PRISMATIC = 2,
	pxJOINT2D_PULLEY    = 3,
	pxJOINT2D_GEAR      = 4
};

class IJoint2D
{
public:
	virtual ~IJoint2D() {}
	virtual pxJoint2DType GetType() = 0;
	virtual void GetPivotA(float * position) = 0;
	virtual float GetPivotAX() = 0;
	virtual float GetPivotAY() = 0;
	virtual void GetPivotB(float * position) = 0;
	virtual float GetPivotBX() = 0;
	virtual float GetPivotBY() = 0;
	// Distance joint
	virtual void SetLength(float length) = 0;
	virtual float GetLength() = 0;
	virtual void SetFrequency(float frequency) = 0;
	virtual float GetFrequency() = 0;
	virtual void SetDampingRatio(float ratio) = 0;
	virtual float GetDampingRatio() = 0;
	// Revolute joint
	virtual void SetHingeLimit(bool enable, float lower, float upper) = 0;
	virtual float GetHingeUpperLimit() = 0;
	virtual float GetHingeLowerLimit() = 0;
	virtual bool GetHingeLimitEnabled() = 0;
	virtual void SetHingeMotor(bool enable, float speed, float maxTorque) = 0;
	virtual float GetHingeMotorSpeed() = 0;
	virtual float GetHingeMotorTorque() = 0;
	virtual bool GetHingeMotorEnabled() = 0;
	// Prismatic joint
	virtual void SetLinearLimit(bool enable, float lower, float upper) = 0;
	virtual float GetLinearUpperLimit() = 0;
	virtual float GetLinearLowerLimit() = 0;
	virtual bool GetLinearLimitEnabled() = 0;
	virtual void SetLinearMotor(bool enable, float speed, float maxForce) = 0;
	virtual float GetLinearMotorSpeed() = 0;
	virtual float GetLinearMotorForce() = 0;
	virtual bool GetLinearMotorEnabled() = 0;
	// Pulley joint
	virtual float GetPulleyLengthA() = 0;
	virtual float GetPulleyLengthB() = 0;
	// Gear joint
	virtual void SetGearRatio(float ratio) = 0;
	virtual float GetGearRatio() = 0;
};

#endif