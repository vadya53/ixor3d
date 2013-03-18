//
//  entity.mm
//  iXors3D
//
//  Created by Knightmare on 01.09.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import "entity.h"
#import "camera.h"
#import "loaders.h"
#import "bone.h"
#import "terrain.h"
#import "channel.h"
#import "sprite.h"
#import "md2Normals.h"
#import "filesystem.h"
#import "texturemanager.h"
#import "audiomanager.h"
#import "3dsloader.h"

#define min(a, b) (a < b ? a : b)
#define max(a, b) (a > b ? a : b)

xEntity::xEntity()
{
	_scale          = xVector(1.0f, 1.0f, 1.0f);
	_position       = xVector(0.0f, 0.0f, 0.0f);
	_rotation       = xQuaternion();
	_name           = "";
	_needUpdate     = false;
	_parent         = NULL;
	_visible        = true;
	_copiedFrom     = NULL;
	_type           = ENTITY_NODE;
	_order          = 0;
	_autoFade       = false;
	_fadeNear       = 0.0f;
	_fadeFar        = 0.0f;
	_rootBone       = NULL;
	_pickMode       = 0;
	_collideType    = 0;
	_collideBox     = xBox();
	_collideRadii   = xVector();
	_collider       = NULL;
	_physBody       = NULL;
	_trimeshVB      = NULL;
	_trimeshIB      = NULL;
	_needSyncBody   = false;
	_isSingleMesh   = false;
	_singleMesh     = NULL;
	_md2Frames      = NULL;
	_md2Time        = 0.0f;
	_md2LocalTime   = 0.0f;
	_md2Speed       = 1.0f;
	_md2Mode        = 0;
	_md2Dest        = 1;
	_md2Updated     = true;
	_md2Cloned      = false;
	_atlas          = NULL;
	_captured       = false;
	_userData       = NULL;
	_alphaFunc      = 4;
	_alphaRef       = 0.0f;
	_atlasFlags     = 9;
	xRender::Instance()->AddEntity(this);
	Reset();
}

xEntity::~xEntity()
{
	_name       = "";
	_needUpdate = false;
	_parent     = NULL;
	_visible    = true;
}

void xEntity::Release()
{
	if(this == xAudioManager::Instance()->GetListener()) xAudioManager::Instance()->FreeListener();
	if(_singleMesh != NULL) _singleMesh->RemoveInstance(this);
	if(_instances.size() > 0)
	{
		std::vector<xEntity*> instances = _instances;
		for(int i = 0; i < instances.size(); i++) RemoveInstance(instances[i]);
	}
	if(_type == ENTITY_BONE) ((xBone*)this)->ClearAnimData();
	for(int i = 0; i < _surfaces.size(); i++)
	{
		_surfaces[i]->Release();
		delete _surfaces[i];
	}
	std::vector<xEntity*> childList = _childs;
	for(int i = 0; i < childList.size(); i++)
	{
		childList[i]->Release();
		delete childList[i];
	}
	if(_parent != NULL) _parent->DeleteChild(this);
	if(_copiedFrom != NULL)
	{
		std::vector<xEntity*>::iterator itr = std::find(_copiedFrom->_copies.begin(), _copiedFrom->_copies.end(), this);
		if(itr != _copiedFrom->_copies.end()) _copiedFrom->_copies.erase(itr);
	}
	for(int i = 0; i < _copies.size(); i++)
	{
		_copies[i]->_copiedFrom = NULL;
	}
	if(_md2Sequences.size() > 0) xRender::Instance()->DeleteMD2Mesh(this);
	for(int i = 0; i < _md2Sequences.size(); i++) delete [] _md2Sequences[i];
	_md2Sequences.clear();
	_md2Frames = NULL;
	if(_atlas != NULL)
	{
		delete _atlas;
		_atlas = NULL;
	}
	xRender::Instance()->DeleteEntity(this);
	xRender::Instance()->DeleteAnimated((xBone*)this);
	if(_type == ENTITY_CAMERA) xRender::Instance()->DeleteCamera((xCamera*)this);
	if(_type == ENTITY_LIGHT)  xRender::Instance()->DeleteLight((xLight*)this);
	SetOrder(0);
	SetPickMode(0);
	FreeShapes();
}

bool xEntity::IsSkinned()
{
	return (_rootBone != NULL);
}

xBrush * xEntity::GetBrush()
{
	return &_masterBrush;
}

xTransform xEntity::GetWorldTransform()
{
	if(_needUpdate) UpdateWorldTransform();
	return _worldTransform;
}

void xEntity::SetOrder(int order)
{
	_order = order;
	xRender::Instance()->SetOrderedEntity(this);
}

int xEntity::GetOrder()
{
	return _order;
}

void xEntity::UpdateWorldTransform()
{
	_worldTransform = xTransform(_position) * xTransform(xMatrix(_rotation) * ScaleMatrix(_scale));
	if(_parent != NULL) _worldTransform = _parent->GetWorldTransform() * _worldTransform;
	for(int i = 0; i < _childs.size(); i++) _childs[i]->ForceUpdate();
	_needUpdate   = false;
	_needSyncBody = false;
}

void xEntity::ForceUpdate()
{
	_needUpdate   = true;
	_needSyncBody = true;
	if(_singleMesh != NULL) _singleMesh->_updateMap[this].update = true;
	for(int i = 0; i < _childs.size(); i++) _childs[i]->ForceUpdate();
}

void xEntity::SetWorldMatrix()
{
	GLfloat matrix[] = { _worldTransform.matrix.i.x, _worldTransform.matrix.i.y, _worldTransform.matrix.i.z, 0.0f,
						 _worldTransform.matrix.j.x, _worldTransform.matrix.j.y, _worldTransform.matrix.j.z, 0.0f,
						 _worldTransform.matrix.k.x, _worldTransform.matrix.k.y, _worldTransform.matrix.k.z, 0.0f,
						 _worldTransform.position.x, _worldTransform.position.y, _worldTransform.position.z, 1.0f };
	xRender::Instance()->GetActiveCamera()->SetViewMatrix();
	glMatrixMode(GL_MODELVIEW);
	glMultMatrixf(matrix);
}

xEntType xEntity::GetType()
{
	return _type;
}

void xEntity::Translate(float x, float y, float z)
{
	_position += xVector(x, y, z);
	ForceUpdate();
}

void xEntity::SetPosition(float x, float y, float z, bool global)
{
	if(global && _parent != NULL)
	{
		_position = _parent->GetWorldTransform().Inversed() * xVector(x, y, z);
	}
	else
	{
		_position.x = x;
		_position.y = y;
		_position.z = z;
	}
	ForceUpdate();
}

void xEntity::Move(float x, float y, float z, bool global)
{
	_position = _position + GetQuaternion(global) * xVector(x, y, z);
	ForceUpdate();
}

xQuaternion xEntity::GetQuaternion(bool global)
{
	if(global && _parent != NULL)
	{
		return _parent->GetQuaternion(true) * _rotation;
	}
	else
	{
		return _rotation;
	}
}

void xEntity::SetRotation(float pitch, float yaw, float roll, bool global)
{
	if(global && _parent != NULL)
	{
		_rotation = -_parent->GetQuaternion(true) * RotationQuaternion(pitch, yaw, roll);
	}
	else
	{
		_rotation = RotationQuaternion(pitch, yaw, roll);
	}
	ForceUpdate();
}

void xEntity::Turn(float pitch, float yaw, float roll, bool global)
{
	if(global)
	{
		//SetQuaternion(RotationQuaternion(pitch, yaw, roll) * GetQuaternion(true), true);
		//*
		if(_type == ENTITY_CAMERA)
		{
			xQuaternion globalQuat = GetQuaternion(true);
			pitch     += QuaternionPitch(globalQuat);
			yaw       += QuaternionYaw(globalQuat);
			roll      += QuaternionRoll(globalQuat);
			SetQuaternion(RotationQuaternion(pitch, yaw, roll), true);
		}
		else
		{
			SetQuaternion(RotationQuaternion(pitch, yaw, roll) * GetQuaternion(true), true);
		}
		//*/
	}
	else
	{
		_rotation = _rotation * RotationQuaternion(pitch, yaw, roll);
	}
	ForceUpdate();
}

void xEntity::SetScale(float x, float y, float z, bool global)
{
	if(global && _parent != NULL)
	{
		xVector parentScale = _parent->GetScale(true);
		_scale.x = x / parentScale.x;
		_scale.y = y / parentScale.y;
		_scale.z = z / parentScale.z;
	}
	else
	{
	    _scale.x = x;
		_scale.y = y;
		_scale.z = z;
	}
	ForceUpdate();
}

xVector xEntity::GetPosition(bool global)
{
	if(global && _parent != NULL)
	{
		return _parent->GetWorldTransform() * _position;
	}
	else
	{
		return xVector(_position.x, _position.y, _position.z);
	}
}

xVector xEntity::GetRotation(bool global)
{
	xQuaternion rotate = GetQuaternion(global);
	return xVector(QuaternionPitch(rotate), QuaternionYaw(rotate), QuaternionRoll(rotate));
}

xVector xEntity::GetScale(bool global)
{
	if(global && _parent != NULL)
    {
		return _scale * _parent->GetScale(true);
    }
    else
	{
        return _scale;
	}
}

void xEntity::SetName(const char * name)
{
	_name = name;
}

const char * xEntity::GetName()
{
	_nameBuff = _name.c_str();
	return _nameBuff;
}

bool xEntity::IsVisible()
{
	return _visible;
}

void xEntity::Show()
{
	_visible = true;
	for(int i = 0; i < _childs.size(); i++)
	{
		_childs[i]->Show();
	}
}

void xEntity::Hide()
{
	_visible = false;
	for(int i = 0; i < _childs.size(); i++)
	{
		_childs[i]->Hide();
	}
}

bool xEntity::InView(xCamera * camera)
{
	if(camera == NULL) return true;
	xTransform world = GetWorldTransform();
	for(int i = 0; i < _surfaces.size(); i++)
	{
		if(_surfaces[i]->InView(world, camera)) return true;
	}
	if(_surfaces.size() == 0 && _childs.size() == 0 && _parent == NULL)
	{
		if(camera->GetFrustum()->PointInFrustum(world.position)) return true;
	}
	for(int i = 0; i < _childs.size(); i++)
	{
		if(_childs[i]->InView(camera)) return true;
	}
	return false;
}

xSurface * xEntity::CreateSurface(xBrush * brush)
{
	xSurface * newSurface = new xSurface(brush == 0 ? &_masterBrush : brush);
	_surfaces.push_back(newSurface);
	return newSurface;
}

int xEntity::CountSurfaces()
{
	return _surfaces.size();
}

xSurface * xEntity::GetSurface(int index)
{
	if(index < 0 || index >= _surfaces.size()) return NULL;
	return _surfaces[index];
}

xSurface * xEntity::FindSurface(xBrush * brush)
{
	for(int i = 0; i < _surfaces.size(); i++)
	{
		if(_surfaces[i]->GetCreationBrush() == brush) return _surfaces[i];
	}
	return NULL;
}

void xEntity::SetParent(xEntity * entity)
{
	if(_parent != NULL) _parent->DeleteChild(this);
	_parent = entity;
	if(_parent != NULL) _parent->AddChild(this);
	ForceUpdate();
}

xEntity * xEntity::FindChild(const char * name)
{
	if(strcmp(name, _name.c_str()) == 0) return this;
	for(int i = 0; i < _childs.size(); i++)
	{
		xEntity * result = _childs[i]->FindChild(name);
		if(result != NULL) return result;
	}
	return NULL;
}

xEntity * xEntity::GetParent()
{
	return _parent;
}

void xEntity::AddChild(xEntity * entity)
{
	if(std::find(_childs.begin(), _childs.end(), entity) != _childs.end()) return;
	_childs.push_back(entity);
}

void xEntity::DeleteChild(xEntity * entity)
{
	std::vector<xEntity*>::iterator i = std::find(_childs.begin(), _childs.end(), entity);
	if(i == _childs.end()) return;
	_childs.erase(i);
}

int xEntity::CountChilds()
{
	return _childs.size();
}

xEntity * xEntity::GetChild(int index)
{
	if(index < 0 || index >= _childs.size()) return NULL;
	return _childs[index];
}

void xEntity::CreateCube()
{
	static xVector normals[]   = { xVector(0.0f, 0.0f, -1.0f), xVector(1.0f, 0.0f, 0.0f), xVector(0.0f, 0.0f, 1.0f),
								   xVector(-1.0f, 0.0f, 0.0f), xVector(0.0f, 1.0f, 0.0f), xVector(0.0f, -1.0f, 0.0f) };
	static xVector texCoords[] = { xVector(1.0f, 0.0f, 1.0f), xVector(0.0f, 0.0f, 1.0f),
								   xVector(0.0f, 1.0f, 1.0f), xVector(1.0f, 1.0f, 1.0f) };
	static int vertices[]      = { 2, 3, 1, 0, 3, 7, 5, 1, 7, 6, 4, 5, 6, 2, 0, 4, 6, 7, 3, 2, 0, 1, 5, 4 };
	static xBox box(xVector(-1.0f, -1.0f, -1.0f), xVector(1.0f, 1.0f, 1.0f));
	xSurface * surface = CreateSurface(NULL);
	for(int i = 0; i < 24; i += 4)
	{
		const xVector & normal = normals[i / 4];
		for(int j = 0; j < 4; ++j)
		{
			xVector coords = box.Corner(vertices[i + j]);
			int index = surface->AddVertex(coords.x, coords.y, coords.z, texCoords[j].x, texCoords[j].y);
			surface->VertexNormal(index, normal.x, normal.y, normal.z);
			surface->VertexTexCoords(index, texCoords[j].x, texCoords[j].y, 0.0f, 1);
		}
		surface->AddTriangle(i + 0, i + 1, i + 2);
		surface->AddTriangle(i + 2, i + 3, i + 0);
	}
	surface->UpdateBoundingVolumes();
}

