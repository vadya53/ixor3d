//
//  brush.h
//  iXors3D
//
//  Created by Knightmare on 03.09.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "texture.h"

struct BrushTexture
{
	xTexture * texture;
	int        frame;
};

struct xBrush
{
	int             red, green, blue;
	float           alpha;
	float           shininess;
	int             blendMode;
	int             FX;
	BrushTexture  * textures;
	xBrush();
	~xBrush();
	void Copy(xBrush * from);
};