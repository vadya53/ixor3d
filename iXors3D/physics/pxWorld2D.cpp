//
//  pxWorld2D.m
//  iXors3D
//
//  Created by Knightmare on 8/2/10.
//  Copyright 2010 XorsTeam. All rights reserved.
//

#include "pxWorld2D.h"
#include "pxBody2D.h"
#include "pxJoint2D.h"
#include <algorithm>

unsigned int timeGetTime();

pxWorld2D::pxWorld2D()
{
	_world         = new b2World(b2Vec2(0.0f, 10.0f), true);
	_lastTime      = 0.0;
	_iteration     = 0;
	_velIterations = 6;
	_posIterations = 2;
}

pxWorld2D::~pxWorld2D()
{
	delete _world;
}

unsigned int pxWorld2D::GetIteration()
{
	return _iteration;
}

void pxWorld2D::SetGravity(float x, float y)
{
	_world->SetGravity(b2Vec2(x, y));
}

b2Body * pxWorld2D::CreateRigidBody(const b2Shape * shape, float mass)
{
	b2BodyDef bodyDefinition;
	bodyDefinition.type = (mass > 0.0f ? b2_dynamicBody : b2_staticBody);
	b2Body * body = _world->CreateBody(&bodyDefinition);
	body->CreateFixture(shape, 1.0f);
	if(mass > 0.0f)
	{
		float massInverse = mass / body->GetMass();
		b2MassData massData;
		massData.center = body->GetLocalCenter();
		massData.mass   = mass;
		massData.I      = body->GetInertia() * massInverse;
		body->SetMassData(&massData);
	}
	return body;
}

IBody2D * pxWorld2D::CreateBoxBody(float width, float height, float mass)
{
	b2PolygonShape boxShape;
	boxShape.SetAsBox(width / 2.0f, height / 2.0f);	
	b2Body * body = CreateRigidBody(&boxShape, mass);
	pxBody2D * newBody = new pxBody2D(this, body);
	body->SetUserData(newBody);
	_bodies.push_back(newBody);
	return newBody;
}

IBody2D * pxWorld2D::CreateCircleBody(float radii, float mass)
{
	b2CircleShape circleShape;
	circleShape.m_p.Set(0.0f, 0.0f);
	circleShape.m_radius = radii;
	b2Body * body = CreateRigidBody(&circleShape, mass);
	pxBody2D * newBody = new pxBody2D(this, body);
	body->SetUserData(newBody);
	_bodies.push_back(newBody);
	return newBody;
}

IBody2D * pxWorld2D::CreatePolygonBody(float * points, int count, float mass)
{
	b2PolygonShape polygonShape;
	polygonShape.Set((b2Vec2*)points, count);
	b2Body * body = CreateRigidBody(&polygonShape, mass);
	pxBody2D * newBody = new pxBody2D(this, body);
	body->SetUserData(newBody);
	_bodies.push_back(newBody);
	return newBody;
}

IBody2D * pxWorld2D::CreateDummyBody()
{
	b2BodyDef bodyDefinition;
	bodyDefinition.type = b2_staticBody;
	b2Body * body = _world->CreateBody(&bodyDefinition);
	pxBody2D * newBody = new pxBody2D(this, body);
	body->SetUserData(newBody);
	_bodies.push_back(newBody);
	return newBody;	
}

void pxWorld2D::DeleteBody(IBody2D * body)
{
	std::vector<IBody2D*>::iterator itr = std::find(_bodies.begin(), _bodies.end(), body);
	if(itr != _bodies.end()) _bodies.erase(itr);
	pxBody2D * realBody = (pxBody2D*)body;
	_world->DestroyBody(realBody->GetBody());
	delete realBody;
}

void pxWorld2D::SetIterations(int velocity, int position)
{
	_velIterations = velocity;
	_posIterations = position;
}

void pxWorld2D::Update(float speed)
{
	if(_lastTime == 0.0) _lastTime = double(timeGetTime()) / 1000.0;
	float elapsed = double(timeGetTime()) / 1000.0 - _lastTime;
	_lastTime     = double(timeGetTime()) / 1000.0;
	_world->Step(elapsed * double(speed), _velIterations, _posIterations);
	//_world->Step(1.0f / 60.0f, 6, 2);
	_world->ClearForces();
	_iteration++;
}

void pxWorld2D::DeleteJoint(IJoint2D * joint)
{
	std::vector<IJoint2D*>::iterator itr = std::find(_joints.begin(), _joints.end(), joint);
	if(itr != _joints.end()) _joints.erase(itr);
	_world->DestroyJoint(((pxJoint2D*)joint)->GetJoint());
	delete joint;
}

void pxWorld2D::Clear()
{
	std::vector<IJoint2D*> joints(_joints);
	std::vector<IBody2D*>  bodies(_bodies);
	for(int i = 0; i < joints.size(); i++) DeleteJoint(joints[i]);
	for(int i = 0; i < bodies.size(); i++) DeleteBody(bodies[i]);
}

IJoint2D * pxWorld2D::CreateDistanceJoint(IBody2D * bodyA, IBody2D * bodyB, bool collide)
{
	return CreateDistanceJoint(bodyA, bodyB, 0, 0, 0, 0, collide);
}