void xEntity::CreateSphere(int segments)
{
	xSurface * surface = CreateSurface(NULL);
	int horisSegs      = segments * 2;
	int vertSegs       = segments;
	xVector coords     = xVector(0.0f, 1.0f, 0.0f);
	xVector normal     = xVector(0.0f, 1.0f, 0.0f);
	for(int i = 0; i < horisSegs; ++i)
	{
		int index = surface->AddVertex(coords.x, coords.y, coords.z, ((float)i + 0.5f) / (float)horisSegs, 0.0f);
		surface->VertexNormal(index, normal.x, normal.y, normal.z);
		surface->VertexTexCoords(index, ((float)i + 0.5f) / (float)horisSegs, 0.0f, 0.0f, 1);
	}
	for(int i = 1; i < vertSegs; ++i)
	{
		float pitch = (float)i * 3.1415f / (float)vertSegs - (3.1415f / 2.0f);
		for(int j = 0; j <= horisSegs; ++j)
		{
			float yaw = (float)(j % horisSegs) * (3.1415f * 2.0f) / (float)horisSegs;
			coords = normal = RotationMatrix(RadToDeg(pitch), RadToDeg(yaw), 0.0f).k;
			int index = surface->AddVertex(coords.x, coords.y, coords.z, float(j) / float(horisSegs), float(i) / float(vertSegs));
			surface->VertexNormal(index, normal.x, normal.y, normal.z);
			surface->VertexTexCoords(index, float(j) / float(horisSegs), float(i) / float(vertSegs), 0.0f, 1);
		}
	}
	coords = xVector(0.0f, -1.0f, 0.0f);
	normal = xVector(0.0f, -1.0f, 0.0f);
	for(int i = 0; i < horisSegs; ++i)
	{
		int index = surface->AddVertex(coords.x, coords.y, coords.z, ((float)i + 0.5f) / (float)horisSegs, 0.0f);
		surface->VertexNormal(index, normal.x, normal.y, normal.z);
		surface->VertexTexCoords(index, ((float)i + 0.5f) / (float)horisSegs, 0.0f, 0.0f, 1);
	}
	for(int i = 0; i < horisSegs; ++i) surface->AddTriangle(i, i + horisSegs + 1, i + horisSegs);
	for(int i = 1; i < vertSegs - 1; ++i)
	{
		for(int j = 0; j < horisSegs; ++j)
		{
			int v0 = i * (horisSegs + 1) + j - 1;
			int v1 = v0 + 1;
			int v2 = v1 + horisSegs + 1;
			surface->AddTriangle(v0, v1, v2);
			v1 = v2;
			v2 = v1 - 1;
			surface->AddTriangle(v0, v1, v2);
		}
	}
	for(int i = 0; i < horisSegs; ++i)
	{
		int v0 = (horisSegs + 1) * (vertSegs - 1) + i - 1;
		int v1 = v0 + 1;
		int v2 = v1 + horisSegs;
		surface->AddTriangle(v0, v1, v2);
	}
	surface->UpdateBoundingVolumes();
}

void xEntity::CreateCyllinder(int segments, bool solid)
{
	xSurface * surface = CreateSurface(NULL);
	for(int i = 0; i <= segments; ++i)
	{
		float yaw = float(i % segments) * (3.1415f * 2.0f) / (float)segments;
		xVector coords = RotationMatrix(0.0f, RadToDeg(yaw), 0.0f).k;
		coords.y       = 1.0f;
		xVector normal = xVector(coords.x, 0.0f, coords.z);
		int index = surface->AddVertex(coords.x, coords.y, coords.z, float(i) / segments, 0.0f);
		surface->VertexNormal(index, normal.x, normal.y, normal.z);
		surface->VertexTexCoords(index, float(i) / segments, 0.0f, 0.0f, 1);
		coords.y       = -1.0f;
		index = surface->AddVertex(coords.x, coords.y, coords.z, float(i) / segments, 1.0f);
		surface->VertexNormal(index, normal.x, normal.y, normal.z);
		surface->VertexTexCoords(index, float(i) / segments, 1.0f, 0.0f, 1);
	}
	for(int i = 0; i < segments; ++i)
	{
		surface->AddTriangle(i * 2, i * 2 + 2, i * 2 + 3);
		surface->AddTriangle(i * 2, i * 2 + 3, i * 2 + 1);
	}
	if(!solid)
	{
		surface->UpdateBoundingVolumes();
		return;
	}
	surface = CreateSurface(NULL);
	for(int i = 0; i < segments; ++i)
	{
		float yaw = float(i) * (3.1415f * 2.0f) / (float)segments;
		xVector coords = RotationMatrix(0.0f, RadToDeg(yaw), 0.0f).k;
		coords.y       = 1.0f;
		xVector normal = xVector(0.0f, 1.0f, 0.0f);
		int index = surface->AddVertex(coords.x, coords.y, coords.z, coords.x * 0.5f + 0.5f, coords.z * 0.5f + 0.5f);
		surface->VertexNormal(index, normal.x, normal.y, normal.z);
		surface->VertexTexCoords(index, coords.x * 0.5f + 0.5f, coords.z * 0.5f + 0.5f, 0.0f, 1);
		coords.y       = -1.0f;
		normal = xVector(0.0f, -1.0f, 0.0f);
		index = surface->AddVertex(coords.x, coords.y, coords.z, coords.x * 0.5f + 0.5f, coords.z * 0.5f + 0.5f);
		surface->VertexNormal(index, normal.x, normal.y, normal.z);
		surface->VertexTexCoords(index, coords.x * 0.5f + 0.5f, coords.z * 0.5f + 0.5f, 0.0f, 1);
	}
	for(int i = 2; i < segments; ++i)
	{
		surface->AddTriangle(0, i * 2, (i - 1) * 2);
		surface->AddTriangle(1, (i - 1) * 2 + 1, i * 2 + 1);
	}
	surface->UpdateBoundingVolumes();
}

void xEntity::CreateCone(int segments, bool solid)
{
	xSurface * surface = CreateSurface(NULL);
	xVector coords = xVector(0.0f, 1.0f, 0.0f);
	xVector normal = xVector(0.0f, 1.0f, 0.0f);
	for(int i = 0; i < segments; ++i)
	{
		int index = surface->AddVertex(coords.x, coords.y, coords.z, ((float)i + 0.5f) / (float)segments, 0.0f);
		surface->VertexNormal(index, normal.x, normal.y, normal.z);
		surface->VertexTexCoords(index, ((float)i + 0.5f) / (float)segments, 0.0f, 0.0f, 1);
	}
	for(int i = 0; i <= segments; ++i)
	{
		float yaw = float(i % segments) * (3.141f * 2.0f) / (float)segments;
		coords    = YawMatrix(RadToDeg(yaw)).k;
		coords.y  = -1.0f;
		normal    = xVector(coords.x, 0.0f, coords.z);
		int index = surface->AddVertex(coords.x, coords.y, coords.z, float(i) / (float)segments, 1.0f);
		surface->VertexNormal(index, normal.x, normal.y, normal.z);
		surface->VertexTexCoords(index, float(i) / (float)segments, 1.0f, 0.0f, 1);
	}
	for(int i = 0; i < segments; ++i)
	{
		surface->AddTriangle(i, i + segments + 1, i + segments);
	}
	if(!solid)
	{
		surface->UpdateBoundingVolumes();
		return;
	}
	surface = CreateSurface(NULL);
	for(int i = 0; i < segments; ++i)
	{
		float yaw = float(i) * (3.141f * 2.0f) / (float)segments;
		coords    = YawMatrix(RadToDeg(yaw)).k;
		coords.y  = -1.0f;
		normal    = xVector(0.0f, -1.0f, 0.0f);
		int index = surface->AddVertex(coords.x, coords.y, coords.z, coords.x * 0.5f + 0.5f, coords.z * 0.5f + 0.5f);
		surface->VertexNormal(index, normal.x, normal.y, normal.z);
		surface->VertexTexCoords(index, coords.x * 0.5f + 0.5f, coords.z * 0.5f + 0.5f, 0.0f, 1);
		
	}
	for(int i = 2; i < segments; ++i) surface->AddTriangle(0, i - 1, i);
	surface->UpdateBoundingVolumes();
}

void xEntity::AddMesh(xEntity * other)
{
	for(int i = 0; i < other->_surfaces.size(); i++)
	{
		_surfaces.push_back(other->_surfaces[i]->Clone(true));
	}
}

void xEntity::FlipMesh()
{
	for(int i = 0; i < _surfaces.size(); i++)
	{
		_surfaces[i]->FlipTriangles();
	}
}

void xEntity::AddSurface(xSurface * newSurface)
{
	_surfaces.push_back(newSurface);
}

xEntity * xEntity::Clone(xEntity * parent, bool cloneGeom)
{
	if(_type == ENTITY_SPRITE) return ((xSprite*)this)->Clone(parent, cloneGeom);
	xEntity * newEntity = new xEntity();
	if(cloneGeom)
	{
		newEntity->_copiedFrom = this;
		_copies.push_back(newEntity);
	}
	newEntity->SetParent(parent);
	newEntity->_name = _name;
	newEntity->_masterBrush.Copy(&_masterBrush);
	newEntity->SetPickMode(_pickMode);
	newEntity->_position   = _position;
	newEntity->_scale      = _scale;
	newEntity->_rotation   = _rotation;
	newEntity->_needUpdate = true;
	newEntity->SetAutoFade(_fadeNear, _fadeFar);
	newEntity->_autoFade   = _autoFade;
	newEntity->SetOrder(_order);
	for(int i = 0; i < _surfaces.size(); i++)
	{
		newEntity->_surfaces.push_back(_surfaces[i]->Clone(cloneGeom));
	}
	//
	if(_md2Sequences.size() > 0)
	{
		int numVertices = _surfaces[0]->CountVertices();
		for(int i = 0; i < _md2Sequences.size(); i++)
		{
			int frames = _md2Sequences[i][0].length * 10;
			MD2Loader::MD2Frame * newFrames = new MD2Loader::MD2Frame[frames];
			for(int j = 0; j < frames; j++)
			{
				newFrames[j]          = _md2Sequences[i][j];
				newFrames[j].vertices = new MD2Loader::MD2Vertex[numVertices];
				memcpy(newFrames[j].vertices, _md2Sequences[i][j].vertices, numVertices * sizeof(MD2Loader::MD2Vertex));
			}
			newEntity->_md2Sequences.push_back(newFrames);
		}
		newEntity->_md2Cloned = !cloneGeom;
		newEntity->_md2Frames = newEntity->_md2Sequences[0];
		newEntity->UpdateMD2Mesh();
		xRender::Instance()->AddMD2Mesh(newEntity);
	}
	//
	for(int i = 0; i < _childs.size(); i++)
	{
		if(_childs[i]->_type == ENTITY_BONE)
		{
			xBone * newBone = ((xBone*)_childs[i])->Clone(newEntity, cloneGeom);
			if(_rootBone == _childs[i]) 
			{
				newEntity->_rootBone = newBone;
				xRender::Instance()->AddAnimated((xBone*)newEntity);
			}
		}
		else
		{
			_childs[i]->Clone(newEntity, cloneGeom);
		}
	}
	return newEntity;
}

void xEntity::ApplyBrush(xBrush * brush, bool single)
{
	_masterBrush.red       = brush->red;
	_masterBrush.green     = brush->green;
	_masterBrush.blue      = brush->blue;
	_masterBrush.alpha     = brush->alpha;
	_masterBrush.shininess = brush->shininess;
	_masterBrush.blendMode = brush->blendMode;
	_masterBrush.FX        = brush->FX;
	for(int i = 0; i < xRender::Instance()->GetMaxTextureUnits(); i++)
	{
		_masterBrush.textures[i].texture = brush->textures[i].texture;
		_masterBrush.textures[i].frame   = brush->textures[i].frame;
	}
	for(int i = 0; i < _surfaces.size(); i++)
	{
		if(index == 0 && _atlas != NULL)
		{
			xBrush * brush = _surfaces[i]->GetBrush();
			if(brush->textures[0].texture != NULL)
			{
				_atlas->DeleteTexture(brush->textures[0].texture, brush->textures[0].frame);
			}
			delete brush;
			if(brush->textures[0].texture != NULL) _atlas->AddTexture(brush->textures[0].texture, brush->textures[0].frame);
		}
		_surfaces[i]->ApplyBrush(brush);
	}
	if(_singleMesh != NULL) ForceUpdate();
	if(!single)
	{
		for(int i = 0; i < _copies.size(); i++)
		{
			_copies[i]->ApplyBrush(brush, single);
		}
	}
}

void xEntity::PositionMesh(float x, float y, float z)
{
	for(int i = 0; i < _surfaces.size(); i++)
	{
		_surfaces[i]->PositionVertices(x, y, z);
	}
}

void xEntity::RotateMesh(float pitch, float yaw, float roll)
{
	for(int i = 0; i < _surfaces.size(); i++)
	{
		_surfaces[i]->RotateVertices(pitch, yaw, roll);
	}
}

void xEntity::ScaleMesh(float x, float y, float z)
{
	for(int i = 0; i < _surfaces.size(); i++)
	{
		_surfaces[i]->ScaleVertices(x, y, z);
	}
}

void xEntity::GenerateNormals()
{
	for(int i = 0; i < _surfaces.size(); i++)
	{
		_surfaces[i]->GenerateNormals();
	}
	for(int i = 0; i < _childs.size(); i++) _childs[i]->GenerateNormals();
}

xBox xEntity::GetBoundingBox()
{
	if(_surfaces.size() == 0) return xBox(xVector(0.0f, 0.0f, 0.0f));
	xBox box = _surfaces[0]->GetBoundingBox();
	for(int i = 1; i < _surfaces.size(); i++)
	{
		box.Update(_surfaces[i]->GetBoundingBox());
	}
	return box;
}

xVector xEntity::GetBoundingSphereCenter()
{
	return GetBoundingBox().Centre();
}

float xEntity::GetBoundingSphereRadius()
{
	xBox box = GetBoundingBox();
	return box.Centre().Distance(box.min);
}

float xEntity::GetMeshWidth()
{
	xBox box = GetBoundingBox();
	return box.max.x - box.min.x;
}

float xEntity::GetMeshHeight()
{
	xBox box = GetBoundingBox();
	return box.max.y - box.min.y;
}

float xEntity::GetMeshDepth()
{
	xBox box = GetBoundingBox();
	return box.max.z - box.min.z;
}

void xEntity::SetColor(int red, int green, int blue)
{
	_masterBrush.red   = red;
	_masterBrush.green = green;
	_masterBrush.blue  = blue;
	for(int i = 0; i < _surfaces.size(); i++)
	{
		_surfaces[i]->SetColor(red, green, blue);
	}
	if(_singleMesh != NULL) ForceUpdate();
}

xVector xEntity::GetColor()
{
	return xVector(_masterBrush.red, _masterBrush.green, _masterBrush.blue);
}

