//
//  surface.mm
//  iXors3D
//
//  Created by Knightmare on 31.08.09.
//  Copyright 2009 Xors3D Team. All rights reserved.
//

#import "surface.h"
#import "camera.h"
#import "texturemanager.h"

xVertex::xVertex()
{
	x     = 0.0f;
	y     = 0.0f;
	z     = 0.0f;
	nx    = 0.0f;
	ny    = 0.0f;
	nz    = 0.0f;
	tu1   = 0.0f;
	tv1   = 0.0f;
	tu2   = 0.0f;
	tv2   = 0.0f;
	color = 0xffffffff;
}

xSurface::xSurface(xBrush * brush, xGeomBuffer * gbuffer)
{
	if(gbuffer != NULL)
	{
		_gbuffer = gbuffer;
		_gbuffer->_counter++;
	}
	else
	{
		_gbuffer = new xGeomBuffer();
	}
	_creationBrush = brush;
	_changes       = true;
	if(_creationBrush != NULL)
	{
		_color          = xVector((float)brush->red / 255.0f, (float)brush->green / 255.0f, (float)brush->blue / 255.0f);
		_alpha          = brush->alpha;
		_shininess      = brush->shininess * 128.0f;
		_blend          = brush->blendMode;
		_FX             = brush->FX;
		_textures       = new BrushTexture[xRender::Instance()->GetMaxTextureUnits()];
		for(int i = 0; i < xRender::Instance()->GetMaxTextureUnits(); i++)
		{
			_textures[i].texture = brush->textures[i].texture;
			_textures[i].frame   = brush->textures[i].frame;
			if(_textures[i].texture != NULL) _textures[i].texture->Retain();
		}
	}
	else
	{
		_color          = xVector(1.0f, 1.0f, 1.0f);
		_alpha          = 1.0f;
		_shininess      = 0.0f;
		_blend          = 1;
		_FX             = 0;
		_textures       = new BrushTexture[xRender::Instance()->GetMaxTextureUnits()];
		for(int i = 0; i < xRender::Instance()->GetMaxTextureUnits(); i++) _textures[i].texture = NULL;
	}
	_alphaFunc = 4;
	_alphaRef  = 0.0f;
}

void xSurface::ApplyBrush(xBrush * brush)
{
	_color          = xVector((float)brush->red / 255.0f, (float)brush->green / 255.0f, (float)brush->blue / 255.0f);
	_alpha          = brush->alpha;
	_shininess      = brush->shininess * 128.0f;
	_blend          = brush->blendMode;
	_FX             = brush->FX;
	for(int i = 0; i < xRender::Instance()->GetMaxTextureUnits(); i++)
	{
		if(_textures[i].texture == brush->textures[i].texture &&
		   _textures[i].frame == brush->textures[i].frame) continue;
		if(_textures[i].texture != NULL)
		{
			xTextureManager::Instance()->ReleaseTexture(_textures[i].texture);
		}
		_textures[i].texture = brush->textures[i].texture;
		_textures[i].frame   = brush->textures[i].frame;
		if(_textures[i].texture != NULL) _textures[i].texture->Retain();
	}
}

xBrush * xSurface::GetBrush()
{
	xBrush * newBrush = new xBrush();
	newBrush->red       = _color.x * 255.0f;
	newBrush->green     = _color.y * 255.0f;
	newBrush->blue      = _color.z * 255.0f;
	newBrush->alpha     = _alpha;
	newBrush->shininess = _shininess / 128.0f;
	newBrush->blendMode = _blend;
	newBrush->FX        = _FX;
	for(int i = 0; i < xRender::Instance()->GetMaxTextureUnits(); i++)
	{
		newBrush->textures[i].texture = _textures[i].texture;
		newBrush->textures[i].frame   = _textures[i].frame;
		if(newBrush->textures[i].texture != NULL) newBrush->textures[i].texture->Retain();
	}
	return newBrush;
}

xBrush * xSurface::GetCreationBrush()
{
	return _creationBrush;
}

void xSurface::Release()
{
	_gbuffer->_counter--;
	if(_gbuffer->_counter == 0)
	{
		if(_gbuffer->_vertices != NULL)     free(_gbuffer->_vertices);
		if(_gbuffer->_origVertices != NULL) free(_gbuffer->_origVertices);
		if(_gbuffer->_triangles != NULL)    free(_gbuffer->_triangles);
	}
	_color          = xVector(1.0f, 1.0f, 1.0f);
	_alpha          = 1.0f;
	_shininess      = 0.0f;
	_blend          = 1;
	_FX             = 0;
	for(int i = 0; i < xRender::Instance()->GetMaxTextureUnits(); i++)
	{
		if(_textures[i].texture != NULL)
		{
			xTextureManager::Instance()->ReleaseTexture(_textures[i].texture);
		}
	}
	delete [] _textures;
}

