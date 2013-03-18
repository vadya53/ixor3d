//
//  md2loader.mm
//  iXors3D
//
//  Created by Knightmare on 7/2/10.
//  Copyright 2010 XorsTeam. All rights reserved.
//

#import "md2loader.h"
#import "filesystem.h"
#import <map>

MD2Loader::MD2Frame::MD2Frame()
{
	vertices = NULL;
}

MD2Loader::MD2Frame::~MD2Frame()
{
	if(vertices != NULL) delete [] vertices;
}

MD2Loader::MD2Loader()
{
	_frames = NULL;
}

bool MD2Loader::LoadFile(const char * path, LoaderNode ** rootNode,
						 TexturesArray * textures,
						 MaterialsArray * materials)
{
	NSString * realPath = [NSString stringWithUTF8String: xFileSystem::Instance()->GetRealPath(path).c_str()];
	FILE * input = fopen([realPath UTF8String], "rb");
	if(input == NULL)
	{
		printf("ERROR(%s:%i): Unable to open file '%s'.\n", __FILE__, __LINE__, path);
		return false;
	}
	RAMFile * file = new RAMFile(input);
	fclose(input);
	// read header
	MD2Header header;
	ReadData(file, &header, sizeof(MD2Header));
	int md2Req = (('2' << 24) + ('P' << 16) + ('D' << 8) + 'I');
	if(header.identity != md2Req)
	{
		file->Release();
		printf("ERROR(%s:%i): Unable to open file '%s'. File is not a MD2 model.\n", __FILE__, __LINE__, path);
		return false;
	}
	// read textures
	materials->push_back(LoaderMaterial());
	file->offset = header.offsetSkins;
	for(int i = 0; i < header.numSkins; i++)
	{
		char buffer[64];
		ReadData(file, buffer, 64);
		std::string path = buffer;
		int slashPos = path.find_last_of("/"); 
		if(slashPos == path.npos) slashPos = path.find_last_of("\\");
		if(slashPos != path.npos) path = path.substr(slashPos + 1);
		if(textures->size() == 0)
		{
			LoaderTexture texture;
			texture._filename = path;
			texture._flags    = 1 + 8;
			textures->push_back(texture);
		}
		else
		{
			(*textures)[0]._filename = path;
		}
		(*materials)[0]._textures[0] = 0;
	}
	// read texture coords
	file->offset = header.offsetTexCoords;
	MD2TexCoords * texCoords = new MD2TexCoords[header.numTexCoords];
	ReadData(file, texCoords, header.numTexCoords * sizeof(MD2TexCoords));
	// read triangles
	file->offset = header.offsetTriangles;
	MD2Triangle * triangles = new MD2Triangle[header.numTriangles];
	ReadData(file, triangles, header.numTriangles * sizeof(MD2Triangle));
	// create surface
	*rootNode = new LoaderNode();
	LoaderSurface surface;
	surface._materialID = 0;
	surface._vertices   = new std::vector<xVertex>();
	surface._vertices->resize(header.numVertices);
	std::map<int, MD2TexCoords> verticesMap;
	std::vector<ushort> duplicates;
	for(unsigned int i = 0; i < header.numTriangles; i++)
	{
		ushort v0 = triangles[i].vertices[0];
		ushort v1 = triangles[i].vertices[1];
		ushort v2 = triangles[i].vertices[2];
		ushort t0 = triangles[i].texCoords[0];
		ushort t1 = triangles[i].texCoords[1];
		ushort t2 = triangles[i].texCoords[2];
		std::map<int, MD2TexCoords>::iterator itr;
		itr = verticesMap.find(v0);
		if(itr == verticesMap.end())
		{
			(*surface._vertices)[v0].tu1 = float(texCoords[t0].u) / float(header.skinWidth);
			(*surface._vertices)[v0].tv1 = float(texCoords[t0].v) / float(header.skinHeight);
			(*surface._vertices)[v0].tu2 = float(texCoords[t0].u) / float(header.skinWidth);
			(*surface._vertices)[v0].tv2 = float(texCoords[t0].v) / float(header.skinHeight);
			verticesMap[v0] = texCoords[t0];
		}
		else if(verticesMap[v0].u != texCoords[t0].u || verticesMap[v0].v != texCoords[t0].v)
		{
			xVertex newVertex;
			newVertex.tu1 = float(texCoords[t0].u) / float(header.skinWidth);
			newVertex.tv1 = float(texCoords[t0].v) / float(header.skinHeight);
			newVertex.tu2 = float(texCoords[t0].u) / float(header.skinWidth);
			newVertex.tv2 = float(texCoords[t0].v) / float(header.skinHeight);
			duplicates.push_back(v0);
			v0 = surface._vertices->size();
			surface._vertices->push_back(newVertex);
		}
		itr = verticesMap.find(v1);
		if(itr == verticesMap.end())
		{
			(*surface._vertices)[v1].tu1 = float(texCoords[t1].u) / float(header.skinWidth);
			(*surface._vertices)[v1].tv1 = float(texCoords[t1].v) / float(header.skinHeight);
			(*surface._vertices)[v1].tu2 = float(texCoords[t1].u) / float(header.skinWidth);
			(*surface._vertices)[v1].tv2 = float(texCoords[t1].v) / float(header.skinHeight);
			verticesMap[v1] = texCoords[t1];
		}
		else if(verticesMap[v1].u != texCoords[t1].u || verticesMap[v1].v != texCoords[t1].v)
		{
			xVertex newVertex;
			newVertex.tu1 = float(texCoords[t1].u) / float(header.skinWidth);
			newVertex.tv1 = float(texCoords[t1].v) / float(header.skinHeight);
			newVertex.tu2 = float(texCoords[t1].u) / float(header.skinWidth);
			newVertex.tv2 = float(texCoords[t1].v) / float(header.skinHeight);
			duplicates.push_back(v1);
			v1 = surface._vertices->size();
			surface._vertices->push_back(newVertex);
		}
		itr = verticesMap.find(v2);
		if(itr == verticesMap.end())
		{
			(*surface._vertices)[v2].tu1 = float(texCoords[t2].u) / float(header.skinWidth);
			(*surface._vertices)[v2].tv1 = float(texCoords[t2].v) / float(header.skinHeight);
			(*surface._vertices)[v2].tu2 = float(texCoords[t2].u) / float(header.skinWidth);
			(*surface._vertices)[v2].tv2 = float(texCoords[t2].v) / float(header.skinHeight);
			verticesMap[v2] = texCoords[t2];
		}
		else if(verticesMap[v2].u != texCoords[t2].u || verticesMap[v2].v != texCoords[t2].v)
		{
			xVertex newVertex;
			newVertex.tu1 = float(texCoords[t2].u) / float(header.skinWidth);
			newVertex.tv1 = float(texCoords[t2].v) / float(header.skinHeight);
			newVertex.tu2 = float(texCoords[t2].u) / float(header.skinWidth);
			newVertex.tv2 = float(texCoords[t2].v) / float(header.skinHeight);
			duplicates.push_back(v2);
			v2 = surface._vertices->size();
			surface._vertices->push_back(newVertex);
		}
		surface._triangles->push_back(LoaderSurface::Triangle(v0, v1, v2));
	}
	delete [] texCoords;
	delete [] triangles;
	(*rootNode)->_surfaces.push_back(surface);
	// read frames
	_frames = new MD2Frame[header.numFrames];
	file->offset = header.offsetFrames;
	for(unsigned int i = 0; i < header.numFrames; i++)
	{
		_frames[i].length = float(header.numFrames) / 10.0f;
		ReadData(file, &_frames[i].scale, 12);
		ReadData(file, &_frames[i].translate, 12);
		float t = _frames[i].scale.x;
		_frames[i].scale.x = _frames[i].scale.y;
		_frames[i].scale.y = _frames[i].scale.z;
		_frames[i].scale.z = -t;
		t = _frames[i].translate.x;
		_frames[i].translate.x = _frames[i].translate.y;
		_frames[i].translate.y = _frames[i].translate.z;
		_frames[i].translate.z = -t;
		file->offset += 16;
		_frames[i].vertices = new MD2Vertex[header.numVertices + duplicates.size()];
		ReadData(file, _frames[i].vertices, header.numVertices * sizeof(MD2Vertex));
		for(unsigned int j = 0; j < header.numVertices; j++)
		{
			short t = _frames[i].vertices[j].position[0];
			_frames[i].vertices[j].position[0] = _frames[i].vertices[j].position[1];
			_frames[i].vertices[j].position[1] = _frames[i].vertices[j].position[2];
			_frames[i].vertices[j].position[2] = t;
		}
		for(unsigned int j = 0; j < duplicates.size(); j++)
		{
			_frames[i].vertices[header.numVertices + j] = _frames[i].vertices[duplicates[j]];
		}
		file->offset = header.offsetFrames + (i + 1) * header.frameSize;
	}
	//
	file->Release();
	delete file;
	return true;
}

MD2Loader::MD2Frame * MD2Loader::GetFrames()
{
	return _frames;
}