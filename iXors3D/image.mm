//
//  image.mm
//  iXors3D
//
//  Created by Knightmare on 27.08.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import "image.h"
#import <math.h>
#import <iostream>
#import "2datlas.h"

#define max(a, b) (a > b ? a : b)
#define min(a, b) (a < b ? a : b)

bool  xImage::_midHandle     = false;

xImage::xImage()
{
	_texture = NULL;
	_width   = 0;
	_height  = 0;
	_offsetx = 0;
	_offsety = 0;
	_scalex  = 1.0f;
	_scaley  = 1.0f;
	_angle   = 0.0f;
	_red     = 1.0f;
	_green   = 1.0f;
	_blue    = 1.0f;
	_alpha   = 1.0f;
	_blend   = 3;
	_frames  = 1;
	_atlas   = 0;
}

xImage::~xImage()
{
	_texture = NULL;
	_width   = 0;
	_height  = 0;
	_offsetx = 0;
	_offsety = 0;
	_scalex  = 1.0f;
	_scaley  = 1.0f;
	_angle   = 0.0f;
}

bool xImage::Load(const char * path)
{
	if(_texture != NULL)
	{
		printf("ERROR(%s:%i): Unable to load image from file '%s'. Image already created.\n", __FILE__, __LINE__, path);
		return false;
	}
	// create texture
	_texture = new xTexture();
	if(!_texture)
	{
		printf("ERROR(%s:%i): Unable to load image from file '%s'. Unable to allocate new texture.\n", __FILE__, __LINE__, path);
		return false;
	}
	// load texture from file
	if(!_texture->Load(path, 1))
	{
		delete _texture;
		return false;
	}
	// set width and height
	_width  = _texture->GetWidth();
	_height = _texture->GetHeight();
	// set mid handle if need
	if(_midHandle) MidHandle();
	// all done
	return true;
}

#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
bool xImage::CreateWithUIImage(UIImage * image)
{
	if(_texture != NULL)
	{
		printf("ERROR(%s:%i): Unable to load image from UIImage. Image already created.\n", __FILE__, __LINE__);
		return false;
	}
	// create texture
	_texture = new xTexture();
	if(!_texture)
	{
		printf("ERROR(%s:%i): Unable to load image from UIImage. Unable to allocate new texture.\n", __FILE__, __LINE__);
		return false;
	}
	// load texture from file
	if(!_texture->CreateWithUIImage(image))
	{
		delete _texture;
		return false;
	}
	// set width and height
	_width  = _texture->GetWidth();
	_height = _texture->GetHeight();
	// set mid handle if need
	if(_midHandle) MidHandle();
	// all done
	return true;
}
#endif

bool xImage::LoadAnimated(const char * path, int frameWidth, int frameHeight, int firstFrame, int frames)
{
	if(_texture != NULL)
	{
		printf("ERROR(%s:%i): Unable to load animated image from file '%s'. Image already created.\n", __FILE__, __LINE__, path);
		return false;
	}
	// create texture
	_texture = new xTexture();
	if(!_texture)
	{
		printf("ERROR(%s:%i): Unable to load animated image from file '%s'. Unable to allocate new texture.\n", __FILE__, __LINE__, path);
		return false;
	}
	// load texture from file
	if(!_texture->LoadAnimated(path, 1, frameWidth, frameHeight, firstFrame, frames))
	{
		delete _texture;
		return false;
	}
	// set width and height
	_width  = _texture->GetWidth();
	_height = _texture->GetHeight();
	_frames = frames;
	// set mid handle if need
	if(_midHandle) MidHandle();
	// all done
	return true;
}

bool xImage::Create(int frameWidth, int frameHeight, int frames)
{
	if(_texture != NULL)
	{
		printf("ERROR(%s:%i): Unable to create image. Image already created.\n", __FILE__, __LINE__);
		return false;
	}
	// create texture
	_texture = new xTexture();
	if(!_texture)
	{
		printf("ERROR(%s:%i): Unable to create image. Unable to allocate new texture.\n", __FILE__, __LINE__);
		return false;
	}
	if(!_texture->Create(1, frameWidth, frameHeight, frames))
	{
		delete _texture;
		return false;
	}
	// set width and height
	_width  = _texture->GetWidth();
	_height = _texture->GetHeight();
	_frames = frames;
	// set mid handle if need
	if(_midHandle) MidHandle();
	// all done
	return true;
}

