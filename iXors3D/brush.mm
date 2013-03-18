//
//  brush.mm
//  iXors3D
//
//  Created by Knightmare on 03.09.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import "brush.h"
#import "render.h"
#import "texturemanager.h"

xBrush::xBrush()
{
	red       = 255;
	green     = 255;
	blue      = 255;
	alpha     = 1.0f;
	shininess = 0.0f;
	blendMode = 1;
	FX        = 0;
	textures  = new BrushTexture[xRender::Instance()->GetMaxTextureUnits()];
	for(int i = 0; i < xRender::Instance()->GetMaxTextureUnits(); i++)
	{
		textures[i].texture = NULL;
		textures[i].frame   = 0;
	}
}

void xBrush::Copy(xBrush * from)
{
	red       = from->red;
	green     = from->green;
	blue      = from->blue;
	alpha     = from->alpha;
	shininess = from->shininess;
	blendMode = from->blendMode;
	FX        = from->FX;
	for(int i = 0; i < xRender::Instance()->GetMaxTextureUnits(); i++)
	{
		xTextureManager::Instance()->ReleaseTexture(textures[i].texture);
		textures[i].texture = from->textures[i].texture;
		textures[i].frame   = from->textures[i].frame;
		if(textures[i].texture != NULL) textures[i].texture->Retain();
	}
}

xBrush::~xBrush()
{
	red       = 255;
	green     = 255;
	blue      = 255;
	alpha     = 1.0f;
	shininess = 0.0f;
	blendMode = 1;
	FX        = 0;
	for(int i = 0; i < xRender::Instance()->GetMaxTextureUnits(); i++)
	{
		if(textures[i].texture != NULL)
		{
			xTextureManager::Instance()->ReleaseTexture(textures[i].texture);
		}
	}
	delete [] textures;
}