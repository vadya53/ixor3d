#include "pxBody.h"
#include <algorithm>

std::vector<IBody*> pxBody::_bodiesList = std::vector<IBody*>();

pxBody::pxBody(btRigidBody * body)
{
	_body          = body;
	_lastIteration = 0;
	_contacts      = NULL;
	_lastNode      = NULL;
	_bodiesList.push_back(this);
}

pxBody::~pxBody()
{
	std::vector<IBody*>::iterator itr = find(_bodiesList.begin(), _bodiesList.end(), (IBody*)this);
	if(itr != _bodiesList.end()) _bodiesList.erase(itr);
}

pxBodyTypes pxBody::GetBodyType()
{
	return pxBODY_RIGID;
}

btCollisionShape * pxBody::GetCollisionShape()
{
	return _body->getCollisionShape();
}

btRigidBody * pxBody::GetBody()
{
	return _body;
}

void pxBody::SetPosition(float x, float y, float z)
{
	btTransform transform = _body->getWorldTransform();
	transform.setOrigin(btVector3(x, y, z));
	_body->setWorldTransform(transform);
}

void pxBody::SetScale(float x, float y, float z)
{
	if(_body->getCollisionShape() == NULL) return;
	_body->getCollisionShape()->setLocalScaling(btVector3(x, y, z));
}

void pxBody::SetRotation(float x, float y, float z)
{
	static float radian = 3.1415926f / 180.0f;
	btTransform transform = _body->getWorldTransform();
	transform.setRotation(btQuaternion(x * radian, y * radian, z * radian));
	_body->setWorldTransform(transform);
}

void pxBody::SetQuaternion(float x, float y, float z, float w)
{
	btTransform transform = _body->getWorldTransform();
	transform.setRotation(btQuaternion(x, y, z, w));
	_body->setWorldTransform(transform);
}

void pxBody::GetPosition(float * position)
{
	btTransform transform = _body->getWorldTransform();
	btVector3 translate   = transform.getOrigin();
	position[0]           = translate.x();
	position[1]           = translate.y();
	position[2]           = translate.z();
}

void pxBody::GetRotation(float * rotation)
{
	btTransform transform = _body->getWorldTransform();
	btMatrix3x3(transform.getRotation()).getEulerYPR(rotation[1],
													 rotation[0],
													 rotation[2]);
}

void pxBody::GetQuaternion(float * quaternion)
{
	btTransform transform = _body->getWorldTransform();
	btQuaternion rotation = transform.getRotation();
	quaternion[0]         = rotation.x();
	quaternion[1]         = rotation.y();
	quaternion[2]         = rotation.z();
	quaternion[3]         = rotation.w();
}

float pxBody::GetPositionX()
{
	btTransform transform = _body->getWorldTransform();
	return transform.getOrigin().x();
}

float pxBody::GetPositionY()
{
	btTransform transform = _body->getWorldTransform();
	return transform.getOrigin().y();
}

float pxBody::GetPositionZ()
{
	btTransform transform = _body->getWorldTransform();
	return transform.getOrigin().z();
}

float pxBody::GetRotationX()
{
	static float degree = 180.0f / 3.1415926f;
	float yaw, pitch, roll;
	btTransform transform = _body->getWorldTransform();
	btMatrix3x3(transform.getRotation()).getEulerYPR(roll, yaw, pitch);
	return pitch * degree;
}

float pxBody::GetRotationY()
{
	static float degree = 180.0f / 3.1415926f;
	float yaw, pitch, roll;
	btTransform transform = _body->getWorldTransform();
	btMatrix3x3(transform.getRotation()).getEulerYPR(roll, yaw, pitch);
	return yaw * degree;
}

float pxBody::GetRotationZ()
{
	static float degree = 180.0f / 3.1415926f;
	float yaw, pitch, roll;
	btTransform transform = _body->getWorldTransform();
	btMatrix3x3(transform.getRotation()).getEulerYPR(roll, yaw, pitch);
	return roll * degree;
}

