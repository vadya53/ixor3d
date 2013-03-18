#include "pxJoint.h"
#include <iostream>

pxJoint::pxJoint(pxJointType type, btTypedConstraint * joint)
{
	_type        = type;
	_systemJoint = joint;
}

pxJoint::~pxJoint()
{
	if(_systemJoint != NULL) delete _systemJoint;
}

btTypedConstraint * pxJoint::GetJoint()
{
	return _systemJoint;
}

pxJointType pxJoint::GetType()
{
	return _type;
}

void pxJoint::SetPivotA(float x, float y, float z)
{
	if(_type == pxJOINT_POINT2POINT)
	{
		((btPoint2PointConstraint*)_systemJoint)->setPivotA(btVector3(x, y, z));
	}
}

void pxJoint::SetPivotB(float x, float y, float z)
{
	if(_type == pxJOINT_POINT2POINT)
	{
		((btPoint2PointConstraint*)_systemJoint)->setPivotB(btVector3(x, y, z));
	}
}

void pxJoint::GetPivotA(float * position)
{
	if(_type == pxJOINT_POINT2POINT)
	{
		btVector3 pivot = ((btPoint2PointConstraint*)_systemJoint)->getPivotInA();
		position[0]     = pivot.x();
		position[1]     = pivot.y();
		position[2]     = pivot.z();
	}
}

float pxJoint::GetPivotAX()
{
	if(_type == pxJOINT_POINT2POINT)
	{
		btVector3 pivot = ((btPoint2PointConstraint*)_systemJoint)->getPivotInA();
		return pivot.x();
	}
	return 0.0f;
}

float pxJoint::GetPivotAY()
{
	if(_type == pxJOINT_POINT2POINT)
	{
		btVector3 pivot = ((btPoint2PointConstraint*)_systemJoint)->getPivotInA();
		return pivot.y();
	}
	return 0.0f;
}

float pxJoint::GetPivotAZ()
{
	if(_type == pxJOINT_POINT2POINT)
	{
		btVector3 pivot = ((btPoint2PointConstraint*)_systemJoint)->getPivotInA();
		return pivot.z();
	}
	return 0.0f;
}

void pxJoint::GetPivotB(float * position)
{
	if(_type == pxJOINT_POINT2POINT)
	{
		btVector3 pivot = ((btPoint2PointConstraint*)_systemJoint)->getPivotInB();
		position[0]     = pivot.x();
		position[1]     = pivot.y();
		position[2]     = pivot.z();
	}
}

float pxJoint::GetPivotBX()
{
	if(_type == pxJOINT_POINT2POINT)
	{
		btVector3 pivot = ((btPoint2PointConstraint*)_systemJoint)->getPivotInB();
		return pivot.x();
	}
	return 0.0f;
}

float pxJoint::GetPivotBY()
{
	if(_type == pxJOINT_POINT2POINT)
	{
		btVector3 pivot = ((btPoint2PointConstraint*)_systemJoint)->getPivotInB();
		return pivot.y();
	}
	return 0.0f;
}

float pxJoint::GetPivotBZ()
{
	if(_type == pxJOINT_POINT2POINT)
	{
		btVector3 pivot = ((btPoint2PointConstraint*)_systemJoint)->getPivotInB();
		return pivot.z();
	}
	return 0.0f;
}

void pxJoint::SetLinearLimits(float lowerX, float lowerY, float lowerZ, float upperX, float upperY, float upperZ)
{
	if(_type == pxJOINT_6DOF || _type == pxJOINT_SPRING)
	{
		((btGeneric6DofConstraint*)_systemJoint)->setLinearLowerLimit(btVector3(lowerX, lowerY, lowerZ));
		((btGeneric6DofConstraint*)_systemJoint)->setLinearUpperLimit(btVector3(upperX, upperY, upperZ));
	}
}

