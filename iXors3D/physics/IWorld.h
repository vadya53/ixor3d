#ifndef _IWORLD_H_
#define _IWORLD_H_

#include "IBody.h"
#include "IJoint.h"

class IWorld
{
public:
	virtual ~IWorld(){}
	virtual void SetGravity(float x, float y, float z) = 0;
	virtual IBody * CreateDummyBody() = 0;
	virtual IBody * CreateCubeBody(float width, float height, float depth, float mass) = 0;
	virtual IBody * CreateSphereBody(float radius, float mass) = 0;
	virtual IBody * CreateCapsuleBody(float radius, float height, float mass) = 0;
	virtual IBody * CreateConeBody(float radius, float height, float mass) = 0;
	virtual IBody * CreateCylinderBody(float width, float height, float depth, float mass) = 0;
	virtual IBody * CreateTriMeshBody(float * vertices, int numVertices, int * indices, int numIndices, float mass) = 0;
	virtual IBody * CreateHullBody(float * vertices, int numVertices, float mass) = 0;
	virtual void DeleteBody(IBody * body) = 0;
	virtual void Update(float speed) = 0;
	virtual void ProceedContacts(IBody * body) = 0;
	virtual IJoint * CreateJoint(pxJointType type, IBody * firstBody, IBody * secondBody) = 0;
	virtual void DeleteJoint(IJoint * joint) = 0;
};

#endif