float pxBody::GetQuaternionX()
{
	btTransform transform = _body->getWorldTransform();
	return transform.getRotation().x();
}

float pxBody::GetQuaternionY()
{
	btTransform transform = _body->getWorldTransform();
	return transform.getRotation().y();
}

float pxBody::GetQuaternionZ()
{
	btTransform transform = _body->getWorldTransform();
	return transform.getRotation().z();
}

float pxBody::GetQuaternionW()
{
	btTransform transform = _body->getWorldTransform();
	return transform.getRotation().w();
}

void pxBody::ApplyCentralForce(float x, float y, float z)
{
	_body->activate();
	_body->applyCentralForce(btVector3(x, y, z));
}

void pxBody::ApplyCentralImpulse(float x, float y, float z)
{
	_body->activate();
	_body->applyCentralImpulse(btVector3(x, y, z));
}

void pxBody::ReleaseForces()
{
	_body->clearForces();
	_body->setLinearVelocity(btVector3(0.0f, 0.0f, 0.0f));
	_body->setAngularVelocity(btVector3(0.0f, 0.0f, 0.0f));
}

void pxBody::ApplyTorque(float x, float y, float z)
{
	_body->activate();
	_body->applyTorque(btVector3(x, y, z));
}

void pxBody::ApplyTorqueImpulse(float x, float y, float z)
{
	_body->activate();
	_body->applyTorqueImpulse(btVector3(x, y, z));
}

void pxBody::ApplyForce(float x, float y, float z, float pointx, float pointy, float pointz)
{
	_body->activate();
	_body->applyForce(btVector3(x, y, z), btVector3(pointx, pointy, pointz));
}

void pxBody::ApplyImpulse(float x, float y, float z, float pointx, float pointy, float pointz)
{
	_body->activate();
	_body->applyImpulse(btVector3(x, y, z), btVector3(pointx, pointy, pointz));
}

void pxBody::SetDamping(float linear, float angular)
{
	_body->setDamping(linear, angular);
}

float pxBody::GetLinearDamping()
{
	return _body->getLinearDamping();
}

float pxBody::GetAngularDamping()
{
	return _body->getAngularDamping();
}

void pxBody::SetFriction(float friction)
{
	_body->setFriction(friction);
}

float pxBody::GetFriction()
{
	return _body->getFriction();
}

void pxBody::SetRestitution(float restitution)
{
	_body->setRestitution(restitution);
}

float pxBody::GetRestitution()
{
	return _body->getRestitution();
}

void pxBody::GetForce(float * force)
{
	btVector3 forceVector = _body->getTotalForce();
	force[0] = forceVector.x();
	force[1] = forceVector.y();
	force[2] = forceVector.z();
}

float pxBody::GetForceX()
{
	return _body->getTotalForce().x();
}

float pxBody::GetForceY()
{
	return _body->getTotalForce().y();
}

float pxBody::GetForceZ()
{
	return _body->getTotalForce().z();
}

void pxBody::GetTorque(float * torque)
{
	btVector3 torqueVector = _body->getTotalTorque();
	torque[0] = torqueVector.x();
	torque[1] = torqueVector.y();
	torque[2] = torqueVector.z();
}

float pxBody::GetTorqueX()
{
	return _body->getTotalTorque().x();
}

float pxBody::GetTorqueY()
{
	return _body->getTotalTorque().y();
}

float pxBody::GetTorqueZ()
{
	return _body->getTotalTorque().z();
}

void pxBody::SetLastIteration(unsigned int value)
{
	_lastIteration = value;
}

unsigned int pxBody::GetLastIteration()
{
	return _lastIteration;
}

void pxBody::ClearContacts()
{
	if(_contacts == NULL) return;
	pxContact * currentNode = _contacts;
	_contacts               = NULL;
	_lastNode               = NULL;
	do
	{
		pxContact * nextNode = currentNode->nextNode;
		delete currentNode;
		currentNode = nextNode;
	}
	while(currentNode != NULL);
}

