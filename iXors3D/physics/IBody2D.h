//
//  IBody2D.h
//  iXors3D
//
//  Created by Knightmare on 8/2/10.
//  Copyright 2010 XorsTeam. All rights reserved.
//
#ifndef _IBODY2D_H_
#define _IBODY2D_H_

class IBody2D
{
public:
	virtual ~IBody2D() {}
	virtual void SetPosition(float x, float y) = 0;
	virtual void SetRotation(float angle) = 0;
	virtual void GetPosition(float * position) = 0;
	virtual float GetPositionX() = 0;
	virtual float GetPositionY() = 0;
	virtual float GetRotation() = 0;
	virtual void LockRotation(bool flag) = 0;
	virtual bool RotationLocked() = 0;
	virtual void SetBullet(bool flag) = 0;
	virtual bool IsBullet() = 0;
	virtual void SetSensor(bool flag) = 0;
	virtual bool IsSensor() = 0;
	virtual void Activate(bool flag) = 0;
	virtual bool IsActive() = 0;
	virtual void AllowSleep(bool flag) = 0;
	virtual bool IsAllowedSleep() = 0;
	virtual void ApplyCentralForce(float x, float y) = 0;
	virtual void ApplyCentralImpulse(float x, float y) = 0;
	virtual void ApplyForce(float x, float y, float pointx, float pointy) = 0;
	virtual void ApplyImpulse(float x, float y, float pointx, float pointy) = 0;
	virtual void ApplyTorque(float omega) = 0;
	virtual void ApplyTorqueImpulse(float omega) = 0;
	virtual void ReleaseForces() = 0;
	virtual void SetDamping(float linear, float angular) = 0;
	virtual float GetLinearDamping() = 0;
	virtual float GetAngularDamping() = 0;
	virtual void SetFriction(float friction) = 0;
	virtual float GetFriction() = 0;
	virtual void SetDensity(float density) = 0;
	virtual float GetDensity() = 0;
	virtual void SetRestitution(float restitution) = 0;
	virtual float GetRestitution() = 0;
	virtual int CountTouches() = 0;
	virtual IBody2D * GetTouchingShape(int index) = 0;
	virtual int CountContacts() = 0;
	virtual void GetContactPoint(int index, float * position) = 0;
	virtual float GetContactX(int index) = 0;
	virtual float GetContactY(int index) = 0;
	virtual void GetContactNormal(int index, float * normal) = 0;
	virtual float GetContactNX(int index) = 0;
	virtual float GetContactNY(int index) = 0;
	virtual IBody2D * GetContactSecondBody(int index) = 0;
	virtual void SetMass(float mass) = 0;
	virtual float GetMass() = 0;
};

#endif