xSurface * xSurface::Clone(bool cloneGeom)
{
	xBrush * brush = GetBrush();
	xSurface * newSurface = new xSurface(brush, cloneGeom ? NULL : _gbuffer);
	delete brush;
	if(cloneGeom)
	{
		newSurface->_gbuffer->_vertices             = new xVertex[_gbuffer->_vertsArraySize];
		memcpy(newSurface->_gbuffer->_vertices, _gbuffer->_vertices, _gbuffer->_vertsCount * sizeof(xVertex));
		if(_gbuffer->_origVertices != NULL)
		{
			newSurface->_gbuffer->_origVertices     = new xVertex[_gbuffer->_vertsCount];
			memcpy(newSurface->_gbuffer->_origVertices, _gbuffer->_origVertices, _gbuffer->_vertsCount * sizeof(xVertex));
		}
		else
		{
			newSurface->_gbuffer->_origVertices     = NULL;
		}
		newSurface->_gbuffer->_triangles            = new ushort[3 * _gbuffer->_trisArraySize];
		memcpy(newSurface->_gbuffer->_triangles, _gbuffer->_triangles, _gbuffer->_trisCount * 3 * sizeof(ushort));
		newSurface->_gbuffer->_vertsCount           = _gbuffer->_vertsCount;
		newSurface->_gbuffer->_trisCount            = _gbuffer->_trisCount;
		newSurface->_gbuffer->_vertsArraySize       = _gbuffer->_vertsArraySize;
		newSurface->_gbuffer->_trisArraySize        = _gbuffer->_trisArraySize;
		newSurface->_gbuffer->_alphaVerts           = _gbuffer->_alphaVerts;
		newSurface->_gbuffer->_boundingBox          = _gbuffer->_boundingBox;
		newSurface->_gbuffer->_boundingSphereCenter = _gbuffer->_boundingSphereCenter;
		newSurface->_gbuffer->_boundingSphereRadius = _gbuffer->_boundingSphereRadius;
	}
	return newSurface;
}

int xSurface::AddVertex(float x, float y, float z, float tu, float tv)
{
	_changes = true;
	// resize vertices array if it needed
	if(_gbuffer->_vertsCount == _gbuffer->_vertsArraySize)
	{
		// allocate new array
		xVertex * newArray = (xVertex*)malloc((_gbuffer->_vertsArraySize + 64) * sizeof(xVertex));
		// copy old vertices
		if(_gbuffer->_vertices != NULL) memcpy(newArray, _gbuffer->_vertices, _gbuffer->_vertsCount * sizeof(xVertex));
		// release old array‰
		if(_gbuffer->_vertices != NULL) free(_gbuffer->_vertices);
		// swap arrays
		_gbuffer->_vertices = newArray;
		_gbuffer->_vertsArraySize += 64;
	}
	// set new vertex
	_gbuffer->_vertices[_gbuffer->_vertsCount].x     = x;
	_gbuffer->_vertices[_gbuffer->_vertsCount].y     = y;
	_gbuffer->_vertices[_gbuffer->_vertsCount].z     = z;
	_gbuffer->_vertices[_gbuffer->_vertsCount].nx    = 0.0f;
	_gbuffer->_vertices[_gbuffer->_vertsCount].ny    = 0.0f;
	_gbuffer->_vertices[_gbuffer->_vertsCount].nz    = 0.0f;
	_gbuffer->_vertices[_gbuffer->_vertsCount].tu1   = tu;
	_gbuffer->_vertices[_gbuffer->_vertsCount].tv1   = tv;
	_gbuffer->_vertices[_gbuffer->_vertsCount].tu2   = 0.0f;
	_gbuffer->_vertices[_gbuffer->_vertsCount].tv2   = 0.0f;
	_gbuffer->_vertices[_gbuffer->_vertsCount].color = 0xffffffff;
	_gbuffer->_needBVUpdate = true;
	return _gbuffer->_vertsCount++;
}

int xSurface::AddTriangle(ushort v0, ushort v1, ushort v2)
{
	_changes = true;
	// resize vertices array if it needed
	if(_gbuffer->_trisCount == _gbuffer->_trisArraySize)
	{
		// allocate new array
		ushort * newArray = (ushort*)malloc((_gbuffer->_trisArraySize + 64) * 3 * sizeof(ushort));
		// copy old triangles
		if(_gbuffer->_triangles != NULL) memcpy(newArray, _gbuffer->_triangles, _gbuffer->_trisCount * 3 * sizeof(ushort));
		// release old array
		if(_gbuffer->_triangles != NULL) free(_gbuffer->_triangles);
		// swap arrays
		_gbuffer->_triangles = newArray;
		_gbuffer->_trisArraySize += 64;
	}
	// set new triangle
	_gbuffer->_triangles[_gbuffer->_trisCount * 3 + 0] = v0;
	_gbuffer->_triangles[_gbuffer->_trisCount * 3 + 1] = v1;
	_gbuffer->_triangles[_gbuffer->_trisCount * 3 + 2] = v2;
	return _gbuffer->_trisCount++;
}

void xSurface::VertexCoords(int index, float x, float y, float z)
{
	if(index < 0 || index >= _gbuffer->_vertsCount) return;
	_changes                     = true;
	_gbuffer->_vertices[index].x = x;
	_gbuffer->_vertices[index].y = y;
	_gbuffer->_vertices[index].z = z;
	_gbuffer->_needBVUpdate      = true;
}

void xSurface::VertexNormal(int index, float x, float y, float z)
{
	if(index < 0 || index >= _gbuffer->_vertsCount) return;
	_gbuffer->_vertices[index].nx = x;
	_gbuffer->_vertices[index].ny = y;
	_gbuffer->_vertices[index].nz = z;
}