void pxBody::AddContact(btCollisionObject * body, float x, float y, float z, float nx, float ny, float nz, float distance)
{
	pxContact * newContact = new pxContact();
	newContact->physBody  = body;
	newContact->otherBody = NULL;
	newContact->pointx    = x;
	newContact->pointy    = y;
	newContact->pointz    = z;
	newContact->normalx   = nx;
	newContact->normaly   = ny;
	newContact->normalz   = nz;
	newContact->distance  = distance;
	newContact->nextNode  = NULL;
	if(_lastNode == NULL) 
	{
		_contacts = newContact;
		_lastNode = newContact;
	}
	else
	{
		_lastNode->nextNode = newContact;
		_lastNode           = newContact;
	}
}

pxBody::pxContact * pxBody::GetContactByIndex(int index)
{
	if(_contacts == NULL) return NULL;
	int         number      = 0;
	pxContact * currentNode = _contacts;
	do
	{
		if(number == index) return currentNode;
		number++;
		currentNode = currentNode->nextNode;
	}
	while(currentNode != NULL);
	return NULL;
}

int pxBody::GetContactsNumber()
{
	if(_contacts == NULL) return 0;
	int         number      = 0;
	pxContact * currentNode = _contacts;
	do
	{
		number++;
		currentNode = currentNode->nextNode;
	}
	while(currentNode != NULL);
	return number;
}

void pxBody::GetContactPoint(int index, float * point)
{
	pxContact * contact = GetContactByIndex(index);
	if(contact == NULL) return;
	point[0] = contact->pointx;
	point[1] = contact->pointy;
	point[2] = contact->pointz;
}

float pxBody::GetContactX(int index)
{
	pxContact * contact = GetContactByIndex(index);
	if(contact == NULL) return 0.0f;
	return contact->pointx;
}

float pxBody::GetContactY(int index)
{
	pxContact * contact = GetContactByIndex(index);
	if(contact == NULL) return 0.0f;
	return contact->pointy;
}

float pxBody::GetContactZ(int index)
{
	pxContact * contact = GetContactByIndex(index);
	if(contact == NULL) return 0.0f;
	return contact->pointz;
}

void pxBody::GetContactNormal(int index, float * normal)
{
	pxContact * contact = GetContactByIndex(index);
	if(contact == NULL) return;
	normal[0] = contact->normalx;
	normal[1] = contact->normaly;
	normal[2] = contact->normalz;
}

float pxBody::GetContactNX(int index)
{
	pxContact * contact = GetContactByIndex(index);
	if(contact == NULL) return 0.0f;
	return contact->normalx;
}

float pxBody::GetContactNY(int index)
{
	pxContact * contact = GetContactByIndex(index);
	if(contact == NULL) return 0.0f;
	return contact->normaly;
}

float pxBody::GetContactNZ(int index)
{
	pxContact * contact = GetContactByIndex(index);
	if(contact == NULL) return 0.0f;
	return contact->normalz;
}

float pxBody::GetContactDistance(int index)
{
	pxContact * contact = GetContactByIndex(index);
	if(contact == NULL) return 0.0f;
	return contact->distance;
}

IBody * pxBody::GetContactSecondBody(int index)
{
	pxContact * contact = GetContactByIndex(index);
	if(contact == NULL) return NULL;
	if(contact->otherBody == NULL)
	{
		for(unsigned int i = 0; i < _bodiesList.size(); i++)
		{
			switch(_bodiesList[i]->GetBodyType())
			{
				case pxBODY_RIGID:
				{
					pxBody * rigidBody = (pxBody*)_bodiesList[i];
					if(contact->physBody == rigidBody->GetBody())
					{
						contact->otherBody = _bodiesList[i];
						return contact->otherBody;
					}
				}
				break;
			}
		}
	}
	return contact->otherBody;
}