void pxJoint::SetAngularLimits(float lowerX, float lowerY, float lowerZ, float upperX, float upperY, float upperZ)
{
	if(_type == pxJOINT_6DOF || _type == pxJOINT_SPRING)
	{
		((btGeneric6DofConstraint*)_systemJoint)->setAngularLowerLimit(btVector3(lowerX, lowerY, lowerZ));
		((btGeneric6DofConstraint*)_systemJoint)->setAngularUpperLimit(btVector3(upperX, upperY, upperZ));
	}
}

void pxJoint::GetLinearLimits(float * lower, float * upper)
{
	if(_type == pxJOINT_6DOF || _type == pxJOINT_SPRING)
	{
		btVector3 _lower = ((btGeneric6DofConstraint*)_systemJoint)->getTranslationalLimitMotor()->m_lowerLimit;
		btVector3 _upper = ((btGeneric6DofConstraint*)_systemJoint)->getTranslationalLimitMotor()->m_upperLimit;
		if(lower != NULL)
		{
			lower[0] = _lower.x();
			lower[1] = _lower.y();
			lower[2] = _lower.z();
		}
		if(upper != NULL)
		{
			upper[0] = _upper.x();
			upper[1] = _upper.y();
			upper[2] = _upper.z();
		}
	}
}

void pxJoint::GetAngularLimits(float * lower, float * upper)
{
	if(_type == pxJOINT_6DOF || _type == pxJOINT_SPRING)
	{
		if(lower != NULL)
		{
			lower[0] = ((btGeneric6DofConstraint*)_systemJoint)->getRotationalLimitMotor(0)->m_loLimit;
			lower[1] = ((btGeneric6DofConstraint*)_systemJoint)->getRotationalLimitMotor(1)->m_loLimit;
			lower[2] = ((btGeneric6DofConstraint*)_systemJoint)->getRotationalLimitMotor(2)->m_loLimit;
		}
		if(upper != NULL)
		{
			upper[0] = ((btGeneric6DofConstraint*)_systemJoint)->getRotationalLimitMotor(0)->m_hiLimit;
			upper[1] = ((btGeneric6DofConstraint*)_systemJoint)->getRotationalLimitMotor(1)->m_hiLimit;
			upper[2] = ((btGeneric6DofConstraint*)_systemJoint)->getRotationalLimitMotor(2)->m_hiLimit;
		}
	}
}

float pxJoint::GetLinearLowerX()
{
	if(_type == pxJOINT_6DOF || _type == pxJOINT_SPRING)
	{
		return ((btGeneric6DofConstraint*)_systemJoint)->getTranslationalLimitMotor()->m_lowerLimit.x();
	}
	return 0.0f;
}

float pxJoint::GetLinearLowerY()
{
	if(_type == pxJOINT_6DOF || _type == pxJOINT_SPRING)
	{
		return ((btGeneric6DofConstraint*)_systemJoint)->getTranslationalLimitMotor()->m_lowerLimit.y();
	}
	return 0.0f;
}

float pxJoint::GetLinearLowerZ()
{
	if(_type == pxJOINT_6DOF || _type == pxJOINT_SPRING)
	{
		return ((btGeneric6DofConstraint*)_systemJoint)->getTranslationalLimitMotor()->m_lowerLimit.z();
	}
	return 0.0f;
}

float pxJoint::GetLinearUpperX()
{
	if(_type == pxJOINT_6DOF || _type == pxJOINT_SPRING)
	{
		return ((btGeneric6DofConstraint*)_systemJoint)->getTranslationalLimitMotor()->m_upperLimit.x();
	}
	return 0.0f;
}

float pxJoint::GetLinearUpperY()
{
	if(_type == pxJOINT_6DOF || _type == pxJOINT_SPRING)
	{
		return ((btGeneric6DofConstraint*)_systemJoint)->getTranslationalLimitMotor()->m_upperLimit.y();
	}
	return 0.0f;
}

float pxJoint::GetLinearUpperZ()
{
	if(_type == pxJOINT_6DOF || _type == pxJOINT_SPRING)
	{
		return ((btGeneric6DofConstraint*)_systemJoint)->getTranslationalLimitMotor()->m_upperLimit.z();
	}
	return 0.0f;
}

