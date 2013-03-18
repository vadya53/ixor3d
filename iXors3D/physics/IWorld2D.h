//
//  IWorld2D.h
//  iXors3D
//
//  Created by Knightmare on 8/2/10.
//  Copyright 2010 XorsTeam. All rights reserved.
//
#ifndef _IWORLD2D_H_
#define _IWORLD2D_H_

#include "IBody2D.h"
#include "IJoint2D.h"

class IWorld2D
{
public:
	virtual ~IWorld2D(){}
	virtual void SetGravity(float x, float y) = 0;
	virtual IBody2D * CreateDummyBody() = 0;
	virtual IBody2D * CreateBoxBody(float width, float height, float mass) = 0;
	virtual IBody2D * CreateCircleBody(float radii, float mass) = 0;
	virtual IBody2D * CreatePolygonBody(float * points, int count, float mass) = 0;
	virtual void DeleteBody(IBody2D * body) = 0;
	virtual void Update(float speed) = 0;
	virtual void DeleteJoint(IJoint2D * joint) = 0;
	virtual void Clear() = 0;
	virtual IJoint2D * CreateDistanceJoint(IBody2D * bodyA, IBody2D * bodyB, bool collide) = 0;
	virtual IJoint2D * CreateDistanceJoint(IBody2D * bodyA, IBody2D * bodyB, float pivotAX, float pivotAY, float pivotBX, float pivotBY, bool collide) = 0;
	virtual IJoint2D * CreateRevoluteJoint(IBody2D * bodyA, IBody2D * bodyB, bool collide) = 0;
	virtual IJoint2D * CreateRevoluteJoint(IBody2D * bodyA, IBody2D * bodyB, float axisX, float axisY, bool collide) = 0;
	virtual IJoint2D * CreatePrismaticJoint(IBody2D * bodyA, IBody2D * bodyB, float axisX, float axisY, bool collide) = 0;
	virtual IJoint2D * CreatePrismaticJoint(IBody2D * bodyA, IBody2D * bodyB, float pivotX, float pivotY, float axisX, float axisY, bool collide) = 0;
	virtual IJoint2D * CreatePulleyJoint(IBody2D * bodyA, IBody2D * bodyB, float anchorAX, float anchorAY, float anchorBX, float anchorBY, bool collide) = 0;
	virtual IJoint2D * CreatePulleyJoint(IBody2D * bodyA, IBody2D * bodyB, float anchorAX, float anchorAY, float anchorBX, float anchorBY, float pivotAX, float pivotAY, float pivotBX, float pivotBY, bool collide) = 0;
	virtual IJoint2D * CreateGearJoint(IJoint2D * jointA, IJoint2D * jointB) = 0;
	virtual void SetIterations(int velocity, int position) = 0;
};

#endif