//
//  buffer.m
//  iXors3D
//
//  Created by Knightmare on 30.08.09.
//  Copyright 2009 Xors3D Tram. All rights reserved.
//

#import "buffer.h"

xBuffer ** buffers        = NULL;
int        buffersCounter = 0;
int        buffersSize    = 0;
int        lastBuffer     = 0;

xBuffer::xBuffer()
{
	_texture = NULL;
	_image   = NULL;
	_frame   = 0;
}

xBuffer * GetTextureBuffer(xTexture * texture, int frame)
{
	if(buffersSize == 0) return NULL;
	for(int i = 0; i < buffersCounter; i++)
	{
		if(buffers[i]->_texture != NULL)
		{
			if(buffers[i]->_texture == texture && buffers[i]->_frame == frame)
			{
				lastBuffer = i;
				return buffers[i];
			}
		}
	}
	return NULL;
}

xBuffer * GetImageBuffer(xImage * image, int frame)
{
	if(buffersSize == 0) return NULL;
	for(int i = 0; i < buffersCounter; i++)
	{
		if(buffers[i]->_image != NULL)
		{
			if(buffers[i]->_image == image && buffers[i]->_frame == frame)
			{
				lastBuffer = i;
				return buffers[i];
			}
		}
	}
	return NULL;
}

int AddTextureBuffer(xTexture * texture, int frame)
{
	// if buffer already exists
	if(GetTextureBuffer(texture, frame) != NULL) return lastBuffer + 1;
	// resize buffers rray if needed
	if(buffersCounter == buffersSize)
	{
		// craete new array
		xBuffer ** newBuffers = (xBuffer**)malloc((buffersSize + 64) * sizeof(xBuffer *));
		// copy buffers
		if(buffers != NULL) memcpy(newBuffers, buffers, buffersCounter * sizeof(xBuffer *));
		// destroy old
		if(buffers != NULL) free(buffers);
		// switch arrays
		buffers = newBuffers;
		// increase buffers size
		buffersSize += 64;
	}
	// put buffer
	xBuffer * newBuffer     = new xBuffer();
	newBuffer->_texture     = texture;
	newBuffer->_frame       = frame;
	buffers[buffersCounter] = newBuffer;
	return ++buffersCounter;
}

int AddImageBuffer(xImage * image, int frame)
{
	// if buffer already exists
	if(GetImageBuffer(image, frame) != NULL) return lastBuffer + 1;
	// resize buffers rray if needed
	if(buffersCounter == buffersSize)
	{
		// craete new array
		xBuffer ** newBuffers = (xBuffer**)malloc((buffersSize + 64) * sizeof(xBuffer *));
		// copy buffers
		if(buffers != NULL) memcpy(newBuffers, buffers, buffersCounter * sizeof(xBuffer *));
		// destroy old
		if(buffers != NULL) free(buffers);
		// switch arrays
		buffers = newBuffers;
		// increase buffers size
		buffersSize += 64;
	}
	// put buffer
	xBuffer * newBuffer     = new xBuffer();
	newBuffer->_image       = image;
	newBuffer->_frame       = frame;
	buffers[buffersCounter] = newBuffer;
	return ++buffersCounter;
}

xBuffer * GetBufferByID(int bid)
{
	if(bid < 1 || bid > buffersCounter) return NULL;
	return buffers[bid - 1];
}

bool IsBufferLocked(int bid)
{
	xBuffer * buffer = GetBufferByID(bid);
	if(buffer == NULL) return false;
	if(buffer->_texture != NULL) return buffer->_texture->IsLocked(buffer->_frame);
	if(buffer->_image   != NULL) return buffer->_image->IsLocked(buffer->_frame);
	return false;
}