IJoint2D * pxWorld2D::CreateDistanceJoint(IBody2D * bodyA, IBody2D * bodyB, float pivotAX, float pivotAY, float pivotBX, float pivotBY, bool collide)
{
	b2Vec2 anchorA = ((pxBody2D*)bodyA)->GetBody()->GetWorldPoint(b2Vec2(pivotAX, pivotAY));
	b2Vec2 anchorB = ((pxBody2D*)bodyB)->GetBody()->GetWorldPoint(b2Vec2(pivotBX, pivotBY));
	b2DistanceJointDef definition;
	definition.Initialize(((pxBody2D*)bodyA)->GetBody(), ((pxBody2D*)bodyB)->GetBody(), anchorA, anchorB);
	definition.collideConnected = collide;
	IJoint2D * newJoint = new pxJoint2D(pxJOINT2D_DISTANCE, _world->CreateJoint(&definition));
	_joints.push_back(newJoint);
	return newJoint;
}

IJoint2D * pxWorld2D::CreateRevoluteJoint(IBody2D * bodyA, IBody2D * bodyB, bool collide)
{
	return CreateRevoluteJoint(bodyA, bodyB, 0, 0, collide);
}

IJoint2D * pxWorld2D::CreateRevoluteJoint(IBody2D * bodyA, IBody2D * bodyB, float axisX, float axisY, bool collide)
{
	b2Vec2 anchor = ((pxBody2D*)bodyA)->GetBody()->GetWorldPoint(b2Vec2(axisX, axisY));
	b2RevoluteJointDef definition;
	definition.Initialize(((pxBody2D*)bodyA)->GetBody(), ((pxBody2D*)bodyB)->GetBody(), anchor);
	definition.collideConnected = collide;
	IJoint2D * newJoint = new pxJoint2D(pxJOINT2D_REVOLUTE, _world->CreateJoint(&definition));
	_joints.push_back(newJoint);
	return newJoint;
}

IJoint2D * pxWorld2D::CreatePrismaticJoint(IBody2D * bodyA, IBody2D * bodyB, float axisX, float axisY, bool collide)
{
	return CreatePrismaticJoint(bodyA, bodyB, 0, 0, axisX, axisY, collide);
}

IJoint2D * pxWorld2D::CreatePrismaticJoint(IBody2D * bodyA, IBody2D * bodyB, float pivotX, float pivotY, float axisX, float axisY, bool collide)
{
	b2Vec2 anchor = ((pxBody2D*)bodyA)->GetBody()->GetWorldPoint(b2Vec2(pivotX, pivotY));
	b2PrismaticJointDef definition;
	definition.Initialize(((pxBody2D*)bodyA)->GetBody(), ((pxBody2D*)bodyB)->GetBody(), anchor, b2Vec2(axisX, axisY));
	definition.collideConnected = collide;
	IJoint2D * newJoint = new pxJoint2D(pxJOINT2D_PRISMATIC, _world->CreateJoint(&definition));
	_joints.push_back(newJoint);
	return newJoint;
}

IJoint2D * pxWorld2D::CreatePulleyJoint(IBody2D * bodyA, IBody2D * bodyB, float anchorAX, float anchorAY, float anchorBX, float anchorBY, bool collide)
{
	return CreatePulleyJoint(bodyA, bodyB, anchorAX, anchorAY, anchorBX, anchorBY, 0, 0, 0, 0, collide);
}

IJoint2D * pxWorld2D::CreatePulleyJoint(IBody2D * bodyA, IBody2D * bodyB, float anchorAX, float anchorAY, float anchorBX, float anchorBY, float pivotAX, float pivotAY, float pivotBX, float pivotBY, bool collide)
{
	b2Vec2 anchorA = ((pxBody2D*)bodyA)->GetBody()->GetWorldPoint(b2Vec2(pivotAX, pivotAY));
	b2Vec2 anchorB = ((pxBody2D*)bodyB)->GetBody()->GetWorldPoint(b2Vec2(pivotBX, pivotBY));
	b2PulleyJointDef definition;
	definition.Initialize(((pxBody2D*)bodyA)->GetBody(), ((pxBody2D*)bodyB)->GetBody(), 
						  b2Vec2(anchorAX, anchorAY), b2Vec2(anchorBX, anchorBY), anchorA, anchorB, 1.0f);
	definition.collideConnected = collide;
	IJoint2D * newJoint = new pxJoint2D(pxJOINT2D_PULLEY, _world->CreateJoint(&definition));
	_joints.push_back(newJoint);
	return newJoint;
}

IJoint2D * pxWorld2D::CreateGearJoint(IJoint2D * jointA, IJoint2D * jointB)
{
	if((jointA->GetType() != pxJOINT2D_REVOLUTE && jointA->GetType() != pxJOINT2D_PRISMATIC)
	   || (jointB->GetType() != pxJOINT2D_REVOLUTE && jointB->GetType() != pxJOINT2D_PRISMATIC))
	{
		printf("ERROR(%s:%i): Invalid joints types for gear joint (must be revolute or prismatic)\n", __FILE__, __LINE__);
		return NULL;
	}
	b2GearJointDef definition;
	definition.joint1 = ((pxJoint2D*)jointA)->GetJoint();
	definition.joint2 = ((pxJoint2D*)jointB)->GetJoint();
	definition.ratio  = 1.0f;
	IJoint2D * newJoint = new pxJoint2D(pxJOINT2D_GEAR, _world->CreateJoint(&definition));
	_joints.push_back(newJoint);
	return newJoint;
	
}