void xSurface::VertexColor(int index, int red, int green, int blue, float alpha)
{
	if(index < 0 || index >= _gbuffer->_vertsCount) return;
	int oldAlpha = _gbuffer->_vertices[index].color & 255;
	if(alpha < 1.0f && oldAlpha == 255)
	{
		_gbuffer->_alphaVerts++;
	}
	else if(oldAlpha < 255 && alpha == 1.0f)
	{
		_gbuffer->_alphaVerts--;
	}
	_gbuffer->_vertices[index].color = red | (green << 8) | (blue << 16) | ((int(alpha * 255) & 255) << 24);
}

void xSurface::VertexTexCoords(int index, float tu, float tv, float tw, int setNum)
{
	if(index < 0 || index >= _gbuffer->_vertsCount) return;
	if(setNum == 0)
	{
		_gbuffer->_vertices[index].tu1 = tu;
		_gbuffer->_vertices[index].tv1 = tv;
	}
	else
	{
		_gbuffer->_vertices[index].tu2 = tu;
		_gbuffer->_vertices[index].tv2 = tv;
	}
}

xVector xSurface::GetVertexCoords(int index)
{
	if(index < 0 || index >= _gbuffer->_vertsCount) return xVector();
	return xVector(_gbuffer->_vertices[index].x, _gbuffer->_vertices[index].y, _gbuffer->_vertices[index].z);
}

xVector xSurface::GetVertexNormal(int index)
{
	if(index < 0 || index >= _gbuffer->_vertsCount) return xVector();
	return xVector(_gbuffer->_vertices[index].nx, _gbuffer->_vertices[index].ny, _gbuffer->_vertices[index].nz);
}

xVector xSurface::GetVertexTexCoords(int index, int setNum)
{
	if(index < 0 || index >= _gbuffer->_vertsCount) return xVector();
	if(setNum == 0)
	{
		return xVector(_gbuffer->_vertices[index].tu1, _gbuffer->_vertices[index].tv1, 0.0f);
	}
	{
		return xVector(_gbuffer->_vertices[index].tu2, _gbuffer->_vertices[index].tv2, 0.0f);
	}
}

xVector xSurface::GetVertexColor(int index)
{
	if(index < 0 || index >= _gbuffer->_vertsCount) return xVector();
	int red   = (_gbuffer->_vertices[index].color)       & 255;
	int green = (_gbuffer->_vertices[index].color >> 8)  & 255;
	int blue  = (_gbuffer->_vertices[index].color >> 16) & 255;
	return xVector(red, green, blue);
}

float xSurface::GetVertexAlpha(int index)
{
	if(index < 0 || index >= _gbuffer->_vertsCount) return 0.0f;
	return float((_gbuffer->_vertices[index].color >> 24) & 255) / 255.0f;
}

int xSurface::CountVertices()
{
	return _gbuffer->_vertsCount;
}

int xSurface::CountTriangles()
{
	return _gbuffer->_trisCount;
}

int xSurface::TriangleVertex(int index, int corner)
{
	if(corner < 0 || corner > 2) return 0;
	if(index < 0 || index >= _gbuffer->_trisCount) return 0;
	return _gbuffer->_triangles[index * 3 + corner];
}

void xSurface::Clear(bool vertices, bool triangles)
{
	if(_gbuffer->_vertices != NULL && vertices)
	{
		free(_gbuffer->_vertices);
		_gbuffer->_vertices       = NULL;
		_gbuffer->_vertsCount     = 0;
		_gbuffer->_vertsArraySize = 0;
		_gbuffer->_alphaVerts     = 0;
		_gbuffer->_needBVUpdate   = true;
	}
	if(_gbuffer->_triangles != NULL && triangles)
	{
		free(_gbuffer->_triangles);
		_gbuffer->_triangles     = NULL;
		_gbuffer->_trisCount     = 0;
		_gbuffer->_trisArraySize = 0;
	}
}

bool xSurface::NeedAlphaBlend()
{
	bool needAlphaBlend = false;
	for(int i = 0; i < xRender::Instance()->GetMaxTextureUnits(); i++)
	{
		if(_textures[i].texture != NULL)
		{
			needAlphaBlend |= _textures[i].texture->GetFlags() & 2;
		}
	}
	return (_alpha < 1.0f || _blend > 1 || (_gbuffer->_alphaVerts > 0 && _FX & 2) || needAlphaBlend);
}

void xSurface::UpdateBoundingVolumes()
{
	if(_gbuffer->_vertsCount == 0)
	{
		_gbuffer->_boundingBox          = xBox(xVector(0.0f, 0.0f, 0.0f));
		_gbuffer->_boundingSphereCenter = xVector(0.0f, 0.0f, 0.0f);
		_gbuffer->_boundingSphereRadius = 0.0f;
		_gbuffer->_needBVUpdate         = false;
		return;
	}
	_gbuffer->_boundingBox = xBox(xVector(_gbuffer->_vertices[0].x, _gbuffer->_vertices[0].y, _gbuffer->_vertices[0].z));
	for(int i = 1; i < _gbuffer->_vertsCount; i++)
	{
		_gbuffer->_boundingBox.Update(xVector(_gbuffer->_vertices[i].x, _gbuffer->_vertices[i].y, _gbuffer->_vertices[i].z));
	}
	_gbuffer->_boundingSphereCenter = _gbuffer->_boundingBox.Centre();
	_gbuffer->_boundingSphereRadius = _gbuffer->_boundingSphereCenter.Distance(_gbuffer->_boundingBox.min);
	_gbuffer->_needBVUpdate = false;
}