float pxJoint::GetAngularLowerX()
{
	if(_type == pxJOINT_6DOF || _type == pxJOINT_SPRING)
	{
		return ((btGeneric6DofConstraint*)_systemJoint)->getRotationalLimitMotor(0)->m_loLimit;
	}
	return 0.0f;
}

float pxJoint::GetAngularLowerY()
{
	if(_type == pxJOINT_6DOF || _type == pxJOINT_SPRING)
	{
		return ((btGeneric6DofConstraint*)_systemJoint)->getRotationalLimitMotor(1)->m_loLimit;
	}
	return 0.0f;
}

float pxJoint::GetAngularLowerZ()
{
	if(_type == pxJOINT_6DOF || _type == pxJOINT_SPRING)
	{
		return ((btGeneric6DofConstraint*)_systemJoint)->getRotationalLimitMotor(2)->m_loLimit;
	}
	return 0.0f;
}

float pxJoint::GetAngularUpperX()
{
	if(_type == pxJOINT_6DOF || _type == pxJOINT_SPRING)
	{
		return ((btGeneric6DofConstraint*)_systemJoint)->getRotationalLimitMotor(0)->m_hiLimit;
	}
	return 0.0f;
}

float pxJoint::GetAngularUpperY()
{
	if(_type == pxJOINT_6DOF || _type == pxJOINT_SPRING)
	{
		return ((btGeneric6DofConstraint*)_systemJoint)->getRotationalLimitMotor(1)->m_hiLimit;
	}
	return 0.0f;
}

float pxJoint::GetAngularUpperZ()
{
	if(_type == pxJOINT_6DOF || _type == pxJOINT_SPRING)
	{
		return ((btGeneric6DofConstraint*)_systemJoint)->getRotationalLimitMotor(2)->m_hiLimit;
	}
	return 0.0f;
}

void pxJoint::SetSpringData(int index, bool enablesd, float damping, float stiffness)
{
	if(_type == pxJOINT_SPRING)
	{
		((btGeneric6DofSpringConstraint*)_systemJoint)->enableSpring(index, enablesd);
		if(enablesd)
		{
			((btGeneric6DofSpringConstraint*)_systemJoint)->setDamping(index, damping);
			((btGeneric6DofSpringConstraint*)_systemJoint)->setStiffness(index, stiffness);
		}
	}
}

void pxJoint::SetHingeAxis(float x, float y, float z)
{
	if(_type == pxJOINT_HINGE)
	{
		btVector3 axisInA = btVector3(x, y, z);
		btRigidBody & rbA = ((btHingeConstraint*)_systemJoint)->getRigidBodyA();
		btVector3 rbAxisA1 = rbA.getCenterOfMassTransform().getBasis().getColumn(0);
		btVector3 rbAxisA2;
		btScalar projection = axisInA.dot(rbAxisA1);
		if(projection >= 1.0f - SIMD_EPSILON)
		{
			rbAxisA1 = -rbA.getCenterOfMassTransform().getBasis().getColumn(2);
			rbAxisA2 =  rbA.getCenterOfMassTransform().getBasis().getColumn(1);
		}
		else if(projection <= -1.0f + SIMD_EPSILON)
		{
			rbAxisA1 = rbA.getCenterOfMassTransform().getBasis().getColumn(2);
			rbAxisA2 = rbA.getCenterOfMassTransform().getBasis().getColumn(1);      
		}
		else
		{
			rbAxisA2 = axisInA.cross(rbAxisA1);
			rbAxisA1 = rbAxisA2.cross(axisInA);
		}
		btTransform & frameA = ((btHingeConstraint*)_systemJoint)->getAFrame();
		frameA.getBasis().setValue(rbAxisA1.getX(), rbAxisA2.getX(), axisInA.getX(),
								   rbAxisA1.getY(), rbAxisA2.getY(), axisInA.getY(),
								   rbAxisA1.getZ(), rbAxisA2.getZ(), axisInA.getZ());
		btVector3 axisInB = btVector3(0.0f, 1.0f, 0.0f);
		btQuaternion rotationArc = shortestArcQuat(axisInA, axisInB);
		btVector3 rbAxisB1 =  quatRotate(rotationArc,rbAxisA1);
		btVector3 rbAxisB2 =  axisInB.cross(rbAxisB1);
		btTransform & frameB = ((btHingeConstraint*)_systemJoint)->getBFrame();
		frameB.getBasis().setValue(rbAxisB1.getX(), rbAxisB2.getX(), axisInB.getX(),
								   rbAxisB1.getY(), rbAxisB2.getY(), axisInB.getY(),
								   rbAxisB1.getZ(), rbAxisB2.getZ(), axisInB.getZ());
	}
}

