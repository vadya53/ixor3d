#ifndef _IBODY_H_
#define _IBODY_H_

enum pxBodyTypes
{
	pxBODY_RIGID = 0
};

class IBody
{
public:
	virtual ~IBody(){}
	virtual pxBodyTypes GetBodyType() = 0;
	virtual void SetPosition(float x, float y, float z) = 0;
	virtual void SetScale(float x, float y, float z) = 0;
	virtual void SetRotation(float x, float y, float z) = 0;
	virtual void SetQuaternion(float x, float y, float z, float w) = 0;
	virtual void GetPosition(float * position) = 0;
	virtual void GetRotation(float * position) = 0;
	virtual void GetQuaternion(float * position) = 0;
	virtual float GetPositionX() = 0;
	virtual float GetPositionY() = 0;
	virtual float GetPositionZ() = 0;
	virtual float GetRotationX() = 0;
	virtual float GetRotationY() = 0;
	virtual float GetRotationZ() = 0;
	virtual float GetQuaternionX() = 0;
	virtual float GetQuaternionY() = 0;
	virtual float GetQuaternionZ() = 0;
	virtual float GetQuaternionW() = 0;
	virtual void ApplyCentralForce(float x, float y, float z) = 0;
	virtual void ApplyCentralImpulse(float x, float y, float z) = 0;
	virtual void ApplyTorque(float x, float y, float z) = 0;
	virtual void ApplyTorqueImpulse(float x, float y, float z) = 0;
	virtual void ApplyForce(float x, float y, float z, float pointx, float pointy, float pointz) = 0;
	virtual void ApplyImpulse(float x, float y, float z, float pointx, float pointy, float pointz) = 0;
	virtual void ReleaseForces() = 0;
	virtual void SetDamping(float linear, float angular) = 0;
	virtual float GetLinearDamping() = 0;
	virtual float GetAngularDamping() = 0;
	virtual void SetFriction(float friction) = 0;
	virtual float GetFriction() = 0;
	virtual void SetRestitution(float restitution) = 0;
	virtual float GetRestitution() = 0;
	virtual void GetForce(float * force) = 0;
	virtual float GetForceX() = 0;
	virtual float GetForceY() = 0;
	virtual float GetForceZ() = 0;
	virtual void GetTorque(float * torque) = 0;
	virtual float GetTorqueX() = 0;
	virtual float GetTorqueY() = 0;
	virtual float GetTorqueZ() = 0;
	virtual int GetContactsNumber() = 0;
	virtual void GetContactPoint(int index, float * point) = 0;
	virtual float GetContactX(int index) = 0;
	virtual float GetContactY(int index) = 0;
	virtual float GetContactZ(int index) = 0;
	virtual void GetContactNormal(int index, float * normal) = 0;
	virtual float GetContactNX(int index) = 0;
	virtual float GetContactNY(int index) = 0;
	virtual float GetContactNZ(int index) = 0;
	virtual float GetContactDistance(int index) = 0;
	virtual IBody * GetContactSecondBody(int index) = 0;
};

#endif