void xEntity::SetAlpha(float alpha)
{
	_masterBrush.alpha = alpha;
	for(int i = 0; i < _surfaces.size(); i++)
	{
		_surfaces[i]->SetAlpha(alpha);
	}
}

float xEntity::GetAlpha()
{
	return _masterBrush.alpha;
}

void xEntity::SetShininess(float shininess)
{
	_masterBrush.shininess = shininess;
	for(int i = 0; i < _surfaces.size(); i++)
	{
		_surfaces[i]->SetShininess(shininess);
	}
}

float xEntity::GetShininess()
{
	return _masterBrush.shininess;
}

void xEntity::SetBlendMode(int mode)
{
	_masterBrush.blendMode = mode;
	for(int i = 0; i < _surfaces.size(); i++)
	{
		_surfaces[i]->SetBlendMode(mode);
	}
}

int xEntity::GetBlendMode()
{
	return _masterBrush.blendMode;
}

void xEntity::SetFXFlags(int fx)
{
	_masterBrush.FX = fx;
	for(int i = 0; i < _surfaces.size(); i++)
	{
		_surfaces[i]->SetFX(fx);
	}
}

int xEntity::GetFXFlags()
{
	return _masterBrush.FX;
}

void xEntity::SetTexture(int index, xTexture * texture, int frame)
{
	if(index < 0 || index >= xRender::Instance()->GetMaxTextureUnits()) return;
	if(_masterBrush.textures[index].texture != NULL)
	{
		xTextureManager::Instance()->ReleaseTexture(_masterBrush.textures[index].texture);
	}
	_masterBrush.textures[index].texture = texture;
	_masterBrush.textures[index].frame   = frame;
	if(_masterBrush.textures[index].texture != NULL) _masterBrush.textures[index].texture->Retain();
	for(int i = 0; i < _surfaces.size(); i++)
	{
		if(index == 0 && _atlas != NULL)
		{
			xBrush * brush = _surfaces[i]->GetBrush();
			if(brush->textures[0].texture != NULL)
			{
				_atlas->DeleteTexture(brush->textures[0].texture, brush->textures[0].frame);
			}
			delete brush;
			if(texture != NULL) _atlas->AddTexture(texture, frame);
			ForceUpdate();
		}
		_surfaces[i]->SetTexture(index, texture, frame);
	}
}

xTexture * xEntity::GetTexture(int index)
{
	if(index < 0 || index >= xRender::Instance()->GetMaxTextureUnits()) return NULL;
	return _masterBrush.textures[index].texture;
}

void xEntity::FitMesh(float x, float y, float z, float width, float height, float depth, bool uniform)
{
	xBox box = GetBoundingBox();
	xTransform tranform; 
	float sx = width  / box.Width();
	float sy = height / box.Height();
	float sz = depth  / box.Depth();
	if(uniform)
	{
		sx = min(sx, min(sy, sz));
		tranform.matrix.i.x = sx;
		tranform.matrix.j.y = sx;
		tranform.matrix.k.z = sx;
	}
	else
	{
		tranform.matrix.i.x = sx;
		tranform.matrix.j.y = sy;
		tranform.matrix.k.z = sz;
	}
	tranform.position = xVector(x + width * 0.5f, y + height * 0.5f, z + depth * 0.5f) - tranform * box.Centre();
	for(int i = 0; i < _surfaces.size(); i++) _surfaces[i]->TransformVertices(tranform);
}

void xEntity::UpdateEmittedChannels()
{
	if(_channels.size() == 0) return;
	xVector position = GetPosition(true);
	std::vector<xChannel*>::iterator itr = _channels.begin();
	while(itr != _channels.end())
	{
		if(xChannel::Validate(*itr))
		{
			(*itr)->SetPosition(position.x, position.y, position.z);
			itr++;
		}
		else
		{
			itr = _channels.erase(itr);
		}
	}
}

void xEntity::AddChannel(xChannel * channel)
{
	_channels.push_back(channel);
}

void xEntity::Draw()
{
	UpdateEmittedChannels();
	UpdateMD2Mesh();
	if(!_visible) return;
	if(_needUpdate) UpdateWorldTransform();
	SetWorldMatrix();
	if(_isSingleMesh) UpdateSingleSurface();
	bool added = false;
	if(_autoFade)
	{
		float alpha = 1.0f;
		if(xRender::Instance()->GetActiveCamera() != NULL)
		{
			alpha = (GetPosition(true).Distance(xRender::Instance()->GetActiveCamera()->GetPosition(true)) - _fadeNear) / (_fadeFar - _fadeNear);
		}
		else
		{
			alpha = (GetPosition(true).Length() - _fadeNear) / (_fadeFar - _fadeNear);
		}
		if(_fadeNear < 0.0f) _fadeNear = 0.0f;
		if(_fadeNear > 0.0f) _fadeNear = 1.0f;
		SetAlpha(1.0f - alpha);
	}
	if(_type == ENTITY_SPRITE)
	{
		((xSprite*)this)->UpdateSurface();
		xRender::Instance()->GetActiveCamera()->SetLightMatrix();
	}
	else if(_type == ENTITY_TERRAIN)
	{
		((xTerrain*)this)->Draw();
	}
	if(IsSkinned()) UpdateSkin();
	for(int i = 0; i < _surfaces.size(); i++)
	{
		if(_type == ENTITY_SPRITE && i == 0)
		{
			if(!_surfaces[i]->InView(xTransform(), xRender::Instance()->GetActiveCamera())) continue;
		}
		else
		{
			if(!_surfaces[i]->InView(_worldTransform, xRender::Instance()->GetActiveCamera())
			   && !_isSingleMesh) continue;
		}
		if(!xRender::Instance()->OrderedStage())
		{
			if(_surfaces[i]->NeedAlphaBlend())
			{
				if(!xRender::Instance()->TransparentStage())
				{
					if(!added)
					{
						xRender::Instance()->AddTransparent(this);
						added = true;
					}
					continue;
				}
			}
			else
			{
				if(xRender::Instance()->TransparentStage()) continue;
			}
		}
		_surfaces[i]->Draw();
	}
}

void xEntity::MergeHierarhy(xEntity * parent)
{
	_position   = xVector(0.0, 0.0, 0.0);
	_rotation   = xQuaternion();
	_scale      = xVector(1.0, 1.0, 1.0);
	ForceUpdate();
	if(parent != NULL)
	{
		for(int i = 0; i < _surfaces.size(); i++) parent->_surfaces.push_back(_surfaces[i]);
		_surfaces.clear();
	}
	std::vector<xEntity*> childArray = _childs;
	for(int i = 0; i < childArray.size(); i++)
	{
		childArray[i]->MergeHierarhy(parent != NULL ? parent : this);
		if(parent == NULL)
		{
			childArray[i]->Release();
			delete childArray[i];
		}
	}
	if(parent == NULL) _childs.clear();
}

bool xEntity::LoadMesh(const char * path)
{
	LoaderNode     * rootNode;
	TexturesArray    textures;
	MaterialsArray   materials;
	switch(IdentifyFileType(path))
	{
		case B3DFILE:
		{
			B3DLoader loader;
			if(!loader.LoadFile(path, &rootNode, &textures, &materials))
			{
				return false;
			}
		}
		break;
		case MD2FILE:
		{
			MD2Loader loader;
			if(!loader.LoadFile(path, &rootNode, &textures, &materials))
			{
				return false;
			}
			_md2Frames = loader.GetFrames();
		}
		break;
		case _3DSFILE:
		{
			Loader3DS loader;
			if(!loader.LoadFile(path, &rootNode, &textures, &materials))
			{
				return false;
			}
		}
		break;
		case UNKNOWNFILE:
		{
			return false;
		}
		break;
	}
	// 
	if(_md2Frames != NULL)
	{
		for(int i = 0; i < rootNode->_surfaces[0]._vertices->size(); i++)
		{
			float x   = float(_md2Frames[0].vertices[i].position[0]) * _md2Frames[0].scale.x + _md2Frames[0].translate.x;
			float y   = float(_md2Frames[0].vertices[i].position[1]) * _md2Frames[0].scale.y + _md2Frames[0].translate.y;
			float z   = float(_md2Frames[0].vertices[i].position[2]) * _md2Frames[0].scale.z + _md2Frames[0].translate.z;
			xVector n = md2Normals[_md2Frames[0].vertices[i].normalIndex % 162];
			(*rootNode->_surfaces[0]._vertices)[i].x  = x;
			(*rootNode->_surfaces[0]._vertices)[i].y  = y;
			(*rootNode->_surfaces[0]._vertices)[i].z  = z;
			(*rootNode->_surfaces[0]._vertices)[i].nx = n.x;
			(*rootNode->_surfaces[0]._vertices)[i].ny = n.y;
			(*rootNode->_surfaces[0]._vertices)[i].nz = n.z;
		}
		delete [] _md2Frames;
		_md2Frames = NULL;
	}
	//
	std::string filePath = "";
	std::string fileName = xFileSystem::Instance()->GetRealPath(path);
	NSString * nsPath = [[NSBundle mainBundle] resourcePath];
	fileName = fileName.substr(nsPath == nil ? 0 : [nsPath length]);
	int langDir = fileName.find(".lproj/");
	if(langDir != fileName.npos) fileName = fileName.substr(langDir + 7);
	int slashPos = fileName.find_last_of('/');
	if(slashPos != fileName.npos) filePath = fileName.substr(0, slashPos);	
	if(filePath.length() > 0) filePath += "/";
	for(int i = 0; i < textures.size(); i++)
	{
		textures[i]._texture = xTextureManager::Instance()->LoadTexture((filePath + textures[i]._filename).c_str(), textures[i]._flags);
		if(textures[i]._texture != NULL)
		{
			textures[i]._texture->SetBlendMode(textures[i]._blend);
			textures[i]._texture->SetOffset(textures[i]._posX, textures[i]._posY);
			textures[i]._texture->SetScale(1.0f / textures[i]._scaleX, 1.0f / textures[i]._scaleY);
			textures[i]._texture->SetRotation(textures[i]._rotation / 3.1415f * 180.0f);
			textures[i]._texture->SetCoordsSet(textures[i]._flags & 65536);
		}
	}
	MakeMesh(*rootNode, textures, materials, false);
	MergeHierarhy(NULL);
	for(int i = 0; i < textures.size(); i++)
	{
		xTextureManager::Instance()->ReleaseTexture(textures[i]._texture);
	}
	rootNode->Release();
	delete rootNode;
	return true;
}

void xEntity::SetQuaternion(xQuaternion quat, bool global)
{
	if(global && _parent != NULL)
	{
		_rotation = -_parent->GetQuaternion(true) * quat;
	}
	else
	{
		_rotation = quat;
	}
	ForceUpdate();
}

bool xEntity::LoadAnimMesh(const char * path)
{
	LoaderNode     * rootNode;
	TexturesArray    textures;
	MaterialsArray   materials;
	switch(IdentifyFileType(path))
	{
		case B3DFILE:
		{
			B3DLoader loader;
			if(!loader.LoadFile(path, &rootNode, &textures, &materials))
			{
				return false;
			}
		}
		break;
		case MD2FILE:
		{
			MD2Loader loader;
			if(!loader.LoadFile(path, &rootNode, &textures, &materials))
			{
				return false;
			}
			_md2Frames = loader.GetFrames();
			_md2Sequences.push_back(_md2Frames);
			xRender::Instance()->AddMD2Mesh(this);
		}
		break;
		case _3DSFILE:
		{
			Loader3DS loader;
			if(!loader.LoadFile(path, &rootNode, &textures, &materials))
			{
				return false;
			}
		}
		break;
		case UNKNOWNFILE:
		{
			return false;
		}
		break;
	}
	std::string filePath = "";
	std::string fileName = xFileSystem::Instance()->GetRealPath(path);
	NSString * nsPath = [[NSBundle mainBundle] resourcePath];
	fileName = fileName.substr(nsPath == nil ? 0 : [nsPath length]);
	int langDir = fileName.find(".lproj/");
	if(langDir != fileName.npos) fileName = fileName.substr(langDir + 7);
	int slashPos = fileName.find_last_of('/');
	if(slashPos != fileName.npos) filePath = fileName.substr(0, slashPos);	
	if(filePath.length() > 0) filePath += "/";
	for(int i = 0; i < textures.size(); i++)
	{
		textures[i]._texture = xTextureManager::Instance()->LoadTexture((filePath + textures[i]._filename).c_str(), textures[i]._flags);
		if(textures[i]._texture != NULL)
		{
			textures[i]._texture->SetBlendMode(textures[i]._blend);
			textures[i]._texture->SetOffset(textures[i]._posX, textures[i]._posY);
			textures[i]._texture->SetScale(1.0f / textures[i]._scaleX, 1.0f / textures[i]._scaleY);
			textures[i]._texture->SetRotation(textures[i]._rotation / 3.1415f * 180.0f);
			textures[i]._texture->SetCoordsSet(textures[i]._flags & 65536);
		}
	}
	MakeMesh(*rootNode, textures, materials, true);
	for(int i = 0; i < textures.size(); i++)
	{
		xTextureManager::Instance()->ReleaseTexture(textures[i]._texture);
	}
	UpdateMD2Mesh();
	rootNode->Release();
	delete rootNode;
	return true;
}

