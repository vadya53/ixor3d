//
//  textureatlas.mm
//  iXors3D
//
//  Created by Knightmare on 7/3/10.
//  Copyright 2010 XorsTeam. All rights reserved.
//

#import "textureatlas.h"
#import "render.h"

bool __x3dDebugAtlases = false;

xTextureAtlas::xAtlasPosition::xAtlasPosition()
{
}

xTextureAtlas::xAtlasPosition::xAtlasPosition(int _x, int _y)
{
	x = _x;
	y = _y;
}

bool xTextureAtlas::xAtlasPosition::operator ==(const xAtlasPosition & position) const
{
	return x == position.x && y == position.y;
}

xTextureAtlas::xAtlasRegion::xAtlasRegion()
{
	x       = 0;
	y       = 0;
	width   = 0;
	height  = 0;
	texture = NULL;
	frame   = 0;
	counter = 1;
}

xTextureAtlas::xAtlasRegion::xAtlasRegion(int _x, int _y, int _w, int _h, xTexture * _texture, int _frame)
{
	x       = _x;
	y       = _y;
	width   = _w > 0 ? _w : 0;
	height  = _h > 0 ? _h : 0;
	texture = _texture;
	frame   = _frame;
	counter = 1;
}

bool xTextureAtlas::xAtlasRegion::Contains(const xAtlasPosition & position) const
{
	return position.x >= x && position.y >= y
		&& position.x < (x + width) && position.y < (y + height);
}

bool xTextureAtlas::xAtlasRegion::Contains(const xAtlasRegion & region) const
{
	return region.x >= x && region.y >= y && (region.x + region.width) <= (x + width)
		&& (region.y + region.height) <= (y + height);
}

bool xTextureAtlas::xAtlasRegion::Intersects(const xAtlasRegion & region) const
{
	return width > 0 && height > 0 && region.width > 0 && region.height > 0
		&& (region.x + region.width) > x && region.x < (x + width)
		&& (region.y + region.height) > y && region.y < (y + height);
}

bool xTextureAtlas::xAtlasRegion::Greater(const xAtlasRegion & first, const xAtlasRegion & second)
{
	return (first.width > second.width && first.width > second.height)
		|| (first.height > second.width && first.height > second.height);
}

xTextureAtlas::xTextureAtlas()
{
	_atlasTexture = NULL;
	Initialize();
}

xTextureAtlas::~xTextureAtlas()
{
	Release();
}

void xTextureAtlas::Initialize(int width, int height)
{
	Release();
	_size         = xAtlasRegion(0, 0, width, height, NULL, 0);
	_updated      = false;
	_atlasTexture = NULL;
	_positions.push_back(xAtlasPosition(0, 0));
}

void xTextureAtlas::Release()
{
	_positions.clear();
	_regions.clear();
	_size.width  = 0;
	_size.height = 0;
	_updated     = false;
	if(_atlasTexture != NULL)
	{
		_atlasTexture->ForceRelease();
		delete _atlasTexture;
	}
	_atlasTexture = NULL;
}

bool xTextureAtlas::IsFree(const xAtlasRegion & region) const
{
	if(!_size.Contains(region)) return false;
	std::vector<xAtlasRegion>::const_iterator itr;
	for(itr = _regions.begin(); itr != _regions.end(); ++itr)
	{
		if(itr->Intersects(region)) return false;
	}
	return true;
}

void xTextureAtlas::AddPosition(const xAtlasPosition & position)
{
	bool found = false;
	std::vector<xAtlasPosition>::iterator itr;
	for(itr = _positions.begin(); !found && itr != _positions.end(); ++itr)
	{
		if(position.x + position.y < itr->x + itr->y) found = true;
	}
	if(found)
	{
		_positions.insert(itr, position);
	}
	else
	{
		_positions.push_back(position);
	}
}

void xTextureAtlas::AddRegion(const xAtlasRegion & region)
{
	_regions.push_back(region);
	AddPosition(xAtlasPosition(region.x,                region.y + region.height));
	AddPosition(xAtlasPosition(region.x + region.width, region.y));
}

