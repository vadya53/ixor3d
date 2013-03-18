//
//  pxWorld2D.h
//  iXors3D
//
//  Created by Knightmare on 8/2/10.
//  Copyright 2010 XorsTeam. All rights reserved.
//
#ifndef _PXWORLD2D_H_
#define _PXWORLD2D_H_

#include "IWorld2D.h"
#include "IJoint2D.h"
#include <Box2D.h>
#include <vector>

class pxWorld2D : public IWorld2D
{
private:
	b2World                * _world;
	double                   _lastTime;
	std::vector<IBody2D*>    _bodies;
	std::vector<IJoint2D*>   _joints;
	unsigned int             _iteration;
	int                      _velIterations, _posIterations;
private:
	b2Body * CreateRigidBody(const b2Shape * shape, float mass);
public:
	pxWorld2D();
	unsigned int GetIteration();
	virtual ~pxWorld2D();
	virtual void SetGravity(float x, float y);
	virtual IBody2D * CreateDummyBody();
	virtual IBody2D * CreateBoxBody(float width, float height, float mass);
	virtual IBody2D * CreateCircleBody(float radii, float mass);
	virtual IBody2D * CreatePolygonBody(float * points, int count, float mass);
	virtual void DeleteBody(IBody2D * body);
	virtual void Update(float speed);
	virtual void DeleteJoint(IJoint2D * joint);
	virtual void Clear();
	virtual IJoint2D * CreateDistanceJoint(IBody2D * bodyA, IBody2D * bodyB, bool collide);
	virtual IJoint2D * CreateDistanceJoint(IBody2D * bodyA, IBody2D * bodyB, float pivotAX, float pivotAY, float pivotBX, float pivotBY, bool collide);
	virtual IJoint2D * CreateRevoluteJoint(IBody2D * bodyA, IBody2D * bodyB, bool collide);
	virtual IJoint2D * CreateRevoluteJoint(IBody2D * bodyA, IBody2D * bodyB, float axisX, float axisY, bool collide);
	virtual IJoint2D * CreatePrismaticJoint(IBody2D * bodyA, IBody2D * bodyB, float axisX, float axisY, bool collide);
	virtual IJoint2D * CreatePrismaticJoint(IBody2D * bodyA, IBody2D * bodyB, float pivotX, float pivotY, float axisX, float axisY, bool collide);
	virtual IJoint2D * CreatePulleyJoint(IBody2D * bodyA, IBody2D * bodyB, float anchorAX, float anchorAY, float anchorBX, float anchorBY, bool collide);
	virtual IJoint2D * CreatePulleyJoint(IBody2D * bodyA, IBody2D * bodyB, float anchorAX, float anchorAY, float anchorBX, float anchorBY, float pivotAX, float pivotAY, float pivotBX, float pivotBY, bool collide);
	virtual IJoint2D * CreateGearJoint(IJoint2D * jointA, IJoint2D * jointB);
	virtual void SetIterations(int velocity, int position);
};

#endif