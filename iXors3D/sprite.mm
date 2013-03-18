//
//  sprite.mm
//  iXors3D
//
//  Created by Knightmare on 15.10.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import "sprite.h"
#import "camera.h"

xSprite::xSprite()
{
	_angle    = 0.0f;
	_scalex   = 1.0f;
	_scaley   = 1.0f;
	_offsetx  = 0.0f;
	_offsety  = 0.0f;
	_viewMode = 1;
	// create surface for sprite
	xSurface * newSurface = CreateSurface(NULL);
	// create geometry
	newSurface->AddVertex(-1.0f,  1.0f, 0.0f, 0.0f, 0.0f);
	newSurface->AddVertex( 1.0f,  1.0f, 0.0f, 1.0f, 0.0f);
	newSurface->AddVertex(-1.0f, -1.0f, 0.0f, 0.0f, 1.0f);
	newSurface->AddVertex( 1.0f, -1.0f, 0.0f, 1.0f, 1.0f);
	newSurface->AddTriangle(2, 1, 0);
	newSurface->AddTriangle(2, 3, 1);
	// set 'fullbright' as default FX flag
	SetFXFlags(1);
	// set type
	_type = ENTITY_SPRITE;
}

xEntity * xSprite::Clone(xEntity * parent, bool cloneGeom)
{
	xSprite * newEntity = new xSprite();
	newEntity->SetParent(parent);
	newEntity->_name = _name;
	newEntity->_masterBrush.Copy(&_masterBrush);
	newEntity->SetPickMode(_pickMode);
	newEntity->_angle    = _angle;
	newEntity->_scalex   = _scalex;
	newEntity->_scaley   = _scaley;
	newEntity->_offsetx  = _offsetx;
	newEntity->_offsety  = _offsety;
	newEntity->_viewMode = _viewMode;
	xBrush * brush = GetSurface(0)->GetBrush();
	newEntity->GetSurface(0)->ApplyBrush(brush);
	delete brush;
	for(int i = 0; i < CountChilds(); i++) GetChild(i)->Clone(newEntity, cloneGeom);
	return newEntity;
}

void xSprite::SetOffset(float x, float y)
{
	_offsetx = x;
	_offsety = y;
}

void xSprite::SetScale(float x, float y)
{
	_scalex = x;
	_scaley = y;
}

void xSprite::SetRotation(float angle)
{
	_angle = angle;
}

void xSprite::SetViewMode(int mode)
{
	_viewMode = mode;
}

void xSprite::UpdateSurface()
{
	xTransform transform = GetWorldTransform();
	if(_viewMode == 1)
	{
		transform.matrix = xRender::Instance()->GetActiveCamera()->GetWorldTransform().matrix;
	}
	else if(_viewMode == 3)
	{
		transform.matrix.k = xRender::Instance()->GetActiveCamera()->GetWorldTransform().matrix.k;
		transform.matrix.Orthogonalize();
	}
	else if(_viewMode == 4)
	{
		xMatrix matrix   = xRender::Instance()->GetActiveCamera()->GetWorldTransform().matrix;
		transform.matrix = YawMatrix(MatrixYaw(matrix)) * transform.matrix;
	}
	transform.matrix = transform.matrix * RollMatrix(_angle) * ScaleMatrix(_scalex, _scaley, 1.0f);
	xVector vertex;
	xSurface * surface = GetSurface(0);
	vertex = transform * xVector(-1.0f - _offsetx,  1.0f - _offsety, 0.0f);
	surface->VertexCoords(0, vertex.x, vertex.y, vertex.z);
	vertex = transform * xVector( 1.0f - _offsetx,  1.0f - _offsety, 0.0f);
	surface->VertexCoords(1, vertex.x, vertex.y, vertex.z);
	vertex = transform * xVector(-1.0f - _offsetx, -1.0f - _offsety, 0.0f);
	surface->VertexCoords(2, vertex.x, vertex.y, vertex.z);
	vertex = transform * xVector( 1.0f - _offsetx, -1.0f - _offsety, 0.0f);
	surface->VertexCoords(3, vertex.x, vertex.y, vertex.z);
}
