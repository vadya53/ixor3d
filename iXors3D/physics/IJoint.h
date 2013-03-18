#ifndef _IJOINT_H_
#define _IJOINT_H_

#include "IBody.h"

enum pxJointType
{
	pxJOINT_POINT2POINT = 0,
	pxJOINT_6DOF        = 1,
	pxJOINT_SPRING      = 2,
	pxJOINT_HINGE       = 3
};

class IJoint
{
public:
	virtual ~IJoint(){}
	virtual pxJointType GetType() = 0;
	// P2P CONTACTS ONLY
	virtual void SetPivotA(float x, float y, float z) = 0;
	virtual void SetPivotB(float x, float y, float z) = 0;
	virtual void GetPivotA(float * position) = 0;
	virtual float GetPivotAX() = 0;
	virtual float GetPivotAY() = 0;
	virtual float GetPivotAZ() = 0;
	virtual void GetPivotB(float * position) = 0;
	virtual float GetPivotBX() = 0;
	virtual float GetPivotBY() = 0;
	virtual float GetPivotBZ() = 0;
	// 6DOF AND SPRINGS ONLY
	virtual void SetLinearLimits(float lowerX, float lowerY, float lowerZ, float upperX, float upperY, float upperZ) = 0;
	virtual void SetAngularLimits(float lowerX, float lowerY, float lowerZ, float upperX, float upperY, float upperZ) = 0;
	virtual void GetLinearLimits(float * lower, float * upper) = 0;
	virtual void GetAngularLimits(float * lower, float * upper) = 0;
	virtual float GetLinearLowerX() = 0;
	virtual float GetLinearLowerY() = 0;
	virtual float GetLinearLowerZ() = 0;
	virtual float GetLinearUpperX() = 0;
	virtual float GetLinearUpperY() = 0;
	virtual float GetLinearUpperZ() = 0;
	virtual float GetAngularLowerX() = 0;
	virtual float GetAngularLowerY() = 0;
	virtual float GetAngularLowerZ() = 0;
	virtual float GetAngularUpperX() = 0;
	virtual float GetAngularUpperY() = 0;
	virtual float GetAngularUpperZ() = 0;
	// SPRINGS ONLY
	virtual void SetSpringData(int index, bool enablesd, float damping, float stiffness) = 0;
	// HINGE ONLY
	virtual void SetHingeAxis(float x, float y, float z) = 0;
	virtual void SetHingeLimit(float lower, float upper, float softness, float biasFactor, float relaxationFactor) = 0;
	virtual float GetHingeLowerLimit() = 0;
	virtual float GetHingeUpperLimit() = 0;
	// 6DOF, SPRINGS AND HINGE
	virtual void EnableMotor(int dof, bool enabled, float targetVelocity, float maxForce) = 0;
	// HINGE ONLY
	virtual void SetHingeMotorTarget(float angle, float delta) = 0;
};

#endif