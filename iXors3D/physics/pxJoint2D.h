//
//  pxJoint2D.h
//  iXors3D
//
//  Created by Fadeev 'Knightmare' Dmitry on 8/5/10.
//  Copyright 2010 XorsTeam. All rights reserved.
//

#ifndef _PXJOINT2D_H_
#define _PXJOINT2D_H_

#include "IJoint2D.h"
#include <Box2D.h>

class pxJoint2D : public IJoint2D
{
private:
	pxJoint2DType   _type;
	b2Joint       * _joint;
public:
	pxJoint2D(pxJoint2DType type, b2Joint * joint);
	b2Joint * GetJoint();
	virtual ~pxJoint2D();
	virtual pxJoint2DType GetType();
	virtual void GetPivotA(float * position);
	virtual float GetPivotAX();
	virtual float GetPivotAY();
	virtual void GetPivotB(float * position);
	virtual float GetPivotBX();
	virtual float GetPivotBY();
	virtual void SetLength(float length);
	virtual float GetLength();
	virtual void SetFrequency(float frequency);
	virtual float GetFrequency();
	virtual void SetDampingRatio(float ratio);
	virtual float GetDampingRatio();
	virtual void SetHingeLimit(bool enable, float lower, float upper);
	virtual float GetHingeUpperLimit();
	virtual float GetHingeLowerLimit();
	virtual bool GetHingeLimitEnabled();
	virtual void SetHingeMotor(bool enable, float speed, float maxTorque);
	virtual float GetHingeMotorSpeed();
	virtual float GetHingeMotorTorque();
	virtual bool GetHingeMotorEnabled();
	virtual void SetLinearLimit(bool enable, float lower, float upper);
	virtual float GetLinearUpperLimit();
	virtual float GetLinearLowerLimit();
	virtual bool GetLinearLimitEnabled();
	virtual void SetLinearMotor(bool enable, float speed, float maxForce);
	virtual float GetLinearMotorSpeed();
	virtual float GetLinearMotorForce();
	virtual bool GetLinearMotorEnabled();
	virtual float GetPulleyLengthA();
	virtual float GetPulleyLengthB();
	virtual void SetGearRatio(float ratio);
	virtual float GetGearRatio();
};

#endif