void xEntity::MakeMesh(LoaderNode& node, TexturesArray& textures, MaterialsArray& materials, bool anim)
{
	SetName(node._name.c_str());
	SetPosition(node._position.x, node._position.y, node._position.z, false);
	SetScale(node._scale.x, node._scale.y, node._scale.z, false);
	SetQuaternion(node._rotation, false);
	UpdateWorldTransform();
	if(node._surfaces.size() > 0)
	{
		for(int i = 0; i < node._surfaces.size(); i++)
		{
			if(node._surfaces[i]._vertices == NULL || node._surfaces[i]._triangles == NULL) continue;
			xSurface * newSurf = CreateSurface(NULL);
			newSurf->SetAlphaVertexCount(node._surfaces[i]._cntAlphaVertex);
			xVertex * vert = newSurf->AllocateVB(node._surfaces[i]._vertices->size());
			ushort * tris  = newSurf->AllocateIB(node._surfaces[i]._triangles->size());
			memcpy((void*)vert, (void*)&(*node._surfaces[i]._vertices)[0], node._surfaces[i]._vertices->size() * sizeof(xVertex));
			if(!anim)
			{
				xTransform transform = GetWorldTransform();
				for(int v = 0; v < node._surfaces[i]._vertices->size(); v++)
				{
					xVector pos = transform * xVector(vert[v].x, vert[v].y, vert[v].z);
					vert[v].x = pos.x;
					vert[v].y = pos.y;
					vert[v].z = pos.z;
					if(node._surfaces[i]._flags & 1)
					{
						pos = transform.matrix * xVector(vert[v].nx, vert[v].ny, vert[v].nz);
						pos.Normalize();
						vert[v].nx = pos.x;
						vert[v].ny = pos.y;
						vert[v].nz = pos.z;
					}
				}
			}
			newSurf->UpdateBoundingVolumes();
			memcpy((void*)tris, (void*)&(*node._surfaces[i]._triangles)[0], node._surfaces[i]._triangles->size() * 3 * sizeof(ushort));
			if(!(node._surfaces[i]._flags & 1)) newSurf->GenerateNormals();
			int brush = node._surfaces[i]._materialID;
			if(brush != -1)
			{
				newSurf->SetColor(materials[brush]._red * 255, materials[brush]._green * 255, materials[brush]._blue * 255);
				newSurf->SetAlpha(materials[brush]._alpha);
				newSurf->SetBlendMode(materials[brush]._blend);
				newSurf->SetFX(materials[brush]._FX);
				newSurf->SetShininess(materials[brush]._shininess);
				for(int j = 0; j < 8; j++)
				{
					int texID = materials[brush]._textures[j];
					if(texID != -1) newSurf->SetTexture(j, textures[texID]._texture, 0);
				}
			}
		}
	}
	if(node._brushID != -1)
	{
		_masterBrush.red       = materials[node._brushID]._red   * 255;
		_masterBrush.green     = materials[node._brushID]._green * 255;
		_masterBrush.blue      = materials[node._brushID]._blue  * 255;
		_masterBrush.alpha     = materials[node._brushID]._alpha;
		_masterBrush.shininess = materials[node._brushID]._shininess;
		_masterBrush.blendMode = materials[node._brushID]._blend;
		_masterBrush.FX        = materials[node._brushID]._FX;
		int index = 0;
		for(int i = 0; i < 8; i++)
		{
			int texID = materials[node._brushID]._textures[i];
			if(texID != -1)
			{
				_masterBrush.textures[index].texture = textures[texID]._texture;
				_masterBrush.textures[index].frame   = 0;
				if(_masterBrush.textures[index].texture != NULL) _masterBrush.textures[index].texture->Retain();
				index++;
			}
			if(index == xRender::Instance()->GetMaxTextureUnits()) break;
		}
	}
	if(anim && _type == ENTITY_BONE)
	{
		if(node._animKeys.size() > 0)
		{
			if(node._animations.size() == 0)
			{
				int frames = 0;
				for(int i = 0; i < node._animKeys.size(); i++) frames = max(frames, node._animKeys[i]._frame);
				LoaderAnimation newAnimation;
				newAnimation._fps        = 30.0f;
				newAnimation._startFrame = 0;
				newAnimation._endFrame   = frames;
				node._animations.push_back(newAnimation);
			}
			xAnimSet * newSet = new xAnimSet();
			if(node._animations[0]._fps == 0.0f) node._animations[0]._fps = 30.0f;
			newSet->SetFPS(node._animations[0]._fps);
			for(int i = 0; i < node._animKeys.size(); i++)
			{
				float time           = float(node._animKeys[i]._frame) / newSet->GetFPS();
				xVector position     = xVector(node._position.x, node._position.y, node._position.z);
				xVector scale        = node._scale;
				xQuaternion rotation = node._rotation;
				int type             = 0;
				if(node._animKeys[i]._flag & 1)
				{
					position = xVector(node._animKeys[i]._position.x, node._animKeys[i]._position.y, node._animKeys[i]._position.z);
					type += 1;
				}
				if(node._animKeys[i]._flag & 2)
				{
					scale = node._animKeys[i]._scale;
					type += 4;
				}
				if(node._animKeys[i]._flag & 4)
				{
					rotation = node._animKeys[i]._rotation;
					type += 2;
				}
				newSet->AddAnimationKey(time, node._animKeys[i]._frame, position, scale, rotation, type);
			}
			newSet->SetFramesCount(node._animations[0]._endFrame - node._animations[0]._startFrame);
			newSet->SetLenght(float(node._animations[0]._endFrame - node._animations[0]._startFrame) / node._animations[0]._fps);
			((xBone*)this)->AddAnimationSet(newSet);
		}
	}
	if(node._subNodes.size() > 0)
	{
		for(int i = 0; i < node._subNodes.size(); i++)
		{
			if((node._subNodes[i]->_boneID == 0 && node._animKeys.size() == 0 
				&& node._subNodes[i]->_animKeys.size() == 0) || !anim)
			{
				xEntity * newNode = new xEntity();
				newNode->SetParent(this);
				newNode->MakeMesh(*node._subNodes[i], textures, materials, anim);
			}
			else
			{
				xBone * newBone = new xBone(node._subNodes[i]->_boneID, xVector(node._subNodes[i]->_position.x, node._subNodes[i]->_position.y, node._subNodes[i]->_position.z), node._subNodes[i]->_rotation, node._subNodes[i]->_scale);
				newBone->SetParent(this);
				newBone->ComputeBindPose();
				if(node._boneID == 0 && node._subNodes[i]->_boneID != 0)
				{
					_rootBone = newBone;
					xRender::Instance()->AddAnimated((xBone*)this);
					for(int j = 0; j < _surfaces.size(); j++) _surfaces[j]->AllocateSkinnedVB();
				}
				newBone->MakeMesh(*node._subNodes[i], textures, materials, anim);
			}
		}
	}
}

void xEntity::UpdateSkin()
{
	if(_rootBone == NULL) return;
	xTransform worldInversed = GetWorldTransform().Inversed();
	xTransform ** tforms     = _rootBone->GetBonesTransforms(worldInversed);
	for(int i = 0; i < _surfaces.size(); i++)
	{
		xVertex * activeVerts = _surfaces[i]->GetVB();
		xVertex * origVerts   = _surfaces[i]->GetBindPoseVB();
		xVector position;
		for(int j = 0; j < _surfaces[i]->CountVertices(); j++)
		{
			if(origVerts[j].bone1 == 0 && origVerts[j].bone2 == 0 && origVerts[j].bone3 == 0 && origVerts[j].bone4 == 0)
			{
				activeVerts[j].x  = origVerts[j].x;
				activeVerts[j].y  = origVerts[j].y;
				activeVerts[j].z  = origVerts[j].z;
				activeVerts[j].nx = origVerts[j].nx;
				activeVerts[j].ny = origVerts[j].ny;
				activeVerts[j].nz = origVerts[j].nz;
				continue;
			}
			if(origVerts[j].bone1 > 0)
			{
				position = *tforms[origVerts[j].bone1] * xVector(origVerts[j].x, origVerts[j].y, origVerts[j].z);
				activeVerts[j].x  = position.x * origVerts[j].weight1;
				activeVerts[j].y  = position.y * origVerts[j].weight1;
				activeVerts[j].z  = position.z * origVerts[j].weight1;
				position = tforms[origVerts[j].bone1]->matrix.Cofactor() * xVector(origVerts[j].nx, origVerts[j].ny, origVerts[j].nz);
				activeVerts[j].nx = position.x * origVerts[j].weight1;
				activeVerts[j].ny = position.y * origVerts[j].weight1;
				activeVerts[j].nz = position.z * origVerts[j].weight1;
			}
			if(origVerts[j].bone2 > 0)
			{
				position = *tforms[origVerts[j].bone2] * xVector(origVerts[j].x, origVerts[j].y, origVerts[j].z);
				activeVerts[j].x  += position.x * origVerts[j].weight2;
				activeVerts[j].y  += position.y * origVerts[j].weight2;
				activeVerts[j].z  += position.z * origVerts[j].weight2;
				position = tforms[origVerts[j].bone2]->matrix.Cofactor() * xVector(origVerts[j].nx, origVerts[j].ny, origVerts[j].nz);
				activeVerts[j].nx += position.x * origVerts[j].weight2;
				activeVerts[j].ny += position.y * origVerts[j].weight2;
				activeVerts[j].nz += position.z * origVerts[j].weight2;
			}
			if(origVerts[j].bone3 > 0)
			{
				position = *tforms[origVerts[j].bone3] * xVector(origVerts[j].x, origVerts[j].y, origVerts[j].z);
				activeVerts[j].x  += position.x * origVerts[j].weight3;
				activeVerts[j].y  += position.y * origVerts[j].weight3;
				activeVerts[j].z  += position.z * origVerts[j].weight3;
				position = tforms[origVerts[j].bone3]->matrix.Cofactor() * xVector(origVerts[j].nx, origVerts[j].ny, origVerts[j].nz);
				activeVerts[j].nx += position.x * origVerts[j].weight3;
				activeVerts[j].ny += position.y * origVerts[j].weight3;
				activeVerts[j].nz += position.z * origVerts[j].weight3;
			}
			if(origVerts[j].bone4 > 0)
			{
				position = *tforms[origVerts[j].bone4] * xVector(origVerts[j].x, origVerts[j].y, origVerts[j].z);
				float last = 1.0f - origVerts[j].weight1 - origVerts[j].weight2 - origVerts[j].weight3;
				activeVerts[j].x  += position.x * last;
				activeVerts[j].y  += position.y * last;
				activeVerts[j].z  += position.z * last;
				position = tforms[origVerts[j].bone4]->matrix.Cofactor() * xVector(origVerts[j].nx, origVerts[j].ny, origVerts[j].nz);
				activeVerts[j].nx += position.x * last;
				activeVerts[j].ny += position.y * last;
				activeVerts[j].nz += position.z * last;
			}
			position = xVector(activeVerts[j].nx, activeVerts[j].ny, activeVerts[j].nz).Normalized();
			activeVerts[j].nx = position.x;
			activeVerts[j].ny = position.y;
			activeVerts[j].nz = position.z;
		}
	}
}

void xEntity::SetAutoFade(float nearValue, float farValue)
{
	_autoFade = true;
	_fadeNear = nearValue;
	_fadeFar  = farValue;
}

void xEntity::Animate(int mode, float speed, int setID, float smooth)
{
	if(_md2Sequences.size() > 0)
	{
		_md2Mode      = mode;
		_md2Speed     = speed;
		_md2Frames    = _md2Sequences[setID];
		_md2Time      = speed >= 0.0f ? 0.0f : _md2Frames[0].length;
		_md2LocalTime = speed >= 0.0f ? 0.0f : _md2Frames[0].length;
		_md2Dest      = 1;
	}
	if(_type == ENTITY_BONE) ((xBone*)this)->Animate(mode, speed, setID, smooth);
	for(int i = 0; i < _childs.size(); i++) _childs[i]->Animate(mode, speed, setID, smooth);
}

bool xEntity::Animated()
{
	if(_md2Sequences.size() > 0)
	{
		return _md2Mode > 0;
	}
	if(_rootBone != NULL)
	{
		if(((xBone*)_rootBone)->Animated()) return true;
	}
	if(_type == ENTITY_BONE)
	{
		if(((xBone*)this)->Animated()) return true;
	}
	for(int i = 0; i < _childs.size(); i++)
	{
		if(_childs[i]->Animated()) return true;
	}
	return false;
}

int xEntity::AnimationSet()
{
	if(_md2Sequences.size() > 0)
	{
		for(int i = 0; i < _md2Sequences.size(); i++)
		{
			if(_md2Sequences[i] == _md2Frames) return i;
		}
	}
	if(_rootBone != NULL)
	{
		int result = ((xBone*)_rootBone)->GetAnimationSet();
		if(result >= 0) return result;
	}
	if(_type == ENTITY_BONE)
	{
		int result = ((xBone*)this)->GetAnimationSet();
		if(result >= 0) return result;
	}
	for(int i = 0; i < _childs.size(); i++)
	{
		int result = _childs[i]->AnimationSet();
		if(result >= 0) return result;
	}
	return -1;
}

float xEntity::AnimationTime()
{
	if(_md2Sequences.size() > 0) return _md2LocalTime;
	if(_rootBone != NULL)
	{
		float result = ((xBone*)_rootBone)->GetAnimationTime();
		if(result > 0.0f) return result;
	}
	if(_type == ENTITY_BONE)
	{
		float result = ((xBone*)this)->GetAnimationTime();
		if(result > 0.0f) return result;
	}
	for(int i = 0; i < _childs.size(); i++)
	{
		float result = _childs[i]->AnimationTime();
		if(result > 0.0f) return result;
	}
	return 0.0f;
}

float xEntity::AnimationSpeed()
{
	if(_md2Sequences.size() > 0) return _md2Speed;
	if(_rootBone != NULL)
	{
		float result = ((xBone*)_rootBone)->GetAnimationSpeed();
		if(result > 0.0f) return result;
	}
	if(_type == ENTITY_BONE)
	{
		float result = ((xBone*)this)->GetAnimationSpeed();
		if(result > 0.0f) return result;
	}
	for(int i = 0; i < _childs.size(); i++)
	{
		float result = _childs[i]->AnimationSpeed();
		if(result > 0.0f) return result;
	}
	return 0.0f;
}

float xEntity::AnimationLength()
{
	if(_md2Sequences.size() > 0) return _md2Frames[0].length;
	if(_rootBone != NULL)
	{
		float result = ((xBone*)_rootBone)->GetAnimationLength();
		if(result > 0.0f) return result;
	}
	if(_type == ENTITY_BONE)
	{
		float result = ((xBone*)this)->GetAnimationLength();
		if(result > 0.0f) return result;
	}
	for(int i = 0; i < _childs.size(); i++)
	{
		float result = _childs[i]->AnimationLength();
		if(result > 0.0f) return result;
	}
	return 0.0f;
}

int xEntity::ExtractAnimationSet(int startFrame, int endFrame, int setID)
{
	int newSet = -1;
	if(_md2Sequences.size() > 0)
	{
		int result = ExtractMD2AnimationSet(startFrame, endFrame, setID);
		newSet     = max(newSet, result);
	}
	if(_type == ENTITY_BONE)
	{
		int result = ((xBone*)this)->ExtractAnimationSet(startFrame, endFrame, setID);
		newSet     = max(newSet, result);
	}
	for(int i = 0; i < _childs.size(); i++)
	{
		int result = _childs[i]->ExtractAnimationSet(startFrame, endFrame, setID);
		newSet     = max(newSet, result);
	}
	return newSet;
}

