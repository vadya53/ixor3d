//
//  textureatlas.mm
//  iXors3D
//
//  Created by Knightmare on 7/3/10.
//  Copyright 2010 XorsTeam. All rights reserved.
//

#import "textureatlas.h"

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

xTextureAtlas::xAtlasRegion::xAtlasRegion(int _x, int _y, int _w, int _h, CGImageRef _texture, int _frame)
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
	if(_atlasTexture != NULL) CGImageRelease(_atlasTexture);
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

bool xTextureAtlas::AddTexture(CGImageRef texture, int frame)
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
	xAtlasRegion region(0, 0, CGImageGetWidth(texture), CGImageGetHeight(texture), texture, frame);
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
		if(!newAtlas->AddAtEmptySpotAutoGrow(&oldRegions[i], 1024, 1024))
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
	//_updated   = true;
	//return AddAtEmptySpotAutoGrow(&region, 1024, 1024);
}

xTextureAtlas::xAtlasRegion xTextureAtlas::GetTextureRegion(CGImageRef texture, int frame)
{
	for(int i = 0; i < _regions.size(); i++)
	{
		if(_regions[i].texture == texture && _regions[i].frame == frame) return _regions[i];
	}
	return xAtlasRegion(0, 0, CGImageGetWidth(texture), CGImageGetHeight(texture), texture, -1);
}

CGImageRef xTextureAtlas::GetTexture()
{
	if(_updated) RebuildTexture();
	return _atlasTexture;
}

void xTextureAtlas::RebuildTexture()
{
	// compute scaling
	int textureWidth  = _size.width;
	int textureHeight = _size.height;
	// create texture
	if(_atlasTexture != NULL) CGImageRelease(_atlasTexture);
	if(textureWidth == 0 || textureHeight == 0)
	{
		_atlasTexture = NULL;
		_updated      = false;
		return;
	}
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	uint * pixels              = (uint*)malloc(textureWidth * textureHeight * 4);
	CGContextRef context       = CGBitmapContextCreate(pixels, textureWidth, textureHeight, 
													   8, 4 * textureWidth, colorSpace, 
													   kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	CGContextClearRect(context, CGRectMake(0, 0, textureWidth, textureHeight));
	for(int i = 0; i < _regions.size(); i++)
	{
		CGRect rect = CGRectMake(_regions[i].x, _regions[i].y, _regions[i].width, _regions[i].height);
		CGContextDrawImage(context, rect, _regions[i].texture);
	}
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, pixels, textureWidth * textureHeight * 4, NULL);
	_atlasTexture = CGImageCreate(textureWidth, textureHeight, 8, 32, 4 * textureWidth, 
								  colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big,
								  provider, NULL, false, kCGRenderingIntentDefault);
	CGColorSpaceRelease(colorSpace);
	CGContextRelease(context);
	_updated = false;
}

void xTextureAtlas::DeleteTexture(CGImageRef texture, int frame)
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
		AddAtEmptySpotAutoGrow(&oldRegions[i], 1024, 1024);
	}
	_updated = true;
}