float xImage::GetAngle()
{
	return _angle;
}

x2DAtlas * xImage::GetAtlas()
{
	return _atlas;
}

void xImage::CreateForAtlas(xTexture * texture, x2DAtlas * atlas, int width, int height, int frames)
{
	_texture = texture;
	_atlas   = atlas;
	_width   = width;
	_height  = height;
	_frames  = frames;
}

void xImage::DrawFrame(float x, float y, int frame, int rectX, int rectY, int rectWidth, int rectHeight, bool alpha)
{
	if(_atlas != NULL)
	{
		xRender::Instance()->AddToQueue(this, x, y, frame, rectX, rectY, rectWidth, rectHeight);
		return;
	}
	float globalOffsetx = xRender::Instance()->GetGlobalHandle().x;
	float globalOffsety = xRender::Instance()->GetGlobalHandle().y;
	float globalScalex  = xRender::Instance()->GetGlobalScale().x;
	float globalScaley  = xRender::Instance()->GetGlobalScale().y;
	float globalAngle   = xRender::Instance()->GetGlobalRotate();
	float globalRed     = xRender::Instance()->GetGlobalColor().x;
	float globalGreen   = xRender::Instance()->GetGlobalColor().y;
	float globalBlue    = xRender::Instance()->GetGlobalColor().z;
	float globalAlpha   = xRender::Instance()->GetGlobalAlpha();
	int   globalBlend   = xRender::Instance()->GetGlobalBlend();
	//
	xRender::Instance()->AddDIP();
	xRender::Instance()->Prepare2D();
	// create vertex buffer
	GLfloat osx = 0.0f - (_offsetx + globalOffsetx) * _scalex * globalScalex;
	GLfloat osy = 0.0f - (_offsety + globalOffsety) * _scaley * globalScaley;
	GLfloat odx = rectWidth  * _scalex * globalScalex - (_offsetx + globalOffsetx) * _scalex * globalScalex;
	GLfloat ody = rectHeight * _scaley * globalScaley - (_offsety + globalOffsety) * _scaley * globalScaley;
	// rotate corners
	float radAngle =  float(_angle + globalAngle) * (PI / 180.0f);
	float sina     = sin(radAngle);
	float cosa     = cos(radAngle);
	GLfloat c1x = osx * cosa - osy * sina;
	GLfloat c1y = osx * sina + osy * cosa;
	GLfloat c2x = odx * cosa - osy * sina;
	GLfloat c2y = odx * sina + osy * cosa;
	GLfloat c3x = osx * cosa - ody * sina;
	GLfloat c3y = osx * sina + ody * cosa;
	GLfloat c4x = odx * cosa - ody * sina;
	GLfloat c4y = odx * sina + ody * cosa;
	GLfloat minX = float(rectX)              / float(_width);
	GLfloat minY = float(rectY)              / float(_height);
	GLfloat maxX = float(rectX + rectWidth)  / float(_width);
	GLfloat maxY = float(rectY + rectHeight) / float(_height);
	const GLfloat quadPositions[] = { x + c1x, y + c1y, x + c2x, y + c2y, x + c3x, y + c3y, x + c4x, y + c4y };
	const GLfloat quadTexCoords[] = { minX, minY, maxX, minY, minX, maxY, maxX, maxY };
	const GLubyte quadColors[]    = { _red * globalRed * 255, _green * globalGreen * 255, _blue * globalBlue * 255, _alpha * globalAlpha * 255,
									  _red * globalRed * 255, _green * globalGreen * 255, _blue * globalBlue * 255, _alpha * globalAlpha * 255,
									  _red * globalRed * 255, _green * globalGreen * 255, _blue * globalBlue * 255, _alpha * globalAlpha * 255,
									  _red * globalRed * 255, _green * globalGreen * 255, _blue * globalBlue * 255, _alpha * globalAlpha * 255 };
	// set pointer to vertices
	glVertexPointer(2, GL_FLOAT, 0, quadPositions);
	glEnableClientState(GL_VERTEX_ARRAY);
	// set pointer to texture coords
	glTexCoordPointer(2, GL_FLOAT, 0, quadTexCoords);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	// set pointer to colors
	glColorPointer(4, GL_UNSIGNED_BYTE, 0, quadColors);
	glEnableClientState(GL_COLOR_ARRAY);
	// disable normals
	glDisableClientState(GL_NORMAL_ARRAY);
	// bind texture
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, _texture->GetTextureID(frame));
	glEnable(GL_TEXTURE_2D);
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE);
	glTexEnvi(GL_TEXTURE_ENV, GL_SRC0_ALPHA, GL_PREVIOUS);
	glTexEnvi(GL_TEXTURE_ENV, GL_SRC1_ALPHA, GL_TEXTURE);
	glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_ALPHA, GL_SRC_ALPHA);
	glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND1_ALPHA, GL_SRC_ALPHA);
	glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_ALPHA, GL_MODULATE);
	glTexEnvi(GL_TEXTURE_ENV, GL_SRC0_RGB, GL_PREVIOUS);
	glTexEnvi(GL_TEXTURE_ENV, GL_SRC1_RGB, GL_TEXTURE);
	glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_RGB, GL_SRC_COLOR);
	glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND1_RGB, GL_SRC_COLOR);
	glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_MODULATE);
	//
	glActiveTexture(GL_TEXTURE1);
	glDisable(GL_TEXTURE_2D);
	// set blend mode
	if(alpha)
	{
		glEnable(GL_BLEND);
		switch(globalBlend == 0 ? _blend : globalBlend)
		{
			case 1: // disable
			{
				glDisable(GL_BLEND);
				glDisable(GL_ALPHA_TEST);
			}
				break;
			case 2: // mesked
			{
				glDisable(GL_BLEND);
				glEnable(GL_ALPHA_TEST);
				glAlphaFunc(GL_GREATER, 0.0f);
			}
				break;
			case 3:  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); break; // alpha
			case 4:  glBlendFunc(GL_SRC_ALPHA, GL_ONE);                 break; // light
			case 5:  glBlendFunc(GL_ZERO, GL_ONE_MINUS_SRC_ALPHA);      break; // shader
			case -1:  glBlendFunc(src_blend, dsc_blend);     break; // Custom blend
			default: glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		}
	}
	else
	{
		glDisable(GL_BLEND);
	}
	// draw rect
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	if(alpha) glDisable(GL_BLEND);
	glDisable(GL_ALPHA_TEST);	
}