bool xTextureAtlas::AddAtEmptySpot(xAtlasRegion & region)
{
	bool found = false;
	std::vector<xAtlasPosition>::iterator itr;
	for(itr = _positions.begin(); !found && itr != _positions.end(); ++itr)
	{
		xAtlasRegion rect(itr->x, itr->y, region.width, region.height, region.texture, region.frame);
		if(IsFree(rect))
		{
			region = rect;
			found  = true;
			break;
		}
	}
	if(found)
	{
		_positions.erase(itr);
		int x, y;
		for(x = 1; x <= region.x; x++)
		{
			if(!IsFree(xAtlasRegion(region.x - x, region.y, region.width, region.height, region.texture, region.frame))) break;
		}
		for(y = 1; y <= region.y; y++)
		{
			if(!IsFree(xAtlasRegion(region.x, region.y - y, region.width, region.height, region.texture, region.frame))) break;
		}
		if(y > x) 
		{
			region.y -= y - 1;
		}
		else
		{
			region.x -= x - 1;
		}
		AddRegion(region);
	}
	return found;
}

bool xTextureAtlas::Validate() const
{
	return _size.width > 0;
}

int xTextureAtlas::GetWidth() const
{
	return _size.width;
}

int xTextureAtlas::GetHeight() const
{
	return _size.height;
}

bool xTextureAtlas::AddAtEmptySpotAutoGrow(xAtlasRegion * region, int maxWidth, int maxHeight)
{
	if(region->width <= 0) return true;
	int orginalWidth  = _size.width;
	int orginalHeight = _size.height;
	while(!AddAtEmptySpot(*region))
	{
		int pw = _size.width;
		int ph = _size.height;
		if(pw >= maxWidth && ph >= maxHeight)
		{
			_size.width  = orginalWidth;
			_size.height = orginalHeight;
			return false;
		}
		if(pw < maxWidth && (pw < ph || ((pw == ph) && (region->width >= region->height))))
		{
			_size.width = pw * 2;
		}
		else
		{
			_size.height = ph * 2;
		}
		if(AddAtEmptySpot(*region)) break;
		if(pw != _size.width)
		{
			_size.width = pw;
			if(ph < maxWidth) _size.height = ph * 2;
		}
		else
		{
			_size.height = ph;
			if(pw < maxWidth) _size.width  = pw * 2;
		}
		if(pw != _size.width || ph != _size.height)
		{
			if(AddAtEmptySpot(*region)) break;
		}
		_size.width  = pw;
		_size.height = ph;
		if(pw < maxWidth)  _size.width  = pw * 2;
		if(ph < maxHeight) _size.height = ph * 2;
	}
	return true;
}

bool xTextureAtlas::AddTexture(xTexture * texture, int frame, int maxSize)
{
	if(texture == NULL || frame < 0) return false;
	for(int i = 0; i < _regions.size(); i++)
	{
		if(_regions[i].texture == texture && _regions[i].frame == frame)
		{
			_regions[i].counter++;
			return true;
		}
	}
	xAtlasRegion region(0, 0, texture->GetWidth(), texture->GetHeight(), texture, frame);
	std::vector<xAtlasRegion> oldRegions(_regions);
	std::vector<xAtlasRegion>::iterator itr = oldRegions.begin();
	while(itr != oldRegions.end())
	{
		if(((*itr).width * (*itr).height) < (region.width * region.height))
		{
			break;
		}
		itr++;
	}
	oldRegions.insert(itr, region);
	bool success = true;
	xTextureAtlas * newAtlas = new xTextureAtlas();
	newAtlas->Initialize();
	for(int i = 0; i < oldRegions.size(); i++)
	{
		if(!newAtlas->AddAtEmptySpotAutoGrow(&oldRegions[i], maxSize, maxSize))
		{
			success = false;
			break;
		}
	}
	if(!success)
	{
		delete newAtlas;
		return false;
	}
	_updated   = true;
	_regions   = newAtlas->_regions;
	_size      = newAtlas->_size;
	_positions = newAtlas->_positions;
	delete newAtlas;
	return true;
	/*
	if(texture == NULL || frame < 0) return false;
	for(int i = 0; i < _regions.size(); i++)
	{
		if(_regions[i].texture == texture && _regions[i].frame == frame)
		{
			_regions[i].counter++;
			return true;
		}
	}
	xAtlasRegion region(0, 0, texture->GetWidth(), texture->GetHeight(), texture, frame);
	_updated = true;
	return AddAtEmptySpotAutoGrow(&region, maxSize, maxSize);
	*/
}

xTextureAtlas::xAtlasRegion xTextureAtlas::GetTextureRegion(xTexture * texture, int frame)
{
	for(int i = 0; i < _regions.size(); i++)
	{
		if(_regions[i].texture == texture && _regions[i].frame == frame) return _regions[i];
	}
	if(texture == NULL) return xAtlasRegion(0, 0, 1, 1, texture, -1);
	return xAtlasRegion(0, 0, texture->GetWidth(), texture->GetHeight(), texture, -1);
}