void xEntity::SetAnimationTime(float value)
{
	if(_md2Sequences.size() > 0) _md2Time = value;
	if(_type == ENTITY_BONE) ((xBone*)this)->SetAnimationTime(value);
	RebuildMesh(value);
	for(int i = 0; i < _childs.size(); i++) _childs[i]->SetAnimationTime(value);
}

void xEntity::SetAnimationSpeed(float value)
{
	if(_md2Sequences.size() > 0) _md2Speed = value;
	if(_type == ENTITY_BONE) ((xBone*)this)->SetAnimationSpeed(value);
	for(int i = 0; i < _childs.size(); i++) _childs[i]->SetAnimationSpeed(value);
}

int xEntity::LoadAnimationSet(const char * path)
{
	LoaderNode          * rootNode;
	TexturesArray         textures;
	MaterialsArray        materials;
	MD2Loader::MD2Frame * md2Frames = NULL;
	switch(IdentifyFileType(path))
	{
		case B3DFILE:
		{
			B3DLoader loader;
			if(!loader.LoadFile(path, &rootNode, &textures, &materials))
			{
				return -1;
			}
		}
		break;
		case MD2FILE:
		{
			MD2Loader loader;
			if(!loader.LoadFile(path, &rootNode, &textures, &materials))
			{
				return -1;
			}
			md2Frames = loader.GetFrames();
		}
		break;
		case UNKNOWNFILE:
		{
			return -1;
		}
		break;
	}
	int result;
	if(md2Frames == NULL)
	{
		result = ExtractAnimationSetFromFile(rootNode);
	}
	else
	{
		result = _md2Sequences.size();
		_md2Sequences.push_back(md2Frames);
	}
	rootNode->Release();
	return result;
}

int xEntity::ExtractAnimationSetFromFile(LoaderNode * rootNode)
{
	int newSet = -1;
	if(_type == ENTITY_BONE)
	{
		int result = ((xBone*)this)->ExtractAnimationSetFromFile(rootNode);
		newSet     = max(newSet, result);
	}
	for(int i = 0; i < _childs.size(); i++)
	{
		int result = _childs[i]->ExtractAnimationSetFromFile(rootNode);
		newSet     = max(newSet, result);
	}
	return newSet;
}

void xEntity::SetPickMode(int mode)
{
	_pickMode = mode;
	xRender::Instance()->SetPickedEntity(this);
}

int xEntity::GetPickMode()
{
	return _pickMode;
}

void xEntity::Pick(xVector & position, xVector & direction)
{
	if(_pickMode == 1)
	{
		xVector vec = position - _collideBox.Centre();
		float radii = max(_collideRadii.x, _collideRadii.y);
		float b = 2.0f * direction.Dot(vec);
		float c = vec.Dot(vec) - (radii * radii);
		float discriminant = (b * b) - (4.0f * c);
		if(discriminant < 0.0f) return;
		discriminant = sqrtf(discriminant);
		float s0 = (-b + discriminant) / 2.0f;
		float s1 = (-b - discriminant) / 2.0f;
		float s  = s0 > s1 ? s0 : s1;
		if(s < 0.0f) return;
		xVector pickPosition = _collideBox.Centre() + (-direction * radii);
		float distance = position.Distance(pickPosition);
		if(distance > xRender::Instance()->GetPickDistance()) return;
		xRender::Instance()->SetPickPosition(GetWorldTransform() * pickPosition);
		xRender::Instance()->SetPickNormal(GetQuaternion(true) * (-direction));
		xRender::Instance()->SetPickTime(distance / 1000.0f);
		xRender::Instance()->SetPickDistance(distance);
		xRender::Instance()->SetPickTriangle(0);
		xRender::Instance()->SetPickSurface(NULL);
		xRender::Instance()->SetPickEntity(this);
	}
	else if(_pickMode == 2 || _pickMode == 4)
	{
		if(IsSkinned()) UpdateSkin();
		for(int i = 0; i < _surfaces.size(); i++) _surfaces[i]->Pick(this, position, direction);
	}
	else
	{
		float distance;
		if(IntersectBox(position, direction, &distance))
		{
			if(fabs(distance) < xRender::Instance()->GetPickDistance())
			{
				xVector pickPosition = position + (direction * distance);
				xRender::Instance()->SetPickPosition(GetWorldTransform() * pickPosition);
				xRender::Instance()->SetPickNormal(GetQuaternion(true) * -direction);
				xRender::Instance()->SetPickTime(distance / 1000.0f);
				xRender::Instance()->SetPickDistance(distance);
				xRender::Instance()->SetPickTriangle(0);
				xRender::Instance()->SetPickSurface(NULL);
				xRender::Instance()->SetPickEntity(this);
			}
		}
	}
}

bool xEntity::IntersectBox(xVector & position, xVector & direction, float * distance)
{
	xVector _minCorner = _collideBox.Corner(0);
	xVector _maxCorner = _collideBox.Corner(7);
	xVector v0 = xVector(_minCorner.x, _minCorner.y, _minCorner.z);
	xVector v1 = xVector(_minCorner.x, _maxCorner.y, _minCorner.z);
	xVector v2 = xVector(_maxCorner.x, _maxCorner.y, _minCorner.z);
	if(IntersectTriangle(position, direction, v0, v1, v2, distance)) return true;
	v0 = xVector(_maxCorner.x, _minCorner.y, _minCorner.z);
	v1 = xVector(_minCorner.x, _minCorner.y, _minCorner.z);
	v2 = xVector(_maxCorner.x, _maxCorner.y, _minCorner.z);
	if(IntersectTriangle(position, direction, v0, v1, v2, distance)) return true;
	v0 = xVector(_maxCorner.x, _minCorner.y, _minCorner.z);
	v1 = xVector(_maxCorner.x, _maxCorner.y, _minCorner.z);
	v2 = xVector(_maxCorner.x, _maxCorner.y, _maxCorner.z);
	if(IntersectTriangle(position, direction, v0, v1, v2, distance)) return true;
	v0 = xVector(_maxCorner.x, _minCorner.y, _maxCorner.z);
	v1 = xVector(_maxCorner.x, _minCorner.y, _minCorner.z);
	v2 = xVector(_maxCorner.x, _maxCorner.y, _maxCorner.z);
	if(IntersectTriangle(position, direction, v0, v1, v2, distance)) return true;
	v0 = xVector(_maxCorner.x, _minCorner.y, _maxCorner.z);
	v1 = xVector(_maxCorner.x, _maxCorner.y, _maxCorner.z);
	v2 = xVector(_minCorner.x, _maxCorner.y, _maxCorner.z);
	if(IntersectTriangle(position, direction, v0, v1, v2, distance)) return true;
	v0 = xVector(_minCorner.x, _minCorner.y, _maxCorner.z);
	v1 = xVector(_maxCorner.x, _minCorner.y, _maxCorner.z);
	v2 = xVector(_minCorner.x, _maxCorner.y, _maxCorner.z);
	if(IntersectTriangle(position, direction, v0, v1, v2, distance)) return true;
	v0 = xVector(_minCorner.x, _minCorner.y, _maxCorner.z);
	v1 = xVector(_minCorner.x, _maxCorner.y, _maxCorner.z);
	v2 = xVector(_minCorner.x, _maxCorner.y, _minCorner.z);
	if(IntersectTriangle(position, direction, v0, v1, v2, distance)) return true;
	v0 = xVector(_minCorner.x, _minCorner.y, _minCorner.z);
	v1 = xVector(_minCorner.x, _minCorner.y, _maxCorner.z);
	v2 = xVector(_minCorner.x, _maxCorner.y, _minCorner.z);
	if(IntersectTriangle(position, direction, v0, v1, v2, distance)) return true;
	v0 = xVector(_minCorner.x, _maxCorner.y, _minCorner.z);
	v1 = xVector(_minCorner.x, _maxCorner.y, _maxCorner.z);
	v2 = xVector(_maxCorner.x, _maxCorner.y, _maxCorner.z);
	if(IntersectTriangle(position, direction, v0, v1, v2, distance)) return true;
	v0 = xVector(_maxCorner.x, _maxCorner.y, _minCorner.z);
	v1 = xVector(_minCorner.x, _maxCorner.y, _minCorner.z);
	v2 = xVector(_maxCorner.x, _maxCorner.y, _maxCorner.z);
	if(IntersectTriangle(position, direction, v0, v1, v2, distance)) return true;
	v0 = xVector(_minCorner.x, _minCorner.y, _maxCorner.z);
	v1 = xVector(_minCorner.x, _minCorner.y, _minCorner.z);
	v2 = xVector(_maxCorner.x, _minCorner.y, _minCorner.z);
	if(IntersectTriangle(position, direction, v0, v1, v2, distance)) return true;
	v0 = xVector(_maxCorner.x, _minCorner.y, _maxCorner.z);
	v1 = xVector(_minCorner.x, _minCorner.y, _maxCorner.z);
	v2 = xVector(_maxCorner.x, _minCorner.y, _minCorner.z);
	if(IntersectTriangle(position, direction, v0, v1, v2, distance)) return true;
	return false;
}

bool xEntity::IntersectTriangle(const xVector & position, const xVector & direction, xVector & v0, xVector & v1, xVector & v2, float * distance)
{
    xVector edge1 = v1 - v0;
    xVector edge2 = v2 - v0;
	xVector normal = edge1.Cross(edge2);
	if(normal.Dot(direction) >= 0.0f) return false;
    xVector pvec = direction.Cross(edge2);
    float det = edge1.Dot(pvec);
    xVector tvec;
	xVector qvec;
    if(det > 0.00001f)
    {
        tvec = position - v0;
		float u = tvec.Dot(pvec);
		if(u < 0.0f || u > det) return false;
		qvec = tvec.Cross(edge1);
		float v = direction.Dot(qvec);
		if(v < 0.0f || u + v > det) return false;
    }
    else if(det < -0.00001f)
    {
        tvec = position - v0;
        float u = tvec.Dot(pvec);
		if(u > 0.0f || u < det) return false;
		qvec = tvec.Cross(edge1);
		float v = direction.Dot(qvec);
		if(v > 0.0f || u + v < det) return false;
    }
	else
	{
		return false;
	}
    *distance = edge2.Dot(qvec);
    *distance *= 1.0f / det;
    return true;
}

void xEntity::LinePick(xVector & position, xVector & direction)
{
	xTransform inverseWorld = GetWorldTransform().Inversed();
	xVector objectPosition  = inverseWorld * position;
	xVector objectDirection = inverseWorld.matrix * direction;
	objectDirection.Normalize();
	Pick(objectPosition, objectDirection);
}

void xEntity::Reset()
{
	if(_needUpdate) UpdateWorldTransform();
	_collisions.clear();
	_prevTransform = _worldTransform;
}

void xEntity::SetCollisionRadii(xVector radii)
{
	_collideRadii = radii;
}

void xEntity::SetCollisionBox(xBox box)
{
	_collideBox = box;
}

void xEntity::SetCollisionType(int type)
{
	_collideType = type;
}

const std::vector<xEntityCollision*> & xEntity::GetCollisions()
{
	return _collisions;
}

void xEntity::ClearCollisions()
{
	_collisions.clear();
}

int xEntity::GetCollisionType()
{
	return _collideType;
}

xVector xEntity::GetCollisionRadii()
{
	return _collideRadii;
}

xBox xEntity::GetCollisionBox()
{
	return _collideBox;
}

void xEntity::SavePervTransform()
{
	_prevTransform = GetWorldTransform();
}

void xEntity::AddCollision(xEntityCollision * c)
{
	_collisions.push_back(c);
}

xMeshCollider * xEntity::GetCollider()
{
	bool geomGhanges = false;
	for(int k = 0; k < _surfaces.size(); ++k) geomGhanges |= _surfaces[k]->GetChangesState();
	geomGhanges |= (_rootBone != NULL);
	if(IsSkinned()) UpdateSkin();
	if(geomGhanges)
	{
		if(_collider != NULL) delete _collider;
		std::vector<xVector> verts;
		std::vector<xMeshCollider::Triangle> tris;
		for(int k = 0; k < _surfaces.size(); ++k)
		{
			ushort * triangles = _surfaces[k]->GetIB();
			for(int j = 0; j < _surfaces[k]->CountTriangles(); ++j)
			{
				xMeshCollider::Triangle q;
				q.verts[0] = triangles[j * 3 + 0] + verts.size();
				q.verts[1] = triangles[j * 3 + 1] + verts.size();
				q.verts[2] = triangles[j * 3 + 2] + verts.size();
				q.surface  = _surfaces[k];
				q.index    = j;
				tris.push_back(q);
			}
			xVertex * vertices = (_rootBone != NULL ? _surfaces[k]->GetBindPoseVB() : _surfaces[k]->GetVB());
			for(int j = 0; j < _surfaces[k]->CountVertices(); ++j)
			{
				verts.push_back(xVector(vertices[j].x, vertices[j].y, vertices[j].z));
			}
		}
		_collider = new xMeshCollider(verts, tris);
	}
	for(int k = 0; k < _surfaces.size(); ++k) _surfaces[k]->SetChangesState(false);
	return _collider;
}

bool xEntity::Collide(const x3DLine &line, float radius, xCollision * currColl, const xTransform &t)
{
	xMeshCollider * collider = GetCollider();
	if(collider == NULL) return false;
	return collider->Collide(line, radius, currColl, t);
}

xTransform xEntity::GetWorldTransformPrev()
{
	return _prevTransform;
}

xBox xEntity::GetMeshBox()
{
	xBox box = GetBoundingBox();
	for(int i = 0; i < CountChilds(); i++)
	{
		box.Update(GetChild(i)->GetMeshBox());
	}
	if(box.Empty()) return xBox(xVector(), xVector());
	return box;
}

float xEntity::GetMeshRadius()
{
	float radius = 0.0f;
	for(int i = 0; i < CountSurfaces(); i++)
	{
		xVector center = GetSurface(i)->GetBoundingSphereCenter();
		float surfaceRadius = GetSurface(i)->GetBoundingSphereRadius() + center.Length();
		radius = radius > surfaceRadius ? radius : surfaceRadius;
	}
	for(int i = 0; i < CountChilds(); i++)
	{
		float childRadius = GetChild(i)->GetMeshRadius();
		radius = radius > childRadius ? radius : childRadius;
	}
	return radius;
}

// physics commands
void xEntity::InitBody()
{
	if(_physBody == NULL) return;
	xRender::Instance()->AddPhysNode(this);
	xVector     position   = GetPosition(true);
	xVector     scale      = GetScale(true);
	xQuaternion quaternion = GetQuaternion(true);
	_physBody->SetPosition(position.x, position.y, position.z);
	_physBody->SetScale(scale.x, scale.y, scale.z);
	_physBody->SetQuaternion(quaternion.x, quaternion.y, quaternion.z, quaternion.w);
}