void xImage::DrawRect(int x, int y, int frame, int rectX, int rectY, int rectWidth, int rectHeight)
{
	DrawFrame(x, y, frame, rectX, rectY, rectWidth, rectHeight, true);
}

void xImage::Draw(float x, float y, int frame)
{
	DrawFrame(x, y, frame, 0, 0, _width, _height, true);
}

void xImage::DrawBlockRect(int x, int y, int frame, int rectX, int rectY, int rectWidth, int rectHeight)
{
	DrawFrame(x, y, frame, rectX, rectY, rectWidth, rectHeight, false);
}

void xImage::DrawBlock(int x, int y, int frame)
{
	DrawFrame(x, y, frame, 0, 0, _width, _height, false);
}

float xImage::GetScaleX()
{
	return _scalex;
}

float xImage::GetScaleY()
{
	return _scaley;
}

void xImage::SetBlend(int blend)
{
	_blend = blend;
}

void xImage::SetCustomBlend(int src, int desc)
{
	_blend = -1;
	src_blend=src;
	dsc_blend=desc;	
}

float xImage::GetColorRed()
{
	return _red;
}

float xImage::GetColorGreen()
{
	return _green;
}

float xImage::GetColorBlue()
{
	return _blue;
}

float xImage::GetColorAlpha()
{
	return _alpha;
}

xTexture * xImage::GetTexture()
{
	return _texture;
}

