//
//  md2loader.h
//  iXors3D
//
//  Created by Knightmare on 7/2/10.
//  Copyright 2010 XorsTeam. All rights reserved.
//

#ifndef _MD2LOADER_H_
#define _MD2LOADER_H_

#import "mainloader.h"
#import "helpers.h"

class MD2Loader : public MainLoader
{
private:
	struct MD2Header
	{
		int identity;
		int version;
		int skinWidth;
		int skinHeight;
		int frameSize;
		int numSkins;
		int numVertices;
		int numTexCoords;
		int numTriangles;
		int numGLCommands;
		int numFrames;
		int offsetSkins;
		int offsetTexCoords;
		int offsetTriangles;
		int offsetFrames;
		int offsetGLCommands;
		int offsetEnd;
	};
	struct MD2TexCoords
	{
		short u, v;
	};
	struct MD2Triangle
	{
		short vertices[3];
		short texCoords[3];
	};
public:
	struct MD2Vertex
	{
		unsigned char position[3];
		unsigned char normalIndex;
	};
	struct MD2Frame
	{
		float       length;
		xVector     scale;
		xVector     translate;
		MD2Vertex * vertices;
		MD2Frame();
		~MD2Frame();
	};
private:
	MD2Frame * _frames;
public:
	MD2Loader();
	bool LoadFile(const char * path, LoaderNode ** rootNode,
				  TexturesArray * textures,
				  MaterialsArray * materials);
	MD2Frame * GetFrames();
};

#endif