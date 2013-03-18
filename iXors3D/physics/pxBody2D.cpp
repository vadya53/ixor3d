//
//  pxBody2D.cpp
//  iXors3D
//
//  Created by Knightmare on 8/2/10.
//  Copyright 2010 XorsTeam. All rights reserved.
//

#include "pxBody2D.h"
#include "pxWorld2D.h"

pxBody2D::pxBody2D(IWorld2D * world, b2Body * body)
{
	_world     = world;
	_body      = body;
	_iteration = 0;
}

pxBody2D::~pxBody2D()
{
}

b2Body * pxBody2D::GetBody()
{
	return _body;
}

void pxBody2D::SetMass(float mass)
{
	_body->SetType(mass > 0.0f ? b2_dynamicBody : b2_staticBody);
	if(mass > 0.0f)
	{
		float massInverse = mass / _body->GetMass();
		b2MassData massData;
		massData.center = _body->GetLocalCenter();
		massData.mass   = mass;
		massData.I      = _body->GetInertia() * massInverse;
		_body->SetMassData(&massData);
	}
}

float pxBody2D::GetMass()
{
	if(_body->GetType() == b2_staticBody) return 0.0f;
	return _body->GetMass();
}

void pxBody2D::UpdateContacts()
{
	if(_iteration != ((pxWorld2D*)_world)->GetIteration())
	{
		_contacts.clear();
		_touches.clear();
		b2ContactEdge * contactEdge = _body->GetContactList();
		while(contactEdge != NULL)
		{
			if(contactEdge->contact != NULL)
			{
				//if(contactEdge->contact->IsTouching())
				//{
				//	_touches.push_back((IBody2D*)contactEdge->other->GetUserData());
				//}
				//else
				{
					b2WorldManifold manifold;
					contactEdge->contact->GetWorldManifold(&manifold);
					for(int i = 0; i < contactEdge->contact->GetManifold()->pointCount; i++)
					{
						_contacts.push_back(pxContact(manifold.points[i], manifold.normal, 
													  (IBody2D*)contactEdge->other->GetUserData()));
					}
					if(IsSensor() && contactEdge->contact->GetManifold()->pointCount == 0)
					{
						_touches.push_back((IBody2D*)contactEdge->other->GetUserData());
					}
				}
			}
			contactEdge = contactEdge->next;
		}
		_iteration = ((pxWorld2D*)_world)->GetIteration();
	}
}

void pxBody2D::SetPosition(float x, float y)
{
	b2Transform transform = _body->GetTransform();
	_body->SetTransform(b2Vec2(x, y), transform.GetAngle());
	
}

void pxBody2D::SetRotation(float angle)
{
	b2Transform transform = _body->GetTransform();
	_body->SetTransform(transform.position, angle / 180.0f * b2_pi);
}

void pxBody2D::GetPosition(float * position)
{
	b2Transform transform = _body->GetTransform();
	position[0] = transform.position.x;
	position[1] = transform.position.y;
}

float pxBody2D::GetPositionX()
{
	b2Transform transform = _body->GetTransform();
	return transform.position.x;
}

float pxBody2D::GetPositionY()
{
	b2Transform transform = _body->GetTransform();
	return transform.position.y;
}

float pxBody2D::GetRotation()
{
	b2Transform transform = _body->GetTransform();
	return transform.GetAngle() / b2_pi * 180.0f;
}

void pxBody2D::LockRotation(bool flag)
{
	_body->SetFixedRotation(flag);
}

bool pxBody2D::RotationLocked()
{
	return _body->IsFixedRotation();
}

void pxBody2D::SetBullet(bool flag)
{
	_body->SetBullet(flag);
}

bool pxBody2D::IsBullet()
{
	return _body->IsBullet();
}

void pxBody2D::SetSensor(bool flag)
{
	b2Fixture * fixture = _body->GetFixtureList();
	while(fixture != NULL)
	{
		fixture->SetSensor(flag);
		fixture = fixture->GetNext();
	}
}

bool pxBody2D::IsSensor()
{
	b2Fixture * fixture = _body->GetFixtureList();
	if(fixture != NULL) return fixture->IsSensor();
	return false;
}

void pxBody2D::Activate(bool flag)
{
	_body->SetActive(flag);
}

bool pxBody2D::IsActive()
{
	return _body->IsActive();
}

void pxBody2D::AllowSleep(bool flag)
{
	_body->SetSleepingAllowed(flag);
}

bool pxBody2D::IsAllowedSleep()
{
	return _body->IsSleepingAllowed();
}

void pxBody2D::ApplyCentralForce(float x, float y)
{
	b2Vec2 centerOfMass = _body->GetWorldCenter();
	_body->ApplyForce(b2Vec2(x, y), centerOfMass);
}

