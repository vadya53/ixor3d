#ifndef _PXWORLD_H_
#define _PXWORLD_H_

#include "IWorld.h"
#include <btBulletDynamicsCommon.h>
#include <LinearMath/btAlignedObjectArray.h>

class pxWorld : IWorld
{
private:
	btDefaultCollisionConfiguration         * _collisionConfig;
	btCollisionDispatcher                   * _dispatcher;
	btDbvtBroadphase                        * _broadphase;
	btSequentialImpulseConstraintSolver     * _solver;
	btDiscreteDynamicsWorld                 * _world;
	btAlignedObjectArray<btCollisionShape*>	  _collisionShapes;
	float                                     _lastTime;
	unsigned int                              _lastIteration;
private:
	btRigidBody * CreateRigidBody(btCollisionShape * shape, float mass);
public:
	pxWorld();
	virtual ~pxWorld();
	virtual void SetGravity(float x, float y, float z);
	virtual IBody * CreateDummyBody();
	virtual IBody * CreateCubeBody(float width, float height, float depth, float mass);
	virtual IBody * CreateSphereBody(float radius, float mass);
	virtual IBody * CreateCapsuleBody(float radius, float height, float mass);
	virtual IBody * CreateConeBody(float radius, float height, float mass);
	virtual IBody * CreateCylinderBody(float width, float height, float depth, float mass);
	virtual IBody * CreateTriMeshBody(float * vertices, int numVertices, int * indices, int numIndices, float mass);
	virtual IBody * CreateHullBody(float * vertices, int numVertices, float mass);
	virtual void DeleteBody(IBody * body);
	virtual void Update(float speed);
	virtual void ProceedContacts(IBody * body);
	virtual IJoint * CreateJoint(pxJointType type, IBody * firstBody, IBody * secondBody);
	virtual void DeleteJoint(IJoint * joint);
};

#endif