xTexture * xTextureAtlas::GetTexture()
{
	if(_updated) RebuildTexture();
	return _atlasTexture;
}

void xTextureAtlas::RebuildTexture()
{
	// compute scaling
	float scaleX      = 1.0f;
	float scaleY      = 1.0f;
	int textureWidth  = _size.width;
	int textureHeight = _size.height;
	if(textureWidth > xRender::Instance()->GetMaxTextureSize())
	{
		scaleX       = float(xRender::Instance()->GetMaxTextureSize()) / float(_size.width);
		textureWidth = xRender::Instance()->GetMaxTextureSize();
	}
	if(textureHeight > xRender::Instance()->GetMaxTextureSize())
	{
		scaleY        = float(xRender::Instance()->GetMaxTextureSize()) / float(_size.height);
		textureHeight = xRender::Instance()->GetMaxTextureSize();
	}
	// create texture
	if(_atlasTexture != NULL)
	{
		_atlasTexture->ForceRelease();
		delete _atlasTexture;
	}
	if(textureWidth <= 1 || textureHeight <= 1)
	{
		_atlasTexture = NULL;
		_updated      = false;
		return;
	}
	int * pixels = NULL;
	if(__x3dDebugAtlases) pixels = new int[textureWidth * textureHeight];
	_atlasTexture = new xTexture();
	_atlasTexture->Create(1 + 8, textureWidth, textureHeight, 1);
	_atlasTexture->Lock(0);
	for(int i = 0; i < _regions.size(); i++)
	{
		_regions[i].texture->Lock(_regions[i].frame);
		for(int x = 0; x < _regions[i].texture->GetWidth(); x++)
		{
			for(int y = 0; y < _regions[i].texture->GetHeight(); y++)
			{
				int tx = (_regions[i].x + x) * scaleX;
				int ty = (_regions[i].y + y) * scaleY;
				if(tx >= 0 && tx < textureWidth && ty >= 0 && ty < textureHeight)
				{
					GLuint color = _regions[i].texture->ReadPixel(x, y, _regions[i].frame);
					if(__x3dDebugAtlases) pixels[ty * textureWidth + tx] = color;
					_atlasTexture->WritePixel(tx, ty, color, 0);
				}
			}
		}
		_regions[i].texture->Unlock(_regions[i].frame);
	}
	_atlasTexture->Unlock(0);
#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
	if(__x3dDebugAtlases)
	{
		CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, pixels, textureWidth * textureHeight * 4, NULL);
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CGImageRef cgImage = CGImageCreate(textureWidth, textureHeight,
										   8, 32, textureWidth * 4,
										   colorSpace, kCGImageAlphaLast | kCGBitmapByteOrder32Big,
										   provider, NULL, false, kCGRenderingIntentDefault);
		UIImage * uiImage = [UIImage imageWithCGImage: cgImage];
		UIImageWriteToSavedPhotosAlbum(uiImage, NULL, NULL, NULL);
		//CGDataProviderRelease(provider);
		//CGImageRelease(cgImage);
		//CGColorSpaceRelease(colorSpace);
		//delete [] pixels;
	}
#endif
	_updated = false;
}

void xTextureAtlas::DeleteTexture(xTexture * texture, int frame, int maxSize)
{
	std::vector<xAtlasRegion> oldRegions(_regions);
	Release();
	Initialize();
	for(int i = 0; i < oldRegions.size(); i++)
	{
		if(oldRegions[i].texture == texture && oldRegions[i].frame == frame)
		{
			oldRegions[i].counter--;
			if(oldRegions[i].counter == 0) continue;
		}
		AddAtEmptySpotAutoGrow(&oldRegions[i], maxSize, maxSize);
	}
	_updated = true;
}

void xTextureAtlas::EnableDebug(bool flag)
{
	__x3dDebugAtlases = flag;
}

void xTextureAtlas::SetTexture(xTexture * texture)
{
	_atlasTexture = texture;
	_updated      = false;
	_size.width   = _atlasTexture->GetWidth();
	_size.height  = _atlasTexture->GetHeight();
}

void xTextureAtlas::AddRegion(xTexture * texture, int frame, int x, int y, int width, int height)
{
	_regions.push_back(xAtlasRegion(x, y, width, height, texture, frame));
}