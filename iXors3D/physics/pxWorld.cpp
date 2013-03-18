#include "pxWorld.h"
#include "pxBody.h"
#include "pxJoint.h"
#include <iostream>

unsigned int timeGetTime();

pxWorld::pxWorld()
{
	// create dynamic world
	_collisionConfig = new btDefaultCollisionConfiguration();
	_dispatcher      = new btCollisionDispatcher(_collisionConfig);
	_broadphase      = new btDbvtBroadphase();
	_solver          = new btSequentialImpulseConstraintSolver();
	_world           = new btDiscreteDynamicsWorld(_dispatcher, _broadphase,
												   _solver, _collisionConfig);
	// set initial gravity
	_world->setGravity(btVector3(0.0f, -10.0f, 0.0f));
	// set last updte time value
	_lastTime      = 0.0f;
	_lastIteration = 0;
}

pxWorld::~pxWorld()
{
	// remove the rigidbodies from the dynamics world and delete them
	for(int i = _world->getNumCollisionObjects() - 1; i >= 0; i--)
	{
		// get object from array
		btCollisionObject * object = _world->getCollisionObjectArray()[i];
		// cast to rigib body
		btRigidBody       * body   = btRigidBody::upcast(object);
		// remove motion state
		if(body != NULL && body->getMotionState()) delete body->getMotionState();
		// remove body from world
		_world->removeCollisionObject(object);
		// delete body object
		delete object;
	}
	// delete collision shapes
	for(int j = 0; j < _collisionShapes.size(); j++) delete _collisionShapes[j];
	// release Bullet objects
	delete _world;
	delete _solver;
	delete _broadphase;
	delete _dispatcher;
	delete _collisionConfig;
}

void pxWorld::SetGravity(float x, float y, float z)
{
	_world->setGravity(btVector3(x, y, z));
}

btRigidBody * pxWorld::CreateRigidBody(btCollisionShape * shape, float mass)
{
	// compute transform
	btTransform transform;
	transform.setIdentity();
	// compute inertia if body is a dynamic
	btVector3 localInertia(0.0f, 0.0f, 0.0f);
	if(mass > 0.0f && shape != NULL) shape->calculateLocalInertia(mass, localInertia);
	// create motion state for body
	btDefaultMotionState * motionState = new btDefaultMotionState(transform);
	// create body info
	btRigidBody::btRigidBodyConstructionInfo bodyInfo(mass, motionState, shape, localInertia);
	// create body
	btRigidBody * body = new btRigidBody(bodyInfo);
	// add the body to the dynamics world
	_world->addRigidBody(body);
	// return new body
	return body;
}

IBody * pxWorld::CreateCubeBody(float width, float height, float depth, float mass)
{
	// create cube shape
	btCollisionShape * shape = new btBoxShape(btVector3(width / 2.0f, height / 2.0f, depth / 2.0f));
	shape->setUserPointer(NULL);
	_collisionShapes.push_back(shape);
	// create new body
	return (IBody*)new pxBody(CreateRigidBody(shape, mass));
}

IBody * pxWorld::CreateSphereBody(float radius, float mass)
{
	// create sphere shape
	btCollisionShape * shape = new btSphereShape(radius);
	shape->setUserPointer(NULL);
	_collisionShapes.push_back(shape);
	// create new body
	return (IBody*)new pxBody(CreateRigidBody(shape, mass));
}

IBody * pxWorld::CreateCapsuleBody(float radius, float height, float mass)
{
	// create capsule shape
	btCollisionShape * shape = new btCapsuleShape(radius, height);
	shape->setUserPointer(NULL);
	_collisionShapes.push_back(shape);
	// create new body
	return (IBody*)new pxBody(CreateRigidBody(shape, mass));
}

IBody * pxWorld::CreateConeBody(float radius, float height, float mass)
{
	// create cone shape
	btCollisionShape * shape = new btConeShape(radius, height);
	shape->setUserPointer(NULL);
	_collisionShapes.push_back(shape);
	// create new body
	return (IBody*)new pxBody(CreateRigidBody(shape, mass));
}

IBody * pxWorld::CreateCylinderBody(float width, float height, float depth, float mass)
{
	// create cylinder shape
	btCollisionShape * shape = new btCylinderShape(btVector3(width / 2.0f, height / 2.0f, depth / 2.0f));
	shape->setUserPointer(NULL);
	_collisionShapes.push_back(shape);
	// create new body
	return (IBody*)new pxBody(CreateRigidBody(shape, mass));
}

IBody * pxWorld::CreateTriMeshBody(float * vertices, int numVertices, int * indices, int numIndices, float mass)
{
	// create trimesh shape
	btTriangleIndexVertexArray * indexVertexArrays = new btTriangleIndexVertexArray(numIndices / 3,
																					indices,
																					sizeof(int) * 3,
																					numVertices,
																					(btScalar*)vertices,
																					sizeof(float) * 3);
	btCollisionShape * shape = new btBvhTriangleMeshShape(indexVertexArrays, true);
	shape->setUserPointer((void*)indexVertexArrays);
	_collisionShapes.push_back(shape);
	// create new body
	return (IBody*)new pxBody(CreateRigidBody(shape, mass));
}

IBody * pxWorld::CreateHullBody(float * vertices, int numVertices, float mass)
{
	// create cylinder shape
	btCollisionShape * shape = new btConvexHullShape((btScalar*)vertices,
													 numVertices, sizeof(float) * 3);
	shape->setUserPointer(NULL);
	_collisionShapes.push_back(shape);
	// create new body
	return (IBody*)new pxBody(CreateRigidBody(shape, mass));
}