int xImage::CountFrames()
{
	return _frames;
}

void xImage::SetColor(int red, int green, int blue)
{
	_red   = (float)red   / 255.0f;
	_green = (float)green / 255.0f;
	_blue  = (float)blue  / 255.0f;
}

void xImage::SetAlpha(float alpha)
{
	_alpha = alpha;
}

void xImage::SetHandle(int x, int y)
{
	_offsetx = x;
	_offsety = y;
}

void xImage::SetRotate(float angle)
{
	_angle = angle;
}

void xImage::SetScale(float x, float y)
{
	_scalex = x;
	_scaley = y;
}

void xImage::Resize(int width, int height)
{
	_scalex = (float)width  / (float)_width;
	_scaley = (float)height / (float)_height;
}

int xImage::GetWidth()
{
	return _width;
}

int xImage::GetHeight()
{
	return _height;
}

int xImage::GetXHandle()
{
	return _offsetx;
}

int xImage::GetYHandle()
{
	return _offsety;
}

void xImage::MidHandle()
{
	_offsetx = _width  / 2;
	_offsety = _height / 2;
}

void xImage::AutoMidHandle(bool state)
{
	_midHandle = state;
}

void xImage::Release()
{
	if(!_texture) return;
	if(_atlas == NULL)
	{
		_texture->ForceRelease();
		delete _texture;
		_texture = NULL;
	}
	else
	{
		_atlas->DeleteTexture(this);
	}
}

void xImage::DeleteBuffers(x2DAtlas * atlas)
{
	if(_atlas != NULL) return;
	_texture->ForceRelease();
	delete _texture;
	_atlas = atlas;
}

void xImage::Lock(int frame)
{
	if(_atlas != NULL)
	{
		_atlas->GetTexture()->Lock(0);
		return;
	}
	_texture->Lock(frame);
}

void xImage::Unlock(int frame)
{
	if(_atlas != NULL)
	{
		_atlas->GetTexture()->Unlock(0);
		return;
	}
	_texture->Unlock(frame);
}

GLuint xImage::ReadPixel(int x, int y, int frame)
{
	if(_atlas != NULL)
	{
		xTextureAtlas::xAtlasRegion region = _atlas->GetTextureRegion(_texture, frame);
		return _atlas->GetTexture()->ReadPixel(region.x + x, region.y + y, 0);
	}
	return _texture->ReadPixel(x, y, frame);
}

void xImage::WritePixel(int x, int y, GLuint color, int frame)
{
	if(_atlas != NULL)
	{
		xTextureAtlas::xAtlasRegion region = _atlas->GetTextureRegion(_texture, frame);
		_atlas->GetTexture()->WritePixel(region.x + x, region.y + y, color, 0);
		return;
	}
	_texture->WritePixel(x, y, color, frame);
}

void xImage::DeletePixels()
{
	if(_atlas != NULL) _texture->DeletePixels();
}

bool xImage::IsLocked(int frame)
{
	if(_atlas != NULL) return _texture->IsLocked(frame);
	return false;
}