xBox xSurface::GetBoundingBox()
{
	if(_gbuffer->_needBVUpdate) UpdateBoundingVolumes();
	return _gbuffer->_boundingBox;
}

void xSurface::SetBoundingBox(const xBox & bbox)
{
	_gbuffer->_boundingBox   = bbox;
	_gbuffer->_needBVUpdate = false;
}

xVector xSurface::GetBoundingSphereCenter()
{
	if(_gbuffer->_needBVUpdate) UpdateBoundingVolumes();
	return _gbuffer->_boundingSphereCenter;
}

float xSurface::GetBoundingSphereRadius()
{
	if(_gbuffer->_needBVUpdate) UpdateBoundingVolumes();
	return _gbuffer->_boundingSphereRadius;
}

bool xSurface::InView(xTransform transform, xCamera * camera)
{
	if(_alpha < 0.001f) return false;
	if(_gbuffer->_needBVUpdate) UpdateBoundingVolumes();
	if(camera == NULL) return true;
	return camera->GetFrustum()->BoxInFrustum(transform * _gbuffer->_boundingBox);
}

void xSurface::AllocateSkinnedVB()
{
	_gbuffer->_origVertices = (xVertex*)malloc(_gbuffer->_vertsCount * sizeof(xVertex));
	memcpy((void*)_gbuffer->_origVertices, (void*)_gbuffer->_vertices, _gbuffer->_vertsCount * sizeof(xVertex));
}

xVertex * xSurface::GetVB()
{
	return _gbuffer->_vertices;
}

xVertex * xSurface::GetBindPoseVB()
{
	return _gbuffer->_origVertices;
}

ushort * xSurface::GetIB()
{
	return _gbuffer->_triangles;
}

void xSurface::Draw()
{
	if(_gbuffer->_vertices == NULL || _gbuffer->_triangles == NULL) return;
	xRender::Instance()->AddTriangles(_gbuffer->_trisCount);
	xRender::Instance()->AddDIP();
	// set material
	bool * lightStates = new bool[xRender::Instance()->GetMaxLights()];
	GLfloat ambient[4];
	glEnable(GL_CULL_FACE);
	if(_FX & 1)
	{
		for(int i = 0; i < xRender::Instance()->GetMaxLights(); i++)
		{
			lightStates[i] = glIsEnabled(GL_LIGHT0 + i);
			glDisable(GL_LIGHT0 + i);
		}
		glGetFloatv(GL_LIGHT_MODEL_AMBIENT, ambient);
		GLfloat fullBright[] = { 1.0f, 1.0f, 1.0f, 1.0f };
		glLightModelfv(GL_LIGHT_MODEL_AMBIENT, fullBright);
	}
	if(_FX & 2)
	{
		glEnable(GL_COLOR_MATERIAL);
	}
	else
	{
		glDisable(GL_COLOR_MATERIAL);
		glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE, &_color.x);
		glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, &xVector(1.0f, 1.0f, 1.0f).x);
		glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, _shininess);
	}
	if(_FX & 4) glShadeModel(GL_FLAT);
	bool fogEnabled = glIsEnabled(GL_FOG);
	if(_FX & 8) glDisable(GL_FOG);
	if(_FX & 16) glDisable(GL_CULL_FACE);
	// set textures
	bool needAlphaTest  = false;
	bool needAlphaBlend = false;
	xRender::Instance()->ResetTextureLayers();
	for(int i = 0; i < xRender::Instance()->GetMaxTextureUnits(); i++)
	{
		if(_textures[i].texture != NULL)
		{
			needAlphaBlend |= _textures[i].texture->GetFlags() & 2;
			needAlphaTest  |= _textures[i].texture->GetFlags() & 4;
			xRender::Instance()->SetTexture(_textures[i].texture, _textures[i].frame);
		}
	}
	// set alpha test
	if(needAlphaTest)
	{
		glEnable(GL_ALPHA_TEST);
		glAlphaFunc(GL_NEVER + _alphaFunc, _alphaRef);
	}
	// set blend mode
	needAlphaBlend |= _alpha < 1.0f || _blend > 1 || (_gbuffer->_alphaVerts > 0 && _FX & 2);
	if(needAlphaBlend)
	{
		xRender::Instance()->SetBlend(_blend);
	}
	// set geometry
	// set vertex pointer
	glVertexPointer(3, GL_FLOAT, sizeof(xVertex), &_gbuffer->_vertices[0].x);
	// set normals pointer
	glNormalPointer(GL_FLOAT, sizeof(xVertex), &_gbuffer->_vertices[0].nx);
	// set colors pointer
	glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(xVertex), &_gbuffer->_vertices[0].color);
	// set texture coords pointer
	int textureLayer = 0;
	for(int i = 0; i < xRender::Instance()->GetMaxTextureUnits(); i++)
	{
		if(_textures[i].texture != NULL)
		{
			glClientActiveTexture(GL_TEXTURE0 + textureLayer);
			glEnableClientState(GL_TEXTURE_COORD_ARRAY);
			if(_textures[i].texture->GetCoordsSet() == 0)
			{
				glTexCoordPointer(2, GL_FLOAT, sizeof(xVertex), &_gbuffer->_vertices[0].tu1);
			}
			else
			{
				glTexCoordPointer(2, GL_FLOAT, sizeof(xVertex), &_gbuffer->_vertices[0].tu2);
			}
			textureLayer++;
		}
	}
	// enable states
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_NORMAL_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
	// draw vertices
	glDrawElements(GL_TRIANGLES, _gbuffer->_trisCount * 3, GL_UNSIGNED_SHORT, _gbuffer->_triangles);
	// restore states
	for(int i = 1; i < xRender::Instance()->GetMaxTextureUnits(); i++)
	{
		glClientActiveTexture(GL_TEXTURE0 + i);
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	}
	glClientActiveTexture(GL_TEXTURE0);
	if(_FX & 1)
	{
		for(int i = 0; i < xRender::Instance()->GetMaxLights(); i++)
		{
			if(lightStates[i]) glEnable(GL_LIGHT0 + i);
		}
		glLightModelfv(GL_LIGHT_MODEL_AMBIENT, ambient);
	}
	if(_FX & 4) glShadeModel(GL_SMOOTH);
	if(_FX & 8 && fogEnabled) glEnable(GL_FOG);
	if(needAlphaTest)
	{
		glAlphaFunc(GL_NEVER + 4, 0.0f);
		glDisable(GL_ALPHA_TEST);
	}
	if(needAlphaBlend)
	{
		glDisable(GL_BLEND);
		glDepthMask(GL_TRUE);
	}
