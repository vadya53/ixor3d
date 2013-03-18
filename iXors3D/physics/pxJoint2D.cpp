//
//  pxJoint2D.cpp
//  iXors3D
//
//  Created by Fadeev 'Knightmare' Dmitry on 8/5/10.
//  Copyright 2010 XorsTeam. All rights reserved.
//

#include "pxJoint2D.h"

pxJoint2D::pxJoint2D(pxJoint2DType type, b2Joint * joint)
{
	_type  = type;
	_joint = joint;
}

pxJoint2D::~pxJoint2D()
{
}

pxJoint2DType pxJoint2D::GetType()
{
	return _type;
}

void pxJoint2D::GetPivotA(float * position)
{
	b2Vec2 anchor = _joint->GetAnchorA();
	position[0] = anchor.x;
	position[1] = anchor.y;
}

float pxJoint2D::GetPivotAX()
{
	return _joint->GetAnchorA().x;
}

float pxJoint2D::GetPivotAY()
{
	return _joint->GetAnchorA().y;
}

void pxJoint2D::GetPivotB(float * position)
{
	b2Vec2 anchor = _joint->GetAnchorB();
	position[0] = anchor.x;
	position[1] = anchor.y;
}

float pxJoint2D::GetPivotBX()
{
	return _joint->GetAnchorB().x;
}

float pxJoint2D::GetPivotBY()
{
	return _joint->GetAnchorB().y;
}

b2Joint * pxJoint2D::GetJoint()
{
	return _joint;
}

void pxJoint2D::SetLength(float length)
{
	if(_type == pxJOINT2D_DISTANCE)
	{
		((b2DistanceJoint*)_joint)->SetLength(length);
	}
}

float pxJoint2D::GetLength()
{
	if(_type == pxJOINT2D_DISTANCE)
	{
		return ((b2DistanceJoint*)_joint)->GetLength();
	}
	return 0.0f;
}

void pxJoint2D::SetFrequency(float frequency)
{
	if(_type == pxJOINT2D_DISTANCE)
	{
		((b2DistanceJoint*)_joint)->SetFrequency(frequency);
	}
}

float pxJoint2D::GetFrequency()
{
	if(_type == pxJOINT2D_DISTANCE)
	{
		return ((b2DistanceJoint*)_joint)->GetFrequency();
	}
	return 0.0f;
}

void pxJoint2D::SetDampingRatio(float ratio)
{
	if(_type == pxJOINT2D_DISTANCE)
	{
		((b2DistanceJoint*)_joint)->SetDampingRatio(ratio);
	}
}

float pxJoint2D::GetDampingRatio()
{
	if(_type == pxJOINT2D_DISTANCE)
	{
		return ((b2DistanceJoint*)_joint)->GetDampingRatio();
	}
	return 0.0f;
}

void pxJoint2D::SetHingeLimit(bool enable, float lower, float upper)
{
	if(_type == pxJOINT2D_REVOLUTE)
	{
		((b2RevoluteJoint*)_joint)->SetLimits(lower / 180.0f * b2_pi, upper / 180.0f * b2_pi);
		((b2RevoluteJoint*)_joint)->EnableLimit(enable);
	}
}

float pxJoint2D::GetHingeUpperLimit()
{
	if(_type == pxJOINT2D_REVOLUTE)
	{
		return ((b2RevoluteJoint*)_joint)->GetUpperLimit();
	}
	return 0.0f;
}

float pxJoint2D::GetHingeLowerLimit()
{
	if(_type == pxJOINT2D_REVOLUTE)
	{
		return ((b2RevoluteJoint*)_joint)->GetLowerLimit() / b2_pi * 180.0f;
	}
	return 0.0f;
}

bool pxJoint2D::GetHingeLimitEnabled()
{
	if(_type == pxJOINT2D_REVOLUTE)
	{
		return ((b2RevoluteJoint*)_joint)->IsLimitEnabled() / b2_pi * 180.0f;
	}
	return false;
}

