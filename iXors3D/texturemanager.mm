//
//  texturemanager.mm
//  iXors3D
//
//  Created by Fadeev 'Knightmare' Dmitry on 10/26/10.
//  Copyright 2010 XorsTeam. All rights reserved.
//

#import "texturemanager.h"
#import "filesystem.h"

xTextureManager * xTextureManager::_instance = NULL;

xTextureManager::xTextureManager()
{
}

xTextureManager::xTextureManager(const xTextureManager & other)
{
}

const xTextureManager & xTextureManager::operator=(const xTextureManager & other)
{
	return *this;
}

xTextureManager::~xTextureManager()
{
}

xTextureManager * xTextureManager::Instance()
{
	if(_instance == NULL) _instance = new xTextureManager();
	return _instance;
}

xTextureManager::LoadedTextureIterator xTextureManager::FindTexture(const char * path, int flags)
{
	LoadedTextureIterator itr = _loaded.begin();
	while(itr != _loaded.end())
	{
		if(strcasecmp((*itr)->filePath.c_str(), path) == 0 && (*itr)->flags == flags)
		{
			return itr;
		}
		itr++;
	}
	return _loaded.end();
}

xTextureManager::LoadedTextureIterator xTextureManager::FindAnimatedTexture(const char * path, int flags, int frameWidth, int frameHeight, int firstFrame, int frameCount)
{
	LoadedTextureIterator itr = _loadedAnimated.begin();
	while(itr != _loadedAnimated.end())
	{
		if(strcasecmp((*itr)->filePath.c_str(), path) == 0 && (*itr)->flags == flags)
		{
			if((*itr)->width == frameWidth && (*itr)->height == frameHeight)
			{
				if((*itr)->startFrame == firstFrame && (*itr)->totalFrames == frameCount)
				{
					return itr;
				}
			}
		}
		itr++;
	}
	return _loadedAnimated.end();
}

xTextureManager::TextureIterator xTextureManager::FindCreatedTexture(xTexture * texture)
{
	return find(_created.begin(), _created.end(), texture);
}

xTextureManager::LoadedTextureIterator xTextureManager::FindTexture(xTexture::TextureBuffer * texture)
{
	LoadedTextureIterator itr = _loaded.begin();
	while(itr != _loaded.end())
	{
		if((*itr)->buffer == texture) return itr;
		itr++;
	}
	return _loaded.end();
}

xTextureManager::LoadedTextureIterator xTextureManager::FindAnimatedTexture(xTexture::TextureBuffer * texture)
{
	LoadedTextureIterator itr = _loadedAnimated.begin();
	while(itr != _loadedAnimated.end())
	{
		if((*itr)->buffer == texture) return itr;
		itr++;
	}
	return _loadedAnimated.end();
}

xTexture * xTextureManager::LoadTexture(const char * path, int flags)
{
	LoadedTextureIterator itr = FindTexture(path, flags);
	if(itr != _loaded.end())
	{
		(*itr)->buffer->Retain();
		return new xTexture((*itr)->buffer);
	}
	TextureData * newTexture = new TextureData();
	newTexture->filePath = path;
	newTexture->flags    = flags;
	xTexture * texture   = new xTexture();
	if(!texture->Load(path, flags))
	{
		delete texture;
		delete newTexture;
		return NULL;
	}
	newTexture->buffer = texture->GetBufferObject();
	_loaded.push_back(newTexture);
	return texture;
}

xTexture * xTextureManager::LoadAnimTexture(const char * path, int flags, int frameWidth, int frameHeight, int firstFrame, int frameCount)
{
	LoadedTextureIterator itr = FindAnimatedTexture(path, flags, frameWidth, frameHeight, firstFrame, frameCount);
	if(itr != _loadedAnimated.end())
	{
		(*itr)->buffer->Retain();
		return new xTexture((*itr)->buffer);
	}
	TextureData * newTexture = new TextureData();
	newTexture->filePath     = path;
	newTexture->flags        = flags;
	newTexture->height       = frameHeight;
	newTexture->width        = frameWidth;
	newTexture->startFrame   = firstFrame;
	newTexture->totalFrames  = frameCount;
	xTexture * texture       = new xTexture();
	if(!texture->LoadAnimated(path, flags, frameWidth, frameHeight, firstFrame, frameCount))
	{
		delete texture;
		delete newTexture;
		return NULL;
	}
	newTexture->buffer = texture->GetBufferObject();
	_loadedAnimated.push_back(newTexture);
	return texture;
}

xTexture * xTextureManager::CreateTexture(int width, int height, int flags, int frames)
{
	xTexture * newTexture = new xTexture();
	if(!newTexture->Create(width, height, flags, frames))
	{
		delete newTexture;
		return NULL;
	}
	_created.push_back(newTexture);
	return newTexture;
}

void xTextureManager::Clear()
{
	for(int i = 0; i < _loaded.size(); i++)
	{
		_loaded[i]->buffer->Release();
		delete _loaded[i]->buffer;
		delete _loaded[i];
	}
	_loaded.clear();
	for(int i = 0; i < _loadedAnimated.size(); i++)
	{
		_loadedAnimated[i]->buffer->Release();
		delete _loadedAnimated[i]->buffer;
		delete _loadedAnimated[i];
	}
	_loadedAnimated.clear();
	for(int i = 0; i < _created.size(); i++)
	{
		_created[i]->Release();
		delete _created[i];
	}
	_created.clear();
}

void xTextureManager::ReleaseTexture(xTexture * texture)
{
	if(texture == NULL) return;
	bool created = texture->CreatedTexture();
	texture->Release();
	if(texture->GetCounter() < 1)
	{
		if(created)
		{
			TextureIterator itr = FindCreatedTexture(texture);
			if(itr != _created.end()) _created.erase(itr);
		}
		delete texture;
	}
}

void xTextureManager::ReleaseBuffer(void * buffer)
{
	LoadedTextureIterator itr = FindTexture((xTexture::TextureBuffer*)buffer);
	if(itr != _loaded.end())
	{
		_loaded.erase(itr);
		return;
	}
	itr = FindAnimatedTexture((xTexture::TextureBuffer*)buffer);
	if(itr != _loadedAnimated.end())
	{
		_loadedAnimated.erase(itr);
		return;
	}
}

void xTextureManager::SetTexturePath(const char * path)
{
	_texturePath = path;
}

const char * xTextureManager::GetTexturePath()
{
	return _texturePath.c_str();
}