#if !TARGET_OS_EMBEDDED && !TARGET_IPHONE_SIMULATOR
	for(int i = 0; i < xRender::Instance()->GetMaxTextureUnits(); i++)
	{
		glActiveTexture(GL_TEXTURE0 + i);
		glDisable(GL_TEXTURE_GEN_S);
		glDisable(GL_TEXTURE_GEN_T);
	}
#endif
	delete [] lightStates;
}

void xSurface::SetAlphaFunc(int func)
{
	_alphaFunc = func;
	if(_alphaFunc < 0) _alphaRef = 0;
	if(_alphaFunc > 7) _alphaRef = 7;
}

void xSurface::SetAlphaRef(float reference)
{
	_alphaRef = reference;
	if(_alphaRef < 0.0f) _alphaRef = 0.0f;
	if(_alphaRef > 1.0f) _alphaRef = 1.0f;
}

int xSurface::GetAlphaFunc()
{
	return _alphaFunc;
}

float xSurface::GetAlphaRef()
{
	return _alphaRef;
}

void xSurface::SetColor(int red, int green, int blue)
{
	_color.x = (float)red   / 255.0f;
	_color.y = (float)green / 255.0f;
	_color.z = (float)blue  / 255.0f;
}

void xSurface::SetAlpha(float alpha)
{
	_alpha = alpha;
}

void xSurface::SetShininess(float shininess)
{
	_shininess = shininess;
}

void xSurface::SetBlendMode(int mode)
{
	_blend = mode;
}

void xSurface::SetFX(int fx)
{
	_FX = fx;
}

void xSurface::SetTexture(int index, xTexture * texture, int frame)
{
	if(index < 0 || index >= xRender::Instance()->GetMaxTextureUnits()) return;
	if(_textures[index].texture != NULL)
	{
		xTextureManager::Instance()->ReleaseTexture(_textures[index].texture);
	}
	_textures[index].texture = texture;
	_textures[index].frame   = frame;
	if(_textures[index].texture != NULL) _textures[index].texture->Retain();
}

void xSurface::FlipTriangles()
{
	for(int i = 0; i < _gbuffer->_trisCount; i++)
	{
		ushort temp = _gbuffer->_triangles[i * 3 + 0];
		_gbuffer->_triangles[i * 3 + 0] = _gbuffer->_triangles[i * 3 + 2];
		_gbuffer->_triangles[i * 3 + 2] = temp;
	}
	_changes = true;
}

void xSurface::PositionVertices(float x, float y, float z)
{
	for(int i = 0; i < _gbuffer->_vertsCount; i++)
	{
		_gbuffer->_vertices[i].x += x;
		_gbuffer->_vertices[i].y += y;
		_gbuffer->_vertices[i].z += z;
	}
	_changes = true;
}

void xSurface::RotateVertices(float pitch, float yaw, float roll)
{
	xMatrix matrix = RotationMatrix(pitch, yaw, roll);
	for(int i = 0; i < _gbuffer->_vertsCount; i++)
	{
		xVector newPosition = matrix * xVector(_gbuffer->_vertices[i].x, _gbuffer->_vertices[i].y, _gbuffer->_vertices[i].z);
		_gbuffer->_vertices[i].x = newPosition.x;
		_gbuffer->_vertices[i].y = newPosition.y;
		_gbuffer->_vertices[i].z = newPosition.z;
	}
	_changes = true;
}

void xSurface::ScaleVertices(float x, float y, float z)
{
	for(int i = 0; i < _gbuffer->_vertsCount; i++)
	{
		_gbuffer->_vertices[i].x *= x;
		_gbuffer->_vertices[i].y *= y;
		_gbuffer->_vertices[i].z *= z;
	}
	_changes = true;
}