void pxJoint2D::SetHingeMotor(bool enable, float speed, float maxTorque)
{
	if(_type == pxJOINT2D_REVOLUTE)
	{
		((b2RevoluteJoint*)_joint)->SetMotorSpeed(speed / 180.0f * b2_pi);
		((b2RevoluteJoint*)_joint)->SetMaxMotorTorque(maxTorque);
		((b2RevoluteJoint*)_joint)->EnableMotor(enable);
	}
}

float pxJoint2D::GetHingeMotorSpeed()
{
	if(_type == pxJOINT2D_REVOLUTE)
	{
		return ((b2RevoluteJoint*)_joint)->GetMotorSpeed() / b2_pi * 180.0f;
	}
	return 0.0f;
}

float pxJoint2D::GetHingeMotorTorque()
{
	if(_type == pxJOINT2D_REVOLUTE)
	{
		return ((b2RevoluteJoint*)_joint)->GetMotorTorque();
	}
	return 0.0f;
}

bool pxJoint2D::GetHingeMotorEnabled()
{
	if(_type == pxJOINT2D_REVOLUTE)
	{
		return ((b2RevoluteJoint*)_joint)->IsMotorEnabled();
	}
	return false;
}

void pxJoint2D::SetLinearLimit(bool enable, float lower, float upper)
{
	if(_type == pxJOINT2D_PRISMATIC)
	{
		((b2PrismaticJoint*)_joint)->SetLimits(lower, upper);
		((b2PrismaticJoint*)_joint)->EnableLimit(enable);
	}
}

float pxJoint2D::GetLinearUpperLimit()
{
	if(_type == pxJOINT2D_PRISMATIC)
	{
		return ((b2PrismaticJoint*)_joint)->GetUpperLimit();
	}
	return 0.0f;
}

float pxJoint2D::GetLinearLowerLimit()
{
	if(_type == pxJOINT2D_PRISMATIC)
	{
		return ((b2PrismaticJoint*)_joint)->GetLowerLimit();
	}
	return 0.0f;
}

bool pxJoint2D::GetLinearLimitEnabled()
{
	if(_type == pxJOINT2D_PRISMATIC)
	{
		return ((b2PrismaticJoint*)_joint)->IsLimitEnabled();
	}
	return false;
}

void pxJoint2D::SetLinearMotor(bool enable, float speed, float maxForce)
{
	if(_type == pxJOINT2D_PRISMATIC)
	{
		((b2PrismaticJoint*)_joint)->SetMotorSpeed(speed);
		((b2PrismaticJoint*)_joint)->SetMaxMotorForce(maxForce);
		((b2PrismaticJoint*)_joint)->EnableMotor(enable);
	}
}

float pxJoint2D::GetLinearMotorSpeed()
{
	if(_type == pxJOINT2D_PRISMATIC)
	{
		return ((b2PrismaticJoint*)_joint)->GetMotorSpeed();
	}
	return 0.0f;
}

float pxJoint2D::GetLinearMotorForce()
{
	if(_type == pxJOINT2D_PRISMATIC)
	{
		return ((b2PrismaticJoint*)_joint)->GetMotorForce();
	}
	return 0.0f;
}

bool pxJoint2D::GetLinearMotorEnabled()
{
	if(_type == pxJOINT2D_PRISMATIC)
	{
		return ((b2PrismaticJoint*)_joint)->IsMotorEnabled();
	}
	return false;
}

float pxJoint2D::GetPulleyLengthA()
{
	if(_type == pxJOINT2D_PULLEY)
	{
		return ((b2PulleyJoint*)_joint)->GetLength1();
	}
	return 0.0f;
}

float pxJoint2D::GetPulleyLengthB()
{
	if(_type == pxJOINT2D_PULLEY)
	{
		return ((b2PulleyJoint*)_joint)->GetLength2();
	}
	return 0.0f;
}

void pxJoint2D::SetGearRatio(float ratio)
{
	if(_type == pxJOINT2D_GEAR)
	{
		((b2GearJoint*)_joint)->SetRatio(ratio);
	}
}

float pxJoint2D::GetGearRatio()
{
	if(_type == pxJOINT2D_GEAR)
	{
		return ((b2GearJoint*)_joint)->GetRatio();
	}
	return 0.0f;
}