void xEntity::AddDummyShape()
{
	IWorld * _physWorld = xRender::Instance()->GetPhysWorld();
	if(_physWorld == NULL) return;
	_physBody = _physWorld->CreateDummyBody();
	InitBody();
}

void xEntity::AddBoxShape(float mass, float width, float height, float depth)
{
	if(width <= 0.0f || height <= 0.0f || depth <= 0.0f)
	{
		xBox boundingBox = GetMeshBox();
		width  = boundingBox.Width();
		height = boundingBox.Height();
		depth  = boundingBox.Depth();
	}
	IWorld * _physWorld = xRender::Instance()->GetPhysWorld();
	if(_physWorld == NULL) return;
	_physBody = _physWorld->CreateCubeBody(width, height, depth, mass);
	InitBody();
}

void xEntity::AddSphereShape(float mass, float redius)
{
	if(redius <= 0.0f) redius = GetMeshRadius();
	IWorld * _physWorld = xRender::Instance()->GetPhysWorld();
	if(_physWorld == NULL) return;
	_physBody = _physWorld->CreateSphereBody(redius, mass);
	InitBody();
}

void xEntity::AddCapsuleShape(float mass, float radius, float height)
{
	IWorld * _physWorld = xRender::Instance()->GetPhysWorld();
	if(_physWorld == NULL) return;
	if(radius <= 0.0f || height <= 0.0f)
	{
		xBox boundingBox = GetMeshBox();
		float width  = boundingBox.Width();
		height = boundingBox.Height();
		float depth  = boundingBox.Depth();
		radius = max(width, depth) / 2.0f;
	}
	_physBody = _physWorld->CreateCapsuleBody(radius, height, mass);
	InitBody();
}

void xEntity::AddConeShape(float mass, float radius, float height)
{
	IWorld * _physWorld = xRender::Instance()->GetPhysWorld();
	if(_physWorld == NULL) return;
	if(radius <= 0.0f || height <= 0.0f)
	{
		xBox boundingBox = GetMeshBox();
		float width  = boundingBox.Width();
		height = boundingBox.Height();
		float depth  = boundingBox.Depth();
		radius = max(width, depth) / 2.0f;
	}
	_physBody = _physWorld->CreateConeBody(radius, height, mass);
	InitBody();
}

void xEntity::AddCylinderShape(float mass, float width, float height, float depth)
{
	IWorld * _physWorld = xRender::Instance()->GetPhysWorld();
	if(_physWorld == NULL) return;
	if(width <= 0.0f || height <= 0.0f || depth <= 0.0f)
	{
		xBox boundingBox = GetMeshBox();
		width  = boundingBox.Width();
		height = boundingBox.Height();
		depth  = boundingBox.Depth();
	}
	_physBody = _physWorld->CreateCylinderBody(width, height, depth, mass);
	InitBody();
}

void xEntity::AddTriMeshShape(float mass)
{
	IWorld * _physWorld = xRender::Instance()->GetPhysWorld();
	if(_physWorld == NULL) return;
	GetVB();
	GetIB();
	int     verticesCount = GetVBSize();
	int     indicesCount  = GetIBSize();
	_physBody = _physWorld->CreateTriMeshBody(_trimeshVB, verticesCount,
											  _trimeshIB, indicesCount * 3, mass);
	InitBody();
}

void xEntity::AddHullShape(float mass)
{
	IWorld * _physWorld = xRender::Instance()->GetPhysWorld();
	if(_physWorld == NULL) return;
	GetVB();
	_physBody = _physWorld->CreateHullBody(_trimeshVB, GetVBSize(), mass);
	InitBody();
}

void xEntity::PushSurfaces(FloatArray * vertices)
{
	for(int i = 0; i < CountSurfaces(); i++)
	{
		xVertex * verts = GetSurface(i)->GetVB();
		for(int j = 0; j < GetSurface(i)->CountVertices(); j++)
		{
			vertices->push_back(verts[j].x);
			vertices->push_back(verts[j].y);
			vertices->push_back(verts[j].z);
		}
	}
	for(int i = 0; i < CountChilds(); i++) GetChild(i)->PushSurfaces(vertices);
}

void xEntity::PushSurfaces(IntArray * indices, int offset)
{
	for(int i = 0; i < CountSurfaces(); i++)
	{
		ushort * index = GetSurface(i)->GetIB();
		for(int j = 0; j < GetSurface(i)->CountTriangles(); j++)
		{
			indices->push_back(offset + index[j * 3 + 0]);
			indices->push_back(offset + index[j * 3 + 1]);
			indices->push_back(offset + index[j * 3 + 2]);
		}
		offset += GetSurface(i)->CountVertices();
	}
	for(int i = 0; i < CountChilds(); i++) GetChild(i)->PushSurfaces(indices, offset);
}

void xEntity::GetVB()
{
	if(_trimeshVB == NULL)
	{
		FloatArray vertices;
		PushSurfaces(&vertices);
		_trimeshVB = new float[vertices.size()];
		memcpy((void*)_trimeshVB, (void*)&vertices[0], vertices.size() * sizeof(float));
	}
}

void xEntity::GetIB()
{
	if(_trimeshIB == NULL)
	{
		IntArray indices;
		PushSurfaces(&indices, 0);
		_trimeshIB = new int[indices.size()];
		memcpy((void*)_trimeshIB, (void*)&indices[0], indices.size() * sizeof(int));
	}
}

int xEntity::GetVBSize()
{
	FloatArray vertices;
	PushSurfaces(&vertices);
	return vertices.size() / 3;
}

int xEntity::GetIBSize()
{
	IntArray indices;
	PushSurfaces(&indices, 0);
	return indices.size() / 3;
}

void xEntity::SyncBodyTransform()
{
	if(_physBody == NULL) return;
	if(_needSyncBody)
	{
		_needSyncBody = false;
		UpdateWorldTransform();
		xVector     position   = GetPosition(true);
		xVector     scale      = GetScale(true);
		xQuaternion quaternion = GetQuaternion(true);
		quaternion = MakeQuaternion(quaternion.x, quaternion.y, quaternion.z, quaternion.w);
		_physBody->SetPosition(position.x, position.y, position.z);
		_physBody->SetScale(scale.x, scale.y, scale.z);
		_physBody->SetQuaternion(quaternion.x, quaternion.y, -quaternion.z, quaternion.w);
	}
}

void xEntity::SyncEntityTransform()
{
	if(_physBody == NULL) return;
	xVector     position;
	xQuaternion quaternion;
	_physBody->GetPosition((float*)&position);
	_physBody->GetQuaternion((float*)&quaternion);
	quaternion = MakeQuaternion(quaternion.x, quaternion.y, -quaternion.z, quaternion.w);
	SetPosition(position.x, position.y, position.z, true);
	SetQuaternion(quaternion, true);
	UpdateWorldTransform();
}

void xEntity::ApplyCentralForce(float x, float y, float z)
{
	if(_physBody == NULL) return;
	_physBody->ApplyCentralForce(x, y, z);
}

void xEntity::ApplyCentralImpulse(float x, float y, float z)
{
	if(_physBody == NULL) return;
	_physBody->ApplyCentralImpulse(x, y, z);
}

void xEntity::ReleaseForces()
{
	if(_physBody == NULL) return;
	_physBody->ReleaseForces();
}

void xEntity::ApplyTorque(float x, float y, float z)
{
	if(_physBody == NULL) return;
	_physBody->ApplyTorque(x, -y, z);
}

void xEntity::ApplyTorqueImpulse(float x, float y, float z)
{
	if(_physBody == NULL) return;
	_physBody->ApplyTorqueImpulse(x, -y, z);
}

void xEntity::ApplyForce(float x, float y, float z, float pointx, float pointy, float pointz)
{
	if(_physBody == NULL) return;
	_physBody->ApplyForce(x, y, z, pointx, pointy, pointz);
}

void xEntity::ApplyImpulse(float x, float y, float z, float pointx, float pointy, float pointz)
{
	if(_physBody == NULL) return;
	_physBody->ApplyImpulse(x, y, z, pointx, pointy, pointz);
}

void xEntity::SetDamping(float linear, float angular)
{
	if(_physBody == NULL) return;
	_physBody->SetDamping(linear, angular);
}

float xEntity::GetLinearDamping()
{
	if(_physBody == NULL) return 0.0f;
	return _physBody->GetLinearDamping();
}

float xEntity::GetAngularDamping()
{
	if(_physBody == NULL) return 0.0f;
	return _physBody->GetAngularDamping();
}

void xEntity::SetFriction(float friction)
{
	if(_physBody == NULL) return;
	_physBody->SetFriction(friction);
}

float xEntity::GetFriction()
{
	if(_physBody == NULL) return 0.0f;
	return _physBody->GetFriction();
}

void xEntity::SetRestitution(float restitution)
{
	if(_physBody == NULL) return;
	_physBody->SetRestitution(restitution);
}

float xEntity::GetRestitution()
{
	if(_physBody == NULL) return 0.0f;
	return _physBody->GetRestitution();
}

xVector xEntity::GetForce()
{
	if(_physBody == NULL) return xVector();
	xVector result;
	_physBody->GetForce((float*)&result);
	return result;
}

xVector xEntity::GetTorque()
{
	if(_physBody == NULL) return xVector();
	xVector result;
	_physBody->GetTorque((float*)&result);
	result.y = -result.y;
	return result;
}

void xEntity::FreeShapes()
{
	if(_physBody == NULL) return;
	xRender::Instance()->DeletePhysNode(this);
	xRender::Instance()->GetPhysWorld()->DeleteBody(_physBody);
	_physBody  = NULL;
	if(_trimeshVB != NULL)
	{
		delete _trimeshVB;
		_trimeshVB = NULL;
	}
	if(_trimeshIB != NULL)
	{
		delete _trimeshIB;
		_trimeshIB = NULL;
	}
}

int xEntity::GetContactsNumber()
{
	if(_physBody == NULL) return 0;
	xRender::Instance()->GetPhysWorld()->ProceedContacts(_physBody);
	return _physBody->GetContactsNumber();
}

xVector xEntity::GetContactPoint(int index)
{
	if(_physBody == NULL) return xVector();
	xRender::Instance()->GetPhysWorld()->ProceedContacts(_physBody);
	xVector result;
	_physBody->GetContactPoint(index, (float*)&result);
	return result;
}

xVector xEntity::GetContactNormal(int index)
{
	if(_physBody == NULL) return xVector();
	xRender::Instance()->GetPhysWorld()->ProceedContacts(_physBody);
	xVector result;
	_physBody->GetContactNormal(index, (float*)&result);
	return result;
}

float xEntity::GetContactDistance(int index)
{
	if(_physBody == NULL) return 0.0f;
	xRender::Instance()->GetPhysWorld()->ProceedContacts(_physBody);
	return _physBody->GetContactDistance(index);
}

xEntity * xEntity::GetContactSecondBody(int index)
{
	if(_physBody == NULL) return NULL;
	xRender::Instance()->GetPhysWorld()->ProceedContacts(_physBody);
	IBody * physBody = _physBody->GetContactSecondBody(index);
	if(physBody == NULL) return NULL;
	std::vector<xEntity*>::iterator itr = xRender::Instance()->PhysNodesBegin();
	while(itr != xRender::Instance()->PhysNodesEnd())
	{
		if((*itr)->_physBody == physBody) return (*itr);
		itr++;
	}
	return NULL;
}

IBody * xEntity::GetPhysBody()
{
	return _physBody;
}

xQuaternion xEntity::MakeQuaternion(float x, float y, float z, float w)
{
	xMatrix rotate = xMatrix(xQuaternion(x, y, z, w));
	rotate.i.z = -rotate.i.z;
	rotate.j.z = -rotate.j.z;
	rotate.k.x = -rotate.k.x;
	rotate.k.y = -rotate.k.y;
	return MatrixToQuaternion(rotate);
}

void xEntity::MakeSingleSurface()
{
	_isSingleMesh = true;
	// create surface for single surface mesh
	xSurface * newSurface = new xSurface(NULL);
	newSurface->SetFX(2);
	_surfaces.push_back(newSurface);
	// create texture atlas
	_atlas = new xTextureAtlas();
}

void xEntity::AddInstance(xEntity * instance)
{
	if(instance == NULL) return;
	// check instance
	std::vector<xEntity*>::iterator itr = std::find(_instances.begin(), _instances.end(), instance);
	if(itr == _instances.end() && instance->_surfaces.size() > 0)
	{
		// add to instances list
		_instances.push_back(instance);
		// delete instance from main render list
		xRender::Instance()->DeleteEntity(instance);
		// set pointer to single surface mesh in intance
		instance->_singleMesh = this;
		// add textures to atlas
		for(int j = 0; j < instance->CountSurfaces(); j++)
		{
			xSurface * surface = instance->GetSurface(j);
			xBrush   * brush   = surface->GetBrush();
			if(brush->textures[0].texture != NULL)
			{
				_surfaces[0]->SetTexture(0, NULL, 0);
				if(!_atlas->AddTexture(brush->textures[0].texture, brush->textures[0].frame))
				{
					printf("WARNING: Unable to add new texture into single-surface atlas.\n");
				}
			}
			delete brush;
		}
		// reset instances buffers
		ResetSingleSurface();
	}
	// add all childs of instance to single surface
	for(int i = 0; i < instance->_childs.size(); i++) AddInstance(instance->_childs[i]);
}

void xEntity::RemoveInstance(xEntity * instance)
{
	if(instance == NULL) return;
	// check instance
	std::vector<xEntity*>::iterator itr = std::find(_instances.begin(), _instances.end(), instance);
	if(itr != _instances.end())
	{
		// delete from instances
		if(itr != _instances.end()) _instances.erase(itr);
		// add instance to main render list
		xRender::Instance()->AddEntity(instance);
		// reset pointer to single surface mesh in intance
		instance->_singleMesh = NULL;
		// remove textures from atlas
		for(int j = 0; j < instance->CountSurfaces(); j++)
		{
			xSurface * surface = instance->GetSurface(j);
			xBrush   * brush   = surface->GetBrush();
			if(brush->textures[0].texture != NULL)
			{
				_surfaces[0]->SetTexture(0, NULL, 0);
				_atlas->DeleteTexture(brush->textures[0].texture, brush->textures[0].frame);
			}
			delete brush;
		}
		// reset instances buffers
		ResetSingleSurface();
	}
	// remove all childs of instance from single surface
	for(int i = 0; i < instance->_childs.size(); i++) RemoveInstance(instance->_childs[i]);
}