void xSurface::TransformVertices(xTransform transform)
{
	for(int i = 0; i < _gbuffer->_vertsCount; i++)
	{
		xVector newPosition = transform * xVector(_gbuffer->_vertices[i].x, _gbuffer->_vertices[i].y, _gbuffer->_vertices[i].z);
		_gbuffer->_vertices[i].x = newPosition.x;
		_gbuffer->_vertices[i].y = newPosition.y;
		_gbuffer->_vertices[i].z = newPosition.z;
	}
	_changes = true;
}

void xSurface::CalculateNormal(xVector & normal, xVector p0, xVector p1, xVector p2)
{
	xVector s = p1 - p0;
	xVector t = p2 - p0;
	normal    = s.Cross(t);
}

void xSurface::GenerateNormals()
{
	xVector normal;
	for(int i = 0; i < _gbuffer->_vertsCount; i++)
	{
		_gbuffer->_vertices[i].nx = 0.0f;
		_gbuffer->_vertices[i].ny = 0.0f;
		_gbuffer->_vertices[i].nz = 0.0f;
	}
	for(int i = 0; i < _gbuffer->_trisCount; i++)
	{
		int ind0 = i * 3 + 0;
		int ind1 = i * 3 + 1;
		int ind2 = i * 3 + 2;
		CalculateNormal(normal, xVector(_gbuffer->_vertices[_gbuffer->_triangles[ind0]].x, _gbuffer->_vertices[_gbuffer->_triangles[ind0]].y, _gbuffer->_vertices[_gbuffer->_triangles[ind0]].z), 
								xVector(_gbuffer->_vertices[_gbuffer->_triangles[ind1]].x, _gbuffer->_vertices[_gbuffer->_triangles[ind1]].y, _gbuffer->_vertices[_gbuffer->_triangles[ind1]].z), 
								xVector(_gbuffer->_vertices[_gbuffer->_triangles[ind2]].x, _gbuffer->_vertices[_gbuffer->_triangles[ind2]].y, _gbuffer->_vertices[_gbuffer->_triangles[ind2]].z));
		normal.Normalize();
		_gbuffer->_vertices[_gbuffer->_triangles[ind0]].nx += normal.x;
		_gbuffer->_vertices[_gbuffer->_triangles[ind1]].nx += normal.x;
		_gbuffer->_vertices[_gbuffer->_triangles[ind2]].nx += normal.x;
		_gbuffer->_vertices[_gbuffer->_triangles[ind0]].ny += normal.y;
		_gbuffer->_vertices[_gbuffer->_triangles[ind1]].ny += normal.y;
		_gbuffer->_vertices[_gbuffer->_triangles[ind2]].ny += normal.y;
		_gbuffer->_vertices[_gbuffer->_triangles[ind0]].nz += normal.z;
		_gbuffer->_vertices[_gbuffer->_triangles[ind1]].nz += normal.z;
		_gbuffer->_vertices[_gbuffer->_triangles[ind2]].nz += normal.z;
	}
	for(int i = 0; i < _gbuffer->_vertsCount; i++)
	{
		normal.x = _gbuffer->_vertices[i].nx;
		normal.y = _gbuffer->_vertices[i].ny;
		normal.z = _gbuffer->_vertices[i].nz;
		normal.Normalize();
		_gbuffer->_vertices[i].nx = normal.x;
		_gbuffer->_vertices[i].ny = normal.y;
		_gbuffer->_vertices[i].nz = normal.z;
	}
}

void xSurface::SetAlphaVertexCount(int count)
{
	_gbuffer->_alphaVerts = count;
}

xVertex * xSurface::AllocateVB(int size)
{
	if(size == 0)
	{
		_gbuffer->_vertices       = NULL;
		_gbuffer->_vertsCount     = 0;
		_gbuffer->_vertsArraySize = 0;
	}
	else
	{
		_gbuffer->_vertices       = (xVertex*)malloc(size * sizeof(xVertex));
		_gbuffer->_vertsCount     = size;
		_gbuffer->_vertsArraySize = size;
	}
	return _gbuffer->_vertices;
}

ushort * xSurface::AllocateIB(int size)
{
	if(size == 0)
	{
		_gbuffer->_triangles     = NULL;
		_gbuffer->_trisCount     = 0;
		_gbuffer->_trisArraySize = 0;
	}
	else
	{
		_gbuffer->_triangles     = (ushort*)malloc(size * 3 * sizeof(ushort));
		_gbuffer->_trisCount     = size;
		_gbuffer->_trisArraySize = size;
	}
	return _gbuffer->_triangles;
}

