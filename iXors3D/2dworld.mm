//
//  2dworld.mm
//  iXors3D
//
//  Created by Knightmare on 8/2/10.
//  Copyright 2010 XorsTeam. All rights reserved.
//

#import "2dworld.h"

x2DWorld * x2DWorld::_instance = NULL;

x2DWorld::x2DWorld()
{
	_cameraX = 0;
	_cameraY = 0;
}

x2DWorld::x2DWorld(const x2DWorld & other)
{
}

x2DWorld & x2DWorld::operator=(const x2DWorld & other)
{
	return *this;
}

x2DWorld::~x2DWorld()
{
}

x2DWorld * x2DWorld::Instance()
{
	if(_instance == NULL) _instance = new x2DWorld();
	return _instance;
}

void x2DWorld::Render()
{
	for(int i = 0; i < _images.size(); i++)
	{
		if(_images[i]->image != NULL)
		{
			float oldAngle = _images[i]->image->GetAngle();
			float oldHX    = _images[i]->image->GetXHandle();
			float oldHY    = _images[i]->image->GetYHandle();
			float x        = _images[i]->body->GetPositionX();
			float y        = _images[i]->body->GetPositionY();
			float angle    = _images[i]->body->GetRotation();
			_images[i]->image->MidHandle();
			_images[i]->image->SetRotate(angle);
			_images[i]->image->Draw(x - _cameraX, y - _cameraY, _images[i]->frame);
			_images[i]->image->SetRotate(oldAngle);
			_images[i]->image->SetHandle(oldHX, oldHY);
		}
	}
}

void x2DWorld::AssignImage(IBody2D * shape, xImage * image, int frame)
{
	std::vector<RenderPair*>::iterator itr = FindNode(shape);
	if(itr != _images.end())
	{
		(*itr)->image = image;
		(*itr)->frame = frame;
		return;
	}
	RenderPair * pair = new RenderPair();
	pair->body  = shape;
	pair->image = image;
	pair->order = 0;
	pair->frame = frame;
	_images.push_back(pair);
	int i = _images.size() - 1;
	while(i > 0 && _images[i]->order < _images[i - 1]->order)
	{
		std::swap(_images[i], _images[i - 1]);
		--i;
	}
}

void x2DWorld::Clear()
{
	for(int i = 0; i < _images.size(); i++)
	{
		delete _images[i];
	}
	_images.clear();
}

std::vector<x2DWorld::RenderPair*>::iterator x2DWorld::FindNode(IBody2D * shape)
{
	std::vector<RenderPair*>::iterator itr = _images.begin();
	while(itr != _images.end())
	{
		if((*itr)->body == shape) return itr;
		itr++;
	}
	return _images.end();
}

void x2DWorld::SetImageFrame(IBody2D * shape, int frame)
{
	std::vector<RenderPair*>::iterator itr = FindNode(shape);
	if(itr != _images.end())
	{
		(*itr)->frame = frame;
	}
}

void x2DWorld::SetImageOrder(IBody2D * shape, int order)
{
	std::vector<RenderPair*>::iterator itr = FindNode(shape);
	if(itr != _images.end())
	{
		RenderPair * pair = *itr;
		_images.erase(itr);
		pair->order = order;
		_images.push_back(pair);
		int i = _images.size() - 1;
		while(i > 0 && _images[i]->order < _images[i - 1]->order)
		{
			std::swap(_images[i], _images[i - 1]);
			--i;
		}		
	}
}

void x2DWorld::DeleteBody(IBody2D * shape)
{
	std::vector<RenderPair*>::iterator itr = FindNode(shape);
	if(itr != _images.end())
	{
		delete *itr;
		_images.erase(itr);
	}
}

void x2DWorld::SetCameraPosition(int x, int y)
{
	_cameraX = x;
	_cameraY = y;
}

int x2DWorld::GetCameraX()
{
	return _cameraX;
}

int x2DWorld::GetCameraY()
{
	return _cameraY;
}