void pxJoint::SetHingeLimit(float lower, float upper, float softness, float biasFactor, float relaxationFactor)
{
	if(_type == pxJOINT_HINGE)
	{
		((btHingeConstraint*)_systemJoint)->setLimit(lower, upper, softness, biasFactor, relaxationFactor);
	}
}

float pxJoint::GetHingeLowerLimit()
{
	if(_type == pxJOINT_HINGE)
	{
		return ((btHingeConstraint*)_systemJoint)->getLowerLimit();
	}
	return 0.0f;
}

float pxJoint::GetHingeUpperLimit()
{
	if(_type == pxJOINT_HINGE)
	{
		return ((btHingeConstraint*)_systemJoint)->getUpperLimit();
	}
	return 0.0f;
}

void pxJoint::EnableMotor(int dof, bool enabled, float targetVelocity, float maxForce)
{
	if(_type == pxJOINT_6DOF || _type == pxJOINT_SPRING)
	{
		btTranslationalLimitMotor * translateMotor = ((btGeneric6DofConstraint*)_systemJoint)->getTranslationalLimitMotor();
		btRotationalLimitMotor    * rotateMotorX   = ((btGeneric6DofConstraint*)_systemJoint)->getRotationalLimitMotor(0);
		btRotationalLimitMotor    * rotateMotorY   = ((btGeneric6DofConstraint*)_systemJoint)->getRotationalLimitMotor(1);
		btRotationalLimitMotor    * rotateMotorZ   = ((btGeneric6DofConstraint*)_systemJoint)->getRotationalLimitMotor(2);
		switch(dof)
		{
			case 0:
			{
				translateMotor->m_enableMotor[0]    = enabled;
				translateMotor->m_targetVelocity[0] = targetVelocity;
				translateMotor->m_maxMotorForce[0]  = maxForce;
			}
			break;
			case 1:
			{
				translateMotor->m_enableMotor[1]    = enabled;
				translateMotor->m_targetVelocity[1] = targetVelocity;
				translateMotor->m_maxMotorForce[1]  = maxForce;
			}
			break;
			case 2:
			{
				translateMotor->m_enableMotor[2]    = enabled;
				translateMotor->m_targetVelocity[2] = targetVelocity;
				translateMotor->m_maxMotorForce[2]  = maxForce;
			}
			break;
			case 3:
			{
				rotateMotorX->m_enableMotor    = enabled;
				rotateMotorX->m_targetVelocity = targetVelocity;
				rotateMotorX->m_maxMotorForce  = maxForce;
			}
			break;
			case 4:
			{
				rotateMotorY->m_enableMotor    = enabled;
				rotateMotorY->m_targetVelocity = targetVelocity;
				rotateMotorY->m_maxMotorForce  = maxForce;
			}
			break;
			case 5:
			{
				rotateMotorZ->m_enableMotor    = enabled;
				rotateMotorZ->m_targetVelocity = targetVelocity;
				rotateMotorZ->m_maxMotorForce  = maxForce;
			}
			break;
		}
	}
	else if(_type == pxJOINT_HINGE)
	{
		((btHingeConstraint*)_systemJoint)->enableAngularMotor(enabled, targetVelocity, maxForce);
	}
}

void pxJoint::SetHingeMotorTarget(float angle, float delta)
{
	if(_type == pxJOINT_HINGE)
	{
		((btHingeConstraint*)_systemJoint)->setMotorTarget(angle, delta);
	}
}