IBody * pxWorld::CreateDummyBody()
{
	// create new body
	return (IBody*)new pxBody(CreateRigidBody(NULL, 0.0f));
}

void pxWorld::DeleteBody(IBody * body)
{
	// switch body type
	switch(body->GetBodyType())
	{
		// for rigid bodies
		case pxBODY_RIGID:
		{
			// cast pointer
			pxBody           * rigidBody = (pxBody*)body;
			// get body's collision shape
			btCollisionShape * shape     = rigidBody->GetCollisionShape();
			// remove body
			_world->removeCollisionObject(rigidBody->GetBody());
			if(shape != NULL)
			{
				// erase shape from shapes array
				_collisionShapes.remove(shape);
				// delete shape and body object
				if(shape->getUserPointer() != NULL)
				{
					delete (btTriangleIndexVertexArray*)shape->getUserPointer();
				}
				delete shape;
			}
			delete rigidBody;
		}
		break;
	}
}

void pxWorld::Update(float speed)
{
	if(_lastTime == 0.0f) _lastTime = float(timeGetTime()) / 1000.0f;
	float elapsed = float(timeGetTime()) / 1000.0f - _lastTime;
	_world->stepSimulation(elapsed * speed);
	_lastIteration++;
}

IJoint * pxWorld::CreateJoint(pxJointType type, IBody * firstBody, IBody * secondBody)
{
	if(firstBody == NULL || secondBody == NULL) return NULL;
	btTypedConstraint * newSystemJoint = NULL;
	if(firstBody->GetBodyType() == pxBODY_RIGID
		&& secondBody->GetBodyType() == pxBODY_RIGID)
	{
		btRigidBody * rigidFirst  = ((pxBody*)firstBody)->GetBody();
		btRigidBody * rigidSecond = ((pxBody*)secondBody)->GetBody();
		btVector3     distance    = rigidFirst->getWorldTransform().getOrigin() - rigidSecond->getWorldTransform().getOrigin();
		rigidFirst->setActivationState(DISABLE_DEACTIVATION);
		rigidSecond->setActivationState(DISABLE_DEACTIVATION);
		switch(type)
		{
			case pxJOINT_POINT2POINT:
			{
				newSystemJoint = new btPoint2PointConstraint(*rigidFirst, 
															 *rigidSecond,
															 btVector3(0.0f, 0.0f, 0.0f),
															 distance);
			}
			break;
			case pxJOINT_6DOF:
			{
				newSystemJoint = new btGeneric6DofConstraint(*rigidFirst, 
															 *rigidSecond,
															 btTransform::getIdentity(),
															 btTransform::getIdentity(),
															 true);
			}
			break;
			case pxJOINT_SPRING:
			{
				newSystemJoint = new btGeneric6DofSpringConstraint(*rigidFirst, 
																   *rigidSecond,
																   btTransform::getIdentity(),
																   btTransform::getIdentity(),
																   true);
			}
			break;
			case pxJOINT_HINGE:
			{
				btVector3 zero = btVector3(0.0f, 0.0f, 0.0f);
				btVector3 one  = btVector3(0.0f, 1.0f, 0.0f);
				newSystemJoint = new btHingeConstraint(*rigidFirst, 
													   *rigidSecond,
													   zero,
													   distance,
													   one,
													   one,
													   true);
				((btHingeConstraint*)newSystemJoint)->setAngularOnly(true);
			}
			break;
		}
	}
	pxJoint * newJoint = NULL;
	if(newSystemJoint != NULL)
	{
		_world->addConstraint(newSystemJoint);
		newJoint = new pxJoint(type, newSystemJoint);
	}
	return (IJoint*)newJoint;
}

void pxWorld::DeleteJoint(IJoint * joint)
{
	if(joint == NULL) return;
	pxJoint * realJoint = (pxJoint*)joint;
	_world->removeConstraint(realJoint->GetJoint());
	delete realJoint;
}

void pxWorld::ProceedContacts(IBody * body)
{
	// for rigid bodies
	if(body->GetBodyType() == pxBODY_RIGID)
	{
		// cast pointer
		pxBody * rigidBody = (pxBody*)body;
		// if not received contacts from currect iteration
		if(rigidBody->GetLastIteration() != _lastIteration)
		{
			// aclear old contacts
			rigidBody->ClearContacts();
			// check all manifolds
			for(int i = 0; i < _world->getDispatcher()->getNumManifolds(); i++)
			{
				// getting manifold
				btPersistentManifold * contactManifold = _world->getDispatcher()->getManifoldByIndexInternal(i);
				// getting bodies
				btCollisionObject    * body1 = static_cast<btCollisionObject*>(contactManifold->getBody0());
				btCollisionObject    * body2 = static_cast<btCollisionObject*>(contactManifold->getBody1());
				// if checked body used in manifold
				if(body1 == rigidBody->GetBody() || body2 == rigidBody->GetBody())
				{
					// add all constact points into body
					for(int j = 0; j < contactManifold->getNumContacts(); j++)
					{
						// getting contact point
						btManifoldPoint & contactPoint = contactManifold->getContactPoint(j);
						// add contact
						btVector3 point  = contactPoint.getPositionWorldOnB();
						btVector3 normal = contactPoint.m_normalWorldOnB;
						rigidBody->AddContact(body1 == rigidBody->GetBody() ? body2 : body1,
											  point.x(), point.y(), point.z(),
											  normal.x(), normal.y(), normal.z(),
											  contactPoint.getDistance());
					}
				}
			}
			// reset iteration number
			rigidBody->SetLastIteration(_lastIteration);
		}
	}
}