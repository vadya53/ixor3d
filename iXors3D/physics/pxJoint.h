#ifndef _PXJOINT_H_
#define _PXJOINT_H_

#include "IJoint.h"
#include <btBulletDynamicsCommon.h>

class pxJoint : IJoint
{
private:
	btTypedConstraint * _systemJoint;
	pxJointType         _type;
public:
	pxJoint(pxJointType type, btTypedConstraint * joint);
	virtual ~pxJoint();
	btTypedConstraint * GetJoint();
	virtual pxJointType GetType();
	virtual void SetPivotA(float x, float y, float z);
	virtual void SetPivotB(float x, float y, float z);
	virtual void GetPivotA(float * position);
	virtual float GetPivotAX();
	virtual float GetPivotAY();
	virtual float GetPivotAZ();
	virtual void GetPivotB(float * position);
	virtual float GetPivotBX();
	virtual float GetPivotBY();
	virtual float GetPivotBZ();
	virtual void SetLinearLimits(float lowerX, float lowerY, float lowerZ, float upperX, float upperY, float upperZ);
	virtual void SetAngularLimits(float lowerX, float lowerY, float lowerZ, float upperX, float upperY, float upperZ);
	virtual void GetLinearLimits(float * lower, float * upper);
	virtual void GetAngularLimits(float * lower, float * upper);
	virtual float GetLinearLowerX();
	virtual float GetLinearLowerY();
	virtual float GetLinearLowerZ();
	virtual float GetLinearUpperX();
	virtual float GetLinearUpperY();
	virtual float GetLinearUpperZ();
	virtual float GetAngularLowerX();
	virtual float GetAngularLowerY();
	virtual float GetAngularLowerZ();
	virtual float GetAngularUpperX();
	virtual float GetAngularUpperY();
	virtual float GetAngularUpperZ();
	virtual void SetSpringData(int index, bool enablesd, float damping, float stiffness);
	virtual void SetHingeAxis(float x, float y, float z);
	virtual void SetHingeLimit(float lower, float upper, float softness, float biasFactor, float relaxationFactor);
	virtual float GetHingeLowerLimit();
	virtual float GetHingeUpperLimit();
	virtual void EnableMotor(int dof, bool enabled, float targetVelocity, float maxForce);
	virtual void SetHingeMotorTarget(float angle, float delta);
};

#endif