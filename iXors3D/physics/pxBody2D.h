//
//  pxBody2D.h
//  iXors3D
//
//  Created by Knightmare on 8/2/10.
//  Copyright 2010 XorsTeam. All rights reserved.
//

#ifndef _PXBODY2D_H_
#define _PXBODY2D_H_

#include "IBody2D.h"
#include "IWorld2D.h"
#include <Box2D.h>
#include <vector>

class pxBody2D : public IBody2D
{
private:
	struct pxContact
	{
		b2Vec2    point;
		b2Vec2    normal;
		IBody2D * other;
		pxContact()
		{
			point  = b2Vec2(0.0f, 0.0f);
			normal = b2Vec2(0.0f, 0.0f);
			other  = NULL;
		}
		pxContact(b2Vec2 _point, b2Vec2 _normal, IBody2D * _other)
		{
			point  = _point;
			normal = _normal;
			other  = _other;
		}
	};
private:
	IWorld2D               * _world;
	b2Body                 * _body;
	std::vector<pxContact>   _contacts;
	std::vector<IBody2D*>    _touches;
	unsigned int             _iteration;
private:
	void UpdateContacts();
public:
	pxBody2D(IWorld2D * world, b2Body * body);
	virtual ~pxBody2D();
	b2Body * GetBody();
	virtual void SetPosition(float x, float y);
	virtual void SetRotation(float angle);
	virtual void GetPosition(float * position);
	virtual float GetPositionX();
	virtual float GetPositionY();
	virtual float GetRotation();
	virtual void LockRotation(bool flag);
	virtual bool RotationLocked();
	virtual void SetBullet(bool flag);
	virtual bool IsBullet();
	virtual void SetSensor(bool flag);
	virtual bool IsSensor();
	virtual void Activate(bool flag);
	virtual bool IsActive();
	virtual void AllowSleep(bool flag);
	virtual bool IsAllowedSleep();
	virtual void ApplyCentralForce(float x, float y);
	virtual void ApplyCentralImpulse(float x, float y);
	virtual void ApplyForce(float x, float y, float pointx, float pointy);
	virtual void ApplyImpulse(float x, float y, float pointx, float pointy);
	virtual void ApplyTorque(float omega);
	virtual void ApplyTorqueImpulse(float omega);
	virtual void ReleaseForces();
	virtual void SetDamping(float linear, float angular);
	virtual float GetLinearDamping();
	virtual float GetAngularDamping();
	virtual void SetFriction(float friction);
	virtual float GetFriction();
	virtual void SetDensity(float density);
	virtual float GetDensity();
	virtual void SetRestitution(float restitution);
	virtual float GetRestitution();
	virtual int CountTouches();
	virtual IBody2D * GetTouchingShape(int index);
	virtual int CountContacts();
	virtual void GetContactPoint(int index, float * position);
	virtual float GetContactX(int index);
	virtual float GetContactY(int index);
	virtual void GetContactNormal(int index, float * normal);
	virtual float GetContactNX(int index);
	virtual float GetContactNY(int index);
	virtual IBody2D * GetContactSecondBody(int index);
	virtual void SetMass(float mass);
	virtual float GetMass();
};


#endif