void pxBody2D::ApplyCentralImpulse(float x, float y)
{
	b2Vec2 centerOfMass = _body->GetWorldCenter();
	_body->ApplyLinearImpulse(b2Vec2(x, y), centerOfMass);
}

void pxBody2D::ApplyForce(float x, float y, float pointx, float pointy)
{
	b2Vec2 centerOfMass = _body->GetWorldPoint(b2Vec2(pointx, pointy));
	_body->ApplyForce(b2Vec2(x, y), centerOfMass);
}

void pxBody2D::ApplyImpulse(float x, float y, float pointx, float pointy)
{
	b2Vec2 centerOfMass = _body->GetWorldPoint(b2Vec2(pointx, pointy));
	_body->ApplyLinearImpulse(b2Vec2(x, y), centerOfMass);
}

void pxBody2D::ApplyTorque(float omega)
{
	_body->ApplyTorque(omega);
}

void pxBody2D::ApplyTorqueImpulse(float omega)
{
	_body->ApplyAngularImpulse(omega);
}

void pxBody2D::ReleaseForces()
{
	_body->SetLinearVelocity(b2Vec2(0.0f, 0.0f));
	_body->SetAngularVelocity(0.0f);
}

void pxBody2D::SetDamping(float linear, float angular)
{
	_body->SetLinearDamping(linear);
	_body->SetAngularDamping(angular);
}

float pxBody2D::GetLinearDamping()
{
	return _body->GetLinearDamping();
}

float pxBody2D::GetAngularDamping()
{
	return _body->GetAngularDamping();
}

void pxBody2D::SetFriction(float friction)
{
	b2Fixture * fixture = _body->GetFixtureList();
	while(fixture != NULL)
	{
		fixture->SetFriction(friction);
		fixture = fixture->GetNext();
	}
}

float pxBody2D::GetFriction()
{
	b2Fixture * fixture = _body->GetFixtureList();
	if(fixture != NULL) return fixture->GetFriction();
	return 0.0f;
}

void pxBody2D::SetDensity(float density)
{
	b2Fixture * fixture = _body->GetFixtureList();
	while(fixture != NULL)
	{
		fixture->SetDensity(density);
		fixture = fixture->GetNext();
	}	
}

float pxBody2D::GetDensity()
{
	b2Fixture * fixture = _body->GetFixtureList();
	if(fixture != NULL) return fixture->GetDensity();
	return 0.0f;
}

void pxBody2D::SetRestitution(float restitution)
{
	b2Fixture * fixture = _body->GetFixtureList();
	while(fixture != NULL)
	{
		fixture->SetRestitution(restitution);
		fixture = fixture->GetNext();
	}	
}

float pxBody2D::GetRestitution()
{
	b2Fixture * fixture = _body->GetFixtureList();
	if(fixture != NULL) return fixture->GetRestitution();
	return 0.0f;
}

int pxBody2D::CountTouches()
{
	UpdateContacts();
	return _touches.size();
}

IBody2D * pxBody2D::GetTouchingShape(int index)
{
	UpdateContacts();
	if(index < 0 || index >= _touches.size()) return NULL;
	return _touches[index];
}

int pxBody2D::CountContacts()
{
	UpdateContacts();
	return _contacts.size();
}

void pxBody2D::GetContactPoint(int index, float * position)
{
	UpdateContacts();
	if(index < 0 || index >= _contacts.size()) return;
	position[0] = _contacts[index].point.x;
	position[1] = _contacts[index].point.y;
}

float pxBody2D::GetContactX(int index)
{
	UpdateContacts();
	if(index < 0 || index >= _contacts.size()) return 0.0f;
	return _contacts[index].point.x;
}

float pxBody2D::GetContactY(int index)
{
	UpdateContacts();
	if(index < 0 || index >= _contacts.size()) return 0.0f;
	return _contacts[index].point.y;
}

void pxBody2D::GetContactNormal(int index, float * normal)
{
	UpdateContacts();
	if(index < 0 || index >= _contacts.size()) return;
	normal[0] = _contacts[index].normal.x;
	normal[1] = _contacts[index].normal.y;
}

float pxBody2D::GetContactNX(int index)
{
	UpdateContacts();
	if(index < 0 || index >= _contacts.size()) return 0.0f;
	return _contacts[index].normal.x;
}

float pxBody2D::GetContactNY(int index)
{
	UpdateContacts();
	if(index < 0 || index >= _contacts.size()) return 0.0f;
	return _contacts[index].normal.y;
}

IBody2D * pxBody2D::GetContactSecondBody(int index)
{
	UpdateContacts();
	if(index < 0 || index >= _contacts.size()) return NULL;
	return _contacts[index].other;
}