bool xImage::Collide(int x1, int y1, int frame1, xImage * img2, int x2, int y2, int frame2)
{
	if(frame1 < 0 || frame1 >= _frames) return false;
	if(frame2 < 0 || frame2 >= img2->_frames) return false;
	int ax1 = x1 + _width;
	int ay1 = y1 + _height;
	int bx1 = x2 + img2->_width;
	int by1 = y2 + img2->_height;
	if((bx1 < x1) || (ax1 < x2)) return false;
	if((by1 < y1) || (ay1 < y2)) return false;
	int inter_x0 = max(x1, x2);
	int inter_x1 = min(ax1, bx1);
	int inter_y0 = max(y1, y2);
	int inter_y1 = min(ay1, by1);
	uint * pixels1; 
	int offsetx1 = 0;
	int offsety1 = 0;
	if(_atlas == NULL)
	{
		pixels1 = _texture->GetPixels(frame1);
	}
	else
	{
		pixels1 = _atlas->GetTexture()->GetPixels(0);
		xTextureAtlas::xAtlasRegion region = _atlas->GetTextureRegion(_texture, frame1);
		offsetx1 = region.x;
		offsety1 = region.y;
	}
	uint * pixels2;
	int offsetx2 = 0;
	int offsety2 = 0;
	if(img2->_atlas == NULL)
	{
		pixels2 = img2->_texture->GetPixels(frame2);
	}
	else
	{
		pixels2 = img2->_atlas->GetTexture()->GetPixels(0);
		xTextureAtlas::xAtlasRegion region = img2->_atlas->GetTextureRegion(img2->_texture, frame2);
		offsetx2 = region.x;
		offsety2 = region.y;
	}
	if(pixels1 == NULL || pixels2 == NULL) 
	{
		if(pixels1 != NULL) free(pixels1);
		if(pixels2 != NULL) free(pixels2);
		return false;
	}
	for(int j = inter_y0; j <= inter_y1; j++)
	{
		for(int i = inter_x0; i <= inter_x1; i++)
		{
			int cx1 = i - x1;
			int cy1 = j - y1;
			int cx2 = i - x2;
			int cy2 = j - y2;
			if(cx1 >= 0 && cx2 >= 0 && cy1 >= 0 && cy2 >= 0
				&& cx1 < _width && cy1 < _height && cx2 < img2->_width && cy2 < img2->_height)
			{
				int a1 = (pixels1[offsetx1 + cx1 + (cy1 + offsety1) * _width]       >> 24) & 255;
				int a2 = (pixels2[offsetx2 + cx2 + (cy2 + offsety2) * img2->_width] >> 24) & 255;
				if(a1 > 127 && a2 > 127)
				{
					free(pixels1);
					free(pixels2);
					return true;
				}
			}
		}
	}
	free(pixels1);
	free(pixels2);
	return false;
}

bool xImage::CollideRect(int x, int y, int frame, int rx, int ry, int rw, int rh)
{
	if(frame < 0 || frame >= _frames) return false;
	int ax1 = x + _width;
	int ay1 = y + _height;
	int bx1 = rx + rw;
	int by1 = ry + rh;
	if((bx1 < x) || (ax1 < rx)) return false;
	if((by1 < y) || (ay1 < ry)) return false;
	int inter_x0 = max(x, rx);
	int inter_x1 = min(ax1, bx1);
	int inter_y0 = max(y, ry);
	int inter_y1 = min(ay1, by1);
	uint * pixels1; 
	int offsetx1 = 0;
	int offsety1 = 0;
	if(_atlas == NULL)
	{
		pixels1 = _texture->GetPixels(frame);
	}
	else
	{
		pixels1 = _atlas->GetTexture()->GetPixels(0);
		xTextureAtlas::xAtlasRegion region = _atlas->GetTextureRegion(_texture, frame);
		offsetx1 = region.x;
		offsety1 = region.y;
	}
	if(pixels1 == NULL) return false;
	for(int j = inter_y0; j <= inter_y1; j++)
	{
		for(int i = inter_x0; i <= inter_x1; i++)
		{
			int x1 = i - x;
			int y1 = j - y;
			if(x1 >= 0 && y1 >= 0 && x1 < _width && y1 < _height)
			{
				if(((pixels1[offsetx1 + x1 + (y1 + offsety1) * _width] >> 24) & 255) > 127)
				{
					free(pixels1);
					return true;
				}
			}
		}
	}
	free(pixels1);
	return false;
}

bool xImage::CollideBoxRect(int x, int y, int rx, int ry, int rw, int rh)
{
	int ax1 = x + _width;
	int ay1 = y + _height;
	int bx1 = rx + rw;
	int by1 = ry + rh;
	if((bx1 < x) || (ax1 < rx)) return false;
	if((by1 < y) || (ay1 < ry)) return false;
	return true;
}

bool xImage::CollideBox(int x1, int y1, xImage * img2, int x2, int y2)
{
	int ax1 = x1 + _width;
	int ay1 = y1 + _height;
	int bx1 = x2 + img2->_width;
	int by1 = y2 + img2->_height;
	if((bx1 < x1) || (ax1 < x2)) return false;
	if((by1 < y1) || (ay1 < y2)) return false;
	return true;
}