void xEntity::ResetSingleSurface()
{
	if(_isSingleMesh == false) return;
	// compute total vertices & triangles in single surface
	int totalVertices  = 0;
	int totalTriangles = 0;
	// all instances
	for(int i = 0; i < _instances.size(); i++)
	{
		// all surfaces in instance
		for(int j = 0; j < _instances[i]->CountSurfaces(); j++)
		{
			// add vertices and triangles to counters
			xSurface * surface = _instances[i]->GetSurface(j);
			totalVertices  += surface->CountVertices();
			totalTriangles += surface->CountTriangles();
		}
	}
	// recreate surface buffers
	_surfaces[0]->Clear(true, true);
	xVertex * vertices = _surfaces[0]->AllocateVB(totalVertices);
	ushort  * indices  = _surfaces[0]->AllocateIB(totalTriangles);
	if(totalVertices == 0 || totalTriangles == 0) return;
	// copy all indices
	int verticesOffset  = 0;
	int trianglesOffset = 0;
	// all instances
	_updateMap.clear();
	for(int i = 0; i < _instances.size(); i++)
	{
		// store vertices offset for instance
		_updateMap[_instances[i]].offset = verticesOffset;
		_updateMap[_instances[i]].update = true;
		// all surfaces in instance
		for(int j = 0; j < _instances[i]->CountSurfaces(); j++)
		{
			xSurface * surface      = _instances[i]->GetSurface(j);
			ushort   * surfIndices  = surface->GetIB();
			xVertex  * surfVertices = surface->GetVB();
			// copy all vertices
			memcpy(&vertices[verticesOffset], surfVertices, surface->CountVertices() * sizeof(xVertex));
			// copy all indices with new vertices offset
			for(int k = 0; k < surface->CountTriangles(); k++)
			{
				indices[trianglesOffset + k * 3 + 0] = surfIndices[k * 3 + 0] + verticesOffset;
				indices[trianglesOffset + k * 3 + 1] = surfIndices[k * 3 + 1] + verticesOffset;
				indices[trianglesOffset + k * 3 + 2] = surfIndices[k * 3 + 2] + verticesOffset;
			}
			// compute offset
			verticesOffset  += surface->CountVertices();
			trianglesOffset += surface->CountTriangles() * 3;
		}
	}
}

void xEntity::UpdateSingleSurface()
{
	if(_isSingleMesh == false) return;
	// all instances
	if(_atlas->GetTexture() != NULL) _atlas->GetTexture()->SetFlags(_atlasFlags);
	_surfaces[0]->SetTexture(0, _atlas->GetTexture(), 0);
	xVertex * vertices = _surfaces[0]->GetVB();
	if(vertices == NULL) return;
	std::map<xEntity*, InstanceData>::iterator itr = _updateMap.begin();
	while(itr != _updateMap.end())
	{
		// if instance was updated
		if(itr->second.update == true)
		{
			// update all vertices for instance
			xTransform worldTForm = itr->first->GetWorldTransform();
			int verticesOffset    = 0;
			xVector position;
			for(int i = 0; i < itr->first->CountSurfaces(); i++)
			{
				xBrush  * brush        = itr->first->GetSurface(i)->GetBrush();
				xVertex * surfVertices = itr->first->GetSurface(i)->GetVB();
				xTextureAtlas::xAtlasRegion region = _atlas->GetTextureRegion(brush->textures[0].texture, brush->textures[0].frame);
				float atlasWidth  = _atlas->GetWidth();
				float atlasHeight = _atlas->GetHeight();
				float tu0         = float(region.x)      / atlasWidth;
				float tu1         = float(region.width)  / atlasWidth;
				float tv0         = float(region.y)      / atlasHeight;
				float tv1         = float(region.height) / atlasHeight;
				for(int j = 0; j < itr->first->GetSurface(i)->CountVertices(); j++)
				{
					position = worldTForm * xVector(surfVertices[j].x, surfVertices[j].y, surfVertices[j].z);
					vertices[itr->second.offset + verticesOffset + j].x = position.x;
					vertices[itr->second.offset + verticesOffset + j].y = position.y;
					vertices[itr->second.offset + verticesOffset + j].z = position.z;
					position = worldTForm.matrix.Cofactor() * xVector(surfVertices[j].nx, surfVertices[j].ny, surfVertices[j].nz);
					position.Normalize();
					vertices[itr->second.offset + verticesOffset + j].nx = position.x;
					vertices[itr->second.offset + verticesOffset + j].ny = position.y;
					vertices[itr->second.offset + verticesOffset + j].nz = position.z;
					if(region.frame < 0)
					{
						vertices[itr->second.offset + verticesOffset + j].tu1 = 0.0f;
						vertices[itr->second.offset + verticesOffset + j].tv1 = 0.0f;
					}
					else
					{
						vertices[itr->second.offset + verticesOffset + j].tu1 = tu0 + surfVertices[j].tu1 * tu1;
						vertices[itr->second.offset + verticesOffset + j].tv1 = tv0 + surfVertices[j].tv1 * tv1;
					}
					vertices[itr->second.offset + verticesOffset + j].color = (brush->red & 255) + ((brush->green & 255) << 8) + ((brush->blue & 255) << 16) + 0xFF000000;
				}
				verticesOffset += itr->first->GetSurface(i)->CountVertices();
				delete brush;
			}
			// reset flag
			itr->second.update = false;
		}
		itr++;
	}
}

void xEntity::UpdateMD2Mesh()
{
	if(_md2Frames != NULL && (_md2Updated || _md2Cloned))
	{
		int frame1   = _md2LocalTime * 10;
		int frame2   = frame1 + 1;
		float factor = _md2LocalTime * 10.0f - frame1;
		if(frame2 >= _md2Frames[0].length * 10.0f)
		{
			frame2 = 0;
			factor = 0.5f;
		}
		xSurface * surface  = _surfaces[0];
		xVertex  * vertices = surface->GetVB();
		xBox bbox;
		for(int i = 0; i < surface->CountVertices(); i++)
		{
			float x1       = float(_md2Frames[frame1].vertices[i].position[0]) * _md2Frames[frame1].scale.x + _md2Frames[frame1].translate.x;
			float y1       = float(_md2Frames[frame1].vertices[i].position[1]) * _md2Frames[frame1].scale.y + _md2Frames[frame1].translate.y;
			float z1       = float(_md2Frames[frame1].vertices[i].position[2]) * _md2Frames[frame1].scale.z + _md2Frames[frame1].translate.z;
			xVector n1     = md2Normals[_md2Frames[frame1].vertices[i].normalIndex % 162];
			float x2       = float(_md2Frames[frame2].vertices[i].position[0]) * _md2Frames[frame2].scale.x + _md2Frames[frame2].translate.x;
			float y2       = float(_md2Frames[frame2].vertices[i].position[1]) * _md2Frames[frame2].scale.y + _md2Frames[frame2].translate.y;
			float z2       = float(_md2Frames[frame2].vertices[i].position[2]) * _md2Frames[frame2].scale.z + _md2Frames[frame2].translate.z;
			xVector n2     = md2Normals[_md2Frames[frame2].vertices[i].normalIndex % 162];
			vertices[i].x  = x1 + (x2 - x1) * factor;
			vertices[i].y  = y1 + (y2 - y1) * factor;
			vertices[i].z  = z1 + (z2 - z1) * factor;
			vertices[i].nx = n1.y + (n2.y - n1.y) * factor;
			vertices[i].ny = n1.z + (n2.z - n1.z) * factor;
			vertices[i].nz = -(n1.x + (n2.x - n1.x) * factor);
			bbox.Update(xVector(vertices[i].x, vertices[i].y, vertices[i].z));
		}
		surface->SetBoundingBox(bbox);
		_md2Updated = false;
	}
}

void xEntity::RebuildMesh(float time)
{
	if(_rootBone != NULL)
	{
		_rootBone->SetPose(time);
		xTransform worldInversed = GetWorldTransform().Inversed();
		xTransform ** tforms     = _rootBone->GetBonesTransforms(worldInversed);
		for(int i = 0; i < _surfaces.size(); i++)
		{
			xVertex * activeVerts = _surfaces[i]->GetVB();
			xVertex * origVerts   = _surfaces[i]->GetBindPoseVB();
			xVector position;
			for(int j = 0; j < _surfaces[i]->CountVertices(); j++)
			{
				if(origVerts[j].bone1 == 0 && origVerts[j].bone2 == 0 && origVerts[j].bone3 == 0 && origVerts[j].bone4 == 0)
				{
					activeVerts[j].x  = origVerts[j].x;
					activeVerts[j].y  = origVerts[j].y;
					activeVerts[j].z  = origVerts[j].z;
					activeVerts[j].nx = origVerts[j].nx;
					activeVerts[j].ny = origVerts[j].ny;
					activeVerts[j].nz = origVerts[j].nz;
					continue;
				}
				if(origVerts[j].bone1 > 0)
				{
					position = *tforms[origVerts[j].bone1] * xVector(origVerts[j].x, origVerts[j].y, origVerts[j].z);
					activeVerts[j].x  = position.x * origVerts[j].weight1;
					activeVerts[j].y  = position.y * origVerts[j].weight1;
					activeVerts[j].z  = position.z * origVerts[j].weight1;
					position = tforms[origVerts[j].bone1]->matrix.Cofactor() * xVector(origVerts[j].nx, origVerts[j].ny, origVerts[j].nz);
					activeVerts[j].nx = position.x * origVerts[j].weight1;
					activeVerts[j].ny = position.y * origVerts[j].weight1;
					activeVerts[j].nz = position.z * origVerts[j].weight1;
				}
				if(origVerts[j].bone2 > 0)
				{
					position = *tforms[origVerts[j].bone2] * xVector(origVerts[j].x, origVerts[j].y, origVerts[j].z);
					activeVerts[j].x  += position.x * origVerts[j].weight2;
					activeVerts[j].y  += position.y * origVerts[j].weight2;
					activeVerts[j].z  += position.z * origVerts[j].weight2;
					position = tforms[origVerts[j].bone2]->matrix.Cofactor() * xVector(origVerts[j].nx, origVerts[j].ny, origVerts[j].nz);
					activeVerts[j].nx += position.x * origVerts[j].weight2;
					activeVerts[j].ny += position.y * origVerts[j].weight2;
					activeVerts[j].nz += position.z * origVerts[j].weight2;
				}
				if(origVerts[j].bone3 > 0)
				{
					position = *tforms[origVerts[j].bone3] * xVector(origVerts[j].x, origVerts[j].y, origVerts[j].z);
					activeVerts[j].x  += position.x * origVerts[j].weight3;
					activeVerts[j].y  += position.y * origVerts[j].weight3;
					activeVerts[j].z  += position.z * origVerts[j].weight3;
					position = tforms[origVerts[j].bone3]->matrix.Cofactor() * xVector(origVerts[j].nx, origVerts[j].ny, origVerts[j].nz);
					activeVerts[j].nx += position.x * origVerts[j].weight3;
					activeVerts[j].ny += position.y * origVerts[j].weight3;
					activeVerts[j].nz += position.z * origVerts[j].weight3;
				}
				if(origVerts[j].bone4 > 0)
				{
					position = *tforms[origVerts[j].bone4] * xVector(origVerts[j].x, origVerts[j].y, origVerts[j].z);
					float last = 1.0f - origVerts[j].weight1 - origVerts[j].weight2 - origVerts[j].weight3;
					activeVerts[j].x  += position.x * last;
					activeVerts[j].y  += position.y * last;
					activeVerts[j].z  += position.z * last;
					position = tforms[origVerts[j].bone4]->matrix.Cofactor() * xVector(origVerts[j].nx, origVerts[j].ny, origVerts[j].nz);
					activeVerts[j].nx += position.x * last;
					activeVerts[j].ny += position.y * last;
					activeVerts[j].nz += position.z * last;
				}
				position = xVector(activeVerts[j].nx, activeVerts[j].ny, activeVerts[j].nz).Normalized();
				activeVerts[j].nx = position.x;
				activeVerts[j].ny = position.y;
				activeVerts[j].nz = position.z;
			}
		}
	}
	if(GetType() == ENTITY_BONE) ((xBone*)this)->SetPose(time);
	if(_md2Sequences.size() > 0)
	{
		MD2Loader::MD2Frame * md2Frames = _md2Frames == NULL ? _md2Sequences[0] : _md2Frames;
		float localTime = fmodf(time, md2Frames[0].length);
		int frame1      = localTime * 10;
		int frame2      = frame1 + 1;
		float factor    = localTime * 10.0f - frame1;
		if(frame2 >= md2Frames[0].length * 10.0f)
		{
			frame2 = 0;
			factor = 0.5f;
		}
		xSurface * surface  = _surfaces[0];
		xVertex  * vertices = surface->GetVB();
		xBox bbox;
		for(int i = 0; i < surface->CountVertices(); i++)
		{
			float x1       = float(md2Frames[frame1].vertices[i].position[0]) * md2Frames[frame1].scale.x + md2Frames[frame1].translate.x;
			float y1       = float(md2Frames[frame1].vertices[i].position[1]) * md2Frames[frame1].scale.y + md2Frames[frame1].translate.y;
			float z1       = float(md2Frames[frame1].vertices[i].position[2]) * md2Frames[frame1].scale.z + md2Frames[frame1].translate.z;
			xVector n1     = md2Normals[md2Frames[frame1].vertices[i].normalIndex % 162];
			float x2       = float(md2Frames[frame2].vertices[i].position[0]) * md2Frames[frame2].scale.x + md2Frames[frame2].translate.x;
			float y2       = float(md2Frames[frame2].vertices[i].position[1]) * md2Frames[frame2].scale.y + md2Frames[frame2].translate.y;
			float z2       = float(md2Frames[frame2].vertices[i].position[2]) * md2Frames[frame2].scale.z + md2Frames[frame2].translate.z;
			xVector n2     = md2Normals[md2Frames[frame2].vertices[i].normalIndex % 162];
			vertices[i].x  = x1 + (x2 - x1) * factor;
			vertices[i].y  = y1 + (y2 - y1) * factor;
			vertices[i].z  = z1 + (z2 - z1) * factor;
			vertices[i].nx = n1.y + (n2.y - n1.y) * factor;
			vertices[i].ny = n1.z + (n2.z - n1.z) * factor;
			vertices[i].nz = -(n1.x + (n2.x - n1.x) * factor);
			bbox.Update(xVector(vertices[i].x, vertices[i].y, vertices[i].z));
		}
		surface->SetBoundingBox(bbox);
	}	
}

