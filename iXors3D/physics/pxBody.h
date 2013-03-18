#ifndef _PXBODY_H_
#define _PXBODY_H_

#include <vector>
#include "IBody.h"
#include <btBulletDynamicsCommon.h>

class pxBody : IBody
{
private:
	struct pxContact
	{
		float               pointx, pointy, pointz;
		float               normalx, normaly, normalz;
		float               distance;
		IBody             * otherBody;
		btCollisionObject * physBody;
		pxContact         * nextNode;
	};
	struct pxBodyList
	{
		pxBody    * physBody;
		pxContact * nextNode;
	};
private:
	static std::vector<IBody*>   _bodiesList;
	btRigidBody                * _body;
	unsigned int                 _lastIteration;
	pxContact                  * _contacts;
	pxContact                  * _lastNode;
private:
	pxContact * GetContactByIndex(int index);
public:
	pxBody(btRigidBody * body);
	virtual ~pxBody();
	virtual pxBodyTypes GetBodyType();
	btCollisionShape * GetCollisionShape();
	btRigidBody * GetBody();
	void SetLastIteration(unsigned int value);
	unsigned int GetLastIteration();
	void ClearContacts();
	void AddContact(btCollisionObject * body, float x, float y, float z, float nx, float ny, float nz, float distance);
	// IBody implementation
	virtual void SetPosition(float x, float y, float z);
	virtual void SetScale(float x, float y, float z);
	virtual void SetRotation(float x, float y, float z);
	virtual void SetQuaternion(float x, float y, float z, float w);
	virtual void GetPosition(float * position);
	virtual void GetRotation(float * rotation);
	virtual void GetQuaternion(float * quaternion);
	virtual float GetPositionX();
	virtual float GetPositionY();
	virtual float GetPositionZ();
	virtual float GetRotationX();
	virtual float GetRotationY();
	virtual float GetRotationZ();
	virtual float GetQuaternionX();
	virtual float GetQuaternionY();
	virtual float GetQuaternionZ();
	virtual float GetQuaternionW();
	virtual void ApplyCentralForce(float x, float y, float z);
	virtual void ApplyCentralImpulse(float x, float y, float z);
	virtual void ApplyTorque(float x, float y, float z);
	virtual void ApplyTorqueImpulse(float x, float y, float z);
	virtual void ApplyForce(float x, float y, float z, float pointx, float pointy, float pointz);
	virtual void ApplyImpulse(float x, float y, float z, float pointx, float pointy, float pointz);
	virtual void ReleaseForces();
	virtual void SetDamping(float linear, float angular);
	virtual float GetLinearDamping();
	virtual float GetAngularDamping();
	virtual void SetFriction(float friction);
	virtual float GetFriction();
	virtual void SetRestitution(float restitution);
	virtual float GetRestitution();
	virtual void GetForce(float * force);
	virtual float GetForceX();
	virtual float GetForceY();
	virtual float GetForceZ();
	virtual void GetTorque(float * torque);
	virtual float GetTorqueX();
	virtual float GetTorqueY();
	virtual float GetTorqueZ();
	virtual int GetContactsNumber();
	virtual void GetContactPoint(int index, float * point);
	virtual float GetContactX(int index);
	virtual float GetContactY(int index);
	virtual float GetContactZ(int index);
	virtual void GetContactNormal(int index, float * normal);
	virtual float GetContactNX(int index);
	virtual float GetContactNY(int index);
	virtual float GetContactNZ(int index);
	virtual float GetContactDistance(int index);
	virtual IBody * GetContactSecondBody(int index);
};

#endif