bool xSurface::Pick(xEntity * entity, xVector position, xVector direction)
{
	if(entity->GetPickMode() == 0)
	{
		return false;
	}
	else if(entity->GetPickMode() == 1)
	{
		xVector vec = position - _gbuffer->_boundingSphereCenter;
		float b = 2.0f * direction.Dot(vec);
		float c = vec.Dot(vec) - (_gbuffer->_boundingSphereRadius * _gbuffer->_boundingSphereRadius);
		float discriminant = (b * b) - (4.0f * c);
		if(discriminant < 0.0f) return false;
		discriminant = sqrtf(discriminant);
		float s0 = (-b + discriminant) / 2.0f;
		float s1 = (-b - discriminant) / 2.0f;
		float s  = s0 > s1 ? s0 : s1;
		if(s < 0.0f) return false;
		xVector pickPosition = _gbuffer->_boundingSphereCenter + (-direction * _gbuffer->_boundingSphereRadius);
		float distance = position.Distance(pickPosition);
		if(distance > xRender::Instance()->GetPickDistance()) return false;
		xRender::Instance()->SetPickPosition(entity->GetWorldTransform() * pickPosition);
		xRender::Instance()->SetPickNormal(entity->GetQuaternion(true) * (-direction));
		xRender::Instance()->SetPickTime(distance / 1000.0f);
		xRender::Instance()->SetPickDistance(distance);
		xRender::Instance()->SetPickTriangle(0);
		xRender::Instance()->SetPickSurface(this);
		xRender::Instance()->SetPickEntity(entity);
		return true;
	}
	else if(entity->GetPickMode() == 2)
	{
		float distance;
		int   index1;
		int   index2;
		int   index3;
		bool  picked = false;
		for(int i = 0; i < _gbuffer->_trisCount; i++)
		{
			index1 = 3 * i + 0;
			index2 = 3 * i + 1;
			index3 = 3 * i + 2;
			xVector v0  = xVector(_gbuffer->_vertices[_gbuffer->_triangles[index1]].x,  _gbuffer->_vertices[_gbuffer->_triangles[index1]].y,  _gbuffer->_vertices[_gbuffer->_triangles[index1]].z);
			xVector v1  = xVector(_gbuffer->_vertices[_gbuffer->_triangles[index2]].x,  _gbuffer->_vertices[_gbuffer->_triangles[index2]].y,  _gbuffer->_vertices[_gbuffer->_triangles[index2]].z);
			xVector v2  = xVector(_gbuffer->_vertices[_gbuffer->_triangles[index3]].x,  _gbuffer->_vertices[_gbuffer->_triangles[index3]].y,  _gbuffer->_vertices[_gbuffer->_triangles[index3]].z);
			xVector nv0 = xVector(_gbuffer->_vertices[_gbuffer->_triangles[index1]].nx, _gbuffer->_vertices[_gbuffer->_triangles[index1]].ny, _gbuffer->_vertices[_gbuffer->_triangles[index1]].nz);
			xVector nv1 = xVector(_gbuffer->_vertices[_gbuffer->_triangles[index2]].nx, _gbuffer->_vertices[_gbuffer->_triangles[index2]].ny, _gbuffer->_vertices[_gbuffer->_triangles[index2]].nz);
			xVector nv2 = xVector(_gbuffer->_vertices[_gbuffer->_triangles[index3]].nx, _gbuffer->_vertices[_gbuffer->_triangles[index3]].ny, _gbuffer->_vertices[_gbuffer->_triangles[index3]].nz);
			if(IntersectTriangle(position, direction, v0, v1, v2, &distance))
			{
				xVector pickPosition = position + (direction * distance);
				if(fabs(distance) < xRender::Instance()->GetPickDistance())
				{
					xRender::Instance()->SetPickPosition(entity->GetWorldTransform() * pickPosition);
					xRender::Instance()->SetPickNormal(entity->GetQuaternion(true) * (nv0 + nv1 + nv2).Normalized());
					xRender::Instance()->SetPickTime(distance / 1000.0f);
					xRender::Instance()->SetPickDistance(distance);
					xRender::Instance()->SetPickTriangle(i);
					xRender::Instance()->SetPickSurface(this);
					xRender::Instance()->SetPickEntity(entity);
					picked = true;
				}
			}
		}
		return picked;
	}
	else
	{
		float distance;
		if(IntersectBox(position, direction, &distance))
		{
			if(fabs(distance) < xRender::Instance()->GetPickDistance())
			{
				xVector pickPosition = position + (direction * distance);
				xRender::Instance()->SetPickPosition(entity->GetWorldTransform() * pickPosition);
				xRender::Instance()->SetPickNormal(entity->GetQuaternion(true) * -direction);
				xRender::Instance()->SetPickTime(distance / 1000.0f);
				xRender::Instance()->SetPickDistance(distance);
				xRender::Instance()->SetPickTriangle(0);
				xRender::Instance()->SetPickSurface(this);
				xRender::Instance()->SetPickEntity(entity);
				return true;
			}
		}
	}
	return false;
}