void xEntity::UpdateMD2Animation(float deltaTime)
{
	if(_md2Mode > 0 && _md2Frames != NULL)
	{
		_md2Updated = true;
		float lenght = _md2Frames[0].length;
		_md2Time += deltaTime * _md2Speed;
		if(_md2Mode == 2)
		{
			int loopNum  = _md2Time / lenght;
			_md2Dest = (loopNum + 1) % 2;
		}
		else if(_md2Mode == 3)
		{
			if(_md2Time > lenght || _md2Time < 0.0f)
			{
				_md2LocalTime = _md2Speed >= 0.0f ? lenght : 0.0f;
				_md2Mode      = 0;
				return;
			}
		}
		if(_md2Dest == 0)
		{
			_md2LocalTime = lenght - fmodf(_md2Time, lenght);
		}
		else
		{
			_md2LocalTime = fmodf(_md2Time, lenght);
		}
	}
}

void xEntity::UpdateMD2(float deltaTime)
{
	UpdateMD2Animation(deltaTime);
}

int xEntity::ExtractMD2AnimationSet(int startFrame, int endFrame, int setID)
{
	if(setID < 0 || setID >= _md2Sequences.size()) return -1;
	int result = _md2Sequences.size();
	MD2Loader::MD2Frame * activeSeq = _md2Sequences[setID];
	int lastFrame = activeSeq[0].length * 10.0f;
	if(endFrame > lastFrame) endFrame = lastFrame;
	if(endFrame - startFrame <= 0) return -1;
	MD2Loader::MD2Frame * newFrames = new MD2Loader::MD2Frame[endFrame - startFrame];
	int numVertices = _surfaces[0]->CountVertices();
	for(int i = startFrame; i < endFrame; i++)
	{
		newFrames[i - startFrame] = activeSeq[i];
		newFrames[i - startFrame].vertices = new MD2Loader::MD2Vertex[numVertices];
		memcpy(newFrames[i - startFrame].vertices, activeSeq[i].vertices, numVertices * sizeof(MD2Loader::MD2Vertex));
	}
	return result;
}

void xEntity::Capture()
{
	if(!_visible) return;
	_capturedPosition = _position;
	_capturedScale    = _scale;
	_capturedRotate   = _rotation;
	_capturedAlpha    = GetAlpha();
	_captured         = true;
}

void xEntity::ApplyTweening(float tween)
{
	if(!_captured || tween == 1.0f) return;
	_position = _position.Lerp(_capturedPosition, tween);
	_scale    = _scale.Lerp(_capturedScale,       tween);
	_rotation = _rotation.Slerp(_capturedRotate,  tween);
	SetAlpha((_capturedAlpha - GetAlpha()) * tween);
	_captured = false;
	ForceUpdate();
}

#define ISECT(VV0, VV1, VV2, D0, D1, D2, isect0, isect1) \
isect0 = VV0 + (VV1 - VV0) * D0 / (D0 - D1);             \
isect1 = VV0 + (VV2 - VV0) * D0 / (D0 - D2);

#define SORT(a, b) \
if(a > b)          \
{                  \
	float c;       \
	c = a;         \
	a = b;         \
	b = c;         \
}

#define EDGE_EDGE_TEST(V0, U0, U1)                                         \
Bx = U0[i0] - U1[i0];                                                      \
By = U0[i1] - U1[i1];                                                      \
Cx = V0[i0] - U0[i0];                                                      \
Cy = V0[i1] - U0[i1];                                                      \
f  = Ay * Bx - Ax * By;                                                    \
d  = By * Cx - Bx * Cy;                                                    \
if((f > 0.0f && d >= 0.0f && d <= f) || (f < 0.0f && d <= 0.0f && d >= f)) \
{                                                                          \
	e = Ax * Cy - Ay * Cx;                                                 \
	if(f > 0.0f)                                                           \
	{                                                                      \
		if(e >= 0.0f && e <= f) return true;                               \
	}                                                                      \
	else                                                                   \
	{                                                                      \
		if(e <= 0.0f && e >= f) return true;                               \
	}                                                                      \
}  

#define EDGE_AGAINST_TRI_EDGES(V0, V1, U0, U1, U2) \
{                                                  \
	float Ax, Ay, Bx, By, Cx, Cy, e, d, f;         \
	Ax = V1[i0] - V0[i0];                          \
	Ay = V1[i1] - V0[i1];                          \
	EDGE_EDGE_TEST(V0, U0, U1);                    \
	EDGE_EDGE_TEST(V0, U1, U2);                    \
	EDGE_EDGE_TEST(V0, U2, U0);                    \
}

#define POINT_IN_TRI(V0, U0, U1, U2)    \
{                                       \
	float a, b, c, d0, d1, d2;          \
	a  =  U1[i1] - U0[i1];              \
	b  = -(U1[i0] - U0[i0]);            \
	c  = -a * U0[i0] - b * U0[i1];      \
	d0 =  a * V0[i0] + b * V0[i1] + c;  \
	a  =  U2[i1] - U1[i1];              \
	b  = -(U2[i0] - U1[i0]);            \
	c  = -a * U1[i0] - b * U1[i1];      \
	d1 =  a * V0[i0] + b * V0[i1] + c;  \
	a  =  U0[i1] - U2[i1];              \
	b  = -(U0[i0] - U2[i0]);            \
	c  = -a * U2[i0] - b * U2[i1];      \
	d2 =  a * V0[i0] + b * V0[i1] + c;  \
	if(d0 * d1 > 0.0f)                  \
	{                                   \
		if(d0 * d2 > 0.0f) return true; \
	}                                   \
}

bool xEntity::CoplanarIntersect(xVector n, xVector v0, xVector v1, xVector v2, xVector u0, xVector u1, xVector u2)
{
	float A[3];
	short i0, i1;
	A[0] = fabs(n.x);
	A[1] = fabs(n.y);
	A[2] = fabs(n.z);
	if(A[0] > A[1])
	{
		if(A[0] > A[2])  
		{
			i0 = 1;
			i1 = 2;
		}
		else
		{
			i0 = 0;
			i1 = 1;
		}
	}
	else
	{
		if(A[2] > A[1])
		{
			i0 = 0;
			i1 = 1;                                           
		}
		else
		{
			i0 = 0;
			i1 = 2;
		}
    }
    EDGE_AGAINST_TRI_EDGES(((float*)&v0), ((float*)&v1), ((float*)&u0), ((float*)&u1), ((float*)&u2));
    EDGE_AGAINST_TRI_EDGES(((float*)&v1), ((float*)&v2), ((float*)&u0), ((float*)&u1), ((float*)&u2));
    EDGE_AGAINST_TRI_EDGES(((float*)&v2), ((float*)&v0), ((float*)&u0), ((float*)&u1), ((float*)&u2));
    POINT_IN_TRI(((float*)&v0), ((float*)&u0), ((float*)&u1), ((float*)&u2));
    POINT_IN_TRI(((float*)&u0), ((float*)&v0), ((float*)&v1), ((float*)&v2));
    return false;
}

bool xEntity::TrianglesIntersect(xVector v0, xVector v1, xVector v2, xVector u0, xVector u1, xVector u2)
{
	xVector e1  =  v1 - v0;
	xVector e2  =  v2 - v0;
	xVector n1  =  e1.Cross(e2);
	float   d1  = -n1.Dot(v0);
	float   du0 =  n1.Dot(u0) + d1;
	float   du1 =  n1.Dot(u1) + d1;
	float   du2 =  n1.Dot(u2) + d1;
	if(fabs(du0) < X3DEPSILON) du0 = 0.0f;
	if(fabs(du1) < X3DEPSILON) du1 = 0.0f;
	if(fabs(du2) < X3DEPSILON) du2 = 0.0f;
	float du0du1 = du0 * du1;
	float du0du2 = du0 * du2;
	if(du0du1 > 0.0f && du0du2 > 0.0f) return false;
	e1 = u1 - u0;
	e2 = u2 - u0;
	xVector n2  =  e1.Cross(e2);
	float   d2  = -n2.Dot(u0);
	float   dv0 =  n2.Dot(v0) + d2;
	float   dv1 =  n2.Dot(v1) + d2;
	float   dv2 =  n2.Dot(v2) + d2;
	if(fabs(dv0) < X3DEPSILON) dv0 = 0.0f;
	if(fabs(dv1) < X3DEPSILON) dv1 = 0.0f;
	if(fabs(dv2) < X3DEPSILON) dv2 = 0.0f;
	float dv0dv1 = dv0 * dv1;
	float dv0dv2 = dv0 * dv2;
	if(dv0dv1 > 0.0f && dv0dv2 > 0.0f) return false;
	xVector d   = n1.Cross(n2);
	float max   = fabs(d.x);
	int   index = 0;
	float b     = fabs(d.y);
	float c     = fabs(d.z);
	if(b > max)
	{
		max   = b;
		index = 1;
	}
	if(c > max) 
	{
		max   = c;
		index = 2;
	}
	float vp0 = ((float*)&v0)[index];
	float vp1 = ((float*)&v1)[index];
	float vp2 = ((float*)&v2)[index];
	float up0 = ((float*)&u0)[index];
	float up1 = ((float*)&u1)[index];
	float up2 = ((float*)&u2)[index];
	float isect10, isect11, isect20, isect21;
	if(dv0dv1 > 0.0f)
	{
		ISECT(vp2, vp0, vp1, dv2, dv0, dv1, isect10, isect11);
	}
	else if(dv0dv2 > 0.0f)
	{
		ISECT(vp1, vp0, vp2, dv1, dv0, dv2, isect10, isect11);
	}
	else if(dv1 * dv2 > 0.0f || dv0 != 0.0f)
	{
		ISECT(vp0, vp1, vp2, dv0, dv1, dv2, isect10, isect11);
	}
	else if(dv1 != 0.0f)
	{
		ISECT(vp1, vp0, vp2, dv1, dv0, dv2, isect10, isect11);
	}
	else if(dv2 != 0.0f)
	{
		ISECT(vp2, vp0, vp1, dv2, dv0, dv1, isect10, isect11);
	}
	else
	{
		return CoplanarIntersect(n1, v0, v1, v2, u0, u1, u2);
	}
	if(du0du1 > 0.0f)
	{
		ISECT(up2, up0, up1, du2, du0, du1, isect20, isect21);
	}
	else if(du0du2 > 0.0f)
	{
		ISECT(up1, up0, up2, du1, du0, du2, isect20, isect21);
	}
	else if(du1 * du2 > 0.0f || du0 != 0.0f)
	{
		ISECT(up0, up1, up2, du0, du1, du2, isect20, isect21);
	}
	else if(dv1 != 0.0f)
	{
		ISECT(up1, up0, up2, du1, du0, du2, isect20, isect21);
	}
	else if(dv2 != 0.0f)
	{
		ISECT(up2, up0, up1, du2, du0, du1, isect20, isect21);
	}
	else
	{
		return CoplanarIntersect(n1, v0, v1, v2, u0, u1, u2);
	}
	SORT(isect10, isect11);
	SORT(isect20, isect21);
	if(isect11 < isect20 || isect21 < isect10) return false;
	return true;
}

bool xEntity::MeshesIntersect(xEntity * other)
{
	xTransform world1 = GetWorldTransform();
	xTransform world2 = other->GetWorldTransform();
	for(int i = 0; i < CountSurfaces(); i++)
	{
		xSurface * surface1   = GetSurface(i);
		xVertex  * vertices1  = surface1->GetVB();
		ushort   * triangles1 = surface1->GetIB();
		xBox       bbox1      = world1 * surface1->GetBoundingBox();
		for(int j = 0; j < other->CountSurfaces(); j++)
		{
			xSurface * surface2   = other->GetSurface(j);
			xVertex  * vertices2  = surface2->GetVB();
			ushort   * triangles2 = surface2->GetIB();
			xBox       bbox2      = world2 * surface2->GetBoundingBox();
			if(!bbox1.Overlaps(bbox2)) continue;
			for(int t1 = 0; t1 < surface1->CountTriangles(); t1++)
			{
				for(int t2 = 0; t2 < surface2->CountTriangles(); t2++)
				{
					int vi0    = triangles1[t1 * 3 + 0];
					int vi1    = triangles1[t1 * 3 + 1];
					int vi2    = triangles1[t1 * 3 + 2];
					int ui0    = triangles2[t2 * 3 + 0];
					int ui1    = triangles2[t2 * 3 + 1];
					int ui2    = triangles2[t2 * 3 + 2];
					xVector v0 = world1 * (*((xVector*)&vertices1[vi0].x));
					xVector v1 = world1 * (*((xVector*)&vertices1[vi1].x));
					xVector v2 = world1 * (*((xVector*)&vertices1[vi2].x));
					xVector u0 = world2 * (*((xVector*)&vertices2[ui0].x));
					xVector u1 = world2 * (*((xVector*)&vertices2[ui1].x));
					xVector u2 = world2 * (*((xVector*)&vertices2[ui2].x));
					if(TrianglesIntersect(v0, v1, v2, u0, u1, u2)) return true;
				}
			}
		}
	}
	return false;
}

void xEntity::SetUserData(void * data)
{
	_userData = data;
}

void * xEntity::GetUserData()
{
	return _userData;
}

void xEntity::SetAlphaFunc(int func)
{
	_alphaFunc = func;
	if(_alphaFunc < 0) _alphaRef = 0;
	if(_alphaFunc > 7) _alphaRef = 7;
	for(int i = 0; i < CountSurfaces(); i++)
	{
		GetSurface(i)->SetAlphaFunc(_alphaFunc);
	}
}

void xEntity::SetAlphaRef(float reference)
{
	_alphaRef = reference;
	if(_alphaRef < 0.0f) _alphaRef = 0.0f;
	if(_alphaRef > 1.0f) _alphaRef = 1.0f;
	for(int i = 0; i < CountSurfaces(); i++)
	{
		GetSurface(i)->SetAlphaRef(_alphaRef);
	}
}

int xEntity::GetAlphaFunc()
{
	return _alphaFunc;
}

float xEntity::GetAlphaRef()
{
	return _alphaRef;
}

void xEntity::SetAtlasFlags(int flags)
{
	_atlasFlags = flags;
}