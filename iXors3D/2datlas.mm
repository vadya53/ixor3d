//
//  2datlas.mm
//  iXors3D
//
//  Created by Fadeev 'Knightmare' Dmitry on 9/6/10.
//  Copyright 2010 XorsTeam. All rights reserved.
//

#import "2datlas.h"
#import <algorithm>
#import "filesystem.h"

x2DAtlas::x2DAtlas()
{
	_atlas = new xTextureAtlas();
	_atlas->Initialize();
	_generated = false;
}

x2DAtlas::~x2DAtlas()
{
}

bool x2DAtlas::Load(const char * path)
{
	if(_generated) return false;
	FILE * input = fopen(xFileSystem::Instance()->GetRealPath(path).c_str(), "r");
	if(input == NULL)
	{
		printf("ERROR(%s:%i): Unable to open atlas from file '%s'.\n", __FILE__, __LINE__, path);
		return false;
	}
	fseek(input, 0, SEEK_END);
	unsigned int length = ftell(input);
	fseek(input, 0, SEEK_SET);
	char header[4];
	fread(header, 1, 4, input);
	if(header[0] != 'X' || header[1] != '3' || header[2] != 'D' || header[3] != 'A')
	{
		printf("ERROR(%s:%i): File '%s' is not a valid atlas.\n", __FILE__, __LINE__, path);
		fclose(input);
		return false;
	}
	int imagesCount;
	fread(&imagesCount, 4, 1, input);
	for(int i = 0; i < imagesCount; i++)
	{
		std::string name;
		int width, height, frames;
		char symbol = fgetc(input);
		while(symbol != '\0')
		{
			name   += symbol;
			symbol  = fgetc(input);
		}
		fread(&width,  4, 1, input);
		fread(&height, 4, 1, input);
		fread(&frames, 4, 1, input);
		xImage * newImage = new xImage();
		newImage->CreateForAtlas((xTexture*)i, this, width, height, frames);
		for(int j = 0; j < frames; j++)
		{
			int frameX, frameY;
			fread(&frameX, 4, 1, input);
			fread(&frameY, 4, 1, input);
			_atlas->AddRegion((xTexture*)i, j, frameX, frameY, width, height);
		}
		_images.push_back(newImage);
		_indexMap[name.c_str()] = _images.size() - 1;
	}
	unsigned int pngDataStart = ftell(input);
	unsigned int pngDataSize  = length - pngDataStart;
	char * pngData = new char[pngDataSize];
	fread(pngData, 1, pngDataSize, input);
	fclose(input);
	xTexture * texture = new xTexture();
	if(!texture->CreateWithBytes(pngData, pngDataSize))
	{
		printf("ERROR(%s:%i): Unable to read PNG texture data from the atlas file '%s'.\n", __FILE__, __LINE__, path);
		delete [] pngData;
		delete texture;
		return false;
	}
	delete [] pngData;
	_atlas->SetTexture(texture);
	_generated = true;
	return true;
}

bool x2DAtlas::AddImage(xImage * image, const char * name)
{
	if(_generated) return false;
	std::vector<xImage*>::iterator itr = std::find(_images.begin(), _images.end(), image);
	if(itr != _images.end()) return false;
	for(int i = 0; i < image->CountFrames(); i++)
	{
		if(!_atlas->AddTexture(image->GetTexture(), i, xRender::Instance()->GetMaxTextureSize())) 
		{
			for(int j = 0; j < i; j++) _atlas->DeleteTexture(image->GetTexture(), j, xRender::Instance()->GetMaxTextureSize());
			return false;
		}
	}
	_images.push_back(image);
	if(strcmp(name, "") != 0) _indexMap[name] = _images.size() - 1;
	return true;
}

int x2DAtlas::CountImages()
{
	return _images.size();
}

xImage * x2DAtlas::GetImage(int index)
{
	if(index < 0 || index >= _images.size()) return NULL;
	return _images[index];
}

xImage * x2DAtlas::FindImage(const char * name)
{
	std::map<std::string, int>::iterator itr = _indexMap.find(name);
	if(itr == _indexMap.end()) return NULL;
	return _images[itr->second];
}

void x2DAtlas::GenerateTexture()
{
	if(_generated) return;
	_atlas->RebuildTexture();
	_generated = true;
	for(int i = 0; i < _images.size(); i++) _images[i]->DeleteBuffers(this);
}

xTexture * x2DAtlas::GetTexture()
{
	if(!_generated) GenerateTexture();
	return _atlas->GetTexture();
}

xTextureAtlas::xAtlasRegion x2DAtlas::GetTextureRegion(xTexture * texture, int frame)
{
	return _atlas->GetTextureRegion(texture, frame);
}

void x2DAtlas::DeleteTexture(xImage * image)
{
	std::vector<xImage*>::iterator itr = std::find(_images.begin(), _images.end(), image);
	if(itr != _images.end()) return;
	int index = itr - _images.begin();
	_images.erase(itr);
	std::map<std::string, int>::iterator itr2 = _indexMap.begin();
	while(itr2 != _indexMap.end())
	{
		if(itr2->second == index) break;
		itr2++;
	}
	if(itr2 == _indexMap.end()) return;
	_indexMap.erase(itr2);
}

int x2DAtlas::GetWidth()
{
	return _atlas->GetWidth();
}

int x2DAtlas::GetHeight()
{
	return _atlas->GetHeight();
}

void x2DAtlas::Release()
{
	for(int i = 0; i < _images.size(); i++)
	{
		_images[i]->Release();
		delete _images[i];
	}
	_atlas->Release();
}
