//
//  buffer.h
//  iXors3D
//
//  Created by Knightmare on 30.08.09.
//  Copyright 2009 Xors3D Tram. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "image.h"

struct xBuffer
{
	xTexture * _texture;
	xImage   * _image;
	int        _frame;
	xBuffer();
};

xBuffer * GetTextureBuffer(xTexture * texture, int frame);
xBuffer * GetImageBuffer(xImage * image, int frame);
int AddTextureBuffer(xTexture * texture, int frame);
int AddImageBuffer(xImage * image, int frame);
xBuffer * GetBufferByID(int bid);
bool IsBufferLocked(int bid);