bool xImage::Picked(int x, int y, int frame, int px, int py)
{
	//
	float globalOffsetx = xRender::Instance()->GetGlobalHandle().x;
	float globalOffsety = xRender::Instance()->GetGlobalHandle().y;
	float globalScalex  = xRender::Instance()->GetGlobalScale().x;
	float globalScaley  = xRender::Instance()->GetGlobalScale().y;
	float globalAngle   = xRender::Instance()->GetGlobalRotate();
	float tx = (px - x) * (1.0f / (_scalex * globalScalex));
	float ty = (py - y) * (1.0f / (_scaley * globalScaley));
	float radAngle = -(_angle + globalAngle) * (PI / 180.f);
	float sina     =  sin(radAngle);
	float cosa     =  cos(radAngle);
	float ntx      =  tx * cosa - ty * sina;
	float nty      =  tx * sina + ty * cosa;
	px = x + ntx + _offsetx + globalOffsetx;
	py = y + nty + _offsety + globalOffsety;
	//
	if(frame < 0 || frame >= _frames) return false;
	int ax1 = x + _width;
	int ay1 = y + _height;
	if((px < x) || (ax1 < px)) return false;
	if((py < y) || (ay1 < py)) return false;
	int x1 = (px - x);
	int y1 = (py - y);
	if(x1 < 0 && y1 < 0 && x1 >= _width && y1 >= _height) return false;
	uint * pixels1; 
	int offsetx1 = 0;
	int offsety1 = 0;
	if(_atlas == NULL)
	{
		pixels1 = _texture->GetPixels(frame);
	}
	else
	{
		pixels1 = _atlas->GetTexture()->GetPixels(0);
		xTextureAtlas::xAtlasRegion region = _atlas->GetTextureRegion(_texture, frame);
		offsetx1 = region.x;
		offsety1 = region.y;
	}
	if(pixels1 == NULL) return false;
	int color = pixels1[offsetx1 + x1 + (y1 + offsety1) * _width];
	free(pixels1);
	return ((color >> 24) & 255) > 127;
}

bool xImage::BoxPicked(int x, int y, int px, int py)
{
	//
	float globalOffsetx = xRender::Instance()->GetGlobalHandle().x;
	float globalOffsety = xRender::Instance()->GetGlobalHandle().y;
	float globalScalex  = xRender::Instance()->GetGlobalScale().x;
	float globalScaley  = xRender::Instance()->GetGlobalScale().y;
	float globalAngle   = xRender::Instance()->GetGlobalRotate();
	float tx = (px - x) * (1.0f / (_scalex * globalScalex));
	float ty = (py - y) * (1.0f / (_scaley * globalScaley));
	float radAngle = -(_angle + globalAngle) * (PI / 180.f);
	float sina     =  sin(radAngle);
	float cosa     =  cos(radAngle);
	float ntx      =  tx * cosa - ty * sina;
	float nty      =  tx * sina + ty * cosa;
	px = x + ntx + _offsetx + globalOffsetx;
	py = y + nty + _offsety + globalOffsety;
	//
	int ax1 = x + _width;
	int ay1 = y + _height;
	if((px < x) || (ax1 < px)) return false;
	if((py < y) || (ay1 < py)) return false;
	return true;
}

void xImage::Mask(int red, int green, int blue)
{
	_texture->ApplyMask(red, green, blue);
}

xImage * xImage::Clone()
{
	if(_atlas != NULL) return NULL;
	xImage * newImage  = new xImage();
	newImage->_texture = _texture->Clone();
	if(newImage->_texture == NULL)
	{
		delete newImage;
		return NULL;
	}
	newImage->_width   = _width;
	newImage->_height  = _height;
	newImage->_offsetx = _offsetx;
	newImage->_offsety = _offsety;
	newImage->_scalex  = _scalex;
	newImage->_scaley  = _scaley;
	newImage->_angle   = _angle;
	return newImage;
}

void xImage::SetTarget(int frame)
{
	if(_atlas != NULL) return;
	_texture->SetTarget(frame);
}