bool xSurface::IntersectBox(xVector & position, xVector & direction, float * distance)
{
	xVector _minCorner = _gbuffer->_boundingBox.min;
	xVector _maxCorner = _gbuffer->_boundingBox.max;
	xVector v0 = xVector(_minCorner.x, _minCorner.y, _minCorner.z);
	xVector v1 = xVector(_minCorner.x, _maxCorner.y, _minCorner.z);
	xVector v2 = xVector(_maxCorner.x, _maxCorner.y, _minCorner.z);
	if(IntersectTriangle(position, direction, v0, v1, v2, distance)) return true;
	v0 = xVector(_maxCorner.x, _minCorner.y, _minCorner.z);
	v1 = xVector(_minCorner.x, _minCorner.y, _minCorner.z);
	v2 = xVector(_maxCorner.x, _maxCorner.y, _minCorner.z);
	if(IntersectTriangle(position, direction, v0, v1, v2, distance)) return true;
	v0 = xVector(_maxCorner.x, _minCorner.y, _minCorner.z);
	v1 = xVector(_maxCorner.x, _maxCorner.y, _minCorner.z);
	v2 = xVector(_maxCorner.x, _maxCorner.y, _maxCorner.z);
	if(IntersectTriangle(position, direction, v0, v1, v2, distance)) return true;
	v0 = xVector(_maxCorner.x, _minCorner.y, _maxCorner.z);
	v1 = xVector(_maxCorner.x, _minCorner.y, _minCorner.z);
	v2 = xVector(_maxCorner.x, _maxCorner.y, _maxCorner.z);
	if(IntersectTriangle(position, direction, v0, v1, v2, distance)) return true;
	v0 = xVector(_maxCorner.x, _minCorner.y, _maxCorner.z);
	v1 = xVector(_maxCorner.x, _maxCorner.y, _maxCorner.z);
	v2 = xVector(_minCorner.x, _maxCorner.y, _maxCorner.z);
	if(IntersectTriangle(position, direction, v0, v1, v2, distance)) return true;
	v0 = xVector(_minCorner.x, _minCorner.y, _maxCorner.z);
	v1 = xVector(_maxCorner.x, _minCorner.y, _maxCorner.z);
	v2 = xVector(_minCorner.x, _maxCorner.y, _maxCorner.z);
	if(IntersectTriangle(position, direction, v0, v1, v2, distance)) return true;
	v0 = xVector(_minCorner.x, _minCorner.y, _maxCorner.z);
	v1 = xVector(_minCorner.x, _maxCorner.y, _maxCorner.z);
	v2 = xVector(_minCorner.x, _maxCorner.y, _minCorner.z);
	if(IntersectTriangle(position, direction, v0, v1, v2, distance)) return true;
	v0 = xVector(_minCorner.x, _minCorner.y, _minCorner.z);
	v1 = xVector(_minCorner.x, _minCorner.y, _maxCorner.z);
	v2 = xVector(_minCorner.x, _maxCorner.y, _minCorner.z);
	if(IntersectTriangle(position, direction, v0, v1, v2, distance)) return true;
	v0 = xVector(_minCorner.x, _maxCorner.y, _minCorner.z);
	v1 = xVector(_minCorner.x, _maxCorner.y, _maxCorner.z);
	v2 = xVector(_maxCorner.x, _maxCorner.y, _maxCorner.z);
	if(IntersectTriangle(position, direction, v0, v1, v2, distance)) return true;
	v0 = xVector(_maxCorner.x, _maxCorner.y, _minCorner.z);
	v1 = xVector(_minCorner.x, _maxCorner.y, _minCorner.z);
	v2 = xVector(_maxCorner.x, _maxCorner.y, _maxCorner.z);
	if(IntersectTriangle(position, direction, v0, v1, v2, distance)) return true;
	v0 = xVector(_minCorner.x, _minCorner.y, _maxCorner.z);
	v1 = xVector(_minCorner.x, _minCorner.y, _minCorner.z);
	v2 = xVector(_maxCorner.x, _minCorner.y, _minCorner.z);
	if(IntersectTriangle(position, direction, v0, v1, v2, distance)) return true;
	v0 = xVector(_maxCorner.x, _minCorner.y, _maxCorner.z);
	v1 = xVector(_minCorner.x, _minCorner.y, _maxCorner.z);
	v2 = xVector(_maxCorner.x, _minCorner.y, _minCorner.z);
	if(IntersectTriangle(position, direction, v0, v1, v2, distance)) return true;
	return false;
}

bool xSurface::IntersectTriangle(const xVector & position, const xVector & direction, xVector & v0, xVector & v1, xVector & v2, float * distance)
{
    xVector edge1 = v1 - v0;
    xVector edge2 = v2 - v0;
	xVector normal = edge1.Cross(edge2);
	if(normal.Dot(direction) >= 0.0f) return false;
    xVector pvec = direction.Cross(edge2);
    float det = edge1.Dot(pvec);
    xVector tvec;
	xVector qvec;
    if(det > 0.00001f)
    {
        tvec = position - v0;
		float u = tvec.Dot(pvec);
		if(u < 0.0f || u > det) return false;
		qvec = tvec.Cross(edge1);
		float v = direction.Dot(qvec);
		if(v < 0.0f || u + v > det) return false;
    }
    else if(det < -0.00001f)
    {
        tvec = position - v0;
        float u = tvec.Dot(pvec);
		if(u > 0.0f || u < det) return false;
		qvec = tvec.Cross(edge1);
		float v = direction.Dot(qvec);
		if(v > 0.0f || u + v < det) return false;
    }
	else
	{
		return false;
	}
    *distance = edge2.Dot(qvec);
    *distance *= 1.0f / det;
    return true;
}

bool xSurface::GetChangesState()
{
	return _changes;
}

void xSurface::SetChangesState(bool state)
{
	_changes = state;
}

void xSurface::SetData(xVertex * vertices, int vetsCount, ushort * triangles, int trisCount)
{
	if(_gbuffer->_vertices  != NULL) free(_gbuffer->_vertices);
	if(_gbuffer->_triangles != NULL) free(_gbuffer->_triangles);
	_gbuffer->_vertices       = vertices;
	_gbuffer->_triangles      = triangles;
	_gbuffer->_vertsCount     = vetsCount;
	_gbuffer->_trisCount      = trisCount;
	_gbuffer->_vertsArraySize = vetsCount;
	_gbuffer->_trisArraySize  = trisCount;
}

int xSurface::GetFX()
{
	return _FX;
}